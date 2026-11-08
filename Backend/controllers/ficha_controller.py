#    Gera/retorna o PDF padronizado da ficha de atendimento.

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Query, Request, status, Response
from sqlalchemy.orm import Session
from typing import Optional, List
from datetime import date, datetime

from database import get_db
from dependencies import get_usuario_atual, exigir_perfil, obter_ip_origem
from models import Usuario, FichaAtendimento, Paciente, AvaliacaoClinica, Utensilios
from schemas import (
    FichaAtendimentoCreate,
    FichaResumoResponse,
    FichaDetalhadaReposicaoResponse,
    MarcarReposicaoRequest,
    DashboardReposicaoResumoResponse,
    IntegracaoStatusResponse,
    IntegracaoReenvioResponse,
)
from services.ficha_service import (
    criar_ficha_completa,
    listar_fichas_com_sinais_vitais,
    buscar_ficha_consolidada_reposicao,
    listar_fichas_para_reposicao,
    contar_fichas,
    registrar_reposicao_utensilios,
    obter_metricas_reposicao_dashboard,
)
from services.validation_service import ErroValidacaoClinica
from services.pdf_service import gerar_pdf_ficha_atendimento
from services.log_service import registrar_auditoria
from services.integration_service import (
    enviar_ficha_para_prefeitura,
    enviar_fichas_para_prefeitura,
    STATUS_PENDENTE,
    STATUS_ENVIADO,
    STATUS_ERRO,
)

#GET /api/fichas/detalhes/{id} (Ex: ficha 011 consolidada)
#GET /api/fichas/reposicao e POST /api/fichas/reposicao/{id} (Reposição do técnico de enfermagem)
#GET /api/fichas/{id}/pdf (Exportação/download de PDF para hospital/impressão).

# Todas as rotas exigem usuário autenticado (token JWT)
router = APIRouter(
    prefix="/fichas",
    tags=["Fichas e Atendimentos (C4 Nível 3/4)"],
    dependencies=[Depends(get_usuario_atual)],
)

@router.get("/", response_model=List[FichaDetalhadaReposicaoResponse])
def listar_fichas(
    response: Response,
    id_unidade: Optional[int] = Query(None, description="Filtrar por unidade móvel"),
    data: Optional[date] = Query(None, description="Filtrar por data do atendimento (YYYY-MM-DD)"),
    skip: int = Query(0, ge=0, description="Quantidade de registros a pular (paginação)"),
    limit: int = Query(50, ge=1, le=200, description="Quantidade máxima de registros por página (1 a 200)"),
    db: Session = Depends(get_db)
):
    """
    Lista fichas de atendimento permitindo busca por data ou unidade (RF08), da mais recente para a mais antiga.
    Paginação com skip/limit; o total de fichas com os filtros aplicados vem no header X-Total-Count.
    """
    data_filtro = None
    if data:
        try:
            data_filtro = datetime.strptime(data, "%Y-%m-%d").date()
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Formato de data inválido. Use YYYY-MM-DD.",
            )
    return listar_fichas_para_reposicao(
        db,
        apenas_pendentes=False,
        id_unidade=id_unidade,
        data=data_filtro,
    )

@router.get("/resumo", response_model=List[FichaResumoResponse])
def get_resumo_fichas(db: Session = Depends(get_db)):
    """Retorna listagem resumida de atendimentos com paciente e PA."""
    return listar_fichas_com_sinais_vitais(db)

@router.get("/detalhes/{id_ficha}", response_model=FichaDetalhadaReposicaoResponse)
def get_ficha_detalhada_reposicao(id_ficha: int, db: Session = Depends(get_db)):
    
    #Retorna os dados consolidados da Ficha, Avaliação Clínica do Paciente
    ficha = buscar_ficha_consolidada_reposicao(db, id_ficha)
    if not ficha:
        raise HTTPException(status_code=404, detail=f"Ficha de atendimento #{id_ficha} não encontrada.")
    return ficha

@router.post("/", response_model=FichaDetalhadaReposicaoResponse, status_code=status.HTTP_201_CREATED)
def criar_ficha_atendimento(
    dados: FichaAtendimentoCreate,
    request: Request,
    background_tasks: BackgroundTasks,
    usuario: Usuario = Depends(get_usuario_atual),
    db: Session = Depends(get_db),
):
    
    # Cria uma nova ficha digital de atendiment.
    try:
        nova_ficha = criar_ficha_completa(
            db=db,
            dados=dados,
            id_responsavel=usuario.id_usuario,
        )
    except ErroValidacaoClinica as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"mensagem": "Falha na validação clínica e de regras de negócio", "erros": e.erros}
        )

    # Registra auditoria
    db.commit()
    registrar_auditoria(
        db=db,
        acao="CRIAR_FICHA",
        detalhes=f"Ficha #{nova_ficha.id_ficha} criada com sucesso para unidade {dados.id_unidade}.",
        id_usuario=usuario.id_usuario,
        ip_origem=obter_ip_origem(request),
    )

    # Envio à Prefeitura (RF06) somente depois do commit, em segundo plano
    background_tasks.add_task(enviar_ficha_para_prefeitura, nova_ficha.id_ficha)

    return buscar_ficha_consolidada_reposicao(db, nova_ficha.id_ficha)

