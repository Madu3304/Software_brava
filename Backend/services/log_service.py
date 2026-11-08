# Backend/services/log_service.py

import logging
from typing import Optional, List
from sqlalchemy.orm import Session
from models import LogAuditoria
from schemas import LogAuditoriaResponse

# Configuração do logger interno Python
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("BravaAuditLog")

def registrar_auditoria(
    db: Session,
    acao: str,
    detalhes: str,
    id_usuario: Optional[int] = None,
    ip_origem: Optional[str] = None,
) -> LogAuditoria:

    logger.info(f"AUDITORIA: [{acao}] Usuario: {id_usuario} | IP: {ip_origem} | {detalhes}")

    log_entry = LogAuditoria(
        id_usuario=id_usuario,
        acao=acao,
        detalhes_metadados=detalhes[:255] if detalhes else None,
        ip_origem=ip_origem,
    )
    db.add(log_entry)
    db.commit()
    db.refresh(log_entry)
    return log_entry

def listar_logs_recentes(
    db: Session,
    limite: int = 100,
    acao: Optional[str] = None,
    id_usuario: Optional[int] = None,
) -> List[LogAuditoriaResponse]:
    query = db.query(LogAuditoria)
    if acao:
        query = query.filter(LogAuditoria.acao.ilike(f"%{acao}%"))
    if id_usuario:
        query = query.filter(LogAuditoria.id_usuario == id_usuario)

    logs = query.order_by(LogAuditoria.data_hora.desc()).limit(limite).all()
    return [LogAuditoriaResponse.model_validate(log) for log in logs]
