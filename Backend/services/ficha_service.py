# Backend/services/ficha_service.py
from datetime import date, datetime, time, timedelta, timezone
from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import func, case
from models import FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios, UnidadeMovel
from schemas import (
    FichaAtendimentoCreate,
    FichaResumoResponse,
    FichaDetalhadaReposicaoResponse,
    AvaliacaoClinicaResumoSchema,
    UtensiliosGastosSchema,
    MarcarReposicaoRequest,
    DashboardReposicaoResumoResponse,
    calcular_idade_de_nascimento,
)
from services.validation_service import validar_regras_clinicas_ficha, ErroValidacaoClinica

def criar_ficha_completa(
    db: Session,
    dados: FichaAtendimentoCreate,
    id_responsavel: Optional[int] = None,
) -> FichaAtendimento:
    """
    Valida e persiste uma FichaAtendimento completa com Paciente, AvaliacaoClinica e Utensilios.
    Utilizada tanto pela criação online (POST /api/fichas/) quanto pelo sync offline (POST /api/sync/lote).
    """
    valido, erros = validar_regras_clinicas_ficha(dados)
    if not valido:
        raise ErroValidacaoClinica(erros)

    id_paciente_criado = dados.id_paciente
    if dados.paciente and not id_paciente_criado:
        idade_final = dados.paciente.idade
        if dados.paciente.data_nascimento:
            idade_calc = calcular_idade_de_nascimento(dados.paciente.data_nascimento)
            if idade_calc is not None:
                idade_final = idade_calc

        novo_paciente = Paciente(
            nome=dados.paciente.nome,
            idade=idade_final,
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
        hora_chamado=dados.hora_chamado or datetime.now(timezone.utc),
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

    # Cria Utensílios Gastos
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

def _montar_avaliacao_schema(avaliacao: Optional[AvaliacaoClinica]) -> Optional[AvaliacaoClinicaResumoSchema]:
    if not avaliacao:
        return None
    return AvaliacaoClinicaResumoSchema(
        id_avaliacao=avaliacao.id_avaliacao,
        pressao_arterial=avaliacao.pressao_arterial,
        frequencia_cardiaca=avaliacao.frequencia_cardiaca,
        frequencia_respiratoria=avaliacao.frequencia_respiratoria,
        saturacao_o2=avaliacao.saturacao_o2,
        glicemia=avaliacao.glicemia,
        temperatura=float(avaliacao.temperatura) if avaliacao.temperatura is not None else None,
        escala_glasgow=avaliacao.escala_glasgow,
        abertura_ocular=avaliacao.abertura_ocular,
        resposta_verbal=avaliacao.resposta_verbal,
        resposta_motora=avaliacao.resposta_motora,
        hemoglicoteste=avaliacao.hemoglicoteste,
        hora_ictus=avaliacao.hora_ictus,
        nome_testemunha=avaliacao.nome_testemunha,
        usa_anticoagulante=avaliacao.usa_anticoagulante,
        assimetria_facial=avaliacao.assimetria_facial,
        queda_braco=avaliacao.queda_braco,
        fala=avaliacao.fala,
        avc_suspeito=avaliacao.avc_suspeito,
        material_retido=avaliacao.material_retido,
        anotacao_CondutaEnfermeiro=avaliacao.anotacao_CondutaEnfermeiro,
        procedimentos_realizados=avaliacao.procedimentos_realizados,
        medicacoes_administradas=avaliacao.medicacoes_administradas,
        conduta=avaliacao.conduta,
    )

def _montar_utensilios_schema(utensilios: Optional[Utensilios]) -> Optional[UtensiliosGastosSchema]:
    if not utensilios:
        return None
    return UtensiliosGastosSchema(
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

def buscar_ficha_consolidada_reposicao(db: Session, id_ficha: int) -> Optional[FichaDetalhadaReposicaoResponse]:
    """
    Busca uma ficha específica consolidando os dados da ficha,
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

    return FichaDetalhadaReposicaoResponse(
        id_ficha=ficha.id_ficha,
        uuid_offline=ficha.uuid_offline,
        bairro=ficha.bairro,
        data_atendimento=ficha.data_atendimento,
        status_envio_prefeitura=ficha.status_envio_prefeitura,
        protocolo_prefeitura=ficha.protocolo_prefeitura,
        placa_unidade=unidade.placa if unidade else None,
        nome_paciente=paciente.nome if paciente else "Não informado",
        idade_paciente=paciente.idade if paciente else None,
        sexo_paciente=paciente.sexo if paciente else None,
        avaliacao_clinica=_montar_avaliacao_schema(avaliacao),
        utensilios_gastos=_montar_utensilios_schema(utensilios),
    )

def aplicar_filtros_fichas(query, id_unidade: Optional[int] = None, data: Optional[date] = None):
    """Aplica os filtros de unidade móvel e de data do atendimento (dia inteiro) na query de fichas (RF08)."""
    if id_unidade is not None:
        query = query.filter(FichaAtendimento.id_unidade == id_unidade)
    if data is not None:
        inicio_dia = datetime.combine(data, time.min)
        query = query.filter(
            FichaAtendimento.data_atendimento >= inicio_dia,
            FichaAtendimento.data_atendimento < inicio_dia + timedelta(days=1),
        )
    return query

def contar_fichas(db: Session, id_unidade: Optional[int] = None, data: Optional[date] = None) -> int:
    """Total de fichas com os mesmos filtros da listagem (usado na paginação)."""
    query = aplicar_filtros_fichas(db.query(func.count(FichaAtendimento.id_ficha)), id_unidade, data)
    return query.scalar() or 0

def listar_fichas_para_reposicao(
    db: Session,
    apenas_pendentes: bool = True,
    id_unidade: Optional[int] = None,
    data: Optional[date] = None,
    skip: int = 0,
    limit: Optional[int] = None,
) -> List[FichaDetalhadaReposicaoResponse]:
    """
    Retorna a listagem para a tela de reposição do Técnico de Enfermagem.
    Permite filtrar apenas por atendimentos cujos materiais ainda não foram repostos,
    por unidade móvel e por data, com paginação (skip/limit). Mais recentes primeiro.
    """
    query = (
        db.query(FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios, UnidadeMovel)
        .outerjoin(Paciente, FichaAtendimento.id_paciente == Paciente.id_paciente)
        .outerjoin(AvaliacaoClinica, FichaAtendimento.id_ficha == AvaliacaoClinica.id_ficha)
        .outerjoin(Utensilios, FichaAtendimento.id_ficha == Utensilios.id_ficha)
        .outerjoin(UnidadeMovel, FichaAtendimento.id_unidade == UnidadeMovel.id_unidade)
    )

    if apenas_pendentes:
        query = query.filter((Utensilios.reposto == False) | (Utensilios.id_utensilios == None))

    query = aplicar_filtros_fichas(query, id_unidade, data)
    query = query.order_by(FichaAtendimento.data_atendimento.desc(), FichaAtendimento.id_ficha.desc())
    if skip:
        query = query.offset(skip)
    if limit is not None:
        query = query.limit(limit)

    resultados = query.all()
    lista = []
    for ficha, paciente, avaliacao, utensilios, unidade in resultados:
        lista.append(
            FichaDetalhadaReposicaoResponse(
                id_ficha=ficha.id_ficha,
                uuid_offline=ficha.uuid_offline,
                bairro=ficha.bairro,
                data_atendimento=ficha.data_atendimento,
                status_envio_prefeitura=ficha.status_envio_prefeitura,
                protocolo_prefeitura=ficha.protocolo_prefeitura,
                placa_unidade=unidade.placa if unidade else None,
                nome_paciente=paciente.nome if paciente else "Não informado",
                idade_paciente=paciente.idade if paciente else None,
                sexo_paciente=paciente.sexo if paciente else None,
                avaliacao_clinica=_montar_avaliacao_schema(avaliacao),
                utensilios_gastos=_montar_utensilios_schema(utensilios),
            )
        )
    return lista

def registrar_reposicao_utensilios(db: Session, id_ficha: int, req: MarcarReposicaoRequest) -> bool:
    """Registra que o técnico de enfermagem repôs os materiais gastos da ficha."""
    ficha = db.query(FichaAtendimento).filter(FichaAtendimento.id_ficha == id_ficha).first()
    if not ficha:
        return False

    utensilios = db.query(Utensilios).filter(Utensilios.id_ficha == id_ficha).first()
    if not utensilios:
        utensilios = Utensilios(
            id_ficha=id_ficha,
            reposto=req.reposto,
            observacoes_reposicao=req.observacoes_reposicao,
            data_reposicao=datetime.now(timezone.utc) if req.reposto else None,
        )
        db.add(utensilios)
    else:
        utensilios.reposto = req.reposto
        if req.observacoes_reposicao:
            utensilios.observacoes_reposicao = req.observacoes_reposicao
        utensilios.data_reposicao = datetime.now(timezone.utc) if req.reposto else None

    db.commit()
    return True

def obter_metricas_reposicao_dashboard(db: Session) -> DashboardReposicaoResumoResponse:
    """Gera dados agregados para alimentar os gráficos do Dashboard Web."""
    total_fichas = db.query(func.count(FichaAtendimento.id_ficha)).scalar() or 0

    row = db.query(
        func.sum(case((Utensilios.reposto == True, 1), else_=0)).label("total_repostos"),
        func.sum(case((Utensilios.reposto == False, 1), else_=0)).label("total_pendentes"),
        func.sum(case((Utensilios.medicamentos_ampolas == True, 1), else_=0)).label("ampolas"),
        func.sum(case((Utensilios.medicamentos_controlados == True, 1), else_=0)).label("controlados"),
        func.sum(case((Utensilios.medicamentos_comprimidos == True, 1), else_=0)).label("comprimidos"),
        func.sum(case((Utensilios.medicamentos_frascoGotas == True, 1), else_=0)).label("frasco_gotas"),
        func.sum(case((Utensilios.anestesico == True, 1), else_=0)).label("anestesico"),
        func.sum(case((Utensilios.material_infusao == True, 1), else_=0)).label("infusao"),
        func.sum(case((Utensilios.material_sondagem == True, 1), else_=0)).label("sondagem"),
        func.sum(case((Utensilios.material_trauma == True, 1), else_=0)).label("trauma"),
        func.sum(case((Utensilios.materiais_diversos == True, 1), else_=0)).label("diversos"),
    ).first()

    total_repostos = int(row.total_repostos or 0) if row else 0
    total_pendentes = int(row.total_pendentes or 0) if row else 0
    consumo = {
        "ampolas": int(row.ampolas or 0) if row else 0,
        "controlados": int(row.controlados or 0) if row else 0,
        "comprimidos": int(row.comprimidos or 0) if row else 0,
        "frasco_gotas": int(row.frasco_gotas or 0) if row else 0,
        "anestesico": int(row.anestesico or 0) if row else 0,
        "infusao": int(row.infusao or 0) if row else 0,
        "sondagem": int(row.sondagem or 0) if row else 0,
        "trauma": int(row.trauma or 0) if row else 0,
        "diversos": int(row.diversos or 0) if row else 0,
    }

    return DashboardReposicaoResumoResponse(
        total_atendimentos=total_fichas,
        total_pendentes_reposicao=total_pendentes,
        total_repostos=total_repostos,
        consumo_por_categoria=consumo,
    )
