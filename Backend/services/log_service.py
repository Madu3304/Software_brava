# Backend/services/log_service.py
"""
Módulo de Auditoria e Rastreabilidade LGPD (Modelo C4 - Nível 4)
Componente: Log Service
Responsabilidade: Registro de logs de execução, acessos, auditoria operacional e falhas técnicas (RNF05).
"""
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
    ip_origem: Optional[str] = "127.0.0.1",
) -> LogAuditoria:
    """
    Grava evento de auditoria no PostgreSQL e espelha no logger da aplicação.
    Em conformidade com a LGPD (sem registrar dados de prontuário, apenas metadados).
    """
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
    """Consulta histórico de auditoria para o painel administrativo."""
    query = db.query(LogAuditoria)
    if acao:
        query = query.filter(LogAuditoria.acao.ilike(f"%{acao}%"))
    if id_usuario:
        query = query.filter(LogAuditoria.id_usuario == id_usuario)

    logs = query.order_by(LogAuditoria.data_hora.desc()).limit(limite).all()
    return [LogAuditoriaResponse.from_orm(log) for log in logs]
