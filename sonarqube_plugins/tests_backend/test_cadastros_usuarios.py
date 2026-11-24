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


def test_seguranca_bola_rbac_e_revogacao_token(client, db_session, seed_dados_basicos, headers_admin, headers_enfermeiro, monkeypatch):
    from controllers import docusign_controller
    from services.security_service import gerar_token_acesso

    # 1. BOLA em reposição e RBAC em /dashboard/metricas
    assert client.post(
        "/api/fichas/reposicao/999999",
        json={"reposto": True, "observacoes_reposicao": "ok"},
        headers=headers_admin,
    ).status_code == 404
    assert client.get("/api/fichas/dashboard/metricas", headers=headers_enfermeiro).status_code == 403

    # 2. DocuSign: validação de envelope_id e sanitização de erro 500
    assert client.get("/api/docusign/status/id!invalido", headers=headers_admin).status_code == 400
    def _boom(**kwargs):
        raise RuntimeError("detalhe interno")
    monkeypatch.setattr(docusign_controller.docusign_service, "criar_envelope_termo_aph", _boom)
    r_ds = client.post(
        "/api/docusign/envelopes",
        json={"numero_ocorrencia": "1", "paciente_nome": "Teste"},
        headers=headers_admin,
    )
    assert r_ds.status_code == 500
    assert "detalhe interno" not in r_ds.text

    # 3. Ollama: modelo fora da allowlist retorna 400
    r_ia = client.post(
        "/api/ia/chat",
        json={"mensagem": "oi", "modelo": "modelo-nao-autorizado"},
        headers=headers_admin,
    )
    assert r_ia.status_code == 400

    # 4. Alterar perfil do usuário revoga JWT antigo
    enf = seed_dados_basicos["enfermeiro"]
    token_antigo = gerar_token_acesso(enf.id_usuario, enf.login, enf.perfil, token_version=1)
    r_upd = client.put(
        f"/api/usuarios/{enf.id_usuario}",
        json={"perfil": "TECNICO"},
        headers=headers_admin,
    )
    assert r_upd.status_code == 200
    r_me = client.get("/api/auth/me", headers={"Authorization": f"Bearer {token_antigo}"})
    assert r_me.status_code == 401

    # 5. Hash legado SHA-256 bloqueado em produção (ALLOW_LEGACY_SHA256=false)
    import hashlib
    from services.security_service import verificar_senha
    sha_legado = hashlib.sha256(b"Senha123").hexdigest()
    monkeypatch.setenv("ALLOW_LEGACY_SHA256", "false")
    assert verificar_senha("Senha123", sha_legado) is False
    monkeypatch.setenv("ALLOW_LEGACY_SHA256", "true")
    assert verificar_senha("Senha123", sha_legado) is True
