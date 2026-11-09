import logging
from typing import List, Optional, Tuple, Sequence, Any
from sqlalchemy.orm import Session
from pydantic import ValidationError

from models import FichaAtendimento, LogAuditoria
from schemas import FichaAtendimentoCreate, SyncLoteResponse
from services.ficha_service import criar_ficha_completa
from services.validation_service import ErroValidacaoClinica

logger = logging.getLogger("BravaSyncService")

def processar_pacote_sync_offline(
    db: Session,
    itens: Sequence[Any],
    id_responsavel: int,
    ip_origem: Optional[str] = None,
) -> Tuple[SyncLoteResponse, List[int]]:
    """
    Persiste lote de fichas com integridade relacional, validação clínica completa
    e idempotência baseada no uuid_offline.
    """
    processados = len(itens)
    sucessos = 0
    duplicados = 0
    erros = []
    ids_fichas_criadas = []

    for item_bruto in itens:
        uuid_item = item_bruto.get("uuid_offline") if isinstance(item_bruto, dict) else getattr(item_bruto, "uuid_offline", None)
        try:
            if isinstance(item_bruto, dict):
                item = FichaAtendimentoCreate(**item_bruto)
            else:
                item = item_bruto

            if item.uuid_offline:
                existente = db.query(FichaAtendimento).filter(
                    FichaAtendimento.uuid_offline == item.uuid_offline
                ).first()

                if existente:
                    duplicados += 1
                    continue

            with db.begin_nested():
                nova_ficha = criar_ficha_completa(
                    db=db,
                    dados=item,
                    id_responsavel=id_responsavel,
                )

            sucessos += 1
            ids_fichas_criadas.append(nova_ficha.id_ficha)

        except ValidationError as e:
            logger.warning("Falha de schema Pydantic no item %s: %s", uuid_item, e)
            msg_erro = e.errors()[0]["msg"] if e.errors() else "Dados inválidos."
            erros.append(f"Erro no item {uuid_item}: {msg_erro}")
        except ErroValidacaoClinica as e:
            logger.warning("Falha clínica no item %s: %s", uuid_item, e.erros)
            erros.append(f"Erro no item {uuid_item}: Falha de validação clínica - {'; '.join(e.erros)}")
        except Exception as e:
            logger.error("Falha interna de persistência na sincronização do item %s: %s", uuid_item, e, exc_info=True)
            erros.append(f"Erro no item {uuid_item}: Falha interna de persistência no processamento do atendimento.")

    log = LogAuditoria(
        id_usuario=id_responsavel,
        ip_origem=ip_origem,
        acao="SYNC_OFFLINE_LOTE",
        detalhes_metadados=f"Sincronização em lote finalizada. Processados: {processados}, Sucessos: {sucessos}, Duplicados: {duplicados}, Erros: {len(erros)}."
    )
    db.add(log)
    db.commit()

    resumo = SyncLoteResponse(
        processados=processados,
        sucessos=sucessos,
        duplicados_ignorados=duplicados,
        erros=erros
    )
    return (resumo, ids_fichas_criadas)
