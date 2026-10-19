# Backend/services/validation_service.py
"""
Módulo de Validação de Regras de Negócio e Saúde (Modelo C4 - Níveis 3 e 4)
Componente: Validation Service
Responsabilidade: Validação de campos clínicos críticos, obrigatoriedade de identificação médica e consistência dos atendimentos.
"""
import re
from typing import List, Tuple, Optional
from schemas import FichaAtendimentoCreate, AvaliacaoClinicaResumoSchema

class ErroValidacaoClinica(Exception):
    def __init__(self, erros: List[str]):
        super().__init__("; ".join(erros))
        self.erros = erros

def validar_formato_pressao_arterial(pa: Optional[str]) -> bool:
    """Valida se a pressão arterial segue o padrão comum (ex: '120/80', '140/90', '12/8')."""
    if not pa or pa.upper() == "N/A":
        return True
    padrao = r"^\d{2,3}\s*[/xX]\s*\d{2,3}$"
    return bool(re.match(padrao, pa.strip()))

def validar_regras_clinicas_ficha(dados: FichaAtendimentoCreate) -> Tuple[bool, List[str]]:
    """
    Executa a validação de regras de negócio essenciais conforme a RFC:
    - RN02: Campos obrigatórios do atendimento
    - RN03: Validação de campos críticos de saúde
    - RN10: Identificação obrigatória do profissional responsável
    - RN11/RN12: Identificação obrigatória do médico de plantão
    """
    erros = []

    # 1. Validação de Unidade e Responsável (RN03, RN10)
    if not dados.id_unidade:
        erros.append("A Unidade Móvel (Brava) é obrigatória.")
    if not dados.id_responsavel:
        erros.append("O profissional responsável pelo atendimento é obrigatório (RN10).")

    # 2. Validação do Médico de Plantão (RN11, RN12)
    if not dados.id_medico:
        erros.append("A identificação do médico de plantão é obrigatória para o fechamento da ocorrência (RN11/RN12).")

    # 3. Validação dos Sinais Vitais (se houver avaliação clínica)
    if dados.avaliacao_clinica:
        av = dados.avaliacao_clinica
        if av.pressao_arterial and not validar_formato_pressao_arterial(av.pressao_arterial):
            erros.append(f"Formato inválido de Pressão Arterial: '{av.pressao_arterial}'. Use o padrão '120/80'.")

        if av.frequencia_cardiaca is not None and not (20 <= av.frequencia_cardiaca <= 250):
            erros.append(f"Frequência cardíaca fora dos parâmetros fisiológicos válidos ({av.frequencia_cardiaca} bpm).")

        if av.escala_glasgow is not None and not (3 <= av.escala_glasgow <= 15):
            erros.append(f"A pontuação na Escala de Glasgow deve estar entre 3 e 15 (informado: {av.escala_glasgow}).")

        if av.saturacao_o2 is not None and not (40 <= av.saturacao_o2 <= 100):
            erros.append(f"A saturação de O2 deve estar entre 40% e 100% (informado: {av.saturacao_o2}%).")

    # 4. Validação de status de viatura parada (RF11)
    if dados.unidade_parada and not (dados.motivo_unidade_parada or "").strip():
        erros.append("Quando a unidade estiver marcada como parada, o motivo da parada é obrigatório (RF11).")

    return (len(erros) == 0, erros)
