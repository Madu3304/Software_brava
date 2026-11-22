# Backend/seed.py

import os
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
from dotenv import load_dotenv
from sqlalchemy.orm import Session
from database import SessionLocal, Base, engine
from models import (
    Usuario,
    UnidadeMovel,
    Medico,
    Tecnico,
    Condutor,
    HospitalDestino,
    BaseOperacional,
    Paciente,
    FichaAtendimento,
    AvaliacaoClinica,
    Utensilios,
)
from models.paciente import pseudonimizar_cpf
from services.security_service import gerar_hash_senha

load_dotenv()


def _agora_sp() -> datetime:
    try:
        fuso_sp = ZoneInfo("America/Sao_Paulo")
    except Exception:
        fuso_sp = timezone(timedelta(hours=-3))
    return datetime.now(fuso_sp)


def _seed_usuarios(db: Session) -> list[Usuario]:
    senha_admin = os.getenv("ADMIN_PASSWORD")
    senha_equipe = os.getenv("EQUIPE_PASSWORD")
    exigir_troca_senha = os.getenv("SEED_TROCAR_SENHA", "true").strip().lower() in (
        "true", "1", "sim", "yes", "on"
    )

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
        print(f"[SEED] Criando usuário {dados['perfil']} (login: {dados['login']})...")
        db.add(Usuario(
            nome=dados["nome"],
            email=dados["email"],
            login=dados["login"],
            senha_hash=gerar_hash_senha(dados["senha"]),
            perfil=dados["perfil"],
            registro_profissional=dados["registro_profissional"],
            ativo=True,
            trocar_senha=exigir_troca_senha,
        ))

    db.flush()
    return db.query(Usuario).all()


def _seed_bases_e_unidades(db: Session) -> tuple[list[BaseOperacional], list[UnidadeMovel]]:
    bases_iniciais = [
        ("Base Central SAMU", "Rua Plácido Olímpio de Oliveira, 148", "Centro", "(47) 3481-5192"),
        ("Base Norte - Aventureiro", "Rua Tuiuti, 2100", "Aventureiro", "(47) 3481-5193"),
        ("Base Sul - Floresta", "Rua Santa Catarina, 1850", "Floresta", "(47) 3481-5194"),
        ("Base Leste - Boa Vista", "Rua Prefeito Helmuth Fallgatter, 920", "Boa Vista", "(47) 3481-5195"),
    ]
    for nome, endereco, bairro, telefone in bases_iniciais:
        if not db.query(BaseOperacional).filter(BaseOperacional.nome == nome).first():
            db.add(BaseOperacional(
                nome=nome,
                endereco=endereco,
                bairro=bairro,
                telefone=telefone,
                ativo=True,
            ))

    bravas = [
        ("USB-01", "BRA-0101", "USB (Suporte Básico)", "Brava 1", "DISPONIVEL", None),
        ("USB-02", "BRA-0202", "USB (Suporte Básico)", "Brava 2", "EM_ATENDIMENTO", None),
        ("USA-01", "BRA-0303", "USA (Suporte Avançado)", "Brava 3", "DISPONIVEL", None),
        ("USB-04", "BRA-0404", "USB (Suporte Básico)", "Brava 4", "PARADA", "Manutenção preventiva do sistema de freios"),
    ]
    for codigo, placa, tipo, base_nome, status, motivo_parada in bravas:
        u_existente = db.query(UnidadeMovel).filter(UnidadeMovel.base_unidade == base_nome).first()
        if not u_existente:
            print(f"[SEED] Criando Unidade Móvel: {base_nome} ({placa})...")
            db.add(UnidadeMovel(
                codigo=codigo,
                placa=placa,
                tipo=tipo,
                base_unidade=base_nome,
                status=status,
                motivo_parada=motivo_parada,
            ))
        else:
            if not u_existente.codigo:
                u_existente.codigo = codigo
            if not u_existente.tipo:
                u_existente.tipo = tipo

    db.flush()
    return db.query(BaseOperacional).all(), db.query(UnidadeMovel).all()


