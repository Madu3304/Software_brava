import os
import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import inspect, text

from database import engine, Base, SessionLocal
from controllers import api_router
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

# Configuração de CORS para permitir acesso do Flutter Web e Mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

if __name__ == "__main__":
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    print(f"\n[INFO] Iniciando servidor FastAPI em http://{host}:{port} ...")
    uvicorn.run("main:app", host=host, port=port, reload=True)