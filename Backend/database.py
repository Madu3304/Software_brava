from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# URL de conexão com o PostgreSQL
# Observação: Se a senha contiver caracteres especiais como '$', usamos a codificação %24 ou URL encoding
DATABASE_URL = "postgresql+psycopg2://postgres:Bolo%24369@localhost:5432/Brava"

engine = create_engine(DATABASE_URL, echo=True)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    """Função utilitária para obter sessão do banco de dados (Dependency Injection no FastAPI)"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
