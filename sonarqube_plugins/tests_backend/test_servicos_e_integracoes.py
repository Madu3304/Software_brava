from datetime import datetime, timezone
import httpx
from models.paciente import Paciente, pseudonimizar_cpf, mascarar_cpf_exibicao
import schemas
from services import integration_service, report_service
from services.ollama_service import OllamaService


class _FakeHttpResponse:
    def __init__(self, status_code=200, json_data=None):
        self.status_code = status_code
        self._json_data = json_data or {}
        self.text = str(self._json_data)

    def raise_for_status(self):
        if self.status_code >= 400:
            raise RuntimeError(f"HTTP {self.status_code}")

    def json(self):
        return self._json_data


class _FakeClientContext:
    def __init__(self, response=None, raise_exc=None):
        self._response = response
        self._raise_exc = raise_exc

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        return False

    def get(self, *args, **kwargs):
        if self._raise_exc:
            raise self._raise_exc
        return self._response

    def post(self, *args, **kwargs):
        if self._raise_exc:
            raise self._raise_exc
        return self._response


def test_paciente_lgpd_helpers():
    h = pseudonimizar_cpf("529.982.247-25")
    assert h is not None and len(h) == 64
    assert pseudonimizar_cpf("") is None
    assert pseudonimizar_cpf("---") is None
    assert mascarar_cpf_exibicao(h) == "***.***.***-**"
    assert mascarar_cpf_exibicao(None) is None

    p = Paciente(nome="Teste", data_nascimento=datetime(1990, 1, 1, tzinfo=timezone.utc))
    assert p.idade_calculada >= 35


def test_ollama_service_e_controller(client, headers_enfermeiro, monkeypatch):
    srv = OllamaService(base_url="http://localhost:11434", default_model="llama3.2:3b")

    monkeypatch.setattr(
        "services.ollama_service.httpx.Client",
        lambda timeout=5.0: _FakeClientContext(
            _FakeHttpResponse(200, {"models": [{"name": "llama3.2:3b"}]})
        ),
    )
    st_ok = srv.verificar_status()
    assert st_ok["online"] is True
    assert "llama3.2:3b" in st_ok["modelos_disponiveis"]

    monkeypatch.setattr(
        "services.ollama_service.httpx.Client",
        lambda timeout=30.0: _FakeClientContext(
            _FakeHttpResponse(200, {"model": "llama3.2:3b", "message": {"content": "Resposta IA"}})
        ),
    )
    resp = srv.gerar_resposta("Qual a escala de Glasgow?", contexto="APH")
    assert resp["resposta"] == "Resposta IA"

    res_api_st = client.get("/api/ia/status", headers=headers_enfermeiro)
    assert res_api_st.status_code == 200

    res_api_chat = client.post(
        "/api/ia/chat",
        json={"mensagem": "Resumo protocolo AVC"},
        headers=headers_enfermeiro,
    )
    assert res_api_chat.status_code == 200

    monkeypatch.setattr(
        "services.ollama_service.httpx.Client",
        lambda timeout=30.0: _FakeClientContext(raise_exc=RuntimeError("offline")),
    )
    assert srv.verificar_status()["online"] is False
    assert client.post("/api/ia/chat", json={"mensagem": "Oi"}, headers=headers_enfermeiro).status_code == 503


def test_docusign_controller_e_service(client, headers_enfermeiro):
    res_env = client.post(
        "/api/docusign/envelopes",
        json={
            "numero_ocorrencia": "REG-1001",
            "paciente_nome": "Maria Teste",
            "email_destinatario": "maria@teste.com",
        },
        headers=headers_enfermeiro,
    )
    assert res_env.status_code in (200, 201)
    env_id = res_env.json().get("envelope_id", "env-demo-123")
    res_st = client.get(f"/api/docusign/status/{env_id}", headers=headers_enfermeiro)
    assert res_st.status_code == 200


def test_reports_e_logs_controller(client, headers_admin, db_session, seed_dados_basicos):
    assert report_service._parse_mes("março") == 3
    assert report_service._parse_mes("11") == 11
    assert report_service._parse_mes("invalido") is None

    res_dash = client.get("/api/reports/dashboard?ano=2026&mes=novembro&dia=22&unidade=Brava", headers=headers_admin)
    assert res_dash.status_code == 200
    assert "total_atendimentos" in res_dash.json()

    res_logs = client.get("/api/logs/?limit=10", headers=headers_admin)
    assert res_logs.status_code == 200


