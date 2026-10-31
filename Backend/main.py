import os
import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import inspect, text

from database import engine, Base, SessionLocal
from controllers import api_router
from rate_limit import limiter, tratar_limite_excedido
from slowapi.errors import RateLimitExceeded
from seed import seed_initial_data

# Ambiente de execução: a carga inicial de dados (seed) só roda em desenvolvimento
APP_ENV = os.getenv("APP_ENV", "production").strip().lower()

def ajustar_colunas_novas():
    """
    Adiciona em bancos já existentes as colunas criadas depois da primeira versão
    (create_all não altera tabelas existentes). Usuários antigos ficam com troca de senha obrigatória.
    """
    colunas_usuario = {c["name"] for c in inspect(engine).get_columns("usuario")}
    if "trocar_senha" not in colunas_usuario:
        print("[DATABASE] Adicionando coluna usuario.trocar_senha...")
        with engine.begin() as conn:
            conn.execute(text("ALTER TABLE usuario ADD COLUMN trocar_senha BOOLEAN NOT NULL DEFAULT TRUE"))

def init_db():
    """Cria tabelas no banco de dados e executa carga inicial de dados (somente em desenvolvimento)."""
    print("[DATABASE] Criando/verificando tabelas no banco de dados...")
    Base.metadata.create_all(bind=engine)
    ajustar_colunas_novas()
    print("[DATABASE] Tabelas verificadas com sucesso!")

    if APP_ENV != "development":
        print(f"[SEED] Ambiente '{APP_ENV}': carga inicial de dados ignorada (defina APP_ENV=development para executar).")
        return

    db = SessionLocal()
    try:
        seed_initial_data(db)
    except Exception as e:
        print(f"[ERRO NO SEED] {e}")
    finally:
        db.close()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Executado automaticamente no startup do servidor (uvicorn main:app)
    init_db()
    yield
    print("[SHUTDOWN] Encerrando servidor da API...")

app = FastAPI(
    title="API Backend SAMU Brava (Joinville)",
    description="API RESTful de comunicação segura entre o Aplicativo Mobile e o Dashboard Web Administrativo, conforme especificação RFC e Diagramas C4 (Níveis 2, 3 e 4).",
    version="1.0.0",
    lifespan=lifespan,
)

# Configuração de CORS: somente as origens listadas em CORS_ORIGINS (.env) podem chamar a API pelo navegador.
# O App Mobile não é afetado (CORS só vale para navegadores, ex.: Flutter Web / Painel Administrativo).
CORS_ORIGINS = [origem.strip().rstrip("/") for origem in os.getenv("CORS_ORIGINS", "").split(",") if origem.strip()]

if not CORS_ORIGINS:
    print("[CORS] CORS_ORIGINS não configurada: nenhuma origem web liberada.")
elif "*" in CORS_ORIGINS:
    print("[CORS] AVISO: CORS_ORIGINS='*' libera qualquer origem. Use apenas em desenvolvimento.")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    # Credenciais (cookies/Authorization automático) nunca são combinadas com '*'
    allow_credentials="*" not in CORS_ORIGINS,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)

# Limite de tentativas nas rotas de autenticação (rate_limit.py)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, tratar_limite_excedido)

# Registra todos os módulos de controllers da aplicação sob o prefixo /api
app.include_router(api_router)

@app.get("/", tags=["Saúde da API"])
def root():
    return {
        "status": "ONLINE",
        "sistema": "Software Brava SAMU",
        "documentacao": "/docs",
        "versao": "1.0.0"
    }

def variavel_booleana(nome: str, padrao: bool = False) -> bool:
    """Lê uma variável de ambiente como booleano (true/1/sim/yes/on)."""
    valor = os.getenv(nome)
    if valor is None:
        return padrao
    return valor.strip().lower() in ("true", "1", "sim", "yes", "on")

if __name__ == "__main__":
    # DEBUG=true: recarrega o servidor ao salvar arquivos (somente desenvolvimento)
    debug = variavel_booleana("DEBUG")
    # Padrão 127.0.0.1: só aceita conexões da própria máquina.
    # Use HOST=0.0.0.0 para aceitar conexões da rede (ex.: testar no tablet ou em produção atrás de proxy).
    host = os.getenv("HOST", "127.0.0.1")
    port = int(os.getenv("PORT", 8000))
    print(f"\n[INFO] Iniciando servidor FastAPI em http://{host}:{port} (DEBUG={'ativo' if debug else 'desativado'}) ...")
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug,
        log_level="debug" if debug else "info",
    )