from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from database import get_db
from models import FichaAtendimento
from schemas import SyncLoteRequest, SyncLoteResponse
from services.sync_service import processar_pacote_sync_offline

router = APIRouter(prefix="/sync", tags=["Sincronização Offline-First (C4 Nível 3/4 - Mobile Exclusivo)"])

# Exclusivo do Mobile. Recebe pacotes de dados gravados em lote pelo SQLite offline, garantindo idempotência via uuid_offline para evitar duplicações.

@router.post("/lote", response_model=SyncLoteResponse, status_code=status.HTTP_200_OK)
def sincronizar_lote_offline(payload: SyncLoteRequest, db: Session = Depends(get_db)):
    """
    Recebe pacote em lote de fichas gravadas no SQLite local do tablet
    durante o modo offline e persiste no PostgreSQL central (RN06 e Modelo C4).
    Garante idempotência verificando o uuid_offline para não duplicar atendimentos.
    """
    return processar_pacote_sync_offline(db=db, itens=payload.fichas)

@router.get("/status")
def get_sync_status(db: Session = Depends(get_db)):
    """Verifica a integridade do serviço de sincronização."""
    total_offline = db.query(FichaAtendimento).filter(FichaAtendimento.uuid_offline != None).count()
    return {
        "status": "ONLINE",
        "servico": "Sync Service SAMU Brava",
        "total_fichas_sincronizadas_offline": total_offline,
    }
