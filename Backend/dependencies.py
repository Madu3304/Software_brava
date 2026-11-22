# Backend/dependencies.py

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from database import get_db
from models import Usuario
from models.token_revogado import TokenRevogado
from services.security_service import (
    TokenInvalidoError,
    decodificar_token_acesso,
    validar_permissao_perfil,
)

def obter_ip_origem(request: Request) -> str | None:
    """IP de origem da requisição (atrás de proxy, rode o uvicorn com --proxy-headers)."""
    return request.client.host if request.client else None

# tokenUrl aponta para o endpoint de formulário usado pelo botão "Authorize" do Swagger (/docs)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")

def get_usuario_atual(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> Usuario:
    """
    Decodifica o JWT do header Authorization e retorna o usuário ativo.

    Verificações realizadas em ordem:
    1. Assinatura e expiração do JWT.
    2. Existência do jti na blocklist de tokens revogados (logout).
    3. Existência e atividade do usuário no banco.
    4. Flag trocar_senha — bloqueia acesso até a senha ser trocada.
    """
    erro_credenciais = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Não autenticado ou token inválido.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = decodificar_token_acesso(token)
        id_usuario = int(payload["sub"])
        jti = payload.get("jti")
    except TokenInvalidoError as e:
        erro_credenciais.detail = str(e)
        raise erro_credenciais
    except (KeyError, ValueError):
        raise erro_credenciais

    # Verifica se o token foi explicitamente revogado pelo logout
    if jti and db.query(TokenRevogado).filter(TokenRevogado.jti == jti).first():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Sessão encerrada. Faça login novamente.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    usuario = db.query(Usuario).filter(Usuario.id_usuario == id_usuario).first()
    if not usuario:
        raise erro_credenciais

    if not usuario.ativo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuário inativo. Contate o Administrador."
        )

    if usuario.trocar_senha:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={
                "codigo": "TROCA_SENHA_OBRIGATORIA",
                "mensagem": "É necessário trocar a senha antes de acessar este recurso.",
            },
        )

    return usuario

def exigir_perfil(*perfis_permitidos: str):
    def verificar_perfil(usuario: Usuario = Depends(get_usuario_atual)) -> Usuario:
        if not validar_permissao_perfil(usuario.perfil, list(perfis_permitidos)):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Acesso negado: perfil sem permissão para este recurso."
            )
        return usuario

    return verificar_perfil
