def test_auth_me_trocar_senha_e_logout_revoga_token(client, seed_dados_basicos):
    res_login = client.post(
        "/api/auth/login",
        json={"login": "tec_teste", "senha": "SenhaTec#1"},
    )
    assert res_login.status_code == 200
    token = res_login.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    res_me = client.get("/api/auth/me", headers=headers)
    assert res_me.status_code == 200
    assert res_me.json()["login"] == "tec_teste"

    res_troca_igual = client.post(
        "/api/auth/trocar-senha",
        json={
            "login": "tec_teste",
            "senha_atual": "SenhaTec#1",
            "nova_senha": "SenhaTec#1",
        },
    )
    assert res_troca_igual.status_code == 400

    res_troca_ok = client.post(
        "/api/auth/trocar-senha",
        json={
            "login": "tec_teste",
            "senha_atual": "SenhaTec#1",
            "nova_senha": "NovaSenhaTec#2",
        },
    )
    assert res_troca_ok.status_code == 200

    res_token_form = client.post(
        "/api/auth/token",
        data={"username": "tec_teste", "password": "NovaSenhaTec#2"},
    )
    assert res_token_form.status_code == 200

    res_logout = client.post("/api/auth/logout", headers=headers)
    assert res_logout.status_code == 200

    # Token revogado deve retornar 401
    res_me_revogado = client.get("/api/auth/me", headers=headers)
    assert res_me_revogado.status_code == 401


def test_crud_usuarios_admin(client, headers_admin):
    res_list = client.get("/api/usuarios/?perfil=TECNICO&ativo=true", headers=headers_admin)
    assert res_list.status_code == 200

    res_create = client.post(
        "/api/usuarios/",
        json={
            "nome": "Novo Socorrista",
            "email": "novo.socorrista@samu.joinville.sc.gov.br",
            "login": "novo_socorrista",
            "senha": "SenhaForte#123",
            "perfil": "CONDUTOR",
            "registro_profissional": "CNH-D",
            "ativo": True,
        },
        headers=headers_admin,
    )
    assert res_create.status_code == 201
    id_usuario = res_create.json()["id_usuario"]

    res_dup = client.post(
        "/api/usuarios/",
        json={
            "nome": "Duplicado",
            "email": "outro@samu.joinville.sc.gov.br",
            "login": "novo_socorrista",
            "senha": "SenhaForte#123",
            "perfil": "CONDUTOR",
        },
        headers=headers_admin,
    )
    assert res_dup.status_code == 400

    res_get = client.get(f"/api/usuarios/{id_usuario}", headers=headers_admin)
    assert res_get.status_code == 200

    res_404 = client.get("/api/usuarios/999999", headers=headers_admin)
    assert res_404.status_code == 404

    res_upd = client.put(
        f"/api/usuarios/{id_usuario}",
        json={"nome": "Socorrista Atualizado", "ativo": False},
        headers=headers_admin,
    )
    assert res_upd.status_code == 200
    assert res_upd.json()["nome"] == "Socorrista Atualizado"
    assert res_upd.json()["ativo"] is False


def test_crud_cadastros_completo(client, headers_admin, headers_enfermeiro):
    # Médicos
    r_med = client.post(
        "/api/cadastros/medicos",
        json={"nome": "Dra. Helena", "codigo_medico": 98765, "crm": "CRM-SC 9999"},
        headers=headers_admin,
    )
    assert r_med.status_code == 201
    id_med = r_med.json()["id_medico"]
    assert client.get("/api/cadastros/medicos", headers=headers_enfermeiro).status_code == 200
    assert client.get("/api/cadastros/medicos/completo", headers=headers_admin).status_code == 200
    assert client.delete(f"/api/cadastros/medicos/{id_med}", headers=headers_admin).status_code == 204

    # Técnicos
    r_tec = client.post(
        "/api/cadastros/tecnicos",
        json={"nome": "Téc. Carlos", "codigo_tecnico": 554433, "coren": "COREN-SC 554433"},
        headers=headers_admin,
    )
    assert r_tec.status_code == 201
    id_tec = r_tec.json()["id_tecnico"]
    assert client.get("/api/cadastros/tecnicos", headers=headers_enfermeiro).status_code == 200
    assert client.get("/api/cadastros/tecnicos/completo", headers=headers_admin).status_code == 200
    assert client.delete(f"/api/cadastros/tecnicos/{id_tec}", headers=headers_admin).status_code == 204

    # Condutores
    r_cond = client.post(
        "/api/cadastros/condutores",
        json={"nome": "Cond. Pedro", "codigo_condutor": 778899},
        headers=headers_admin,
    )
    assert r_cond.status_code == 201
    id_cond = r_cond.json()["id_condutor"]
    assert client.get("/api/cadastros/condutores", headers=headers_enfermeiro).status_code == 200
    assert client.get("/api/cadastros/condutores/completo", headers=headers_admin).status_code == 200
    assert client.delete(f"/api/cadastros/condutores/{id_cond}", headers=headers_admin).status_code == 204

    # Unidades móveis
    r_uni = client.post(
        "/api/cadastros/unidades",
        json={"placa": "SAM-1920", "base_unidade": "Base Sul", "status": "DISPONIVEL"},
        headers=headers_admin,
    )
    assert r_uni.status_code == 201
    id_uni = r_uni.json()["id_unidade"]
    assert client.get("/api/cadastros/unidades", headers=headers_enfermeiro).status_code == 200
    r_st = client.put(
        f"/api/cadastros/unidades/{id_uni}/status?status_novo=EM_ATENDIMENTO&motivo=Despacho",
        headers=headers_admin,
    )
    assert r_st.status_code == 200
    assert client.delete(f"/api/cadastros/unidades/{id_uni}", headers=headers_admin).status_code == 204

    # Bases, Hospitais e Pacientes
    assert client.post("/api/cadastros/bases", json={"nome": "Base Leste"}, headers=headers_admin).status_code == 201
    assert client.get("/api/cadastros/bases", headers=headers_enfermeiro).status_code == 200
    assert client.post("/api/cadastros/hospitais", json={"nome": "Hospital Regional"}, headers=headers_admin).status_code == 201
    assert client.get("/api/cadastros/hospitais", headers=headers_enfermeiro).status_code == 200
    assert client.post(
        "/api/cadastros/pacientes",
        json={"nome": "Paciente Cadastro", "idade": 40, "sexo": "M", "documento": "11144477735"},
        headers=headers_admin,
    ).status_code == 201
    assert client.get("/api/cadastros/pacientes", headers=headers_admin).status_code == 200
