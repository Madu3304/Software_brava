# Backend/seed.py
"""
Script de Carga Inicial de Dados (Seed Data)
Cadastra os usuários padrão (Administrador e Equipe de Campo, com senhas lidas do .env),
as 4 Unidades Móveis (Brava 1 a 4), Médicos Reguladores e Hospitais de Destino.
"""
import os
from dotenv import load_dotenv
from sqlalchemy.orm import Session
from database import SessionLocal, Base, engine
from models import Usuario, UnidadeMovel, Medico, Tecnico, Condutor, HospitalDestino, BaseOperacional
from services.security_service import gerar_hash_senha

load_dotenv()

def seed_initial_data(db: Session):
    """Popula o banco com os dados mínimos necessários caso estejam vazios."""
    print("[SEED] Verificando dados iniciais do sistema...")

    # 1. Usuários Padrão (RN01, RN13)
    # As senhas iniciais vêm do .env (ADMIN_PASSWORD e EQUIPE_PASSWORD) e nunca são exibidas nos logs.
    # Todos os usuários criados aqui precisam trocar a senha no primeiro acesso.
    senha_admin = os.getenv("ADMIN_PASSWORD")
    senha_equipe = os.getenv("EQUIPE_PASSWORD")

    usuarios_iniciais = [
        {
            "nome": "Administrador do Sistema",
            "email": "admin@joinville.sc.gov.br",
            "login": "admin",
            "senha": senha_admin,
            "variavel_senha": "ADMIN_PASSWORD",
            "perfil": "ADMINISTRADOR",
            "registro_profissional": "ADM-001",
        },
        {
            "nome": "Enf. Joaquim (Brava 2)",
            "email": "joaquim@samu.joinville.sc.gov.br",
            "login": "enfermeiro",
            "senha": senha_equipe,
            "variavel_senha": "EQUIPE_PASSWORD",
            "perfil": "ENFERMEIRO",
            "registro_profissional": "COREN-SC 102030",
        },
        {
            "nome": "Téc. Ana (Brava 2)",
            "email": "ana@samu.joinville.sc.gov.br",
            "login": "tecnico",
            "senha": senha_equipe,
            "variavel_senha": "EQUIPE_PASSWORD",
            "perfil": "TECNICO",
            "registro_profissional": "COREN-SC 203040",
        },
        {
            "nome": "Cond. Marcos (Brava 2)",
            "email": "marcos@samu.joinville.sc.gov.br",
            "login": "condutor",
            "senha": senha_equipe,
            "variavel_senha": "EQUIPE_PASSWORD",
            "perfil": "CONDUTOR",
            "registro_profissional": "CNH-D 405060",
        },
    ]

    for dados in usuarios_iniciais:
        if db.query(Usuario).filter(Usuario.login == dados["login"]).first():
            continue
        if not dados["senha"]:
            print(f"[SEED] AVISO: {dados['variavel_senha']} não configurada no .env. Usuário '{dados['login']}' não foi criado.")
            continue
        print(f"[SEED] Criando usuário {dados['perfil']} (login: {dados['login']}) com troca de senha obrigatória no primeiro acesso...")
        db.add(Usuario(
            nome=dados["nome"],
            email=dados["email"],
            login=dados["login"],
            senha_hash=gerar_hash_senha(dados["senha"]),
            perfil=dados["perfil"],
            registro_profissional=dados["registro_profissional"],
            ativo=True,
            trocar_senha=True,
        ))

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
