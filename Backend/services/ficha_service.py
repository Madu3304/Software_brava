# Backend/services/ficha_service.py
from datetime import datetime
from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import func
from models import FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios, UnidadeMovel
from schemas import (
    FichaAtendimentoCreate,
    FichaResumoResponse,
    FichaDetalhadaReposicaoResponse,
    AvaliacaoClinicaResumoSchema,
    UtensiliosGastosSchema,
    MarcarReposicaoRequest,
    DashboardReposicaoResumoResponse,
)
from services.validation_service import validar_regras_clinicas_ficha, ErroValidacaoClinica

def criar_ficha_completa(
    db: Session,
    dados: FichaAtendimentoCreate,
    id_responsavel: Optional[int] = None,
) -> FichaAtendimento:

    # 0. Validação clínica e de regras de negócio
    valido, erros = validar_regras_clinicas_ficha(dados)
    if not valido:
        raise ErroValidacaoClinica(erros)

    # 1. Cria ou vincula paciente
    id_paciente_criado = dados.id_paciente
    if dados.paciente and not id_paciente_criado:
        novo_paciente = Paciente(
            nome=dados.paciente.nome,
            idade=dados.paciente.idade,
            sexo=dados.paciente.sexo,
            documento=dados.paciente.documento,
            data_nascimento=dados.paciente.data_nascimento,
            acompanhante=dados.paciente.acompanhante,
            grau_parentesco=dados.paciente.grau_parentesco,
            telefone_acompanhante=dados.paciente.telefone_acompanhante,
            gravidade_previa=dados.paciente.gravidade_previa,
            historico_clinico=dados.paciente.historico_clinico,
            alergias=dados.paciente.alergias,
            medicamentoUso_paciente=dados.paciente.medicamentoUso_paciente,
            observacao_paciente=dados.paciente.observacao_paciente,
        )
        db.add(novo_paciente)
        db.flush()
        id_paciente_criado = novo_paciente.id_paciente

    # 2. Cria ficha de atendimento com todos os campos
    nova_ficha = FichaAtendimento(
        uuid_offline=dados.uuid_offline,
        id_unidade=dados.id_unidade,
        id_responsavel=id_responsavel,
        id_condutor=dados.id_condutor,
        id_paciente=id_paciente_criado,
        id_tecnico=dados.id_tecnico,
        id_medico=dados.id_medico,
        id_base=dados.id_base,
        id_hospital=dados.id_hospital,
        cep=dados.cep,
        logradouro=dados.logradouro,
        bairro=dados.bairro,
        numero=dados.numero,
        latitude=dados.latitude,
        longitude=dados.longitude,
        gps_endereco_destino=dados.gps_endereco_destino,
        hora_chamado=dados.hora_chamado or datetime.utcnow(),
        hora_saida_base=dados.hora_saida_base,
        hora_chegada_local=dados.hora_chegada_local,
        hora_saida_local=dados.hora_saida_local,
        hora_chegada_hospital=dados.hora_chegada_hospital,
        hora_conclusao=dados.hora_conclusao,
        codigo_local=dados.codigo_local,
        unidade_parada=dados.unidade_parada,
        motivo_unidade_parada=dados.motivo_unidade_parada,
        observacoes_gerais=dados.observacoes_gerais,
    )
    db.add(nova_ficha)
    db.flush()

    # 3. Cria Avaliação Clínica completa (com Glasgow e AVC)
    id_avaliacao_criada = None
    if dados.avaliacao_clinica:
        nova_avaliacao = AvaliacaoClinica(
            id_ficha=nova_ficha.id_ficha,
            id_paciente=id_paciente_criado,
            pressao_arterial=dados.avaliacao_clinica.pressao_arterial,
            frequencia_cardiaca=dados.avaliacao_clinica.frequencia_cardiaca,
            frequencia_respiratoria=dados.avaliacao_clinica.frequencia_respiratoria,
            saturacao_o2=dados.avaliacao_clinica.saturacao_o2,
            glicemia=dados.avaliacao_clinica.glicemia,
            temperatura=dados.avaliacao_clinica.temperatura,
            escala_glasgow=dados.avaliacao_clinica.escala_glasgow,
            abertura_ocular=dados.avaliacao_clinica.abertura_ocular,
            resposta_verbal=dados.avaliacao_clinica.resposta_verbal,
            resposta_motora=dados.avaliacao_clinica.resposta_motora,
            hemoglicoteste=dados.avaliacao_clinica.hemoglicoteste,
            hora_ictus=dados.avaliacao_clinica.hora_ictus,
            nome_testemunha=dados.avaliacao_clinica.nome_testemunha,
            usa_anticoagulante=dados.avaliacao_clinica.usa_anticoagulante,
            assimetria_facial=dados.avaliacao_clinica.assimetria_facial,
            queda_braco=dados.avaliacao_clinica.queda_braco,
            fala=dados.avaliacao_clinica.fala,
            avc_suspeito=dados.avaliacao_clinica.avc_suspeito,
            material_retido=dados.avaliacao_clinica.material_retido,
            anotacao_CondutaEnfermeiro=dados.avaliacao_clinica.anotacao_CondutaEnfermeiro,
            procedimentos_realizados=dados.avaliacao_clinica.procedimentos_realizados,
            medicacoes_administradas=dados.avaliacao_clinica.medicacoes_administradas,
            conduta=dados.avaliacao_clinica.conduta,
        )
        db.add(nova_avaliacao)
        db.flush()
        id_avaliacao_criada = nova_avaliacao.id_avaliacao

    # 4. Cria Utensílios Gastos
    if dados.utensilios_gastos:
        novos_utensilios = Utensilios(
            id_ficha=nova_ficha.id_ficha,
            id_avaliacao=id_avaliacao_criada,
            medicamentos_ampolas=dados.utensilios_gastos.medicamentos_ampolas,
            medicamentos_controlados=dados.utensilios_gastos.medicamentos_controlados,
            medicamentos_comprimidos=dados.utensilios_gastos.medicamentos_comprimidos,
            medicamentos_frascoGotas=dados.utensilios_gastos.medicamentos_frascoGotas,
            anestesico=dados.utensilios_gastos.anestesico,
            material_infusao=dados.utensilios_gastos.material_infusao,
            material_sondagem=dados.utensilios_gastos.material_sondagem,
            material_trauma=dados.utensilios_gastos.material_trauma,
            materiais_diversos=dados.utensilios_gastos.materiais_diversos,
            observacoes_reposicao=dados.utensilios_gastos.observacoes_reposicao,
            reposto=dados.utensilios_gastos.reposto,
        )
        db.add(novos_utensilios)

    return nova_ficha

