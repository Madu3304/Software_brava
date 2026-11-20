from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from dependencies import get_usuario_atual, exigir_perfil
from models import Medico, Tecnico, Condutor, UnidadeMovel, BaseOperacional, HospitalDestino, Paciente
from models import Usuario
from schemas import (
    MedicoCreate, MedicoResponse, MedicoPublicoResponse,
    TecnicoCreate, TecnicoResponse, TecnicoPublicoResponse,
    CondutorCreate, CondutorResponse, CondutorPublicoResponse,
    UnidadeMovelCreate, UnidadeMovelResponse,
    BaseOperacionalCreate, BaseOperacionalResponse,
    HospitalDestinoCreate, HospitalDestinoResponse,
    PacienteCreate, PacienteResponse,
)

router = APIRouter(
    prefix="/cadastros",
    tags=["Cadastros Administrativos (RF10 e Modelo C4)"],
    dependencies=[Depends(get_usuario_atual)],
)

somente_admin = [Depends(exigir_perfil("ADMINISTRADOR"))]

# =============================================================================
# MÉDICOS
# GET  /cadastros/medicos          → público (todos os perfis): sem CPF/matrícula
# GET  /cadastros/medicos/completo → ADMINISTRADOR: dados completos
# POST /cadastros/medicos          → ADMINISTRADOR
# DEL  /cadastros/medicos/{id}     → ADMINISTRADOR
# =============================================================================

@router.get("/medicos", response_model=List[MedicoPublicoResponse])
def listar_medicos(db: Session = Depends(get_db)):
    """
    Lista médicos para seleção na ficha de atendimento.
    Todos os perfis autenticados podem acessar, mas a resposta omite CPF e
    matrícula (MedicoPublicoResponse) — somente id, nome e código de conselho.
    """
    return db.query(Medico).all()

@router.get(
    "/medicos/completo",
    response_model=List[MedicoResponse],
    dependencies=[Depends(exigir_perfil("ADMINISTRADOR"))],
)
def listar_medicos_completo(db: Session = Depends(get_db)):
    """Retorna todos os campos dos médicos, incluindo CPF e matrícula. Restrito a ADMINISTRADOR."""
    return db.query(Medico).all()

@router.post("/medicos", response_model=MedicoResponse, status_code=status.HTTP_201_CREATED, dependencies=somente_admin)
def criar_medico(dados: MedicoCreate, db: Session = Depends(get_db)):
    """Cadastra um novo médico para seleção na ficha de atendimento."""
    medico = Medico(
        nome=dados.nome,
        codigo_medico=dados.codigo_medico,
        cpf=dados.cpf,
        registro_conselho=dados.registro_conselho,
        unidade=dados.unidade,
        matricula=dados.matricula,
        cargo=dados.cargo,
        status=dados.status or "Disponível",
    )
    db.add(medico)
    db.commit()
    db.refresh(medico)
    return medico

@router.delete("/medicos/{id_medico}", status_code=status.HTTP_204_NO_CONTENT, dependencies=somente_admin)
def deletar_medico(id_medico: int, db: Session = Depends(get_db)):
    """Remove um médico do cadastro."""
    medico = db.query(Medico).filter(Medico.id_medico == id_medico).first()
    if not medico:
        raise HTTPException(status_code=404, detail="Médico não encontrado.")
    db.delete(medico)
    db.commit()
    return None

# =============================================================================
# TÉCNICOS DE ENFERMAGEM
# GET  /cadastros/tecnicos          → público (todos os perfis): sem CPF/matrícula
# GET  /cadastros/tecnicos/completo → ADMINISTRADOR: dados completos
# POST /cadastros/tecnicos          → ADMINISTRADOR
# DEL  /cadastros/tecnicos/{id}     → ADMINISTRADOR
# =============================================================================

@router.get("/tecnicos", response_model=List[TecnicoPublicoResponse])
def listar_tecnicos(db: Session = Depends(get_db)):
    """
    Lista técnicos de enfermagem para seleção na ficha.
    Resposta pública omite CPF e matrícula (TecnicoPublicoResponse).
    """
    return db.query(Tecnico).all()

@router.get(
    "/tecnicos/completo",
    response_model=List[TecnicoResponse],
    dependencies=[Depends(exigir_perfil("ADMINISTRADOR"))],
)
def listar_tecnicos_completo(db: Session = Depends(get_db)):
    """Retorna todos os campos dos técnicos, incluindo CPF e matrícula. Restrito a ADMINISTRADOR."""
    return db.query(Tecnico).all()

