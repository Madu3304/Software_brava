from models import Usuario

def test_delete_usuario_faz_soft_delete(client, headers_admin, db_session, seed_dados_basicos):
    """
    Testa B20: DELETE /usuarios/{id} deve realizar soft delete (ativo=False)
    e retornar 204 No Content, mantendo o registro no banco para integridade referencial e LGPD.
    """
    user_deletavel = seed_dados_basicos["usuario_deletavel"]
    user_id = user_deletavel.id_usuario

    # Executa a requisição DELETE
    res = client.delete(f"/api/usuarios/{user_id}", headers=headers_admin)
    assert res.status_code == 204

    # Verifica no banco de dados se o usuário continua existindo fisicamente
    usuario_db = db_session.query(Usuario).filter(Usuario.id_usuario == user_id).first()
    assert usuario_db is not None, "O usuário não pode ser excluído fisicamente (B20)."
    assert usuario_db.ativo is False, "O campo ativo deve ser False após soft delete."

def test_delete_usuario_inexistente_retorna_404(client, headers_admin):
    """Testa que tentar remover usuário inexistente devolve 404 Not Found."""
    res = client.delete("/api/usuarios/99999", headers=headers_admin)
    assert res.status_code == 404
