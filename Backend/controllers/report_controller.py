from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, date
from typing import Optional, List, Dict, Any

from database import get_db
from models import FichaAtendimento, UnidadeMovel
from schemas import DashboardMetricasGeraisResponse
from services.report_service import calcular_metricas_dashboard

router = APIRouter(prefix="/reports", tags=["Relatórios e Dashboard Web (C4 Nível 3/4)"])

#GET /api/reports/dashboard (Volume total, atendimentos hoje, tempo médio de resposta, faixas etárias, bairros com maior incidência e consumo de insumos)
#GET /api/reports/paradas-viaturas (Monitoramento de paradas de ambulâncias e motivos).

@router.get("/dashboard", response_model=DashboardMetricasGeraisResponse)
def get_dashboard_gerencial(db: Session = Depends(get_db)):
    """
    Retorna métricas consolidadas para o Dashboard da Interface Web Administrativa:
    - Volume total de atendimentos (RF13)
    - Tempo médio de resposta (RF16)
    - Faixa etária dos pacientes (RF14)
    - Locais com maior ocorrência (RF15)
    - Monitoramento de paradas de ambulâncias (RF11, RF12)
    - Consumo e reposição de utensílios gastos pela equipe
    """
    return calcular_metricas_dashboard(db)

@router.get("/paradas-viaturas")
def get_paradas_viaturas(db: Session = Depends(get_db)):
    """
    Monitoramento em tempo real de ambulâncias paradas e seus motivos (RF11, RF12).
    """
    unidades_paradas = db.query(UnidadeMovel).filter(UnidadeMovel.status == "PARADA").all()
    fichas_paradas = db.query(FichaAtendimento).filter(FichaAtendimento.unidade_parada == True).all()

    return {
        "total_paradas": len(unidades_paradas),
        "unidades": [
            {
                "id_unidade": u.id_unidade,
                "placa": u.placa,
                "base_unidade": u.base_unidade,
                "status": u.status,
                "motivo": u.motivo_parada,
                "atualizado_em": u.atualizado_em,
            }
            for u in unidades_paradas
        ],
        "historico_fichas_com_parada": [
            {
                "id_ficha": f.id_ficha,
                "id_unidade": f.id_unidade,
                "motivo": f.motivo_unidade_parada,
                "data": f.data_atendimento,
            }
            for f in fichas_paradas
        ]
    }
