# ==============================================================================
# Dockerfile Unificado (Full-Stack) - Software Brava SAMU 192 Joinville
# Compila o Frontend (Flutter Web) e empacota junto com o Backend (FastAPI)
# em uma única imagem Docker pronta para execução.
#
# Como construir e rodar apenas no Docker:
#   docker build -t software-brava .
#   docker run -d --name software-brava -p 8080:8080 -p 8000:8000 software-brava
#
# Acessos:
#   - Aplicação Web (Painel Admin + Ficha APH): http://localhost:8080
#   - API FastAPI / Swagger Docs:               http://localhost:8000/docs
# ==============================================================================

# ------------------------------------------------------------------------------
# Etapa 1: Build do Frontend (Flutter Web)
# ------------------------------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS frontend-builder

WORKDIR /build/Frontend

# Copia arquivos de dependências do Flutter primeiro para aproveitar cache de camadas
COPY Frontend/pubspec.yaml Frontend/pubspec.lock ./
RUN flutter pub get

# Copia o restante do código-fonte do Frontend e compila para Web (Release)
COPY Frontend/ ./
ARG API_URL=SAME_ORIGIN
RUN flutter build web --release --pwa-strategy=none --dart-define=API_URL=${API_URL}

# ------------------------------------------------------------------------------
# Etapa 2: Imagem Final (Backend FastAPI + Nginx servindo Flutter Web)
# ------------------------------------------------------------------------------
FROM python:3.13-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_ENV=development \
    DATABASE_URL=sqlite:////app/data/brava.db \
    ADMIN_PASSWORD=admin123 \
    EQUIPE_PASSWORD=brava123 \
    SEED_TROCAR_SENHA=false \
    CORS_ORIGINS=http://localhost:8080,http://127.0.0.1:8080,http://localhost:8000,http://127.0.0.1:8000 \
    LOGIN_RATE_LIMIT=20/minute \
    HOST=0.0.0.0 \
    PORT=8000

WORKDIR /app

# Instala Nginx e biblioteca cliente do PostgreSQL (libpq5)
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf

# Instala dependências Python do Backend
COPY Backend/requirements.txt /app/Backend/requirements.txt
RUN pip install --no-cache-dir -r /app/Backend/requirements.txt

# Copia código do Backend
COPY Backend/ /app/Backend/

# Copia o bundle Web compilado do Flutter para o diretório do Nginx
COPY --from=frontend-builder /build/Frontend/build/web /usr/share/nginx/html

# Substitui o flutter_service_worker.js para limpar qualquer cache antigo do navegador automaticamente
RUN printf "self.addEventListener('install',function(e){self.skipWaiting();});self.addEventListener('activate',function(e){e.waitUntil(caches.keys().then(function(k){return Promise.all(k.map(function(n){return caches.delete(n);}));}).then(function(){return self.registration.unregister();}).then(function(){return self.clients.matchAll({type:'window'});}).then(function(c){c.forEach(function(w){if('navigate' in w){w.navigate(w.url);}});}));});\n" > /usr/share/nginx/html/flutter_service_worker.js

# Copia configuração do Nginx e script de inicialização
COPY docker/nginx.conf /etc/nginx/conf.d/software_brava.conf
COPY docker/entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh && mkdir -p /app/data

VOLUME ["/app/data"]

# 8080: Frontend Flutter Web + Proxy Reverso (/api, /docs)
# 8000: API FastAPI direta
EXPOSE 8080 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS http://127.0.0.1:8000/ > /dev/null && curl -fsS http://127.0.0.1:8080/ > /dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]

