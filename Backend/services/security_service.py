# Backend/services/security_service.py
"""
Módulo de Segurança e Autenticação (Modelo C4 - Níveis 3 e 4)
Componente: Security Service
Responsabilidade: Criptografia de senhas, emissão/validação de tokens JWT e controle de acesso RBAC.
"""
import os
import hashlib
import hmac
import logging
import secrets
from typing import Dict, Any
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv
import bcrypt

load_dotenv()
logger = logging.getLogger("SecurityService")

# Configurações do JWT (definidas no .env)
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES", 60 * 24))

# Ambiente de execução (mesma convenção do main.py e do seed.py)
APP_ENV = os.getenv("APP_ENV", "production").strip().lower()

# Fora de desenvolvimento a chave é obrigatória: o fallback aleatório é gerado na importação
# do módulo, então cada worker do uvicorn teria uma chave diferente e os tokens emitidos por
# um seriam recusados pelos outros.
if not JWT_SECRET_KEY:
    if APP_ENV != "development":
        raise RuntimeError(
            "JWT_SECRET_KEY é obrigatória quando APP_ENV não é 'development'. "
            "Gere uma com: python -c \"import secrets; print(secrets.token_urlsafe(64))\""
        )
    JWT_SECRET_KEY = secrets.token_urlsafe(64)
    logger.warning("JWT_SECRET_KEY não configurada. Utilizando chave temporária gerada na inicialização.")

class TokenInvalidoError(Exception):
    """Token ausente, expirado, com assinatura inválida ou com payload incompleto."""

def _senha_em_bytes(senha: str) -> bytes:
    return senha.encode("utf-8")[:72]

def gerar_hash_senha(senha: str) -> str:
    """Gera hash bcrypt com salt aleatório embutido para senhas."""
    return bcrypt.hashpw(_senha_em_bytes(senha), bcrypt.gensalt()).decode("utf-8")

def _e_hash_legado_sha256(valor: str) -> bool:
    """Reconhece o formato antigo: SHA-256 em hexadecimal, 64 caracteres, sem salt."""
    return len(valor) == 64 and all(c in "0123456789abcdefABCDEF" for c in valor)

def _hash_legado_sha256(senha: str) -> str:
    return hashlib.sha256(senha.encode("utf-8")).hexdigest()

def verificar_senha(senha_fornecida: str, senha_armazenada: str) -> bool:
    """
    Compara o hash da senha fornecida com o hash armazenado.
    Nunca compara a senha fornecida diretamente com o valor do banco: isso permitiria
    logar usando o próprio hash como senha.
    Aceita também o formato SHA-256 antigo, para que as contas já existentes continuem
    entrando, o hash é regravado em bcrypt no primeiro login bem-sucedido.
    """
    if not senha_fornecida or not senha_armazenada:
        return False
    if _e_hash_legado_sha256(senha_armazenada):
        return hmac.compare_digest(_hash_legado_sha256(senha_fornecida), senha_armazenada)
    try:
        return bcrypt.checkpw(_senha_em_bytes(senha_fornecida), senha_armazenada.encode("utf-8"))
    except ValueError:
        # Hash armazenado em formato irreconhecível: trata como credencial inválida
        return False

def migrar_hash(senha_armazenada: str) -> bool:
    return bool(senha_armazenada) and _e_hash_legado_sha256(senha_armazenada)

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
