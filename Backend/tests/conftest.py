import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from fastapi.testclient import TestClient

from database import Base, get_db
from main import app
from models import Usuario, UnidadeMovel, Medico, Tecnico, Condutor, HospitalDestino, BaseOperacional
from services.security_service import gerar_hash_senha, gerar_token_acesso

SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine_test = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine_test)

@pytest.fixture(scope="session", autouse=True)
def setup_database():
    """Cria o esquema completo das tabelas no banco de memória."""
    Base.metadata.create_all(bind=engine_test)
    yield
    Base.metadata.drop_all(bind=engine_test)

@pytest.fixture
def db_session():
    """Fornece uma sessão transacional limpa e realiza rollback ao término de cada teste."""
    connection = engine_test.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)

    yield session

    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture
def client(db_session):
    """Configura o TestClient da aplicação com override de get_db."""
    def _override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = _override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()

@pytest.fixture
def seed_dados_basicos(db_session):
    """Cria entidades essenciais para o fluxo de atendimento."""
    # Usuário Admin
    admin = Usuario(
        nome="Administrador Geral",
        email="admin.teste@samu.joinville.sc.gov.br",
        login="admin_teste",
        senha_hash=gerar_hash_senha("SenhaAdmin#1"),
        perfil="ADMINISTRADOR",
        ativo=True,
        trocar_senha=False,
    )
    # Usuário Enfermeiro
    enfermeiro = Usuario(
        nome="Enfermeiro Teste",
        email="enfermeiro.teste@samu.joinville.sc.gov.br",
        login="enf_teste",
        senha_hash=gerar_hash_senha("SenhaEnf#1"),
        perfil="ENFERMEIRO",
        registro_profissional="COREN-SC 123456",
        ativo=True,
        trocar_senha=False,
    )
    # Usuário Técnico
    tecnico_user = Usuario(
        nome="Técnico Teste",
        email="tecnico.teste@samu.joinville.sc.gov.br",
        login="tec_teste",
        senha_hash=gerar_hash_senha("SenhaTec#1"),
        perfil="TECNICO",
        registro_profissional="COREN-SC 654321",
        ativo=True,
        trocar_senha=False,
    )
    # Usuário a ser deletado (soft delete)
    usuario_deletavel = Usuario(
        nome="Usuário Desativável",
        email="desativar@samu.joinville.sc.gov.br",
        login="user_desativar",
        senha_hash=gerar_hash_senha("SenhaTemp#1"),
        perfil="TECNICO",
        ativo=True,
        trocar_senha=False,
    )

    # Entidades de apoio
    unidade = UnidadeMovel(placa="BRA-0101", base_unidade="Brava 1", status="DISPONIVEL")
    medico = Medico(nome="Dr. Roberto Silva", codigo_medico=12345)
    condutor = Condutor(nome="Marcos Aurélio", codigo_condutor=405060)
    tecnico = Tecnico(nome="Ana Paula", codigo_tecnico=203040)
    base = BaseOperacional(nome="Base Central SAMU", endereco="Rua XV de Novembro", bairro="Centro")
    hospital = HospitalDestino(nome="Hospital Municipal São José")

    db_session.add_all([
        admin, enfermeiro, tecnico_user, usuario_deletavel,
        unidade, medico, condutor, tecnico, base, hospital
    ])
    db_session.commit()

    return {
        "admin": admin,
        "enfermeiro": enfermeiro,
        "tecnico_user": tecnico_user,
        "usuario_deletavel": usuario_deletavel,
        "unidade": unidade,
        "medico": medico,
        "condutor": condutor,
        "tecnico": tecnico,
        "base": base,
        "hospital": hospital,
    }

@pytest.fixture
def headers_admin(seed_dados_basicos):
    admin = seed_dados_basicos["admin"]
    token = gerar_token_acesso(id_usuario=admin.id_usuario, login=admin.login, perfil=admin.perfil)
    return {"Authorization": f"Bearer {token}"}

@pytest.fixture
def headers_enfermeiro(seed_dados_basicos):
    enf = seed_dados_basicos["enfermeiro"]
    token = gerar_token_acesso(id_usuario=enf.id_usuario, login=enf.login, perfil=enf.perfil)
    return {"Authorization": f"Bearer {token}"}