# Integração com a Prefeitura (RF06): acompanhamento e reenvio, somente Administrador

@router.get(
    "/integracao/status",
    response_model=IntegracaoStatusResponse,
    dependencies=[Depends(exigir_perfil("ADMINISTRADOR"))],
)
def get_status_integracao(db: Session = Depends(get_db)):
    def contar(status_envio: str) -> int:
        return db.query(FichaAtendimento).filter(FichaAtendimento.status_envio_prefeitura == status_envio).count()

    fichas_erro = (
        db.query(FichaAtendimento)
        .filter(FichaAtendimento.status_envio_prefeitura == STATUS_ERRO)
        .order_by(FichaAtendimento.ultima_tentativa_envio.desc())
        .limit(100)
        .all()
    )
    return IntegracaoStatusResponse(
        pendentes=contar(STATUS_PENDENTE),
        enviados=contar(STATUS_ENVIADO),
        com_erro=contar(STATUS_ERRO),
        fichas_com_erro=[
            {
                "id_ficha": f.id_ficha,
                "uuid_offline": f.uuid_offline,
                "tentativas_envio": f.tentativas_envio,
                "ultima_tentativa_envio": f.ultima_tentativa_envio,
                "erro_envio": f.erro_envio,
            }
            for f in fichas_erro
        ],
    )

@router.post(
    "/integracao/reenviar",
    response_model=IntegracaoReenvioResponse,
    dependencies=[Depends(exigir_perfil("ADMINISTRADOR"))],
)
def reenviar_fichas_prefeitura(
    request: Request,
    background_tasks: BackgroundTasks,
    usuario: Usuario = Depends(get_usuario_atual),
    id_ficha: Optional[int] = Query(None, description="Reenviar só esta ficha. Sem o parâmetro, reenvia todas com status PENDENTE ou ERRO."),
    db: Session = Depends(get_db),
):
    query = db.query(FichaAtendimento.id_ficha).filter(
        FichaAtendimento.status_envio_prefeitura.in_([STATUS_PENDENTE, STATUS_ERRO])
    )
    if id_ficha is not None:
        query = query.filter(FichaAtendimento.id_ficha == id_ficha)
    ids = [linha.id_ficha for linha in query.all()]

    if id_ficha is not None and not ids:
        raise HTTPException(status_code=404, detail=f"Ficha #{id_ficha} não encontrada ou já enviada à Prefeitura.")

    if ids:
        background_tasks.add_task(enviar_fichas_para_prefeitura, ids)
    registrar_auditoria(
        db=db,
        acao="REENVIO_PREFEITURA",
        detalhes=f"Reenvio à Prefeitura agendado para {len(ids)} ficha(s).",
        id_usuario=usuario.id_usuario,
        ip_origem=obter_ip_origem(request),
    )
    return IntegracaoReenvioResponse(
        fichas_agendadas=len(ids),
        mensagem=f"Reenvio agendado para {len(ids)} ficha(s).",
    )

@router.get("/reposicao", response_model=List[FichaDetalhadaReposicaoResponse])
def get_fichas_para_reposicao(
    apenas_pendentes: bool = Query(True, description="Filtrar apenas atendimentos com materiais pendentes de reposição"),
    db: Session = Depends(get_db),
):
    return listar_fichas_para_reposicao(db, apenas_pendentes=apenas_pendentes)

@router.post("/reposicao/{id_ficha}")
def post_registrar_reposicao(
    id_ficha: int,
    req: MarcarReposicaoRequest,
    request: Request,
    usuario: Usuario = Depends(get_usuario_atual),
    db: Session = Depends(get_db),
):

    sucesso = registrar_reposicao_utensilios(db, id_ficha, req)
    if not sucesso:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Ficha de atendimento #{id_ficha} não encontrada."
        )

    registrar_auditoria(
        db=db,
        acao="REPOSICAO_UTENSILIOS",
        detalhes=f"Reposição da ficha #{id_ficha} marcada como {'reposta' if req.reposto else 'pendente'}.",
        id_usuario=usuario.id_usuario,
        ip_origem=obter_ip_origem(request),
    )
    return {"sucesso": True, "mensagem": f"Reposição da ficha #{id_ficha} registrada com sucesso."}

@router.get("/dashboard/metricas", response_model=DashboardReposicaoResumoResponse)
def get_metricas_dashboard(db: Session = Depends(get_db)):
    return obter_metricas_reposicao_dashboard(db)

@router.get("/{id_ficha}/pdf")
def get_ficha_pdf(id_ficha: int, db: Session = Depends(get_db)):
    ficha = buscar_ficha_consolidada_reposicao(db, id_ficha)
    if not ficha:
        raise HTTPException(status_code=404, detail="Ficha não encontrada.")

    pdf_bytes = gerar_pdf_ficha_atendimento(ficha)
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename=ficha_atendimento_{id_ficha}.pdf"}
    )

