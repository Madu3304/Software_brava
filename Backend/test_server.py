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

    # 3. Login Enfermeiro (RBAC: deve retornar redirecionamento 'MOBILE')
    res_enf = client.post("/api/auth/login", json={"login": "enfermeiro", "senha": "brava123"})
    print("3. Login Enfermeiro:", res_enf.status_code, res_enf.json())
    assert res_enf.status_code == 200
    assert res_enf.json()["redirecionamento"] == "MOBILE"

    # 4. Dashboard Gerencial
    res_dash = client.get("/api/reports/dashboard")
    print("4. Dashboard Metricas:", res_dash.status_code, res_dash.json())
    assert res_dash.status_code == 200

    # 5. Listagem de Unidades Móveis (Bravas)
    res_unidades = client.get("/api/cadastros/unidades")
    print("5. Unidades Cadastradas:", len(res_unidades.json()))
    assert len(res_unidades.json()) >= 4

print("\n>>> TODOS OS TESTES PASSARAM COM 100% DE SUCESSO! O BACKEND ESTA PRONTO PARA RODAR! <<<")