def listar_fichas_com_sinais_vitais(db: Session) -> list[FichaResumoResponse]:
    """Retorna listagem simples de atendimentos com nome do paciente e PA."""
    resultados = (
        db.query(FichaAtendimento, Paciente, AvaliacaoClinica)
        .outerjoin(Paciente, FichaAtendimento.id_paciente == Paciente.id_paciente)
        .outerjoin(AvaliacaoClinica, FichaAtendimento.id_ficha == AvaliacaoClinica.id_ficha)
        .all()
    )

    lista_formatada = []
    for ficha, paciente, avaliacao in resultados:
        lista_formatada.append(
            FichaResumoResponse(
                id_ficha=ficha.id_ficha,
                nome_paciente=paciente.nome if (paciente and paciente.nome) else "Não informado",
                pressao_arterial=avaliacao.pressao_arterial if (avaliacao and avaliacao.pressao_arterial) else "N/A"
            )
        )
    return lista_formatada

def buscar_ficha_consolidada_reposicao(db: Session, id_ficha: int) -> Optional[FichaDetalhadaReposicaoResponse]:
    """
    Busca uma ficha específica (ex: código 011) consolidando os dados da ficha,
    a avaliação clínica completa do paciente e os utensílios gastos para reposição.
    """
    resultado = (
        db.query(FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios, UnidadeMovel)
        .outerjoin(Paciente, FichaAtendimento.id_paciente == Paciente.id_paciente)
        .outerjoin(AvaliacaoClinica, FichaAtendimento.id_ficha == AvaliacaoClinica.id_ficha)
        .outerjoin(Utensilios, FichaAtendimento.id_ficha == Utensilios.id_ficha)
        .outerjoin(UnidadeMovel, FichaAtendimento.id_unidade == UnidadeMovel.id_unidade)
        .filter(FichaAtendimento.id_ficha == id_ficha)
        .first()
    )

    if not resultado:
        return None

    ficha, paciente, avaliacao, utensilios, unidade = resultado

    avaliacao_schema = None
    if avaliacao:
        avaliacao_schema = AvaliacaoClinicaResumoSchema(
            id_avaliacao=avaliacao.id_avaliacao,
            pressao_arterial=avaliacao.pressao_arterial,
            frequencia_cardiaca=avaliacao.frequencia_cardiaca,
            frequencia_respiratoria=avaliacao.frequencia_respiratoria,
            saturacao_o2=avaliacao.saturacao_o2,
            glicemia=avaliacao.glicemia,
            temperatura=float(avaliacao.temperatura) if avaliacao.temperatura is not None else None,
            escala_glasgow=avaliacao.escala_glasgow,
            conduta=avaliacao.conduta,
            anotacao_CondutaEnfermeiro=avaliacao.anotacao_CondutaEnfermeiro,
            procedimentos_realizados=avaliacao.procedimentos_realizados,
            medicacoes_administradas=avaliacao.medicacoes_administradas,
        )

    utensilios_schema = None
    if utensilios:
        utensilios_schema = UtensiliosGastosSchema(
            id_utensilios=utensilios.id_utensilios,
            medicamentos_ampolas=bool(utensilios.medicamentos_ampolas),
            medicamentos_controlados=bool(utensilios.medicamentos_controlados),
            medicamentos_comprimidos=bool(utensilios.medicamentos_comprimidos),
            medicamentos_frascoGotas=bool(utensilios.medicamentos_frascoGotas),
            anestesico=bool(utensilios.anestesico),
            material_infusao=bool(utensilios.material_infusao),
            material_sondagem=bool(utensilios.material_sondagem),
            material_trauma=bool(utensilios.material_trauma),
            materiais_diversos=bool(utensilios.materiais_diversos),
            observacoes_reposicao=utensilios.observacoes_reposicao,
            reposto=bool(utensilios.reposto),
            data_reposicao=utensilios.data_reposicao,
        )

    return FichaDetalhadaReposicaoResponse(
        id_ficha=ficha.id_ficha,
        data_atendimento=ficha.data_atendimento,
        status_envio_prefeitura=ficha.status_envio_prefeitura,
        protocolo_prefeitura=ficha.protocolo_prefeitura,
        placa_unidade=unidade.placa if unidade else None,
        nome_paciente=paciente.nome if paciente else "Não informado",
        idade_paciente=paciente.idade if paciente else None,
        sexo_paciente=paciente.sexo if paciente else None,
        avaliacao_clinica=avaliacao_schema,
        utensilios_gastos=utensilios_schema,
    )

