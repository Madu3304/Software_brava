#!/bin/sh
set -e

PG_USER="${POSTGRES_USER:-postgres}"
PG_PASS="${POSTGRES_PASSWORD:-postgres}"
PG_DB="${POSTGRES_DB:-brava}"
PG_DATA="${PGDATA:-/var/lib/postgresql/data}"
PG_BIN="$(ls -d /usr/lib/postgresql/*/bin | head -n 1)"

mkdir -p /app/data "$PG_DATA" /var/run/postgresql /var/log/postgresql
chown -R postgres:postgres /var/lib/postgresql /var/run/postgresql /var/log/postgresql
chmod 700 "$PG_DATA"

FIRST_INIT=0
if [ ! -f "$PG_DATA/PG_VERSION" ]; then
    FIRST_INIT=1
    echo "[DOCKER] Inicializando cluster PostgreSQL em $PG_DATA..."
    printf '%s\n' "$PG_PASS" > /tmp/pgpass
    chown postgres:postgres /tmp/pgpass
    chmod 600 /tmp/pgpass
    su - postgres -c "$PG_BIN/initdb -D '$PG_DATA' --username='$PG_USER' --encoding=UTF8 --auth-local=trust --auth-host=scram-sha-256 --pwfile=/tmp/pgpass"
    rm -f /tmp/pgpass

    echo "listen_addresses = '*'" >> "$PG_DATA/postgresql.conf"
    {
        echo "host all all 0.0.0.0/0 scram-sha-256"
        echo "host all all ::/0 scram-sha-256"
    } >> "$PG_DATA/pg_hba.conf"
fi

echo "[DOCKER] Iniciando PostgreSQL na porta 5432..."
if ! su - postgres -c "$PG_BIN/pg_ctl -D '$PG_DATA' status" > /dev/null 2>&1; then
    rm -f "$PG_DATA/postmaster.pid"
    su - postgres -c "$PG_BIN/pg_ctl -D '$PG_DATA' -l /var/log/postgresql/postgresql.log -o '-k /var/run/postgresql' start"
fi

until pg_isready -h 127.0.0.1 -p 5432 -U "$PG_USER" > /dev/null 2>&1; do
    sleep 1
done

if [ "$FIRST_INIT" -eq 1 ]; then
    echo "[DOCKER] Criando banco de dados '$PG_DB' e aplicando init_brava.sql..."
    export PGPASSWORD="$PG_PASS"
    psql -h 127.0.0.1 -U "$PG_USER" -d postgres -c "CREATE DATABASE \"$PG_DB\";"
    if [ -f /docker-entrypoint-initdb.d/01_init_brava.sql ]; then
        psql -h 127.0.0.1 -U "$PG_USER" -d "$PG_DB" -f /docker-entrypoint-initdb.d/01_init_brava.sql
    fi
    unset PGPASSWORD
fi

echo "[DOCKER] Iniciando Frontend Flutter Web (Nginx) na porta 8080..."
nginx

echo "[DOCKER] Iniciando Backend FastAPI (Software Brava SAMU) na porta ${PORT:-8000}..."
cd /app/Backend
if [ "${APP_ENV:-development}" = "development" ]; then
    exec uvicorn main:app --host 0.0.0.0 --port "${PORT:-8000}" --proxy-headers --reload
else
    exec uvicorn main:app --host 0.0.0.0 --port "${PORT:-8000}" --proxy-headers
fi
