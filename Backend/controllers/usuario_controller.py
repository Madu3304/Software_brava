from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional
import hashlib

from database import get_db
from models import Usuario
from schemas import UsuarioCreate, UsuarioUpdate, UsuarioResponse
from services.security_service import gerar_hash_senha
from services.log_service import registrar_auditoria

router = APIRouter(prefix="/usuarios", tags=["Gestão de Usuários e Perfis RBAC (RN01, RN13)"])

# Gerencia contas, senhas com hash SHA-256 e perfis (Administrador, Enfermeiro, Técnico, Condutor).

@router.get("/", response_model=List[UsuarioResponse])
def listar_usuarios(
    perfil: Optional[str] = Query(None, description="Filtrar por perfil: ADMINISTRADOR, ENFERMEIRO, TECNICO, CONDUTOR"),
    ativo: Optional[bool] = Query(None, description="Filtrar por status ativo/inativo"),
    db: Session = Depends(get_db)
):
    """
    Lista usuários cadastrados no sistema, permitindo filtros por perfil funcional e status.
    """
    query = db.query(Usuario)
    if perfil:
        query = query.filter(Usuario.perfil == perfil.upper())
    if ativo is not None:
        query = query.filter(Usuario.ativo == ativo)
    return query.all()

@router.get("/{id_usuario}", response_model=UsuarioResponse)
def obter_usuario(id_usuario: int, db: Session = Depends(get_db)):
    """Obtém detalhes de um usuário específico."""
    usuario = db.query(Usuario).filter(Usuario.id_usuario == id_usuario).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")
    return usuario

@router.post("/", response_model=UsuarioResponse, status_code=status.HTTP_201_CREATED)
def criar_usuario(dados: UsuarioCreate, db: Session = Depends(get_db)):
    """
    Cadastra um novo usuário com controle de perfil (RBAC) e registro profissional.
    """
    # Verifica duplicidade de login
    login_existente = db.query(Usuario).filter(Usuario.login == dados.login).first()
    if login_existente:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Login '{dados.login}' já está em uso por outro profissional."
        )

    novo_usuario = Usuario(
        nome=dados.nome,
        email=dados.email,
        login=dados.login,
        senha_hash=gerar_hash_senha(dados.senha),
        perfil=dados.perfil.upper(),
        registro_profissional=dados.registro_profissional,
        ativo=dados.ativo,
    )
    db.add(novo_usuario)
    db.flush()

    # Log de Auditoria
    registrar_auditoria(
        db=db,
        acao="CRIAR_USUARIO",
        detalhes=f"Novo usuário criado: {novo_usuario.nome} ({novo_usuario.login}) com perfil {novo_usuario.perfil}.",
        id_usuario=novo_usuario.id_usuario,
    )
    db.refresh(novo_usuario)
    return novo_usuario

@router.put("/{id_usuario}", response_model=UsuarioResponse)
def atualizar_usuario(id_usuario: int, dados: UsuarioUpdate, db: Session = Depends(get_db)):
    """
    Atualiza dados do usuário, perfil, senha ou inativa o colaborador (Direito do Titular / LGPD).
    """
    usuario = db.query(Usuario).filter(Usuario.id_usuario == id_usuario).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")

    if dados.nome is not None:
        usuario.nome = dados.nome
    if dados.email is not None:
        usuario.email = dados.email
    if dados.perfil is not None:
        usuario.perfil = dados.perfil.upper()
    if dados.registro_profissional is not None:
        usuario.registro_profissional = dados.registro_profissional
    if dados.ativo is not None:
        usuario.ativo = dados.ativo
    if dados.senha is not None and dados.senha.strip():
        usuario.senha_hash = gerar_hash_senha(dados.senha)

    db.commit()
    registrar_auditoria(
        db=db,
        acao="ATUALIZAR_USUARIO",
        detalhes=f"Dados do usuário {usuario.login} atualizados pelo Administrador.",
        id_usuario=id_usuario,
    )
    db.refresh(usuario)
    return usuario

@router.delete("/{id_usuario}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_usuario(id_usuario: int, db: Session = Depends(get_db)):
    """Remove permanentemente o usuário ou desativa seu acesso."""
    usuario = db.query(Usuario).filter(Usuario.id_usuario == id_usuario).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")

    db.delete(usuario)
    db.commit()
    return None