def listar_fichas_para_reposicao(db: Session, apenas_pendentes: bool = True) -> List[FichaDetalhadaReposicaoResponse]:
    """
    Retorna a listagem para a tela de reposição do Técnico de Enfermagem.
    Permite filtrar apenas por atendimentos cujos materiais ainda não foram repostos.
    """
    query = (
        db.query(FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios, UnidadeMovel)
        .outerjoin(Paciente, FichaAtendimento.id_paciente == Paciente.id_paciente)
        .outerjoin(AvaliacaoClinica, FichaAtendimento.id_ficha == AvaliacaoClinica.id_ficha)
        .outerjoin(Utensilios, FichaAtendimento.id_ficha == Utensilios.id_ficha)
        .outerjoin(UnidadeMovel, FichaAtendimento.id_unidade == UnidadeMovel.id_unidade)
    )

    if apenas_pendentes:
        # Pega onde há utensílios não repostos ou registros sem reposição confirmada
        query = query.filter((Utensilios.reposto == False) | (Utensilios.id_utensilios == None))

    resultados = query.all()
    lista = []
    for ficha, paciente, avaliacao, utensilios, unidade in resultados:
        avaliacao_schema = (
            AvaliacaoClinicaResumoSchema(
                id_avaliacao=avaliacao.id_avaliacao,
                pressao_arterial=avaliacao.pressao_arterial,
                frequencia_cardiaca=avaliacao.frequencia_cardiaca,
                frequencia_respiratoria=avaliacao.frequencia_respiratoria,
                saturacao_o2=avaliacao.saturacao_o2,
                glicemia=avaliacao.glicemia,
                temperatura=float(avaliacao.temperatura) if avaliacao.temperatura is not None else None,
                escala_glasgow=avaliacao.escala_glasgow,
                conduta=avaliacao.conduta,
                anotacao_CondutaEnfermeiro=avaliacao.anotacao_CondutaEnfermeiro,
                procedimentos_realizados=avaliacao.procedimentos_realizados,
                medicacoes_administradas=avaliacao.medicacoes_administradas,
            )
            if avaliacao
            else None
        )

        utensilios_schema = (
            UtensiliosGastosSchema(
                id_utensilios=utensilios.id_utensilios,
                medicamentos_ampolas=bool(utensilios.medicamentos_ampolas),
                medicamentos_controlados=bool(utensilios.medicamentos_controlados),
                medicamentos_comprimidos=bool(utensilios.medicamentos_comprimidos),
                medicamentos_frascoGotas=bool(utensilios.medicamentos_frascoGotas),
                anestesico=bool(utensilios.anestesico),
                material_infusao=bool(utensilios.material_infusao),
                material_sondagem=bool(utensilios.material_sondagem),
                material_trauma=bool(utensilios.material_trauma),
                materiais_diversos=bool(utensilios.materiais_diversos),
                observacoes_reposicao=utensilios.observacoes_reposicao,
                reposto=bool(utensilios.reposto),
                data_reposicao=utensilios.data_reposicao,
            )
            if utensilios
            else None
        )

        lista.append(
            FichaDetalhadaReposicaoResponse(
                id_ficha=ficha.id_ficha,
                data_atendimento=ficha.data_atendimento,
                status_envio_prefeitura=ficha.status_envio_prefeitura,
                protocolo_prefeitura=ficha.protocolo_prefeitura,
                placa_unidade=unidade.placa if unidade else None,
                nome_paciente=paciente.nome if paciente else "Não informado",
                idade_paciente=paciente.idade if paciente else None,
                sexo_paciente=paciente.sexo if paciente else None,
                avaliacao_clinica=avaliacao_schema,
                utensilios_gastos=utensilios_schema,
            )
        )
    return lista

