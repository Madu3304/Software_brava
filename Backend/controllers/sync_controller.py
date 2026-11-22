from fastapi import APIRouter, BackgroundTasks, Depends, Request, status
from sqlalchemy.orm import Session

from database import get_db
from dependencies import get_usuario_atual, obter_ip_origem
from models import FichaAtendimento, Usuario
from schemas import SyncLoteRequest, SyncLoteResponse
from services.sync_service import processar_pacote_sync_offline
from services.integration_service import enviar_fichas_para_prefeitura

router = APIRouter(
    prefix="/sync",
    tags=["Sincronização Offline-First (C4 Nível 3/4 - Mobile Exclusivo)"],
    dependencies=[Depends(get_usuario_atual)],
)

# Exclusivo do Mobile. Recebe pacotes de dados gravados em lote pelo SQLite offline, garantindo idempotência via uuid_offline para evitar duplicações.

@router.post("/lote", response_model=SyncLoteResponse, status_code=status.HTTP_200_OK)
def sincronizar_lote_offline(
    payload: SyncLoteRequest,
    request: Request,
    background_tasks: BackgroundTasks,
    usuario: Usuario = Depends(get_usuario_atual),
    db: Session = Depends(get_db),
):
    """
    Recebe pacote em lote de fichas gravadas no SQLite local do tablet
    durante o modo offline e persiste no PostgreSQL central (RN06 e Modelo C4).
    Garante idempotência verificando o uuid_offline para não duplicar atendimentos.
    O profissional responsável pelas fichas é o usuário autenticado pelo token.
    As fichas criadas são enviadas à Prefeitura (RF06) em segundo plano, depois do commit.
    """
    resumo, ids_fichas_criadas = processar_pacote_sync_offline(
        db=db,
        itens=payload.fichas,
        id_responsavel=usuario.id_usuario,
        ip_origem=obter_ip_origem(request),
    )
    if ids_fichas_criadas:
        background_tasks.add_task(enviar_fichas_para_prefeitura, ids_fichas_criadas)
    return resumo

@router.get("/status")
def get_sync_status(db: Session = Depends(get_db)):
    """Verifica a integridade do serviço de sincronização."""
    total_offline = db.query(FichaAtendimento).filter(FichaAtendimento.uuid_offline != None).count()
    return {
        "status": "ONLINE",
        "servico": "Sync Service SAMU Brava",
        "total_fichas_sincronizadas_offline": total_offline,
    }