@router.post("/tecnicos", response_model=TecnicoResponse, status_code=status.HTTP_201_CREATED, dependencies=somente_admin)
def criar_tecnico(dados: TecnicoCreate, db: Session = Depends(get_db)):
    """Cadastra um novo técnico de enfermagem."""
    tecnico = Tecnico(
        nome=dados.nome,
        codigo_tecnico=dados.codigo_tecnico or dados.codigo_medico,
        cpf=dados.cpf,
        registro_conselho=dados.registro_conselho,
        unidade=dados.unidade,
        matricula=dados.matricula,
        cargo=dados.cargo,
        status=dados.status or "Disponível",
    )
    db.add(tecnico)
    db.commit()
    db.refresh(tecnico)
    return tecnico

@router.delete("/tecnicos/{id_tecnico}", status_code=status.HTTP_204_NO_CONTENT, dependencies=somente_admin)
def deletar_tecnico(id_tecnico: int, db: Session = Depends(get_db)):
    """Remove um técnico de enfermagem do cadastro."""
    tecnico = db.query(Tecnico).filter(Tecnico.id_tecnico == id_tecnico).first()
    if not tecnico:
        raise HTTPException(status_code=404, detail="Técnico não encontrado.")
    db.delete(tecnico)
    db.commit()
    return None

# =============================================================================
# CONDUTORES SOCORRISTAS
# GET  /cadastros/condutores          → público (todos os perfis): sem CPF/matrícula
# GET  /cadastros/condutores/completo → ADMINISTRADOR: dados completos
# POST /cadastros/condutores          → ADMINISTRADOR
# DEL  /cadastros/condutores/{id}     → ADMINISTRADOR
# =============================================================================

@router.get("/condutores", response_model=List[CondutorPublicoResponse])
def listar_condutores(db: Session = Depends(get_db)):
    """
    Lista condutores para seleção na ficha.
    Resposta pública omite CPF e matrícula (CondutorPublicoResponse).
    """
    return db.query(Condutor).all()

@router.get(
    "/condutores/completo",
    response_model=List[CondutorResponse],
    dependencies=[Depends(exigir_perfil("ADMINISTRADOR"))],
)
def listar_condutores_completo(db: Session = Depends(get_db)):
    """Retorna todos os campos dos condutores, incluindo CPF e matrícula. Restrito a ADMINISTRADOR."""
    return db.query(Condutor).all()

@router.post("/condutores", response_model=CondutorResponse, status_code=status.HTTP_201_CREATED, dependencies=somente_admin)
def criar_condutor(dados: CondutorCreate, db: Session = Depends(get_db)):
    """Cadastra um novo condutor socorrista."""
    condutor = Condutor(
        nome=dados.nome,
        codigo_condutor=dados.codigo_condutor,
        cpf=dados.cpf,
        registro_conselho=dados.registro_conselho,
        unidade=dados.unidade,
        matricula=dados.matricula,
        cargo=dados.cargo,
        status=dados.status or "Disponível",
    )
    db.add(condutor)
    db.commit()
    db.refresh(condutor)
    return condutor

@router.delete("/condutores/{id_condutor}", status_code=status.HTTP_204_NO_CONTENT, dependencies=somente_admin)
def deletar_condutor(id_condutor: int, db: Session = Depends(get_db)):
    """Remove um condutor socorrista do cadastro."""
    condutor = db.query(Condutor).filter(Condutor.id_condutor == id_condutor).first()
    if not condutor:
        raise HTTPException(status_code=404, detail="Condutor não encontrado.")
    db.delete(condutor)
    db.commit()
    return None

# =============================================================================
# UNIDADES MÓVEIS (VIATURAS)
# =============================================================================

@router.get("/unidades", response_model=List[UnidadeMovelResponse])
def listar_unidades(db: Session = Depends(get_db)):
    """Lista as unidades móveis (Bravas)."""
    return db.query(UnidadeMovel).all()

@router.post("/unidades", response_model=UnidadeMovelResponse, status_code=status.HTTP_201_CREATED, dependencies=somente_admin)
def criar_unidade(dados: UnidadeMovelCreate, db: Session = Depends(get_db)):
    """Cadastra uma nova unidade móvel básica do SAMU."""
    unidade = UnidadeMovel(
        placa=dados.placa,
        base_unidade=dados.base_unidade,
        status=dados.status,
        motivo_parada=dados.motivo_parada,
    )
    db.add(unidade)
    db.commit()
    db.refresh(unidade)
    return unidade

@router.put("/unidades/{id_unidade}/status", response_model=UnidadeMovelResponse, dependencies=somente_admin)
def atualizar_status_unidade(id_unidade: int, status_novo: str, motivo: str = None, db: Session = Depends(get_db)):
    """Atualiza o status de prontidão da viatura (DISPONIVEL, EM_ATENDIMENTO, PARADA, MANUTENCAO)."""
    unidade = db.query(UnidadeMovel).filter(UnidadeMovel.id_unidade == id_unidade).first()
    if not unidade:
        raise HTTPException(status_code=404, detail="Unidade não encontrada.")
    unidade.status = status_novo
    unidade.motivo_parada = motivo
    db.commit()
    db.refresh(unidade)
    return unidade