def _seed_profissionais(db: Session) -> tuple[list[Medico], list[Tecnico], list[Condutor]]:
    medicos_iniciais = [
        ("Dr. Roberto Silva", 12345, "111.222.333-01", "CRM-SC 12345", "Brava 1", "MED-001", "Médico Regulador", "Disponível"),
        ("Dra. Juliana Mendes", 23456, "111.222.333-02", "CRM-SC 23456", "Brava 3", "MED-002", "Médica Reguladora", "Disponível"),
        ("Dr. Carlos Eduardo Nogueira", 34567, "111.222.333-03", "CRM-SC 34567", "Brava 3", "MED-003", "Médico Intervencionista", "Em Atendimento"),
        ("Dra. Fernanda Alencar", 45678, "111.222.333-04", "CRM-SC 45678", "Brava 1", "MED-004", "Médica Intervencionista", "Disponível"),
        ("Dr. Henrique Vasconcelos", 56789, "111.222.333-05", "CRM-SC 56789", "Brava 2", "MED-005", "Médico Regulador", "Disponível"),
    ]
    for nome, crm, cpf, conselho, unidade, matricula, cargo, status in medicos_iniciais:
        med = db.query(Medico).filter(Medico.codigo_medico == crm).first()
        if not med:
            print(f"[SEED] Cadastrando Médico: {nome}...")
            db.add(Medico(
                nome=nome,
                codigo_medico=crm,
                cpf=cpf,
                registro_conselho=conselho,
                unidade=unidade,
                matricula=matricula,
                cargo=cargo,
                status=status,
            ))
        else:
            med.cpf = med.cpf or cpf
            med.registro_conselho = med.registro_conselho or conselho
            med.unidade = med.unidade or unidade
            med.matricula = med.matricula or matricula
            med.cargo = med.cargo or cargo
            med.status = med.status or status

    tecnicos_iniciais = [
        ("Téc. Ana Paula Oliveira", 203040, "222.333.444-01", "COREN-SC 203040", "Brava 2", "ENF-001", "Técnica de Enfermagem", "Disponível"),
        ("Enf. Joaquim Ferreira", 102030, "222.333.444-02", "COREN-SC 102030", "Brava 2", "ENF-002", "Enfermeiro Assistencial", "Em Atendimento"),
        ("Enf. Camila Duarte", 304050, "222.333.444-03", "COREN-SC 304050", "Brava 3", "ENF-003", "Enfermeira Intervencionista", "Disponível"),
        ("Téc. Bruno Henrique Costa", 405070, "222.333.444-04", "COREN-SC 405070", "Brava 1", "ENF-004", "Técnico de Enfermagem", "Disponível"),
        ("Téc. Larissa Martins", 506080, "222.333.444-05", "COREN-SC 506080", "Brava 4", "ENF-005", "Técnica de Enfermagem", "Disponível"),
    ]
    for nome, cod, cpf, conselho, unidade, matricula, cargo, status in tecnicos_iniciais:
        tec = db.query(Tecnico).filter(Tecnico.codigo_tecnico == cod).first()
        if not tec:
            print(f"[SEED] Cadastrando Enfermeiro/Técnico: {nome}...")
            db.add(Tecnico(
                nome=nome,
                codigo_tecnico=cod,
                cpf=cpf,
                registro_conselho=conselho,
                unidade=unidade,
                matricula=matricula,
                cargo=cargo,
                status=status,
            ))
        else:
            tec.cpf = tec.cpf or cpf
            tec.registro_conselho = tec.registro_conselho or conselho
            tec.unidade = tec.unidade or unidade
            tec.matricula = tec.matricula or matricula
            tec.cargo = tec.cargo or cargo
            tec.status = tec.status or status

    condutores_iniciais = [
        ("Marcos Aurélio Santos", 405060, "333.444.555-01", "CNH-D 405060", "Brava 2", "SOC-001", "Condutor Socorrista", "Em Atendimento"),
        ("Rafael Oliveira Lima", 405061, "333.444.555-02", "CNH-D 405061", "Brava 1", "SOC-002", "Motorista Socorrista", "Disponível"),
        ("Tiago Pereira Souza", 405062, "333.444.555-03", "CNH-E 405062", "Brava 3", "SOC-003", "Condutor Socorrista", "Disponível"),
        ("Diego Almeida Rocha", 405063, "333.444.555-04", "CNH-D 405063", "Brava 4", "SOC-004", "Motorista Socorrista", "Disponível"),
        ("Lucas Gabriel Mendes", 405064, "333.444.555-05", "CNH-D 405064", "Brava 1", "SOC-005", "Condutor Socorrista", "Disponível"),
    ]
    for nome, cod, cpf, conselho, unidade, matricula, cargo, status in condutores_iniciais:
        cond = db.query(Condutor).filter(Condutor.codigo_condutor == cod).first()
        if not cond:
            print(f"[SEED] Cadastrando Condutor/Socorrista: {nome}...")
            db.add(Condutor(
                nome=nome,
                codigo_condutor=cod,
                cpf=cpf,
                registro_conselho=conselho,
                unidade=unidade,
                matricula=matricula,
                cargo=cargo,
                status=status,
            ))
        else:
            cond.cpf = cond.cpf or cpf
            cond.registro_conselho = cond.registro_conselho or conselho
            cond.unidade = cond.unidade or unidade
            cond.matricula = cond.matricula or matricula
            cond.cargo = cond.cargo or cargo
            cond.status = cond.status or status

    db.flush()
    return db.query(Medico).all(), db.query(Tecnico).all(), db.query(Condutor).all()


