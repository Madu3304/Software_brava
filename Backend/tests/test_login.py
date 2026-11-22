def test_login_sucesso(client, seed_dados_basicos):
    """Testa autenticação bem-sucedida retornando token JWT e perfil funcional."""
    resposta = client.post("/api/auth/login", json={
        "login": "admin_teste",
        "senha": "SenhaAdmin#1",
    })
    assert resposta.status_code == 200
    dados = resposta.json()
    assert "access_token" in dados
    assert dados["token_type"] == "bearer"
    assert dados["perfil"] == "ADMINISTRADOR"
    assert dados["redirecionamento"] == "WEB"

def test_login_senha_incorreta(client, seed_dados_basicos):
    """Testa falha de autenticação com senha incorreta."""
    resposta = client.post("/api/auth/login", json={
        "login": "admin_teste",
        "senha": "SenhaErrada#999",
    })
    assert resposta.status_code == 401
    assert "inválidas" in resposta.json()["detail"].lower()

def test_login_usuario_inexistente(client):
    """Testa falha de autenticação com login inexistente."""
    resposta = client.post("/api/auth/login", json={
        "login": "usuario_fantasma",
        "senha": "QualquerSenha#1",
    })
    assert resposta.status_code == 401
    assert "inválidas" in resposta.json()["detail"].lower()