def registrar_reposicao_utensilios(db: Session, id_ficha: int, req: MarcarReposicaoRequest) -> bool:
    """Registra que o técnico de enfermagem repôs os materiais gastos da ficha."""
    utensilios = db.query(Utensilios).filter(Utensilios.id_ficha == id_ficha).first()
    if not utensilios:
        # Se não existia registro, cria um com status reposto
        utensilios = Utensilios(
            id_ficha=id_ficha,
            reposto=req.reposto,
            observacoes_reposicao=req.observacoes_reposicao,
            data_reposicao=datetime.utcnow() if req.reposto else None,
        )
        db.add(utensilios)
    else:
        utensilios.reposto = req.reposto
        if req.observacoes_reposicao:
            utensilios.observacoes_reposicao = req.observacoes_reposicao
        utensilios.data_reposicao = datetime.utcnow() if req.reposto else None

    db.commit()
    return True

def obter_metricas_reposicao_dashboard(db: Session) -> DashboardReposicaoResumoResponse:
    """Gera dados agregados para alimentar os gráficos do Dashboard Web."""
    total_fichas = db.query(func.count(FichaAtendimento.id_ficha)).scalar() or 0
    total_repostos = db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.reposto == True).scalar() or 0
    total_pendentes = db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.reposto == False).scalar() or 0

    consumo = {
        "ampolas": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.medicamentos_ampolas == True).scalar() or 0,
        "controlados": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.medicamentos_controlados == True).scalar() or 0,
        "comprimidos": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.medicamentos_comprimidos == True).scalar() or 0,
        "frasco_gotas": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.medicamentos_frascoGotas == True).scalar() or 0,
        "anestesico": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.anestesico == True).scalar() or 0,
        "infusao": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.material_infusao == True).scalar() or 0,
        "sondagem": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.material_sondagem == True).scalar() or 0,
        "trauma": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.material_trauma == True).scalar() or 0,
        "diversos": db.query(func.count(Utensilios.id_utensilios)).filter(Utensilios.materiais_diversos == True).scalar() or 0,
    }

    return DashboardReposicaoResumoResponse(
        total_atendimentos=total_fichas,
        total_pendentes_reposicao=total_pendentes,
        total_repostos=total_repostos,
        consumo_por_categoria=consumo,
    )
