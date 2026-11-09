#!/bin/sh
set -e

mkdir -p /app/data

echo "[DOCKER] Iniciando Frontend Flutter Web (Nginx) na porta 8080..."
nginx

echo "[DOCKER] Iniciando Backend FastAPI (Software Brava SAMU) na porta ${PORT:-8000}..."
cd /app/Backend
exec uvicorn main:app --host 0.0.0.0 --port "${PORT:-8000}" --proxy-headers
