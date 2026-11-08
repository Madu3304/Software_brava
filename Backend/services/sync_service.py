import logging
logger = logging.getLogger("BravaSyncService")

from typing import List, Optional, Tuple, Sequence, Any
from sqlalchemy.orm import Session
from pydantic import ValidationError

from models import FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios, LogAuditoria
from schemas import FichaSyncItem, SyncLoteResponse
from services.integration_service import transmitir_atendimento_para_prefeitura
from services.validation_service import validar_regras_clinicas_ficha

def processar_pacote_sync_offline(
    db: Session,
    itens: Sequence[Any],
    id_responsavel: int,
    ip_origem: Optional[str] = None,
) -> Tuple[SyncLoteResponse, List[int]]:
 
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

            valido, erros_val = validar_regras_clinicas_ficha(item)
            if not valido:
                erros.append(f"Erro no item {item.uuid_offline}: {'; '.join(erros_val)}")
                continue

            # Savepoint por item: se qualquer etapa abaixo falhar, só este item é desfeito
            # (paciente, ficha, avaliação e utensílios); os demais itens do lote seguem normalmente.
            with db.begin_nested():
                # 2. Paciente
                id_paciente_criado = item.id_paciente
                if item.paciente and not id_paciente_criado:
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

            with db.begin_nested():
                nova_ficha = criar_ficha_completa(
                    db=db,
                    dados=item,
                    id_responsavel=id_responsavel,
                    id_condutor=item.id_condutor,
                    id_paciente=id_paciente_criado,
                    id_tecnico=item.id_tecnico,
                    id_medico=item.id_medico,
                    id_base=item.id_base,
                    id_hospital=item.id_hospital,
                    cep=item.cep,
                    logradouro=item.logradouro,
                    bairro=item.bairro,
                    numero=item.numero,
                    latitude=item.latitude,
                    longitude=item.longitude,
                    gps_endereco_destino=item.gps_endereco_destino,
                    hora_chamado=item.hora_chamado or datetime.utcnow(),
                    hora_saida_base=item.hora_saida_base,
                    hora_chegada_local=item.hora_chegada_local,
                    hora_saida_local=item.hora_saida_local,
                    hora_chegada_hospital=item.hora_chegada_hospital,
                    hora_conclusao=item.hora_conclusao,
                    codigo_local=item.codigo_local,
                    unidade_parada=item.unidade_parada,
                    motivo_unidade_parada=item.motivo_unidade_parada,
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
                        abertura_ocular=item.avaliacao_clinica.abertura_ocular,
                        resposta_verbal=item.avaliacao_clinica.resposta_verbal,
                        resposta_motora=item.avaliacao_clinica.resposta_motora,
                        hemoglicoteste=item.avaliacao_clinica.hemoglicoteste,
                        hora_ictus=item.avaliacao_clinica.hora_ictus,
                        nome_testemunha=item.avaliacao_clinica.nome_testemunha,
                        usa_anticoagulante=item.avaliacao_clinica.usa_anticoagulante,
                        assimetria_facial=item.avaliacao_clinica.assimetria_facial,
                        queda_braco=item.avaliacao_clinica.queda_braco,
                        fala=item.avaliacao_clinica.fala,
                        avc_suspeito=item.avaliacao_clinica.avc_suspeito,
                        material_retido=item.avaliacao_clinica.material_retido,
                        anotacao_CondutaEnfermeiro=item.avaliacao_clinica.anotacao_CondutaEnfermeiro,
                        procedimentos_realizados=item.avaliacao_clinica.procedimentos_realizados,
                        medicacoes_administradas=item.avaliacao_clinica.medicacoes_administradas,
                        conduta=item.avaliacao_clinica.conduta,
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
