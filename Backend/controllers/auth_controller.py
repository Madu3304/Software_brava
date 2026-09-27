from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from datetime import datetime

from database import get_db
from models import Usuario
from schemas import LoginRequest, TokenResponse, UsuarioResponse
from services.security_service import (
    verificar_senha,
    gerar_token_acesso,
    obter_redirecionamento_por_perfil,
)
from services.log_service import registrar_auditoria

# Gerencia autenticação e aplica regra de redirecionamento por perfil: Administrador vs Mobile
router = APIRouter(prefix="/auth", tags=["Autenticação e Sessão (C4 Nível 3/4)"])

@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, request: Request, db: Session = Depends(get_db)):
    """
    Autentica usuários (Administrador ou Equipe de Campo).
    Conforme o Modelo C4 e RFC:
    - Administrador é direcionado para a Interface Web Administrativa (Dashboard / Cadastros).
    - Equipe de Campo (Enfermeiro, Técnico, Condutor) é direcionada para o Aplicativo Mobile (Ficha Técnica).
    """
    usuario = db.query(Usuario).filter(Usuario.login == req.login).first()
    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas: usuário não encontrado."
        )

    if not usuario.ativo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuário inativo. Contate o Administrador."
        )

    if not verificar_senha(req.senha, usuario.senha_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas: senha incorreta."
        )

    # Determina o redirecionamento com base no perfil (RBAC)
    redirecionamento = obter_redirecionamento_por_perfil(usuario.perfil)

    # Gera token de acesso
    token = gerar_token_acesso(usuario.id_usuario, usuario.login, usuario.perfil)

    # Registra Log de Auditoria de Login (RNF05 / Modelo C4)
    ip_origem = request.client.host if request.client else "127.0.0.1"
    registrar_auditoria(
        db=db,
        acao=f"LOGIN_{redirecionamento}",
        detalhes=f"Login realizado com sucesso. Perfil: {usuario.perfil}. Direcionado para {redirecionamento}.",
        id_usuario=usuario.id_usuario,
        ip_origem=ip_origem,
    )

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        id_usuario=usuario.id_usuario,
        nome=usuario.nome,
        login=usuario.login,
        perfil=usuario.perfil,
        redirecionamento=redirecionamento,
    )

@router.post("/logout")
def logout(id_usuario: int, request: Request, db: Session = Depends(get_db)):
    """Encerra a sessão e registra log de auditoria."""
    ip_origem = request.client.host if request.client else "127.0.0.1"
    log = LogAuditoria(
        id_usuario=id_usuario,
        acao="LOGOUT",
        detalhes_metadados="Sessão finalizada pelo usuário.",
        ip_origem=ip_origem,
    )
    db.add(log)
    db.commit()
    return {"mensagem": "Logout efetuado com sucesso."}
