# Backend/dependencies.py
"""
Dependências de Autenticação e Autorização (Modelo C4 - Nível 4)
Uso nos controllers:
- Depends(get_usuario_atual): exige token JWT válido e devolve o usuário logado
- Depends(exigir_perfil("ADMINISTRADOR")): exige token válido e perfil autorizado (RBAC)
"""
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from database import get_db
from models import Usuario
from services.security_service import (
    TokenInvalidoError,
    decodificar_token_acesso,
    validar_permissao_perfil,
)

# tokenUrl aponta para o endpoint de formulário usado pelo botão "Authorize" do Swagger (/docs)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")

def get_usuario_atual(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> Usuario:
    """Decodifica o JWT do header Authorization e retorna o usuário ativo correspondente."""
    erro_credenciais = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Não autenticado ou token inválido.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = decodificar_token_acesso(token)
        id_usuario = int(payload["sub"])
    except TokenInvalidoError as e:
        erro_credenciais.detail = str(e)
        raise erro_credenciais
    except (KeyError, ValueError):
        raise erro_credenciais

    usuario = db.query(Usuario).filter(Usuario.id_usuario == id_usuario).first()
    if not usuario:
        raise erro_credenciais

    if not usuario.ativo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuário inativo. Contate o Administrador."
        )

    return usuario

def exigir_perfil(*perfis_permitidos: str):
    """
    Fábrica de dependência RBAC. O perfil é lido do banco (não do token),
    então alterações de perfil feitas pelo Administrador valem imediatamente.
    """
    def verificar_perfil(usuario: Usuario = Depends(get_usuario_atual)) -> Usuario:
        if not validar_permissao_perfil(usuario.perfil, list(perfis_permitidos)):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Acesso negado: perfil sem permissão para este recurso."
            )
        return usuario

    return verificar_perfil
