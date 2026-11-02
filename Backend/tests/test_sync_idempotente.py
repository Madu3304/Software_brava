import uuid
from schemas import FichaAtendimentoCreate, AvaliacaoClinicaResumoSchema
from models import FichaAtendimento

def test_sync_lote_com_sucesso_e_idempotencia(client, headers_enfermeiro, seed_dados_basicos, db_session):
    """
    Testa B30 e sincronização offline:
    1. Primeiro envio processa e salva a ficha.
    2. Segundo envio com o mesmo uuid_offline é ignorado de forma idempotente sem duplicar nem dar erro.
    """
    uuid_teste = f"test-sync-{uuid.uuid4()}"
    ficha_item = {
        "uuid_offline": uuid_teste,
        "id_unidade": seed_dados_basicos["unidade"].id_unidade,
        "id_medico": seed_dados_basicos["medico"].id_medico,
        "id_condutor": seed_dados_basicos["condutor"].id_condutor,
        "bairro": "Centro",
        "paciente": {
            "nome": "João da Silva",
            "idade": 45,
            "sexo": "M"
        },
        "avaliacao_clinica": {
            "pressao_arterial": "120/80",
            "frequencia_cardiaca": 78,
            "frequencia_respiratoria": 16,
            "saturacao_o2": 98,
            "glicemia": 95,
            "temperatura": 36.5,
            "escala_glasgow": 15
        }
    }

    # Primeiro envio
    res1 = client.post("/api/sync/lote", headers=headers_enfermeiro, json={"fichas": [ficha_item]})
    assert res1.status_code == 200
    dados1 = res1.json()
    assert dados1["processados"] == 1
    assert dados1["sucessos"] == 1
    assert dados1["duplicados_ignorados"] == 0
    assert len(dados1["erros"]) == 0

    # Segundo envio (mesmo uuid_offline - teste de idempotência)
    res2 = client.post("/api/sync/lote", headers=headers_enfermeiro, json={"fichas": [ficha_item]})
    assert res2.status_code == 200
    dados2 = res2.json()
    assert dados2["processados"] == 1
    assert dados2["sucessos"] == 0
    assert dados2["duplicados_ignorados"] == 1
    assert len(dados2["erros"]) == 0

def test_sync_erro_clinico_retorna_mensagem_especifica(client, headers_enfermeiro, seed_dados_basicos):
    """Garante que erro de validação clínica no sync informa a regra violada sem expor erro cru de banco."""
    uuid_teste = f"test-invalido-{uuid.uuid4()}"
    ficha_invalida = {
        "uuid_offline": uuid_teste,
        "id_unidade": seed_dados_basicos["unidade"].id_unidade,
        "id_medico": seed_dados_basicos["medico"].id_medico,
        "avaliacao_clinica": {
            "pressao_arterial": "pressao_errada", # Formato inválido
        }
    }
    res = client.post("/api/sync/lote", headers=headers_enfermeiro, json={"fichas": [ficha_invalida]})
    assert res.status_code == 200
    dados = res.json()
    assert dados["sucessos"] == 0
    assert len(dados["erros"]) == 1
    assert "Pressão Arterial" in dados["erros"][0]
    # Garante que nenhum erro cru do PostgreSQL/SQLite como 'OperationalError' ou 'IntegrityError' seja exposto (B30)
    assert "sqlite" not in dados["erros"][0].lower()
    assert "syntax error" not in dados["erros"][0].lower()