def test_integration_service_mockado(monkeypatch, db_session, seed_dados_basicos):
    from models import FichaAtendimento

    class _NoCloseSessionProxy:
        def __init__(self, session):
            self._s = session
        def __getattr__(self, name):
            return getattr(self._s, name)
        def close(self):
            pass

    id_unidade = seed_dados_basicos["unidade"].id_unidade
    id_resp = seed_dados_basicos["enfermeiro"].id_usuario

    ficha = FichaAtendimento(
        id_unidade=id_unidade,
        id_responsavel=id_resp,
        status_envio_prefeitura="PENDENTE",
    )
    db_session.add(ficha)
    db_session.commit()
    db_session.refresh(ficha)

    payload = integration_service.montar_payload(ficha)
    assert payload["id_ficha_sistema"] == ficha.id_ficha

    monkeypatch.setattr(integration_service, "SessionLocal", lambda: _NoCloseSessionProxy(db_session))
    monkeypatch.setenv("PREFEITURA_API_URL", "https://prefeitura.teste/api")
    monkeypatch.setenv("PREFEITURA_API_TOKEN", "token-teste")
    cfg = integration_service.obter_configuracao()
    assert cfg is not None and cfg["url"] == "https://prefeitura.teste/api"

    monkeypatch.setattr(
        integration_service,
        "criar_cliente_http",
        lambda timeout: _FakeClientContext(
            _FakeHttpResponse(200, {"protocolo": "PROTO-999"})
        ),
    )
    assert integration_service.enviar_ficha_para_prefeitura(ficha.id_ficha) == "ENVIADO"

    ficha2 = FichaAtendimento(
        id_unidade=id_unidade,
        id_responsavel=id_resp,
        status_envio_prefeitura="PENDENTE",
    )
    db_session.add(ficha2)
    db_session.commit()
    db_session.refresh(ficha2)
    monkeypatch.setattr(
        integration_service,
        "criar_cliente_http",
        lambda timeout: _FakeClientContext(raise_exc=httpx.ConnectError("timeout")),
    )
    assert integration_service.enviar_ficha_para_prefeitura(ficha2.id_ficha) == "ERRO"

    monkeypatch.delenv("PREFEITURA_API_URL", raising=False)
    assert integration_service.obter_configuracao() is None


def test_validacao_clinica_edge_cases():
    from services import validation_service
    from schemas import FichaAtendimentoCreate, AvaliacaoClinicaResumoSchema

    assert schemas.validar_formato_cpf("52998224725") is True
    assert schemas.validar_formato_cpf("11111111111") is False
    assert schemas.validar_formato_cpf("123") is False
    assert validation_service.validar_formato_pressao_arterial("N/A") is True
    assert validation_service.validar_formato_pressao_arterial("abc") is False

    ficha_invalida = FichaAtendimentoCreate.model_construct(
        id_unidade=0,
        id_medico=0,
        avaliacao_clinica=AvaliacaoClinicaResumoSchema.model_construct(
            pressao_arterial="999",
            frequencia_cardiaca=5,
            frequencia_respiratoria=90,
            temperatura=50.0,
            glicemia=5,
            saturacao_o2=10,
            escala_glasgow=15,
            abertura_ocular=1,
            resposta_verbal=1,
            resposta_motora=1,
        ),
    )
    valido, erros = validation_service.validar_regras_clinicas_ficha(ficha_invalida)
    assert valido is False
    assert len(erros) >= 6


def test_seed_dados_sinteticos_completos(db_session, monkeypatch):
    from models import FichaAtendimento, Medico, Tecnico, Condutor
    from seed import seed_initial_data
    from services.report_service import calcular_metricas_dashboard

    monkeypatch.setenv("ADMIN_PASSWORD", "AdminTest#123")
    monkeypatch.setenv("EQUIPE_PASSWORD", "EquipeTest#123")
    seed_initial_data(db_session)

    assert db_session.query(Medico).count() >= 5
    assert db_session.query(Tecnico).count() >= 5
    assert db_session.query(Condutor).count() >= 5
    assert db_session.query(FichaAtendimento).count() >= 16

    metricas = calcular_metricas_dashboard(db_session)
    assert metricas.total_atendimentos >= 16
    assert metricas.atendimentos_hoje >= 1
