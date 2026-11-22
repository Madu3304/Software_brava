from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, timezone

from database import get_db
from dependencies import get_usuario_atual, obter_ip_origem
from models import Usuario
from models.token_revogado import TokenRevogado
from schemas import LoginRequest, TokenResponse, UsuarioResponse, TrocarSenhaRequest
from services.security_service import (
    verificar_senha,
    gerar_hash_senha,
    eh_hash_bcrypt,
    gerar_token_acesso,
    decodificar_token_acesso,
    obter_redirecionamento_por_perfil,
    TokenInvalidoError,
)
from services.log_service import registrar_auditoria
from rate_limit import limite_autenticacao, limite_trocar_senha

router = APIRouter(prefix="/auth", tags=["Autenticação e Sessão"])

MENSAGEM_CREDENCIAIS_INVALIDAS = "Credenciais inválidas."

def recusar_credenciais(db: Session, request: Request, acao: str, login: str, motivo: str, usuario: Usuario | None):
    """Registra a tentativa que falhou na auditoria e responde sempre com a mesma mensagem (401)."""
    registrar_auditoria(
        db=db,
        acao=acao,
        detalhes=f"Tentativa recusada para o login '{login[:50]}'. Motivo: {motivo}.",
        id_usuario=usuario.id_usuario if usuario else None,
        ip_origem=obter_ip_origem(request),
    )
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=MENSAGEM_CREDENCIAIS_INVALIDAS,
    )

HASH_DUMMY = gerar_hash_senha("senha_dummy_tempo_constante")

def autenticar_usuario(login: str, senha: str, request: Request, db: Session) -> TokenResponse:
    """Valida as credenciais, gera o JWT e registra a auditoria do login."""
    usuario = db.query(Usuario).filter(Usuario.login == login).first()
    if not usuario:
        verificar_senha(senha, HASH_DUMMY)
        recusar_credenciais(db, request, "LOGIN_FALHA", login, "usuário não encontrado", None)

    if not verificar_senha(senha, usuario.senha_hash):
        recusar_credenciais(db, request, "LOGIN_FALHA", login, "senha incorreta", usuario)

    # O status de inativo só é verificado depois da senha, para não revelar quais logins existem
    if not usuario.ativo:
        recusar_credenciais(db, request, "LOGIN_FALHA", login, "usuário inativo", usuario)

    # Migração transparente de hashes legados (SHA-256 / PBKDF2) para bcrypt no login
    if not eh_hash_bcrypt(usuario.senha_hash):
        usuario.senha_hash = gerar_hash_senha(senha)
        db.commit()

    # Primeiro acesso ou senha redefinida pelo Administrador: exige troca antes de liberar o acesso
    if usuario.trocar_senha:
        registrar_auditoria(
            db=db,
            acao="LOGIN_TROCA_SENHA_OBRIGATORIA",
            detalhes=f"Login bloqueado até troca de senha inicial para '{usuario.login}'.",
            id_usuario=usuario.id_usuario,
            ip_origem=obter_ip_origem(request),
        )
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
@limite_autenticacao
def login(req: LoginRequest, request: Request, db: Session = Depends(get_db)):
    return autenticar_usuario(req.login, req.senha, request, db)

@router.post("/token", response_model=TokenResponse)
@limite_autenticacao
def login_formulario(
    request: Request,
    form: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    return autenticar_usuario(form.username, form.password, request, db)

@router.get("/me", response_model=UsuarioResponse)
def usuario_logado(usuario: Usuario = Depends(get_usuario_atual)):
    return usuario

@router.post("/trocar-senha")
@limite_trocar_senha
def trocar_senha(req: TrocarSenhaRequest, request: Request, db: Session = Depends(get_db)):

    usuario = db.query(Usuario).filter(Usuario.login == req.login).first()
    if not usuario:
        recusar_credenciais(db, request, "TROCAR_SENHA_FALHA", req.login, "usuário não encontrado", None)

    if not verificar_senha(req.senha_atual, usuario.senha_hash):
        recusar_credenciais(db, request, "TROCAR_SENHA_FALHA", req.login, "senha atual incorreta", usuario)

    if not usuario.ativo:
        recusar_credenciais(db, request, "TROCAR_SENHA_FALHA", req.login, "usuário inativo", usuario)

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
    """
    Encerra a sessão e invalida imediatamente o JWT atual via blocklist (jti).

    O token é registrado na tabela token_revogado. A partir desse momento,
    qualquer requisição com esse token recebe 401, mesmo antes de expirar.
    Isso elimina a janela de 24 h de acesso residual após logout.
    """
    # Extrai o jti e a expiração diretamente do token apresentado
    token_header = request.headers.get("Authorization", "")
    raw_token = token_header.removeprefix("Bearer ").strip()

    jti: str | None = None
    expira_em: datetime | None = None

    if raw_token:
        try:
            payload = decodificar_token_acesso(raw_token)
            jti = payload.get("jti")
            exp_ts = payload.get("exp")
            if exp_ts:
                expira_em = datetime.fromtimestamp(exp_ts, tz=timezone.utc)
        except TokenInvalidoError:
            pass  # Token já expirado — não precisa revogar, apenas registrar auditoria

    if jti and expira_em:
        # Insere na blocklist somente se ainda não estiver (duplo logout é inofensivo)
        existe = db.query(TokenRevogado).filter(TokenRevogado.jti == jti).first()
        if not existe:
            db.add(TokenRevogado(
                jti=jti,
                id_usuario=usuario.id_usuario,
                expira_em=expira_em,
            ))

    ip_origem = obter_ip_origem(request)
    registrar_auditoria(
        db=db,
        acao="LOGOUT",
        detalhes=f"Sessão finalizada pelo usuário. Token revogado (jti={jti or 'indisponível'}).",
        id_usuario=usuario.id_usuario,
        ip_origem=ip_origem,
    )
    db.commit()
    return {"mensagem": "Logout efetuado com sucesso. Token invalidado."}
