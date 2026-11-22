# Backend/services/security_service.py

import os
import hashlib
import hmac
import logging
import secrets
from typing import Dict, Any
from datetime import datetime, timedelta, timezone

import jwt
import bcrypt
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger("SecurityService")

# Configurações do JWT (definidas no .env)
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES", 60 * 24))

_APP_ENV = os.getenv("APP_ENV", "production").strip().lower()

if not JWT_SECRET_KEY:
    if _APP_ENV == "production":
        # Em produção, uma chave ausente significa que cada worker/réplica geraria
        # sua própria chave efêmera, invalidando sessões entre reinicializações e
        # impedindo que múltiplos workers validem tokens entre si.
        raise RuntimeError(
            "[SEGURANÇA] JWT_SECRET_KEY não definida em ambiente de produção. "
            "Configure a variável no .env ou nos secrets do orquestrador antes de iniciar."
        )
    # Desenvolvimento: chave efêmera por execução com aviso explícito
    JWT_SECRET_KEY = secrets.token_urlsafe(64)
    logger.warning(
        "[SEGURANÇA] JWT_SECRET_KEY não configurada. "
        "Usando chave temporária gerada na inicialização — tokens expiram ao reiniciar o servidor."
    )

class TokenInvalidoError(Exception):
    """Token ausente, expirado, com assinatura inválida, payload incompleto ou revogado."""

BCRYPT_ROUNDS = 12

def eh_hash_bcrypt(senha_armazenada: str) -> bool:
    """Indica se o hash armazenado já está no formato bcrypt ($2a$, $2b$ ou $2y$)."""
    return bool(senha_armazenada) and senha_armazenada.startswith(("$2b$", "$2a$", "$2y$"))

def gerar_hash_senha(senha: str) -> str:
    """Gera hash seguro bcrypt com salt aleatório e custo 12."""
    senha_bytes = senha.encode("utf-8")[:72]
    return bcrypt.hashpw(senha_bytes, bcrypt.gensalt(rounds=BCRYPT_ROUNDS)).decode("utf-8")

def verificar_senha(senha_fornecida: str, senha_armazenada: str) -> bool:
    """
    Compara a senha fornecida com o hash armazenado.
    Suporta bcrypt (padrão atual) e hashes legados (PBKDF2-HMAC-SHA256 e SHA-256 puro)
    para permitir migração transparente no login.
    """
    if not senha_fornecida or not senha_armazenada:
        return False
    if eh_hash_bcrypt(senha_armazenada):
        try:
            return bcrypt.checkpw(
                senha_fornecida.encode("utf-8")[:72],
                senha_armazenada.encode("utf-8"),
            )
        except (ValueError, TypeError):
            return False
    if senha_armazenada.startswith("pbkdf2_sha256$"):
        try:
            _, iteracoes_str, salt, hash_esperado = senha_armazenada.split("$", 3)
            calculado = hashlib.pbkdf2_hmac(
                "sha256",
                senha_fornecida.encode("utf-8"),
                bytes.fromhex(salt),
                int(iteracoes_str),
            ).hex()
            return hmac.compare_digest(calculado, hash_esperado)
        except (ValueError, TypeError):
            return False
    return hmac.compare_digest(
        hashlib.sha256(senha_fornecida.encode("utf-8")).hexdigest(),
        senha_armazenada,
    )

def gerar_token_acesso(id_usuario: int, login: str, perfil: str) -> str:
    """
    Gera um JWT assinado com jti (UUID único por emissão), identificação,
    perfil (RBAC) e expiração.
    O jti permite revogação individual do token no logout via blocklist.
    """
    agora = datetime.now(timezone.utc)
    payload = {
        "sub": str(id_usuario),
        "login": login,
        "perfil": (perfil or "").strip().upper(),
        "jti": secrets.token_urlsafe(32),   # ID único do token — usado na blocklist de logout
        "iat": agora,
        "exp": agora + timedelta(minutes=JWT_EXPIRE_MINUTES),
    }
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)

def decodificar_token_acesso(token: str) -> Dict[str, Any]:
    """Valida assinatura e expiração do JWT e retorna o payload (incluindo jti)."""
    try:
        payload = jwt.decode(
            token,
            JWT_SECRET_KEY,
            algorithms=[JWT_ALGORITHM],
            options={"require": ["sub", "exp", "jti"]},
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
