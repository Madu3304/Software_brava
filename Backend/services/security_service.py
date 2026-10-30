# Backend/services/security_service.py
"""
Módulo de Segurança e Autenticação (Modelo C4 - Níveis 3 e 4)
Componente: Security Service
Responsabilidade: Criptografia de senhas, validação de tokens e controle de acesso RBAC.
"""
import hashlib
import hmac
import secrets
from typing import Optional, Dict, Any
from datetime import datetime, timedelta

# Configurações de expiração de sessão
SESSION_EXPIRE_HOURS = 24

def gerar_hash_senha(senha: str) -> str:
    """Gera hash seguro SHA-256 para senhas."""
    return hashlib.sha256(senha.encode("utf-8")).hexdigest()

def verificar_senha(senha_fornecida: str, senha_armazenada: str) -> bool:
    """
    Compara o hash da senha fornecida com o hash armazenado.
    Nunca compara a senha fornecida diretamente com o valor do banco: isso permitiria
    logar usando o próprio hash como senha. A comparação usa tempo constante (hmac).
    """
    if not senha_fornecida or not senha_armazenada:
        return False
    return hmac.compare_digest(gerar_hash_senha(senha_fornecida), senha_armazenada)

def gerar_token_acesso(id_usuario: int, login: str, perfil: str) -> str:
    """Gera um token criptográfico único para controle de sessão."""
    token_random = secrets.token_urlsafe(32)
    return f"jwt_{token_random}"

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
