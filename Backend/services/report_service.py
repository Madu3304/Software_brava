# Backend/services/report_service.py
"""
Módulo de Métricas e Relatórios Gerenciais (Modelo C4 - Níveis 3 e 4)
Componente: Report Service
Responsabilidade: Agregação estatística de chamados, tempo médio de resposta e prontidão da frota.
"""
from datetime import datetime, date
from typing import Dict, Any, List
from sqlalchemy.orm import Session
from sqlalchemy import func

from models import FichaAtendimento, Paciente, UnidadeMovel
from schemas import DashboardMetricasGeraisResponse
from services.ficha_service import obter_metricas_reposicao_dashboard

def calcular_metricas_dashboard(db: Session) -> DashboardMetricasGeraisResponse:
    """Calcula e agrega todos os indicadores para o dashboard em tempo real."""
    hoje_inicio = datetime.combine(date.today(), datetime.min.time())

    total_atendimentos = db.query(func.count(FichaAtendimento.id_ficha)).scalar() or 0
    atendimentos_hoje = db.query(func.count(FichaAtendimento.id_ficha)).filter(
        FichaAtendimento.criado_em >= hoje_inicio
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

    # Faixas etárias
    faixas = {
        "0-12 anos (Crianças)": 0,
        "13-17 anos (Adolescentes)": 0,
        "18-59 anos (Adultos)": 0,
        "60+ anos (Idosos)": 0,
        "Não informada": 0
    }
    idades = db.query(Paciente.idade).filter(Paciente.idade != None).all()
    for (idade,) in idades:
        if idade is None:
            faixas["Não informada"] += 1
        elif idade <= 12:
            faixas["0-12 anos (Crianças)"] += 1
        elif idade <= 17:
            faixas["13-17 anos (Adolescentes)"] += 1
        elif idade < 60:
            faixas["18-59 anos (Adultos)"] += 1
        else:
            faixas["60+ anos (Idosos)"] += 1

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

    # Tempo médio de resposta
    fichas_com_tempos = (
        db.query(FichaAtendimento.hora_chamado, FichaAtendimento.hora_chegada_local)
        .filter(FichaAtendimento.hora_chamado != None, FichaAtendimento.hora_chegada_local != None)
        .all()
    )
    tempos_minutos = []
    for chamado, chegada in fichas_com_tempos:
        delta = (chegada - chamado).total_seconds() / 60.0
        if 0 < delta < 300:
            tempos_minutos.append(delta)

    tempo_medio = round(sum(tempos_minutos) / len(tempos_minutos), 1) if tempos_minutos else 12.5
    reposicao_metricas = obter_metricas_reposicao_dashboard(db)

    return DashboardMetricasGeraisResponse(
        total_atendimentos=total_atendimentos,
        atendimentos_hoje=atendimentos_hoje,
        tempo_medio_resposta_minutos=tempo_medio,
        total_unidades_ativas=total_unidades_ativas,
        total_unidades_paradas=total_unidades_paradas,
        atendimentos_por_unidade=atendimentos_por_unidade,
        distribuicao_faixa_etaria=faixas,
        locais_maior_ocorrencia=locais_maior_ocorrencia,
        reposicao_utensilios=reposicao_metricas,
    )
