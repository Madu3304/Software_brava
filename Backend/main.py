import os
import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import engine, Base, SessionLocal
from controllers import api_router
from seed import seed_initial_data

def init_db():
    """Cria tabelas no banco de dados e executa carga inicial de dados."""
    print("[DATABASE] Criando/verificando tabelas no banco de dados...")
    Base.metadata.create_all(bind=engine)
    print("[DATABASE] Tabelas verificadas com sucesso!")
    
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