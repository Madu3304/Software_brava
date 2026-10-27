from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import Medico, Tecnico, Condutor, UnidadeMovel, BaseOperacional, HospitalDestino, Paciente, LogAuditoria
from schemas import (
    MedicoCreate, MedicoResponse,
    TecnicoCreate, TecnicoResponse,
    CondutorCreate, CondutorResponse,
    UnidadeMovelCreate, UnidadeMovelResponse,
    BaseOperacionalCreate, BaseOperacionalResponse,
    HospitalDestinoCreate, HospitalDestinoResponse,
    PacienteCreate, PacienteResponse,
)

router = APIRouter(prefix="/cadastros", tags=["Cadastros Administrativos (RF10 e Modelo C4)"])

# 1. MÉDICOS
# CRUD completo consumido pelo menu lateral do Administrador:

@router.get("/medicos", response_model=List[MedicoResponse])
def listar_medicos(db: Session = Depends(get_db)):
    """Lista todos os médicos cadastrados no sistema."""
    return db.query(Medico).all()

@router.post("/medicos", response_model=MedicoResponse, status_code=status.HTTP_201_CREATED)
def criar_medico(dados: MedicoCreate, db: Session = Depends(get_db)):
    """Cadastra um novo médico para seleção na ficha de atendimento."""
    medico = Medico(nome=dados.nome, codigo_medico=dados.codigo_medico)
    db.add(medico)
    db.commit()
    db.refresh(medico)
    return medico

@router.delete("/medicos/{id_medico}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_medico(id_medico: int, db: Session = Depends(get_db)):
    medico = db.query(Medico).filter(Medico.id_medico == id_medico).first()
    if not medico:
        raise HTTPException(status_code=404, detail="Médico não encontrado.")
    db.delete(medico)
    db.commit()
    return None

# 2. TÉCNICOS DE ENFERMAGEM

@router.get("/tecnicos", response_model=List[TecnicoResponse])
def listar_tecnicos(db: Session = Depends(get_db)):
    """Lista todos os técnicos de enfermagem."""
    return db.query(Tecnico).all()

@router.post("/tecnicos", response_model=TecnicoResponse, status_code=status.HTTP_201_CREATED)
def criar_tecnico(dados: TecnicoCreate, db: Session = Depends(get_db)):
    """Cadastra um novo técnico de enfermagem."""
    tecnico = Tecnico(nome=dados.nome, codigo_medico=dados.codigo_medico)
    db.add(tecnico)
    db.commit()
    db.refresh(tecnico)
    return tecnico

@router.delete("/tecnicos/{id_tecnico}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_tecnico(id_tecnico: int, db: Session = Depends(get_db)):
    tecnico = db.query(Tecnico).filter(Tecnico.id_tecnico == id_tecnico).first()
    if not tecnico:
        raise HTTPException(status_code=404, detail="Técnico não encontrado.")
    db.delete(tecnico)
    db.commit()
    return None

# 3. CONDUTORES SOCORRISTA

@router.get("/condutores", response_model=List[CondutorResponse])
def listar_condutores(db: Session = Depends(get_db)):
    """Lista todos os condutores socorristas."""
    return db.query(Condutor).all()

@router.post("/condutores", response_model=CondutorResponse, status_code=status.HTTP_201_CREATED)
def criar_condutor(dados: CondutorCreate, db: Session = Depends(get_db)):
    """Cadastra um novo condutor socorrista."""
    condutor = Condutor(nome=dados.nome, codigo_condutor=dados.codigo_condutor)
    db.add(condutor)
    db.commit()
    db.refresh(condutor)
    return condutor

@router.delete("/condutores/{id_condutor}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_condutor(id_condutor: int, db: Session = Depends(get_db)):
    condutor = db.query(Condutor).filter(Condutor.id_condutor == id_condutor).first()
    if not condutor:
        raise HTTPException(status_code=404, detail="Condutor não encontrado.")
    db.delete(condutor)
    db.commit()
    return None

# 4. UNIDADES MÓVEIS / AMBULÂNCIAS

@router.get("/unidades", response_model=List[UnidadeMovelResponse])
def listar_unidades(db: Session = Depends(get_db)):
    """Lista as unidades móveis (Bravas)."""
    return db.query(UnidadeMovel).all()

@router.post("/unidades", response_model=UnidadeMovelResponse, status_code=status.HTTP_201_CREATED)
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

@router.put("/unidades/{id_unidade}/status", response_model=UnidadeMovelResponse)
def atualizar_status_unidade(id_unidade: int, status_novo: str, motivo: str = None, db: Session = Depends(get_db)):
    """Atualiza o status de prontidão da viatura (Disponível, Parada, Manutenção)."""
    unidade = db.query(UnidadeMovel).filter(UnidadeMovel.id_unidade == id_unidade).first()
    if not unidade:
        raise HTTPException(status_code=404, detail="Unidade não encontrada.")
    unidade.status = status_novo
    unidade.motivo_parada = motivo
    db.commit()
    db.refresh(unidade)
    return unidade

# 5. BASES OPERACIONAIS

@router.get("/bases", response_model=List[BaseOperacionalResponse])
def listar_bases(db: Session = Depends(get_db)):
    """Lista as bases operacionais do município."""
    return db.query(BaseOperacional).all()

@router.post("/bases", response_model=BaseOperacionalResponse, status_code=status.HTTP_201_CREATED)
def criar_base(dados: BaseOperacionalCreate, db: Session = Depends(get_db)):
    base = BaseOperacional(
        placa=dados.placa,
        base_unidade=dados.base_unidade,
        status=dados.status,
        motivo_parada=dados.motivo_parada,
    )
    db.add(base)
    db.commit()
    db.refresh(base)
    return base

# 6. HOSPITAIS DE DESTINO

@router.get("/hospitais", response_model=List[HospitalDestinoResponse])
def listar_hospitais(db: Session = Depends(get_db)):
    """Lista os hospitais e unidades de pronto atendimento de destino."""
    return db.query(HospitalDestino).all()

@router.post("/hospitais", response_model=HospitalDestinoResponse, status_code=status.HTTP_201_CREATED)
def criar_hospital(dados: HospitalDestinoCreate, db: Session = Depends(get_db)):
    hospital = HospitalDestino(nome=dados.nome, endereco=dados.endereco)
    db.add(hospital)
    db.commit()
    db.refresh(hospital)
    return hospital

# 7. PACIENTES

@router.get("/pacientes", response_model=List[PacienteResponse])
def listar_pacientes(db: Session = Depends(get_db)):
    """Lista pacientes registrados nos atendimentos."""
    return db.query(Paciente).limit(100).all()

@router.post("/pacientes", response_model=PacienteResponse, status_code=status.HTTP_201_CREATED)
def criar_paciente(dados: PacienteCreate, db: Session = Depends(get_db)):
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