@router.delete("/unidades/{id_unidade}", status_code=status.HTTP_204_NO_CONTENT, dependencies=somente_admin)
def deletar_unidade(id_unidade: int, db: Session = Depends(get_db)):
    """
    Remove uma unidade móvel do cadastro.
    Recusado com 409 se a viatura possuir fichas de atendimento vinculadas —
    nesse caso altere o status para MANUTENCAO ou PARADA em vez de excluir.
    """
    unidade = db.query(UnidadeMovel).filter(UnidadeMovel.id_unidade == id_unidade).first()
    if not unidade:
        raise HTTPException(status_code=404, detail="Unidade não encontrada.")
    if unidade.fichas:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                f"A unidade #{id_unidade} possui {len(unidade.fichas)} ficha(s) vinculada(s) "
                "e não pode ser excluída. Desative-a alterando seu status para 'MANUTENCAO' ou 'PARADA'."
            ),
        )
    db.delete(unidade)
    db.commit()
    return None

# =============================================================================
# BASES OPERACIONAIS
# =============================================================================

@router.get("/bases", response_model=List[BaseOperacionalResponse])
def listar_bases(db: Session = Depends(get_db)):
    """Lista as bases operacionais do município."""
    return db.query(BaseOperacional).all()

@router.post("/bases", response_model=BaseOperacionalResponse, status_code=status.HTTP_201_CREATED, dependencies=somente_admin)
def criar_base(dados: BaseOperacionalCreate, db: Session = Depends(get_db)):
    """Cadastra uma nova base operacional física."""
    base = BaseOperacional(
        nome=dados.nome or dados.base_unidade,
        endereco=dados.endereco,
        bairro=dados.bairro,
        telefone=dados.telefone,
        ativo=dados.ativo,
        placa=dados.placa,
        base_unidade=dados.base_unidade,
        status=dados.status,
        motivo_parada=dados.motivo_parada,
    )
    db.add(base)
    db.commit()
    db.refresh(base)
    return base

# =============================================================================
# HOSPITAIS DE DESTINO
# =============================================================================

@router.get("/hospitais", response_model=List[HospitalDestinoResponse])
def listar_hospitais(db: Session = Depends(get_db)):
    """Lista os hospitais e unidades de pronto atendimento de destino."""
    return db.query(HospitalDestino).all()

@router.post("/hospitais", response_model=HospitalDestinoResponse, status_code=status.HTTP_201_CREATED, dependencies=somente_admin)
def criar_hospital(dados: HospitalDestinoCreate, db: Session = Depends(get_db)):
    """Cadastra um hospital ou UPA de destino."""
    hospital = HospitalDestino(nome=dados.nome, endereco=dados.endereco)
    db.add(hospital)
    db.commit()
    db.refresh(hospital)
    return hospital

# =============================================================================
# PACIENTES — restrito a ADMINISTRADOR (contém CPF, alergias, medicações — LGPD)
# =============================================================================

@router.get(
    "/pacientes",
    response_model=List[PacienteResponse],
    dependencies=[Depends(exigir_perfil("ADMINISTRADOR"))],
)
def listar_pacientes(db: Session = Depends(get_db)):
    """
    Lista pacientes registrados nos atendimentos (limitado a 100 mais recentes).
    Restrito a ADMINISTRADOR — pacientes contêm CPF, alergias e medicações (LGPD).
    """
    return db.query(Paciente).limit(100).all()

@router.post("/pacientes", response_model=PacienteResponse, status_code=status.HTTP_201_CREATED, dependencies=somente_admin)
def criar_paciente(dados: PacienteCreate, db: Session = Depends(get_db)):
    """Cadastra um paciente avulso (sem ficha vinculada)."""
    paciente = Paciente(
        nome=dados.nome,
        idade=dados.idade,
        sexo=dados.sexo,
        documento=dados.documento,
        data_nascimento=dados.data_nascimento,
        acompanhante=dados.acompanhante,
        grau_parentesco=dados.grau_parentesco,
        telefone_acompanhante=dados.telefone_acompanhante,
        gravidade_previa=dados.gravidade_previa,
        historico_clinico=dados.historico_clinico,
        alergias=dados.alergias,
        medicamentoUso_paciente=dados.medicamentoUso_paciente,
        observacao_paciente=dados.observacao_paciente,
    )
    db.add(paciente)
    db.commit()
    db.refresh(paciente)
    return paciente
