from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime

from database import get_db
from dependencies import get_usuario_atual, obter_ip_origem
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

def autenticar_usuario(login: str, senha: str, request: Request, db: Session) -> TokenResponse:
    """Valida as credenciais, gera o JWT e registra a auditoria do login."""
    usuario = db.query(Usuario).filter(Usuario.login == login).first()
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

    if not verificar_senha(senha, usuario.senha_hash):
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

    # Gera token de acesso JWT
    token = gerar_token_acesso(usuario.id_usuario, usuario.login, usuario.perfil)

    # Registra Log de Auditoria de Login (RNF05 / Modelo C4)
    ip_origem = obter_ip_origem(request)
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

@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, request: Request, db: Session = Depends(get_db)):
    """
    Autentica usuários (Administrador ou Equipe de Campo).
    Conforme o Modelo C4 e RFC:
    - Administrador é direcionado para a Interface Web Administrativa (Dashboard / Cadastros).
    - Equipe de Campo (Enfermeiro, Técnico, Condutor) é direcionada para o Aplicativo Mobile (Ficha Técnica).
    O access_token retornado deve ser enviado nas demais rotas no header: Authorization: Bearer <token>.
    Se o usuário estiver com troca de senha obrigatória, o login é recusado (403, codigo TROCA_SENHA_OBRIGATORIA)
    até que a senha seja trocada em POST /api/auth/trocar-senha.
    """
    return autenticar_usuario(req.login, req.senha, request, db)

@router.post("/token", response_model=TokenResponse)
def login_formulario(
    request: Request,
    form: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    """Login no padrão OAuth2 (form-data), utilizado pelo botão "Authorize" da documentação /docs."""
    return autenticar_usuario(form.username, form.password, request, db)

@router.get("/me", response_model=UsuarioResponse)
def usuario_logado(usuario: Usuario = Depends(get_usuario_atual)):
    """Retorna os dados do usuário dono do token."""
    return usuario

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

    ip_origem = obter_ip_origem(request)
    registrar_auditoria(
        db=db,
        acao="TROCAR_SENHA",
        detalhes="Senha alterada pelo próprio usuário.",
        id_usuario=usuario.id_usuario,
        ip_origem=ip_origem,
    )
    return {"mensagem": "Senha alterada com sucesso. Faça login com a nova senha."}

@router.post("/logout")
def logout(
    request: Request,
    usuario: Usuario = Depends(get_usuario_atual),
    db: Session = Depends(get_db),
):
    """Encerra a sessão e registra log de auditoria."""
    ip_origem = obter_ip_origem(request)
    registrar_auditoria(
        db=db,
        acao="LOGOUT",
        detalhes="Sessão finalizada pelo usuário.",
        id_usuario=usuario.id_usuario,
        ip_origem=ip_origem,
    )
    return {"mensagem": "Logout efetuado com sucesso."}
