# Backend/services/validation_service.py

import re
from typing import List, Tuple, Optional
from schemas import FichaAtendimentoCreate, AvaliacaoClinicaResumoSchema, validar_formato_cpf, mascarar_documento_lgpd

class ErroValidacaoClinica(Exception):
    def __init__(self, erros: List[str]):
        super().__init__("; ".join(erros))
        self.erros = erros

def validar_formato_pressao_arterial(pa: Optional[str]) -> bool:
    if not pa or pa.upper() == "N/A":
        return True
    padrao = r"^\d{2,3}\s*[/xX]\s*\d{2,3}$"
    return bool(re.match(padrao, pa.strip()))

def validar_regras_clinicas_ficha(dados: FichaAtendimentoCreate) -> Tuple[bool, List[str]]:

    erros = []

    if not dados.id_unidade:
        erros.append("A Unidade Móvel (Brava) é obrigatória.")

    if not dados.id_medico:
        erros.append("A identificação do médico de plantão é obrigatória para o fechamento da ocorrência (RN11/RN12).")

    if dados.avaliacao_clinica:
        av = dados.avaliacao_clinica
        
        if av.pressao_arterial and not validar_formato_pressao_arterial(av.pressao_arterial):
            erros.append(f"Formato inválido de Pressão Arterial: '{av.pressao_arterial}'. Use o padrão '120/80'.")

        if av.frequencia_cardiaca is not None and not (20 <= av.frequencia_cardiaca <= 250):
            erros.append(f"Frequência cardíaca fora dos parâmetros fisiológicos válidos ({av.frequencia_cardiaca} bpm).")

        if av.frequencia_respiratoria is not None and not (5 <= av.frequencia_respiratoria <= 60):
            erros.append(f"Frequência respiratória fora dos parâmetros fisiológicos válidos ({av.frequencia_respiratoria} rpm).")

        if av.temperatura is not None and not (25.0 <= float(av.temperatura) <= 45.0):
            erros.append(f"Temperatura corporal fora dos parâmetros fisiológicos válidos ({av.temperatura} °C).")

        glic = av.glicemia if av.glicemia is not None else av.hemoglicoteste
        if glic is not None and not (10 <= glic <= 800):
            erros.append(f"Glicemia/Hemoglicoteste fora dos parâmetros válidos ({glic} mg/dL).")

        if av.saturacao_o2 is not None and not (40 <= av.saturacao_o2 <= 100):
            erros.append(f"A saturação de O2 deve estar entre 40% e 100% (informado: {av.saturacao_o2}%).")

        if av.escala_glasgow is not None and not (3 <= av.escala_glasgow <= 15):
            erros.append(f"A pontuação na Escala de Glasgow deve estar entre 3 e 15 (informado: {av.escala_glasgow}).")

        ao = av.abertura_ocular
        rv = av.resposta_verbal
        rm = av.resposta_motora
        if ao is not None and rv is not None and rm is not None:
            soma = ao + rv + rm
            if av.escala_glasgow is not None and av.escala_glasgow != soma:
                erros.append(
                    f"A soma dos componentes de Glasgow ({ao} + {rv} + {rm} = {soma}) "
                    f"não confere com a pontuação total informada ({av.escala_glasgow})."
                )

    hc = dados.hora_chamado
    hsb = dados.hora_saida_base
    hcl = dados.hora_chegada_local
    hsl = dados.hora_saida_local
    hch = dados.hora_chegada_hospital
    hconc = dados.hora_conclusao

    if hc and hsb and hsb < hc:
        erros.append("A hora de saída da base não pode ser anterior à hora do chamado.")
    if hc and hcl and hcl < hc:
        erros.append("A hora de chegada ao local não pode ser anterior à hora do chamado.")
    if hsb and hcl and hcl < hsb:
        erros.append("A hora de chegada ao local não pode ser anterior à hora de saída da base.")
    if hcl and hsl and hsl < hcl:
        erros.append("A hora de saída do local não pode ser anterior à hora de chegada ao local.")
    if hsl and hch and hch < hsl:
        erros.append("A hora de chegada ao hospital não pode ser anterior à hora de saída do local.")
    if hcl and hconc and hconc < hcl:
        erros.append("A hora de conclusão não pode ser anterior à hora de chegada ao local.")

    if dados.paciente and dados.paciente.documento:
        if not validar_formato_cpf(dados.paciente.documento):
            erros.append(f"Documento/CPF informado '{dados.paciente.documento}' é inválido pelos critérios da Receita Federal.")

    if dados.unidade_parada and not (dados.motivo_unidade_parada or "").strip():
        erros.append("Quando a unidade estiver marcada como parada, o motivo da parada é obrigatório (RF11).")

    return (len(erros) == 0, erros)
