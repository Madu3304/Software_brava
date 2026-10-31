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

print("\n>>> TODOS OS TESTES PASSARAM COM 100% DE SUCESSO! O BACKEND ESTA PRONTO PARA RODAR! <<<")
