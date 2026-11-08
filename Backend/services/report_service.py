
from datetime import datetime, date, timezone, timedelta
from zoneinfo import ZoneInfo
from typing import Dict, Any, List
from sqlalchemy.orm import Session
from sqlalchemy import func, case

from models import FichaAtendimento, Paciente, UnidadeMovel
from schemas import DashboardMetricasGeraisResponse
from services.ficha_service import obter_metricas_reposicao_dashboard

def calcular_metricas_dashboard(db: Session) -> DashboardMetricasGeraisResponse:
    # Definição do fuso oficial America/Sao_Paulo (B21)
    try:
        fuso_sp = ZoneInfo("America/Sao_Paulo")
    except Exception:
        fuso_sp = timezone(timedelta(hours=-3))

    agora_sp = datetime.now(fuso_sp)
    hoje_inicio_sp = datetime.combine(agora_sp.date(), datetime.min.time(), tzinfo=fuso_sp)
    hoje_inicio_utc = hoje_inicio_sp.astimezone(timezone.utc).replace(tzinfo=None)

    total_atendimentos = db.query(func.count(FichaAtendimento.id_ficha)).scalar() or 0
    atendimentos_hoje = db.query(func.count(FichaAtendimento.id_ficha)).filter(
        (FichaAtendimento.criado_em >= hoje_inicio_sp) | (FichaAtendimento.criado_em >= hoje_inicio_utc)
    ).scalar() or 0

    total_unidades_ativas = db.query(func.count(UnidadeMovel.id_unidade)).filter(
        UnidadeMovel.status != "PARADA"
    ).scalar() or 0

    total_unidades_paradas = db.query(func.count(UnidadeMovel.id_unidade)).filter(
        UnidadeMovel.status == "PARADA"
    ).scalar() or 0

    # Atendimentos por unidade
    unidades_counts = (
        db.query(UnidadeMovel.base_unidade, func.count(FichaAtendimento.id_ficha))
        .join(FichaAtendimento, FichaAtendimento.id_unidade == UnidadeMovel.id_unidade)
        .group_by(UnidadeMovel.base_unidade)
        .all()
    )
    atendimentos_por_unidade = {
        unidade or "Não identificada": total for unidade, total in unidades_counts
    }

    # Faixas etárias calculadas em uma única query com func.sum(case(...))
    faixas_row = db.query(
        func.sum(case(((Paciente.idade != None) & (Paciente.idade <= 12), 1), else_=0)).label("criancas"),
        func.sum(case(((Paciente.idade >= 13) & (Paciente.idade <= 17), 1), else_=0)).label("adolescentes"),
        func.sum(case(((Paciente.idade >= 18) & (Paciente.idade <= 59), 1), else_=0)).label("adultos"),
        func.sum(case((Paciente.idade >= 60, 1), else_=0)).label("idosos"),
        func.sum(case((Paciente.idade == None, 1), else_=0)).label("nao_informada"),
    ).first()

    faixas = {
        "0-12 anos (Crianças)": int(faixas_row.criancas or 0) if faixas_row else 0,
        "13-17 anos (Adolescentes)": int(faixas_row.adolescentes or 0) if faixas_row else 0,
        "18-59 anos (Adultos)": int(faixas_row.adultos or 0) if faixas_row else 0,
        "60+ anos (Idosos)": int(faixas_row.idosos or 0) if faixas_row else 0,
        "Não informada": int(faixas_row.nao_informada or 0) if faixas_row else 0,
    }

    # Bairros com maior incidência
    bairros_query = (
        db.query(FichaAtendimento.bairro, func.count(FichaAtendimento.id_ficha).label("total"))
        .filter(FichaAtendimento.bairro != None)
        .group_by(FichaAtendimento.bairro)
        .order_by(func.count(FichaAtendimento.id_ficha).desc())
        .limit(5)
        .all()
    )
    locais_maior_ocorrencia = [
        {"bairro": bairro, "total": total} for bairro, total in bairros_query
    ]

    # Tempo médio de resposta calculado em uma única query com func.sum
    bind = db.get_bind()
    dialect = bind.dialect.name if bind else "sqlite"
    if dialect == "sqlite":
        diff_minutos = (func.strftime("%s", FichaAtendimento.hora_chegada_local) - func.strftime("%s", FichaAtendimento.hora_chamado)) / 60.0
    else:
        diff_minutos = func.extract("epoch", FichaAtendimento.hora_chegada_local - FichaAtendimento.hora_chamado) / 60.0

    cond_valida = (
        (FichaAtendimento.hora_chamado != None)
        & (FichaAtendimento.hora_chegada_local != None)
        & (diff_minutos > 0)
        & (diff_minutos < 300)
    )

    tempo_row = db.query(
        func.sum(case((cond_valida, diff_minutos), else_=0)).label("soma_minutos"),
        func.sum(case((cond_valida, 1), else_=0)).label("qtd_validos"),
    ).first()

    if tempo_row and tempo_row.qtd_validos and tempo_row.qtd_validos > 0:
        tempo_medio = round(float(tempo_row.soma_minutos) / float(tempo_row.qtd_validos), 1)
        tempo_medio_formatado = f"{tempo_medio} min"
    else:
        tempo_medio = None
        tempo_medio_formatado = "—"

    reposicao_metricas = obter_metricas_reposicao_dashboard(db)

    return DashboardMetricasGeraisResponse(
        total_atendimentos=total_atendimentos,
        atendimentos_hoje=atendimentos_hoje,
        tempo_medio_resposta_minutos=tempo_medio,
        tempo_medio_resposta_formatado=tempo_medio_formatado,
        tempo_medio_formatado=tempo_medio_formatado,
        total_unidades_ativas=total_unidades_ativas,
        total_unidades_paradas=total_unidades_paradas,
        atendimentos_por_unidade=atendimentos_por_unidade,
        distribuicao_faixa_etaria=faixas,
        locais_maior_ocorrencia=locais_maior_ocorrencia,
        reposicao_utensilios=reposicao_metricas,
    )
