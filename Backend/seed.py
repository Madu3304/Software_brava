# Backend/seed.py
"""
Script de Carga Inicial de Dados (Seed Data)
Cadastra os usuários padrão (Administrador e Equipe de Campo),
as 4 Unidades Móveis (Brava 1 a 4), Médicos Reguladores e Hospitais de Destino.
"""
from sqlalchemy.orm import Session
from database import SessionLocal, Base, engine
from models import Usuario, UnidadeMovel, Medico, Tecnico, Condutor, HospitalDestino, BaseOperacional
from services.security_service import gerar_hash_senha

def seed_initial_data(db: Session):
    """Popula o banco com os dados mínimos necessários caso estejam vazios."""
    print("[SEED] Verificando dados iniciais do sistema...")

    # 1. Usuários Padrão (RN01, RN13)
    admin = db.query(Usuario).filter(Usuario.login == "admin").first()
    if not admin:
        print("[SEED] Criando usuário Administrador (login: admin, senha: admin123)...")
        admin = Usuario(
            nome="Administrador do Sistema",
            email="admin@joinville.sc.gov.br",
            login="admin",
            senha_hash=gerar_hash_senha("admin123"),
            perfil="ADMINISTRADOR",
            registro_profissional="ADM-001",
            ativo=True,
        )
        db.add(admin)

    enfermeiro = db.query(Usuario).filter(Usuario.login == "enfermeiro").first()
    if not enfermeiro:
        print("[SEED] Criando usuário Enfermeiro (login: enfermeiro, senha: brava123)...")
        enfermeiro = Usuario(
            nome="Enf. Joaquim (Brava 2)",
            email="joaquim@samu.joinville.sc.gov.br",
            login="enfermeiro",
            senha_hash=gerar_hash_senha("brava123"),
            perfil="ENFERMEIRO",
            registro_profissional="COREN-SC 102030",
            ativo=True,
        )
        db.add(enfermeiro)

    tecnico_usr = db.query(Usuario).filter(Usuario.login == "tecnico").first()
    if not tecnico_usr:
        print("[SEED] Criando usuário Técnico (login: tecnico, senha: brava123)...")
        tecnico_usr = Usuario(
            nome="Téc. Ana (Brava 2)",
            email="ana@samu.joinville.sc.gov.br",
            login="tecnico",
            senha_hash=gerar_hash_senha("brava123"),
            perfil="TECNICO",
            registro_profissional="COREN-SC 203040",
            ativo=True,
        )
        db.add(tecnico_usr)

    condutor_usr = db.query(Usuario).filter(Usuario.login == "condutor").first()
    if not condutor_usr:
        print("[SEED] Criando usuário Condutor Socorrista (login: condutor, senha: brava123)...")
        condutor_usr = Usuario(
            nome="Cond. Marcos (Brava 2)",
            email="marcos@samu.joinville.sc.gov.br",
            login="condutor",
            senha_hash=gerar_hash_senha("brava123"),
            perfil="CONDUTOR",
            registro_profissional="CNH-D 405060",
            ativo=True,
        )
        db.add(condutor_usr)

    # 2. Unidades Móveis (As 4 Bravas do SAMU de Joinville - RF10, RF12)
    bravas = [
        ("BRA-0101", "Brava 1", "DISPONIVEL"),
        ("BRA-0202", "Brava 2", "DISPONIVEL"),
        ("BRA-0303", "Brava 3", "DISPONIVEL"),
        ("BRA-0404", "Brava 4", "DISPONIVEL"),
    ]
    for placa, base_nome, status in bravas:
        u_existente = db.query(UnidadeMovel).filter(UnidadeMovel.base_unidade == base_nome).first()
        if not u_existente:
            print(f"[SEED] Criando Unidade Móvel: {base_nome} ({placa})...")
            db.add(UnidadeMovel(placa=placa, base_unidade=base_nome, status=status))

    # 3. Médicos Reguladores de Plantão (RN11, RN12)
    medicos_iniciais = [
        ("Dr. Roberto Silva (Médico Regulador)", 12345),
        ("Dra. Juliana Mendes (Médica Reguladora)", 23456),
    ]
    for nome, crm in medicos_iniciais:
        med_existente = db.query(Medico).filter(Medico.codigo_medico == crm).first()
        if not med_existente:
            print(f"[SEED] Cadastrando Médico: {nome}...")
            db.add(Medico(nome=nome, codigo_medico=crm))

    # 4. Técnicos cadastrados na tabela técnico
    tec_cadastrado = db.query(Tecnico).filter(Tecnico.codigo_medico == 203040).first()
    if not tec_cadastrado:
        db.add(Tecnico(nome="Ana Paula - Técnica de Enfermagem", codigo_medico=203040))

    # 5. Condutores cadastrados na tabela condutor
    cond_cadastrado = db.query(Condutor).filter(Condutor.codigo_condutor == 405060).first()
    if not cond_cadastrado:
        db.add(Condutor(nome="Marcos Aurélio - Condutor Socorrista", codigo_condutor=405060))

    # 6. Hospitais de Destino (C4 Nível 1/2)
    hospitais = [
        ("Hospital Municipal São José", "Av. Getúlio Vargas, 238 - Anita Garibaldi"),
        ("Hospital Regional Hans Dieter Schmidt", "R. Paulo Schroeder, 1150 - Boa Vista"),
        ("UPA 24h Leste", "R. Mafra, 120 - Aventureiro"),
    ]
    for nome, endereco in hospitais:
        hosp_existente = db.query(HospitalDestino).filter(HospitalDestino.nome == nome).first()
        if not hosp_existente:
            print(f"[SEED] Cadastrando Hospital de Destino: {nome}...")
            db.add(HospitalDestino(nome=nome, endereco=endereco))

    db.commit()
    print("[SEED] Carga inicial de dados finalizada com sucesso!")

if __name__ == "__main__":
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_initial_data(db)
    finally:
        db.close()
