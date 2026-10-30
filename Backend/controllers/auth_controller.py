from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from datetime import datetime

from database import get_db
from models import Usuario
from schemas import LoginRequest, TokenResponse, UsuarioResponse, TrocarSenhaRequest
from services.security_service import (
    verificar_senha,
    gerar_hash_senha,
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
    Se o usuário estiver com troca de senha obrigatória, o login é recusado (403, codigo TROCA_SENHA_OBRIGATORIA)
    até que a senha seja trocada em POST /api/auth/trocar-senha.
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

    # Primeiro acesso ou senha redefinida pelo Administrador: exige troca antes de liberar o acesso
    if usuario.trocar_senha:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={
                "codigo": "TROCA_SENHA_OBRIGATORIA",
                "mensagem": "É necessário trocar a senha antes do primeiro acesso.",
            },
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

@router.post("/trocar-senha")
def trocar_senha(req: TrocarSenhaRequest, request: Request, db: Session = Depends(get_db)):
    """
    Troca a senha do usuário (obrigatória no primeiro acesso ou após redefinição pelo Administrador).
    Exige login e senha atual. A nova senha deve ter no mínimo 8 caracteres e ser diferente da atual.
    """
    usuario = db.query(Usuario).filter(Usuario.login == req.login).first()
    if not usuario or not verificar_senha(req.senha_atual, usuario.senha_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas."
        )

    if not usuario.ativo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuário inativo. Contate o Administrador."
        )

    if req.nova_senha == req.senha_atual:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A nova senha deve ser diferente da senha atual."
        )

    usuario.senha_hash = gerar_hash_senha(req.nova_senha)
    usuario.trocar_senha = False
    db.commit()

    ip_origem = request.client.host if request.client else "127.0.0.1"
    registrar_auditoria(
        db=db,
        acao="TROCAR_SENHA",
        detalhes="Senha alterada pelo próprio usuário.",
        id_usuario=usuario.id_usuario,
        ip_origem=ip_origem,
    )
    return {"mensagem": "Senha alterada com sucesso. Faça login com a nova senha."}

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
