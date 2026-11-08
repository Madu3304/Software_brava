# Backend/rate_limit.py

import os
import logging

from fastapi import Request
from fastapi.responses import JSONResponse
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

logger = logging.getLogger("RateLimit")

LOGIN_RATE_LIMIT = os.getenv("LOGIN_RATE_LIMIT", "5/minute")

# Contadores em memória: valem por processo do servidor (com vários workers, use um storage como Redis)
limiter = Limiter(key_func=get_remote_address)

# Limite compartilhado para login (/login e /token) e escopo separado para /trocar-senha
limite_autenticacao = limiter.shared_limit(LOGIN_RATE_LIMIT, scope="autenticacao")
limite_trocar_senha = limiter.shared_limit(LOGIN_RATE_LIMIT, scope="trocar_senha")

def tratar_limite_excedido(request: Request, exc: RateLimitExceeded) -> JSONResponse:
    """Resposta 429 padronizada quando o limite de tentativas é excedido."""
    ip_origem = request.client.host if request.client else None
    logger.warning(f"Limite de tentativas excedido em {request.url.path} | IP: {ip_origem} | Limite: {exc.detail}")
    return JSONResponse(
        status_code=429,
        content={"detail": "Muitas tentativas. Aguarde alguns instantes e tente novamente."},
        headers={"Retry-After": "60"},
    )
