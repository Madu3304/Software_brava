# Backend/services/sync_service.py
"""
Módulo de Sincronização Offline (Modelo C4 - Níveis 3 e 4)
Componente: Sync Controller / Service
Responsabilidade: Processamento de cargas de dados em lote originadas do SQLite do Aplicativo Mobile.
"""
from typing import List
from datetime import datetime
from sqlalchemy.orm import Session

from models import FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios, LogAuditoria
from schemas import FichaSyncItem, SyncLoteResponse
from services.integration_service import transmitir_atendimento_para_prefeitura

def processar_pacote_sync_offline(db: Session, itens: List[FichaSyncItem]) -> SyncLoteResponse:
    """
    Persiste lote de fichas com integridade relacional e idempotência baseada no uuid_offline.
    Ao final de cada persistência, encaminha o atendimento para o Integration Service.
    """
    processados = len(itens)
    sucessos = 0
    duplicados = 0
    erros = []

    for item in itens:
        try:
            # 1. Checagem de idempotência
            existente = db.query(FichaAtendimento).filter(
                FichaAtendimento.uuid_offline == item.uuid_offline
            ).first()

            if existente:
                duplicados += 1
                continue

            # 2. Paciente
            id_paciente_criado = None
            if item.paciente:
                paciente = Paciente(
                    nome=item.paciente.nome,
                    idade=item.paciente.idade,
                    sexo=item.paciente.sexo,
                    documento=item.paciente.documento,
                    data_nascimento=item.paciente.data_nascimento,
                    acompanhante=item.paciente.acompanhante,
                    grau_parentesco=item.paciente.grau_parentesco,
                    telefone_acompanhante=item.paciente.telefone_acompanhante,
                    gravidade_previa=item.paciente.gravidade_previa,
                    historico_clinico=item.paciente.historico_clinico,
                    alergias=item.paciente.alergias,
                    medicamentoUso_paciente=item.paciente.medicamentoUso_paciente,
                    observacao_paciente=item.paciente.observacao_paciente,
                )
                db.add(paciente)
                db.flush()
                id_paciente_criado = paciente.id_paciente

            # 3. Ficha
            ficha = FichaAtendimento(
                uuid_offline=item.uuid_offline,
                id_unidade=item.id_unidade,
                id_responsavel=item.id_responsavel,
                id_condutor=item.id_condutor,
                id_paciente=id_paciente_criado,
                id_tecnico=item.id_tecnico,
                id_medico=item.id_medico,
                id_hospital=item.id_hospital,
                cep=item.cep,
                logradouro=item.logradouro,
                bairro=item.bairro,
                numero=item.numero,
                latitude=item.latitude,
                longitude=item.longitude,
                hora_chamado=item.hora_chamado or datetime.utcnow(),
                hora_saida_base=item.hora_saida_base,
                hora_chegada_local=item.hora_chegada_local,
                hora_conclusao=item.hora_conclusao,
                observacoes_gerais=item.observacoes_gerais,
            )
            db.add(ficha)
            db.flush()

            # 4. Avaliação Clínica
            id_avaliacao_criada = None
            if item.avaliacao_clinica:
                avaliacao = AvaliacaoClinica(
                    id_ficha=ficha.id_ficha,
                    id_paciente=id_paciente_criado,
                    pressao_arterial=item.avaliacao_clinica.pressao_arterial,
                    frequencia_cardiaca=item.avaliacao_clinica.frequencia_cardiaca,
                    frequencia_respiratoria=item.avaliacao_clinica.frequencia_respiratoria,
                    saturacao_o2=item.avaliacao_clinica.saturacao_o2,
                    glicemia=item.avaliacao_clinica.glicemia,
                    temperatura=item.avaliacao_clinica.temperatura,
                    escala_glasgow=item.avaliacao_clinica.escala_glasgow,
                    conduta=item.avaliacao_clinica.conduta,
                    anotacao_CondutaEnfermeiro=item.avaliacao_clinica.anotacao_CondutaEnfermeiro,
                    procedimentos_realizados=item.avaliacao_clinica.procedimentos_realizados,
                    medicacoes_administradas=item.avaliacao_clinica.medicacoes_administradas,
                )
                db.add(avaliacao)
                db.flush()
                id_avaliacao_criada = avaliacao.id_avaliacao

            # 5. Utensílios Gastos
            if item.utensilios_gastos:
                utensilios = Utensilios(
                    id_ficha=ficha.id_ficha,
                    id_avaliacao=id_avaliacao_criada,
                    medicamentos_ampolas=item.utensilios_gastos.medicamentos_ampolas,
                    medicamentos_controlados=item.utensilios_gastos.medicamentos_controlados,
                    medicamentos_comprimidos=item.utensilios_gastos.medicamentos_comprimidos,
                    medicamentos_frascoGotas=item.utensilios_gastos.medicamentos_frascoGotas,
                    anestesico=item.utensilios_gastos.anestesico,
                    material_infusao=item.utensilios_gastos.material_infusao,
                    material_sondagem=item.utensilios_gastos.material_sondagem,
                    material_trauma=item.utensilios_gastos.material_trauma,
                    materiais_diversos=item.utensilios_gastos.materiais_diversos,
                    observacoes_reposicao=item.utensilios_gastos.observacoes_reposicao,
                    reposto=item.utensilios_gastos.reposto,
                )
                db.add(utensilios)

            sucessos += 1

            # 6. Dispara integração externa com o banco da prefeitura (C4 Nível 3)
            transmitir_atendimento_para_prefeitura({
                "id_ficha": ficha.id_ficha,
                "uuid_offline": item.uuid_offline,
                "id_unidade": item.id_unidade,
                "data": ficha.data_atendimento.isoformat() if ficha.data_atendimento else None,
            })

        except Exception as e:
            erros.append(f"Erro no item {item.uuid_offline}: {str(e)}")

    # 7. Registra auditoria
    log = LogAuditoria(
        acao="SYNC_OFFLINE_LOTE",
        detalhes_metadados=f"Sincronização em lote finalizada. Processados: {processados}, Sucessos: {sucessos}, Duplicados: {duplicados}, Erros: {len(erros)}."
    )
    db.add(log)
    db.commit()

    return SyncLoteResponse(
        processados=processados,
        sucessos=sucessos,
        duplicados_ignorados=duplicados,
        erros=erros
    )
