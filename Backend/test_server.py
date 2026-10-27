from fastapi.testclient import TestClient
from main import app

with TestClient(app) as client:
    # 1. Healthcheck
    res_root = client.get("/")
    print("1. Root Healthcheck:", res_root.status_code, res_root.json())
    assert res_root.status_code == 200

    # 2. Login Admin (RBAC: deve retornar redirecionamento 'WEB')
    res_admin = client.post("/api/auth/login", json={"login": "admin", "senha": "admin123"})
    print("2. Login Admin:", res_admin.status_code, res_admin.json())
    assert res_admin.status_code == 200
    assert res_admin.json()["redirecionamento"] == "WEB"
    headers_admin = {"Authorization": f"Bearer {res_admin.json()['access_token']}"}

    # 3. Login Enfermeiro (RBAC: deve retornar redirecionamento 'MOBILE')
    res_enf = client.post("/api/auth/login", json={"login": "enfermeiro", "senha": "brava123"})
    print("3. Login Enfermeiro:", res_enf.status_code, res_enf.json())
    assert res_enf.status_code == 200
    assert res_enf.json()["redirecionamento"] == "MOBILE"
    headers_enf = {"Authorization": f"Bearer {res_enf.json()['access_token']}"}

    # 4. Dashboard Gerencial
    res_dash = client.get("/api/reports/dashboard", headers=headers_admin)
    print("4. Dashboard Metricas:", res_dash.status_code, res_dash.json())
    assert res_dash.status_code == 200

    # 5. Listagem de Unidades Móveis (Bravas)
    res_unidades = client.get("/api/cadastros/unidades", headers=headers_enf)
    print("5. Unidades Cadastradas:", len(res_unidades.json()))
    assert len(res_unidades.json()) >= 4

    # 6. Rotas protegidas sem token devem retornar 401
    for rota in ["/api/fichas/", "/api/reports/dashboard", "/api/usuarios/", "/api/logs/", "/api/cadastros/unidades"]:
        res = client.get(rota)
        print(f"6. Sem token {rota}:", res.status_code)
        assert res.status_code == 401

    # 7. Token inválido deve retornar 401
    res_invalido = client.get("/api/fichas/", headers={"Authorization": "Bearer token_invalido"})
    print("7. Token inválido:", res_invalido.status_code, res_invalido.json())
    assert res_invalido.status_code == 401

    # 8. Perfil de campo não acessa rotas do Administrador (403)
    for rota in ["/api/reports/dashboard", "/api/usuarios/", "/api/logs/"]:
        res = client.get(rota, headers=headers_enf)
        print(f"8. Enfermeiro em {rota}:", res.status_code)
        assert res.status_code == 403
    res_cadastro = client.post("/api/cadastros/medicos", json={"nome": "Teste"}, headers=headers_enf)
    print("8. Enfermeiro criando médico:", res_cadastro.status_code)
    assert res_cadastro.status_code == 403

    # 9. Usuário logado (/me) e logout
    res_me = client.get("/api/auth/me", headers=headers_enf)
    print("9. Usuário logado:", res_me.status_code, res_me.json()["login"])
    assert res_me.status_code == 200 and res_me.json()["login"] == "enfermeiro"
    res_logout = client.post("/api/auth/logout", headers=headers_enf)
    print("9. Logout:", res_logout.status_code)
    assert res_logout.status_code == 200

    # 10. Login via formulário OAuth2 (botão "Authorize" do /docs)
    res_form = client.post("/api/auth/token", data={"username": "admin", "password": "admin123"})
    print("10. Login formulário OAuth2:", res_form.status_code)
    assert res_form.status_code == 200

print("\n>>> TODOS OS TESTES PASSARAM COM 100% DE SUCESSO! O BACKEND ESTA PRONTO PARA RODAR! <<<")
