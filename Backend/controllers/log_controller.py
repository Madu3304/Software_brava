from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional

from database import get_db
from models import LogAuditoria
from schemas import LogAuditoriaCreate, LogAuditoriaResponse

router = APIRouter(prefix="/logs", tags=["Auditoria e Rastreabilidade LGPD (RNF05 / Modelo C4)"])

#Trilhas de auditoria das operações, acessos e alterações em conformidade com a LGPD

@router.get("/", response_model=List[LogAuditoriaResponse])
def listar_logs_auditoria(
    acao: Optional[str] = Query(None, description="Filtrar por tipo de ação"),
    id_usuario: Optional[int] = Query(None, description="Filtrar por identificador de usuário"),
    limite: int = Query(100, description="Quantidade máxima de registros"),
    db: Session = Depends(get_db)
):
    """
    Lista trilhas de auditoria para o perfil Administrador (RNF05).
    Garante rastreabilidade de acessos, alterações cadastrais e sincronicidade.
    """
    query = db.query(LogAuditoria)
    if acao:
        query = query.filter(LogAuditoria.acao.ilike(f"%{acao}%"))
    if id_usuario:
        query = query.filter(LogAuditoria.id_usuario == id_usuario)

    return query.order_by(LogAuditoria.data_hora.desc()).limit(limite).all()

@router.post("/", response_model=LogAuditoriaResponse, status_code=status.HTTP_201_CREATED)
def registrar_log(dados: LogAuditoriaCreate, db: Session = Depends(get_db)):
    """Registra manualmente um evento de auditoria no sistema."""
    log = LogAuditoria(
        id_usuario=dados.id_usuario,
        acao=dados.acao,
        detalhes_metadados=dados.detalhes_metadados,
        ip_origem=dados.ip_origem,
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    return log
