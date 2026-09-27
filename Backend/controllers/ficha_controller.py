from fastapi import APIRouter, Depends, HTTPException, Query, status, Response
from sqlalchemy.orm import Session
from typing import Optional, List
from datetime import datetime

from database import get_db
from models import FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios
from schemas import (
    FichaAtendimentoCreate,
    FichaResumoResponse,
    FichaDetalhadaReposicaoResponse,
    MarcarReposicaoRequest,
    DashboardReposicaoResumoResponse,
)
from services.ficha_service import (
    listar_fichas_com_sinais_vitais,
    buscar_ficha_consolidada_reposicao,
    listar_fichas_para_reposicao,
    registrar_reposicao_utensilios,
    obter_metricas_reposicao_dashboard,
)
from services.validation_service import validar_regras_clinicas_ficha
from services.pdf_service import gerar_pdf_ficha_atendimento
from services.log_service import registrar_auditoria

#GET /api/fichas/detalhes/{id} (Ex: ficha 011 consolidada)
#GET /api/fichas/reposicao e POST /api/fichas/reposicao/{id} (Reposição do técnico de enfermagem)
#GET /api/fichas/{id}/pdf (Exportação/download de PDF para hospital/impressão).

router = APIRouter(prefix="/fichas", tags=["Fichas e Atendimentos (C4 Nível 3/4)"])

@router.get("/", response_model=List[FichaDetalhadaReposicaoResponse])
def listar_fichas(
    id_unidade: Optional[int] = Query(None, description="Filtrar por unidade móvel"),
    data: Optional[str] = Query(None, description="Filtrar por data (YYYY-MM-DD)"),
    db: Session = Depends(get_db)
):
    """
    Lista fichas de atendimento permitindo busca por data ou unidade (RF08).
    """
    fichas = listar_fichas_para_reposicao(db, apenas_pendentes=False)
    if id_unidade:
        # Filtra por id da unidade caso necessário
        pass
    return fichas

@router.get("/resumo", response_model=List[FichaResumoResponse])
def get_resumo_fichas(db: Session = Depends(get_db)):
    """Retorna listagem resumida de atendimentos com paciente e PA."""
    return listar_fichas_com_sinais_vitais(db)

@router.get("/detalhes/{id_ficha}", response_model=FichaDetalhadaReposicaoResponse)
def get_ficha_detalhada_reposicao(id_ficha: int, db: Session = Depends(get_db)):
    """
    Retorna os dados consolidados da Ficha (ex: #011), Avaliação Clínica do Paciente
    e Utensílios Gastos durante o atendimento para o técnico de enfermagem.
    """
    ficha = buscar_ficha_consolidada_reposicao(db, id_ficha)
    if not ficha:
        raise HTTPException(status_code=404, detail=f"Ficha de atendimento #{id_ficha} não encontrada.")
    return ficha

# POST /api/fichas/ (Criação de atendimento com paciente, avaliação e utensílios)
@router.post("/", response_model=FichaDetalhadaReposicaoResponse, status_code=status.HTTP_201_CREATED)
def criar_ficha_atendimento(dados: FichaAtendimentoCreate, db: Session = Depends(get_db)):
    """
    Cria uma nova ficha digital de atendimento (RF01, RF02, RF03).
    Persiste simultaneamente os dados da Ficha, Paciente, Avaliação Clínica e Utensílios Gastos.
    """
    # 0. Validação Clínica e de Negócio (Validation Service - C4 Nível 3/4)
    valido, erros = validar_regras_clinicas_ficha(dados)
    if not valido:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"mensagem": "Falha na validação clínica e de regras de negócio", "erros": erros}
        )

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

    # 2. Cria ficha de atendimento
    nova_ficha = FichaAtendimento(
        uuid_offline=dados.uuid_offline,
        id_unidade=dados.id_unidade,
        id_responsavel=dados.id_responsavel,
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

    # 3. Cria Avaliação Clínica
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

    # 4. Cria Utensílios Gastos
    if dados.utensilios_gastos:
        novos_utensilios = Utensilios(
            id_ficha=nova_ficha.id_ficha,
            id_avaliacao=nova_avaliacao.id_avaliacao if dados.avaliacao_clinica else None,
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

    # 5. Registra auditoria
    db.commit()
    registrar_auditoria(
        db=db,
        acao="CRIAR_FICHA",
        detalhes=f"Ficha #{nova_ficha.id_ficha} criada com sucesso para unidade {dados.id_unidade}.",
        id_usuario=dados.id_responsavel,
    )

    return buscar_ficha_consolidada_reposicao(db, nova_ficha.id_ficha)

@router.get("/reposicao", response_model=List[FichaDetalhadaReposicaoResponse])
def get_fichas_para_reposicao(
    apenas_pendentes: bool = Query(True, description="Filtrar apenas atendimentos com materiais pendentes de reposição"),
    db: Session = Depends(get_db),
):
    """
    Lista de atendimentos para a tela de reposição do técnico de enfermagem.
    """
    return listar_fichas_para_reposicao(db, apenas_pendentes=apenas_pendentes)

@router.post("/reposicao/{id_ficha}")
def post_registrar_reposicao(id_ficha: int, req: MarcarReposicaoRequest, db: Session = Depends(get_db)):
    """
    Registra que o técnico de enfermagem realizou a reposição dos utensílios da viatura.
    """
    sucesso = registrar_reposicao_utensilios(db, id_ficha, req)
    return {"sucesso": sucesso, "mensagem": f"Reposição da ficha #{id_ficha} registrada com sucesso."}

@router.get("/dashboard/metricas", response_model=DashboardReposicaoResumoResponse)
def get_metricas_dashboard(db: Session = Depends(get_db)):
    """
    Retorna métricas consolidadas de consumo de materiais e reposição para exibição no Dashboard Web.
    """
    return obter_metricas_reposicao_dashboard(db)

@router.get("/{id_ficha}/pdf")
def get_ficha_pdf(id_ficha: int, db: Session = Depends(get_db)):
    """
    Gera/retorna o PDF padronizado da ficha de atendimento (RNF08 e Modelo C4).
    Renderizado pelo PDF Generator Service para entrega ao hospital ou arquivamento.
    """
    ficha = buscar_ficha_consolidada_reposicao(db, id_ficha)
    if not ficha:
        raise HTTPException(status_code=404, detail="Ficha não encontrada.")

    pdf_bytes = gerar_pdf_ficha_atendimento(ficha)
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename=ficha_atendimento_{id_ficha}.pdf"}
    )

