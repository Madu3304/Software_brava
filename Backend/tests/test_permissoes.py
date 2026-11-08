def test_rotas_privadas_sem_token(client):
    """Garante que endpoints protegidos rejeitam requisições sem header Authorization."""
    rotas = [
        "/api/usuarios/",
        "/api/logs/",
        "/api/reports/dashboard",
        "/api/cadastros/unidades",
    ]
    for rota in rotas:
        res = client.get(rota)
        assert res.status_code == 401

def test_admin_acessa_gestao_e_logs(client, headers_admin):
    """Verifica que o perfil ADMINISTRADOR tem acesso pleno aos endpoints de gestão e auditoria."""
    res_usuarios = client.get("/api/usuarios/", headers=headers_admin)
    assert res_usuarios.status_code == 200

    res_logs = client.get("/api/logs/", headers=headers_admin)
    assert res_logs.status_code == 200

    res_dash = client.get("/api/reports/dashboard", headers=headers_admin)
    assert res_dash.status_code == 200

def test_enfermeiro_bloqueado_em_rotas_de_admin(client, headers_enfermeiro):
    """Garante isolamento RBAC: o perfil ENFERMEIRO recebe 403 Forbidden em rotas restritas de admin."""
    rotas_admin = [
        "/api/usuarios/",
        "/api/logs/",
        "/api/reports/dashboard",
    ]
    for rota in rotas_admin:
        res = client.get(rota, headers=headers_enfermeiro)
        assert res.status_code == 403
