import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# Carrega variáveis do arquivo .env caso exista
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

# Fallback para desenvolvimento local caso DATABASE_URL não seja informada
if not DATABASE_URL:
    DATABASE_URL = "sqlite:///./brava.db"
    print("[INFO] DATABASE_URL não configurada. Utilizando fallback local SQLite: sqlite:///./brava.db")

connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(DATABASE_URL, connect_args=connect_args, echo=False)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

Base = declarative_base()


def get_db():
    """Obtém uma sessão do banco de dados."""
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()