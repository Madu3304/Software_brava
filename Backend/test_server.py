import os
import tempfile

# Os testes rodam num banco SQLite temporário, em modo desenvolvimento (seed ativo),
# para não alterar o brava.db local (o teste troca as senhas dos usuários).
pasta_temporaria = tempfile.mkdtemp()
os.environ["DATABASE_URL"] = f"sqlite:///{os.path.join(pasta_temporaria, 'teste.db')}"
os.environ["APP_ENV"] = "development"
os.environ.setdefault("ADMIN_PASSWORD", "admin123")
os.environ.setdefault("EQUIPE_PASSWORD", "brava123")
os.environ["CORS_ORIGINS"] = "http://localhost:8080"
# Limite de tentativas de autenticação usado no teste (o passo 21 confere o bloqueio)
os.environ["LOGIN_RATE_LIMIT"] = "20/minute"
SENHA_ADMIN = os.environ["ADMIN_PASSWORD"]
SENHA_EQUIPE = os.environ["EQUIPE_PASSWORD"]

from fastapi.testclient import TestClient
from main import app

with TestClient(app) as client:
    # 1. Healthcheck
    res_root = client.get("/")
    print("1. Root Healthcheck:", res_root.status_code, res_root.json())
    assert res_root.status_code == 200

    # 2. Primeiro acesso: login é bloqueado até a troca de senha (403)
    res_primeiro = client.post("/api/auth/login", json={"login": "admin", "senha": SENHA_ADMIN})
    print("2. Primeiro acesso Admin:", res_primeiro.status_code, res_primeiro.json())
    assert res_primeiro.status_code == 403
    assert res_primeiro.json()["detail"]["codigo"] == "TROCA_SENHA_OBRIGATORIA"

    # 2.1 Troca de senha: senha curta (422) e senha igual à atual (400) são recusadas
    res_curta = client.post("/api/auth/trocar-senha", json={"login": "admin", "senha_atual": SENHA_ADMIN, "nova_senha": "123"})
    print("2.1 Nova senha curta:", res_curta.status_code)
    assert res_curta.status_code == 422
    res_igual = client.post("/api/auth/trocar-senha", json={"login": "admin", "senha_atual": SENHA_ADMIN, "nova_senha": SENHA_ADMIN})
    print("2.1 Nova senha igual à atual:", res_igual.status_code)
    assert res_igual.status_code == 400

    # 2.2 Troca de senha válida do Admin e do Enfermeiro
    nova_senha_admin = "NovaSenhaAdmin#2026"
    nova_senha_enf = "NovaSenhaEnf#2026"
    res_troca = client.post("/api/auth/trocar-senha", json={"login": "admin", "senha_atual": SENHA_ADMIN, "nova_senha": nova_senha_admin})
    print("2.2 Troca de senha Admin:", res_troca.status_code, res_troca.json())
    assert res_troca.status_code == 200
    res_troca_enf = client.post("/api/auth/trocar-senha", json={"login": "enfermeiro", "senha_atual": SENHA_EQUIPE, "nova_senha": nova_senha_enf})
    assert res_troca_enf.status_code == 200

    # 2.3 A senha inicial deixa de funcionar
    res_antiga = client.post("/api/auth/login", json={"login": "admin", "senha": SENHA_ADMIN})
    print("2.3 Login com senha inicial após a troca:", res_antiga.status_code)
    assert res_antiga.status_code == 401

    # 2.4 Login Admin com a nova senha (RBAC: deve retornar redirecionamento 'WEB')
    res_admin = client.post("/api/auth/login", json={"login": "admin", "senha": nova_senha_admin})
    print("2.4 Login Admin:", res_admin.status_code, res_admin.json())
    assert res_admin.status_code == 200
    assert res_admin.json()["redirecionamento"] == "WEB"
    id_admin = res_admin.json()["id_usuario"]
    headers_admin = {"Authorization": f"Bearer {res_admin.json()['access_token']}"}

    # 3. Login Enfermeiro (RBAC: deve retornar redirecionamento 'MOBILE')
    res_enf = client.post("/api/auth/login", json={"login": "enfermeiro", "senha": nova_senha_enf})
    print("3. Login Enfermeiro:", res_enf.status_code, res_enf.json())
    assert res_enf.status_code == 200
    assert res_enf.json()["redirecionamento"] == "MOBILE"
    id_enf = res_enf.json()["id_usuario"]
    headers_enf = {"Authorization": f"Bearer {res_enf.json()['access_token']}"}

    # 4. Dashboard Gerencial
    res_dash = client.get("/api/reports/dashboard", headers=headers_admin)
    print("4. Dashboard Metricas:", res_dash.status_code, res_dash.json())
    assert res_dash.status_code == 200

    # 5. Listagem de Unidades Móveis (Bravas)
    res_unidades = client.get("/api/cadastros/unidades", headers=headers_enf)
    print("5. Unidades Cadastradas:", len(res_unidades.json()))
    assert len(res_unidades.json()) >= 4

    # 6. Login usando o hash armazenado como senha deve ser recusado (401)
    from services.security_service import gerar_hash_senha
    res_hash = client.post("/api/auth/login", json={"login": "admin", "senha": gerar_hash_senha(nova_senha_admin)})
    print("6. Login com hash como senha:", res_hash.status_code)
    assert res_hash.status_code == 401

    # 7. Usuário criado pelo Administrador também precisa trocar a senha no primeiro acesso
    res_novo = client.post("/api/usuarios/", headers=headers_admin, json={"nome": "Usuário Teste", "login": "teste", "perfil": "TECNICO", "senha": "SenhaInicial#1"})
    assert res_novo.status_code == 201 and res_novo.json()["trocar_senha"] is True
    res_login_novo = client.post("/api/auth/login", json={"login": "teste", "senha": "SenhaInicial#1"})
    print("7. Primeiro acesso de usuário criado pelo Admin:", res_login_novo.status_code)
    assert res_login_novo.status_code == 403

    # 8. CORS: só a origem configurada em CORS_ORIGINS é liberada
    preflight = {"Access-Control-Request-Method": "POST", "Access-Control-Request-Headers": "Authorization, Content-Type"}
    res_cors_ok = client.options("/api/auth/login", headers={"Origin": "http://localhost:8080", **preflight})
    print("8. CORS origem liberada:", res_cors_ok.status_code, res_cors_ok.headers.get("access-control-allow-origin"))
    assert res_cors_ok.headers.get("access-control-allow-origin") == "http://localhost:8080"
    res_cors_bloq = client.options("/api/auth/login", headers={"Origin": "http://site-malicioso.com", **preflight})
    print("8. CORS origem desconhecida:", res_cors_bloq.status_code, res_cors_bloq.headers.get("access-control-allow-origin"))
    assert res_cors_bloq.status_code == 400
    assert res_cors_bloq.headers.get("access-control-allow-origin") is None

    # 9. Rotas protegidas sem token devem retornar 401
    for rota in ["/api/fichas/", "/api/reports/dashboard", "/api/usuarios/", "/api/logs/", "/api/cadastros/unidades"]:
        res = client.get(rota)
        print(f"9. Sem token {rota}:", res.status_code)
        assert res.status_code == 401

    # 10. Token inválido deve retornar 401
    res_invalido = client.get("/api/fichas/", headers={"Authorization": "Bearer token_invalido"})
    print("10. Token inválido:", res_invalido.status_code, res_invalido.json())
    assert res_invalido.status_code == 401

    # 11. Perfil de campo não acessa rotas do Administrador (403)
    for rota in ["/api/reports/dashboard", "/api/usuarios/", "/api/logs/"]:
        res = client.get(rota, headers=headers_enf)
        print(f"11. Enfermeiro em {rota}:", res.status_code)
        assert res.status_code == 403
    res_cadastro = client.post("/api/cadastros/medicos", json={"nome": "Teste"}, headers=headers_enf)
    print("11. Enfermeiro criando médico:", res_cadastro.status_code)
    assert res_cadastro.status_code == 403

    # 12. Usuário logado (/me)
    res_me = client.get("/api/auth/me", headers=headers_enf)
    print("12. Usuário logado:", res_me.status_code, res_me.json()["login"])
    assert res_me.status_code == 200 and res_me.json()["login"] == "enfermeiro"

    # 13. Login via formulário OAuth2 (botão "Authorize" do /docs)
    res_form = client.post("/api/auth/token", data={"username": "admin", "password": nova_senha_admin})
    print("13. Login formulário OAuth2:", res_form.status_code)
    assert res_form.status_code == 200

    # 14. Auditoria: não existe mais POST público em /api/logs (405)
    res_log_falso = client.post("/api/logs/", headers=headers_admin, json={"id_usuario": 2, "acao": "LOG_FALSO", "ip_origem": "1.2.3.4"})
    print("14. POST /api/logs (removido):", res_log_falso.status_code)
    assert res_log_falso.status_code == 405

    # 15. Ficha: o responsável é sempre o usuário do token, mesmo que o corpo informe outro
    ficha = {
        "id_unidade": 1,
        "id_medico": 1,
        "id_responsavel": id_admin,  # tentativa de se passar por outro usuário: deve ser ignorada
        "paciente": {"nome": "Paciente Teste", "idade": 40},
        "avaliacao_clinica": {"pressao_arterial": "120/80"},
    }
    res_ficha = client.post("/api/fichas/", headers=headers_enf, json=ficha)
    print("15. Criar ficha:", res_ficha.status_code)
    assert res_ficha.status_code == 201
    id_ficha = res_ficha.json()["id_ficha"]

    # 16. Sync: o responsável também vem do token
    res_sync = client.post("/api/sync/lote", headers=headers_enf, json={"fichas": [
        {"uuid_offline": "uuid-teste-b8", "id_unidade": 1, "id_responsavel": id_admin}
    ]})
    print("16. Sync lote:", res_sync.status_code, res_sync.json())
    assert res_sync.status_code == 200 and res_sync.json()["sucessos"] == 1

    # 17. Logout usa o usuário do token
    res_logout = client.post("/api/auth/logout", headers=headers_enf)
    print("17. Logout:", res_logout.status_code)
    assert res_logout.status_code == 200

    # 18. Confere no banco: fichas e logs registrados com o usuário do token e o IP da conexão
    from database import SessionLocal
    from models import FichaAtendimento, LogAuditoria
    db = SessionLocal()
    try:
        responsaveis = {
            f.uuid_offline or f.id_ficha: f.id_responsavel
            for f in db.query(FichaAtendimento).filter(
                (FichaAtendimento.id_ficha == id_ficha) | (FichaAtendimento.uuid_offline == "uuid-teste-b8")
            )
        }
        print("18. Responsáveis das fichas:", responsaveis)
        assert set(responsaveis.values()) == {id_enf}

        for acao in ["CRIAR_FICHA", "SYNC_OFFLINE_LOTE", "LOGOUT"]:
            log = db.query(LogAuditoria).filter(LogAuditoria.acao == acao).order_by(LogAuditoria.id_log.desc()).first()
            print(f"18. Log {acao}: usuario={log.id_usuario} ip={log.ip_origem}")
            assert log.id_usuario == id_enf and log.ip_origem == "testclient"

        log_criar = db.query(LogAuditoria).filter(LogAuditoria.acao == "CRIAR_USUARIO").first()
        print(f"18. Log CRIAR_USUARIO: usuario={log_criar.id_usuario} (admin={id_admin})")
        assert log_criar.id_usuario == id_admin

        assert db.query(LogAuditoria).filter(LogAuditoria.acao == "LOG_FALSO").count() == 0
    finally:
        db.close()

    # 19. B9: login inexistente, senha errada e usuário inativo recebem a mesma resposta (401)
    id_teste = res_novo.json()["id_usuario"]
    res_inativar = client.put(f"/api/usuarios/{id_teste}", headers=headers_admin, json={"ativo": False})
    assert res_inativar.status_code == 200
    respostas = {
        "inexistente": client.post("/api/auth/login", json={"login": "nao_existe", "senha": "qualquer123"}),
        "senha errada": client.post("/api/auth/login", json={"login": "admin", "senha": "senha_errada"}),
        "inativo": client.post("/api/auth/login", json={"login": "teste", "senha": "SenhaInicial#1"}),
    }
    for caso, res in respostas.items():
        print(f"19. Login {caso}:", res.status_code, res.json())
        assert res.status_code == 401
        assert res.json() == {"detail": "Credenciais inválidas."}

    # 20. B9: as tentativas que falharam ficam registradas na auditoria
    db = SessionLocal()
    try:
        falhas = db.query(LogAuditoria).filter(LogAuditoria.acao == "LOGIN_FALHA").all()
        print("20. Logs LOGIN_FALHA:", [(f.id_usuario, f.detalhes_metadados) for f in falhas])
        detalhes = " | ".join(f.detalhes_metadados for f in falhas)
        assert "'nao_existe'" in detalhes and "senha incorreta" in detalhes and "usuário inativo" in detalhes
        assert all(f.ip_origem == "testclient" for f in falhas)
    finally:
        db.close()

    # 21. B9: depois do limite de tentativas (LOGIN_RATE_LIMIT), o login é bloqueado (429)
    status_tentativas = [
        client.post("/api/auth/login", json={"login": "admin", "senha": "senha_errada"}).status_code
        for _ in range(25)
    ]
    print("21. Tentativas seguidas:", status_tentativas)
    assert 429 in status_tentativas
    res_bloqueado = client.post("/api/auth/login", json={"login": "admin", "senha": nova_senha_admin})
    print("21. Login correto durante o bloqueio:", res_bloqueado.status_code, res_bloqueado.json())
    assert res_bloqueado.status_code == 429
    res_token_bloqueado = client.post("/api/auth/token", data={"username": "admin", "password": nova_senha_admin})
    print("21. /token durante o bloqueio (limite compartilhado):", res_token_bloqueado.status_code)
    assert res_token_bloqueado.status_code == 429

    # 22. B12: um item com erro no meio do lote não corrompe os outros (savepoint por item)
    # O item do meio falha no banco DEPOIS do flush do paciente e da ficha (inteiro grande demais para o SQLite)
    login_enf2 = client.post("/api/auth/token", data={"username": "enfermeiro", "password": nova_senha_enf})
    if login_enf2.status_code == 429:
        from rate_limit import limiter
        limiter.reset()
        login_enf2 = client.post("/api/auth/token", data={"username": "enfermeiro", "password": nova_senha_enf})
    headers_enf2 = {"Authorization": f"Bearer {login_enf2.json()['access_token']}"}
    lote = {"fichas": [
        {"uuid_offline": "b12-ok-1", "id_unidade": 1, "paciente": {"nome": "Paciente B12 OK 1"}, "avaliacao_clinica": {"pressao_arterial": "120/80"}},
        {"uuid_offline": "b12-erro", "id_unidade": 1, "paciente": {"nome": "Paciente B12 ERRO"}, "avaliacao_clinica": {"frequencia_cardiaca": 2 ** 70}},
        {"uuid_offline": "b12-ok-2", "id_unidade": 1, "paciente": {"nome": "Paciente B12 OK 2"}, "utensilios_gastos": {"material_trauma": True}},
    ]}
    res_lote = client.post("/api/sync/lote", headers=headers_enf2, json=lote)
    print("22. Sync lote com item inválido no meio:", res_lote.status_code, res_lote.json() if res_lote.status_code == 200 else res_lote.text[:80])
    assert res_lote.status_code == 200
    assert res_lote.json()["sucessos"] == 2 and len(res_lote.json()["erros"]) == 1
    assert "b12-erro" in res_lote.json()["erros"][0]

    from models import Paciente, AvaliacaoClinica, Utensilios
    db = SessionLocal()
    try:
        uuids = {f.uuid_offline for f in db.query(FichaAtendimento).filter(FichaAtendimento.uuid_offline.like("b12-%"))}
        pacientes = {p.nome for p in db.query(Paciente).filter(Paciente.nome.like("Paciente B12%"))}
        print("22. Fichas gravadas:", sorted(uuids), "| Pacientes gravados:", sorted(pacientes))
        assert uuids == {"b12-ok-1", "b12-ok-2"}
        # Nada do item com erro ficou pela metade no banco (nem o paciente, nem a ficha)
        assert pacientes == {"Paciente B12 OK 1", "Paciente B12 OK 2"}
        ficha_ok1 = db.query(FichaAtendimento).filter(FichaAtendimento.uuid_offline == "b12-ok-1").one()
        ficha_ok2 = db.query(FichaAtendimento).filter(FichaAtendimento.uuid_offline == "b12-ok-2").one()
        assert db.query(AvaliacaoClinica).filter(AvaliacaoClinica.id_ficha == ficha_ok1.id_ficha).count() == 1
        assert db.query(Utensilios).filter(Utensilios.id_ficha == ficha_ok2.id_ficha).count() == 1
    finally:
        db.close()

    # 23. B12: reenviar o lote é seguro (os já gravados são ignorados; o item com erro continua com erro)
    res_reenvio = client.post("/api/sync/lote", headers=headers_enf2, json=lote)
    print("23. Reenvio do mesmo lote:", res_reenvio.status_code, res_reenvio.json())
    assert res_reenvio.json()["duplicados_ignorados"] == 2 and len(res_reenvio.json()["erros"]) == 1

print("\n>>> TODOS OS TESTES PASSARAM COM 100% DE SUCESSO! O BACKEND ESTA PRONTO PARA RODAR! <<<")
