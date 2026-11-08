from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional

from database import get_db
from dependencies import exigir_perfil
from models import LogAuditoria
from schemas import LogAuditoriaResponse

# Rotas restritas ao perfil ADMINISTRADOR (token JWT obrigatório)
router = APIRouter(
    prefix="/logs",
    tags=["Auditoria e Rastreabilidade LGPD (RNF05 / Modelo C4)"],
    dependencies=[Depends(exigir_perfil("ADMINISTRADOR"))],
)

#Trilhas de auditoria das operações, acessos e alterações em conformidade com a LGPD
# Somente leitura: os registros são gravados pelo próprio backend (log_service), nunca enviados pelo cliente.

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