def _seed_hospitais(db: Session) -> list[HospitalDestino]:
    hospitais = [
        ("Hospital Municipal São José", "Av. Getúlio Vargas, 238 - Anita Garibaldi"),
        ("Hospital Regional Hans Dieter Schmidt", "R. Paulo Schroeder, 1150 - Boa Vista"),
        ("UPA 24h Leste", "R. Mafra, 120 - Aventureiro"),
    ]
    for nome, endereco in hospitais:
        if not db.query(HospitalDestino).filter(HospitalDestino.nome == nome).first():
            print(f"[SEED] Cadastrando Hospital de Destino: {nome}...")
            db.add(HospitalDestino(nome=nome, endereco=endereco))
    db.flush()
    return db.query(HospitalDestino).all()


def _seed_fichas_sinteticas(
    db: Session,
    usuarios: list[Usuario],
    bases: list[BaseOperacional],
    unidades: list[UnidadeMovel],
    medicos: list[Medico],
    tecnicos: list[Tecnico],
    condutores: list[Condutor],
    hospitais: list[HospitalDestino],
) -> None:
    if db.query(FichaAtendimento).count() > 0:
        return
    if not usuarios or not unidades:
        return

    print("[SEED] Gerando atendimentos sintéticos para o Dashboard...")
    agora = _agora_sp()
    responsavel = next((u for u in usuarios if u.login != "admin"), usuarios[0])

    cenarios = [
        ("João Pedro Almeida", 8, "M", "11122233344", "Centro", "Rua do Príncipe", "310", 0, 8, "Vermelho", False, True, False),
        ("Maria Clara Souza", 15, "F", "22233344455", "Aventureiro", "Rua Tuiuti", "1450", 0, 11, "Amarelo", False, True, True),
        ("José Antônio Ribeiro", 72, "M", "33344455566", "Boa Vista", "Rua Prefeito Helmuth Fallgatter", "540", 0, 9, "Vermelho", False, False, True),
        ("Ana Beatriz Costa", 29, "F", "44455566677", "Costa e Silva", "Rua Otto Pfuetzenreuter", "820", 0, 12, "Verde", False, True, False),
        ("Sebastião Ferreira", 67, "M", "55566677788", "Centro", "Av. Juscelino Kubitschek", "410", 1, 10, "Vermelho", False, True, True),
        ("Helena Maria Santos", 81, "F", "66677788899", "Anita Garibaldi", "Av. Getúlio Vargas", "900", 1, 14, "Amarelo", True, False, True),
        ("Lucas Gabriel Pereira", 24, "M", "77788899900", "Aventureiro", "Rua Dilma Virgilina Garcia", "215", 2, 7, "Vermelho", False, True, False),
        ("Patrícia Oliveira", 34, "F", "88899900011", "Bucarein", "Rua São Paulo", "1120", 2, 13, "Amarelo", False, True, False),
        ("Miguel Henrique Rocha", 6, "M", "99900011122", "Centro", "Rua Nove de Março", "640", 3, 9, "Amarelo", False, False, True),
        ("Cláudia Regina Lima", 45, "F", "12312312399", "Boa Vista", "Rua Aubé", "380", 4, 15, "Verde", False, True, False),
        ("Geraldo Nascimento", 76, "M", "23423423488", "Costa e Silva", "Rua Rui Barbosa", "770", 5, 11, "Vermelho", False, True, True),
        ("Fernanda Beatriz Dias", 16, "F", "34534534577", "Aventureiro", "Rua Almirante Jaceguay", "190", 6, 10, "Verde", False, False, False),
        ("Roberto Carlos Moura", 52, "M", "45645645666", "Anita Garibaldi", "Rua Ottokar Doerffel", "512", 7, 16, "Amarelo", False, True, True),
        ("Sônia Aparecida Vieira", 63, "F", "56756756755", "Bucarein", "Rua Inácio Bastos", "285", 8, 12, "Vermelho", False, True, False),
        ("Pedro Henrique Teixeira", 38, "M", "67867867844", "Centro", "Rua Princesa Isabel", "150", 9, 8, "Amarelo", False, False, True),
        ("Lúcia Helena Cardoso", 70, "F", "78978978933", "Aventureiro", "Rua Santa Luzia", "430", 10, 14, "Verde", False, True, False),
    ]

    for idx, (
        nome_pac, idade, sexo, cpf_pac, bairro, logradouro, numero,
        dias_atras, min_resposta, codigo_local, parada_vtr, usa_infusao, usa_trauma
    ) in enumerate(cenarios):
        momento_chamado = (agora - timedelta(days=dias_atras)).replace(
            hour=8 + (idx % 12), minute=10 + (idx % 4) * 10, second=0, microsecond=0
        )
        chegada_local = momento_chamado + timedelta(minutes=min_resposta)
        saida_local = chegada_local + timedelta(minutes=18)
        chegada_hosp = saida_local + timedelta(minutes=12)

        paciente = Paciente(
            nome=nome_pac,
            idade=idade,
            sexo=sexo,
            documento=pseudonimizar_cpf(cpf_pac),
            gravidade_previa=codigo_local,
            alergias="Nega" if idx % 2 == 0 else "Dipirona",
        )
        db.add(paciente)
        db.flush()

        unidade = unidades[idx % len(unidades)]
        medico = medicos[idx % len(medicos)] if medicos else None
        tecnico = tecnicos[idx % len(tecnicos)] if tecnicos else None
        condutor = condutores[idx % len(condutores)] if condutores else None
        base = bases[idx % len(bases)] if bases else None
        hospital = hospitais[idx % len(hospitais)] if hospitais else None

        ficha = FichaAtendimento(
            uuid_offline=f"seed-ficha-{idx + 1:03d}",
            id_unidade=unidade.id_unidade,
            id_responsavel=responsavel.id_usuario,
            id_condutor=condutor.id_condutor if condutor else None,
            id_paciente=paciente.id_paciente,
            id_tecnico=tecnico.id_tecnico if tecnico else None,
            id_medico=medico.id_medico if medico else None,
            id_base=base.id_base if base else None,
            id_hospital=hospital.id_hospital if hospital else None,
            cep="89201-100",
            logradouro=logradouro,
            bairro=bairro,
            numero=numero,
            hora_chamado=momento_chamado,
            hora_saida_base=momento_chamado + timedelta(minutes=2),
            hora_chegada_local=chegada_local,
            hora_saida_local=saida_local,
            hora_chegada_hospital=chegada_hosp,
            hora_conclusao=chegada_hosp + timedelta(minutes=10),
            codigo_local=codigo_local,
            unidade_parada=parada_vtr,
            motivo_unidade_parada="Troca preventiva de pneu após ocorrência" if parada_vtr else None,
            observacoes_gerais=f"Atendimento sintético #{idx + 1} - {bairro}",
            status_envio_prefeitura="ENVIADO" if idx % 3 != 0 else "PENDENTE",
            criado_em=momento_chamado,
            data_atendimento=momento_chamado,
        )
        db.add(ficha)
        db.flush()

        db.add(AvaliacaoClinica(
            id_ficha=ficha.id_ficha,
            id_paciente=paciente.id_paciente,
            pressao_arterial="120/80" if idx % 2 == 0 else "150/90",
            frequencia_cardiaca=78 + (idx % 25),
            frequencia_respiratoria=16 + (idx % 6),
            saturacao_o2=96 - (idx % 4),
            glicemia=98 + (idx % 40),
            temperatura=36.6,
            escala_glasgow=15 if codigo_local != "Vermelho" else 13,
            conduta="Monitoramento de sinais vitais e transporte seguro ao hospital de referência.",
        ))

        db.add(Utensilios(
            id_ficha=ficha.id_ficha,
            medicamentos_ampolas=(idx % 2 == 0),
            material_infusao=usa_infusao,
            material_trauma=usa_trauma,
            materiais_diversos=True,
            reposto=(idx % 3 == 0),
            observacoes_reposicao="Reposição padrão de kit APH" if idx % 3 == 0 else "Aguardando reposição na base",
        ))


def seed_initial_data(db: Session):
    print("[SEED] Verificando dados iniciais e sintéticos do sistema...")
    usuarios = _seed_usuarios(db)
    bases, unidades = _seed_bases_e_unidades(db)
    medicos, tecnicos, condutores = _seed_profissionais(db)
    hospitais = _seed_hospitais(db)
    _seed_fichas_sinteticas(db, usuarios, bases, unidades, medicos, tecnicos, condutores, hospitais)
    db.commit()
    print("[SEED] Carga inicial de dados finalizada com sucesso!")


if __name__ == "__main__":
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_initial_data(db)
    finally:
        db.close()
