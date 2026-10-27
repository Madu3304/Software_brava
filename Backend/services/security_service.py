# Backend/services/security_service.py
"""
Módulo de Segurança e Autenticação (Modelo C4 - Níveis 3 e 4)
Componente: Security Service
Responsabilidade: Criptografia de senhas, emissão/validação de tokens JWT e controle de acesso RBAC.
"""
import os
import hashlib
import logging
import secrets
from typing import Dict, Any
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger("SecurityService")

# Configurações do JWT (definidas no .env)
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES", 60 * 24))

# Fallback para desenvolvimento: chave aleatória por execução (tokens deixam de valer ao reiniciar o servidor)
if not JWT_SECRET_KEY:
    JWT_SECRET_KEY = secrets.token_urlsafe(64)
    logger.warning("JWT_SECRET_KEY não configurada. Utilizando chave temporária gerada na inicialização.")

class TokenInvalidoError(Exception):
    """Token ausente, expirado, com assinatura inválida ou com payload incompleto."""

def gerar_hash_senha(senha: str) -> str:
    """Gera hash seguro SHA-256 para senhas."""
    return hashlib.sha256(senha.encode("utf-8")).hexdigest()

def verificar_senha(senha_fornecida: str, senha_armazenada: str) -> bool:
    """Compara senha em texto plano ou com hash."""
    if senha_fornecida == senha_armazenada:
        return True
    return gerar_hash_senha(senha_fornecida) == senha_armazenada

def gerar_token_acesso(id_usuario: int, login: str, perfil: str) -> str:
    """Gera um JWT assinado contendo identificação, perfil (RBAC) e expiração da sessão."""
    agora = datetime.now(timezone.utc)
    payload = {
        "sub": str(id_usuario),
        "login": login,
        "perfil": (perfil or "").strip().upper(),
        "iat": agora,
        "exp": agora + timedelta(minutes=JWT_EXPIRE_MINUTES),
    }
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)

def decodificar_token_acesso(token: str) -> Dict[str, Any]:
    """Valida assinatura e expiração do JWT e retorna o payload."""
    try:
        payload = jwt.decode(
            token,
            JWT_SECRET_KEY,
            algorithms=[JWT_ALGORITHM],
            options={"require": ["sub", "exp"]},
        )
    except jwt.ExpiredSignatureError as e:
        raise TokenInvalidoError("Sessão expirada. Faça login novamente.") from e
    except jwt.InvalidTokenError as e:
        raise TokenInvalidoError("Token de acesso inválido.") from e
    return payload

def obter_redirecionamento_por_perfil(perfil: str) -> str:
    """
    Regra de negócio RBAC (RFC 6.3 / C4):
    - Administrador: Redirecionado para a Interface Web (Dashboard e Cadastros)
    - Demais perfis (Enfermeiro, Técnico, Condutor): Redirecionados para o Mobile (Ficha Técnica)
    """
    perfil_formatado = (perfil or "").strip().upper()
    if perfil_formatado == "ADMINISTRADOR":
        return "WEB"
    return "MOBILE"

def validar_permissao_perfil(perfil_usuario: str, perfis_permitidos: list[str]) -> bool:
    """Valida se o perfil do usuário possui autorização para o recurso."""
    if not perfil_usuario:
        return False
    perfis_norm = [p.upper() for p in perfis_permitidos]
    return perfil_usuario.upper() in perfis_norm
