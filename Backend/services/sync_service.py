# Backend/services/sync_service.py

from typing import List, Optional, Tuple, Sequence
from sqlalchemy.orm import Session

from models import FichaAtendimento, LogAuditoria
from schemas import FichaAtendimentoCreate, SyncLoteResponse
from services.ficha_service import criar_ficha_completa
from services.validation_service import ErroValidacaoClinica

def processar_pacote_sync_offline(
    db: Session,
    itens: Sequence[FichaAtendimentoCreate],
    id_responsavel: int,
    ip_origem: Optional[str] = None,
) -> Tuple[SyncLoteResponse, List[int]]:
    """
    Usa criar_ficha_completa() dentro de um savepoint (begin_nested) para cada item:
    valida regras clínicas e salva todos os campos de forma unificada.
    """
    processados = len(itens)
    sucessos = 0
    duplicados = 0
    erros = []
    ids_fichas_criadas = []

    for item in itens:
        try:
            # 1. Checagem de idempotência
            if item.uuid_offline:
                existente = db.query(FichaAtendimento).filter(
                    FichaAtendimento.uuid_offline == item.uuid_offline
                ).first()

                if existente:
                    duplicados += 1
                    continue

            # Savepoint por item: se qualquer validação ou inserção falhar, só este item é desfeito
            with db.begin_nested():
                nova_ficha = criar_ficha_completa(
                    db=db,
                    dados=item,
                    id_responsavel=id_responsavel,
                )

            sucessos += 1
            ids_fichas_criadas.append(nova_ficha.id_ficha)

        except ErroValidacaoClinica as e:
            erros.append(f"Erro no item {item.uuid_offline}: Falha de validação clínica - {'; '.join(e.erros)}")
        except Exception as e:
            erros.append(f"Erro no item {item.uuid_offline}: {str(e)}")

    # Registra auditoria da sincronização
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
    return resumo, ids_fichas_criadas
