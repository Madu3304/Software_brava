from database import engine, Base, SessionLocal
from models import Usuario, UnidadeMovel, Paciente, HospitalDestino, FichaAtendimento, AvaliacaoClinica, LogAuditoria

def init_db():
    print("Criando/verificando tabelas no banco de dados via SQLAlchemy ORM...")
    # Cria todas as tabelas no PostgreSQL caso não existam
    Base.metadata.create_all(bind=engine)
    print("Tabelas criadas com sucesso!")

def testar_conexao():
    db = SessionLocal()
    try:
        print("\n--- Testando consulta SQLAlchemy ---")
        usuarios = db.query(Usuario).all()
        print(f"Total de usuários cadastrados: {len(usuarios)}")
        for u in usuarios:
            print(f"ID: {u.id_usuario} | Nome: {u.nome} | Perfil: {u.perfil}")
            
        unidades = db.query(UnidadeMovel).all()
        print(f"Total de unidades móveis: {len(unidades)}")
    except Exception as e:
        print(f"Erro ao consultar o banco: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    init_db()
    testar_conexao()