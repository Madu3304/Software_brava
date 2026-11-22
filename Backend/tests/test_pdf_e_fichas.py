import uuid


def _payload_ficha_completa(seed_dados_basicos, uuid_str=None):
    return {
        "uuid_offline": uuid_str or str(uuid.uuid4()),
        "id_unidade": seed_dados_basicos["unidade"].id_unidade,
        "id_condutor": seed_dados_basicos["condutor"].id_condutor,
        "id_medico": seed_dados_basicos["medico"].id_medico,
        "id_tecnico": seed_dados_basicos["tecnico"].id_tecnico,
        "id_base": seed_dados_basicos["base"].id_base,
        "id_hospital": seed_dados_basicos["hospital"].id_hospital,
        "cep": "89201-100",
        "logradouro": "Rua XV de Novembro",
        "bairro": "Centro",
        "numero": "500",
        "observacoes_gerais": "Atendimento de emergência clínica",
        "paciente": {
            "nome": "Maria Oliveira",
            "idade": 34,
            "sexo": "F",
            "documento": "52998224725",
            "acompanhante": "José Oliveira",
            "grau_parentesco": "Cônjuge",
            "telefone_acompanhante": "(47) 99999-1111",
            "historico_clinico": "Hipertensão gestacional",
            "alergias": "Dipirona",
            "medicamentoUso_paciente": "Metildopa",
        },
        "avaliacao_clinica": {
            "pressao_arterial": "130/80",
            "frequencia_cardiaca": 88,
            "frequencia_respiratoria": 18,
            "saturacao_o2": 98,
            "glicemia": 102,
            "temperatura": 36.6,
            "escala_glasgow": 15,
            "abertura_ocular": 4,
            "resposta_verbal": 5,
            "resposta_motora": 6,
            "usa_anticoagulante": False,
            "assimetria_facial": False,
            "queda_braco": False,
            "fala": False,
            "avc_suspeito": False,
            "anotacao_CondutaEnfermeiro": "Monitorização contínua",
            "procedimentos_realizados": "Acesso venoso periférico",
            "medicacoes_administradas": "Soro fisiológico 0,9%",
            "conduta": "Encaminhada à maternidade",
        },
        "utensilios": {
            "soro_fisiologico_09": True,
            "equipo_macrogotas": True,
            "luvas_estereis": True,
            "observacoes": "Kit básico utilizado",
        },
    }


def test_ciclo_completo_ficha_e_pdf(client, headers_admin, headers_enfermeiro, seed_dados_basicos):
    payload = _payload_ficha_completa(seed_dados_basicos)
    res_post = client.post("/api/fichas/", json=payload, headers=headers_enfermeiro)
    assert res_post.status_code == 201
    data = res_post.json()
    id_ficha = data["id_ficha"]
    assert data["nome_paciente"] == "Maria Oliveira"

    res_list = client.get("/api/fichas/", headers=headers_enfermeiro)
    assert res_list.status_code == 200
    assert len(res_list.json()) >= 1

    res_resumo = client.get("/api/fichas/resumo", headers=headers_admin)
    assert res_resumo.status_code == 200
    assert any(item["id_ficha"] == id_ficha for item in res_resumo.json())

    res_det = client.get(f"/api/fichas/detalhes/{id_ficha}", headers=headers_enfermeiro)
    assert res_det.status_code == 200
    assert res_det.json()["id_ficha"] == id_ficha

    res_det_404 = client.get("/api/fichas/detalhes/999999", headers=headers_admin)
    assert res_det_404.status_code == 404

    res_pdf = client.get(f"/api/fichas/{id_ficha}/pdf", headers=headers_enfermeiro)
    assert res_pdf.status_code == 200
    assert res_pdf.headers["content-type"] == "application/pdf"
    assert res_pdf.content.startswith(b"%PDF")

    res_pdf_404 = client.get("/api/fichas/999999/pdf", headers=headers_admin)
    assert res_pdf_404.status_code == 404


def test_reposicao_integracao_e_metricas_ficha(client, headers_admin, headers_enfermeiro, seed_dados_basicos):
    payload = _payload_ficha_completa(seed_dados_basicos)
    res_post = client.post("/api/fichas/", json=payload, headers=headers_enfermeiro)
    assert res_post.status_code == 201
    id_ficha = res_post.json()["id_ficha"]

    res_rep_list = client.get("/api/fichas/reposicao?apenas_pendentes=true", headers=headers_admin)
    assert res_rep_list.status_code == 200

    res_rep = client.post(
        f"/api/fichas/reposicao/{id_ficha}",
        json={"observacoes": "Reposição concluída na base"},
        headers=headers_admin,
    )
    assert res_rep.status_code == 200

    res_rep_404 = client.post(
        "/api/fichas/reposicao/999999",
        json={"observacoes": "Não existe"},
        headers=headers_admin,
    )
    assert res_rep_404.status_code == 404

    res_metricas = client.get("/api/fichas/dashboard/metricas", headers=headers_admin)
    assert res_metricas.status_code == 200

    res_int_status = client.get("/api/fichas/integracao/status", headers=headers_admin)
    assert res_int_status.status_code == 200
    assert "pendentes" in res_int_status.json()

    res_int_reenviar = client.post("/api/fichas/integracao/reenviar", headers=headers_admin)
    assert res_int_reenviar.status_code == 200
    assert "fichas_agendadas" in res_int_reenviar.json()

    res_int_404 = client.post("/api/fichas/integracao/reenviar?id_ficha=999999", headers=headers_admin)
    assert res_int_404.status_code == 404


def test_criar_ficha_erro_validacao_clinica(client, headers_enfermeiro, seed_dados_basicos):
    payload = _payload_ficha_completa(seed_dados_basicos)
    payload["avaliacao_clinica"]["escala_glasgow"] = 2  # inválido (<3)
    res = client.post("/api/fichas/", json=payload, headers=headers_enfermeiro)
    assert res.status_code in (400, 422)
