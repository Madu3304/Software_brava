# ==============================================================================
# Dockerfile do Backend (FastAPI + SQLAlchemy)
# ==============================================================================
FROM python:3.13-slim

# Variáveis de runtime — sem segredos nas camadas da imagem.
# Credenciais (ADMIN_PASSWORD, EQUIPE_PASSWORD, JWT_SECRET_KEY, CPF_HMAC_KEY)
# devem ser injetadas exclusivamente via variável de ambiente em runtime:
#   docker run -e ADMIN_PASSWORD=... ou via Docker Compose secrets.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOST=0.0.0.0 \
    PORT=8000

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Cria usuário não-privilegiado para executar a aplicação.
# Rodar como root em container amplia o impacto de qualquer RCE explorada —
# um processo sem root não consegue escalar privilégios no host tão facilmente.
RUN groupadd --system appgroup \
 && useradd  --system --gid appgroup --no-create-home appuser \
 && mkdir -p /app/data \
 && chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS http://127.0.0.1:8000/ || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
