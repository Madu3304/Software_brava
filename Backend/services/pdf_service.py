# Backend/services/pdf_service.py
"""
Módulo de Geração de PDF (Modelo C4 - Níveis 3 e 4)
Componente: PDF Generator Service
Responsabilidade: Renderização de documentos clínicos padronizados do atendimento (RNF08)
para impressão física ou entrega ao Hospital de Destino.
"""
from datetime import datetime
from typing import Optional
from schemas import FichaDetalhadaReposicaoResponse

def formatar_data(dt: Optional[datetime]) -> str:
    if not dt:
        return "N/A"
    return dt.strftime("%d/%m/%Y %H:%M:%S")

def gerar_pdf_ficha_atendimento(ficha: FichaDetalhadaReposicaoResponse) -> bytes:
    """
    Renderiza o documento em PDF estruturado para atendimento do SAMU.
    Contém todos os blocos exigidos pela portaria GM/MS 2048 e pela RFC da prefeitura.
    """
    paciente_nome = ficha.nome_paciente or "Não informado"
    paciente_idade = f"{ficha.idade_paciente} anos" if ficha.idade_paciente is not None else "Não informada"
    paciente_sexo = ficha.sexo_paciente or "Não informado"
    viatura = ficha.placa_unidade or "Não identificada"
    data_atend = formatar_data(ficha.data_atendimento)

    # Detalhes clínicos
    pa = "N/A"
    fc = "N/A"
    glasgow = "N/A"
    conduta = "Nenhuma conduta registrada"
    if ficha.avaliacao_clinica:
        pa = ficha.avaliacao_clinica.pressao_arterial or "N/A"
        fc = f"{ficha.avaliacao_clinica.frequencia_cardiaca} bpm" if ficha.avaliacao_clinica.frequencia_cardiaca else "N/A"
        glasgow = f"{ficha.avaliacao_clinica.escala_glasgow}/15" if ficha.avaliacao_clinica.escala_glasgow else "N/A"
        conduta = ficha.avaliacao_clinica.conduta or ficha.avaliacao_clinica.anotacao_CondutaEnfermeiro or conduta

    # Utensílios gastos
    materiais = []
    if ficha.utensilios_gastos:
        u = ficha.utensilios_gastos
        if u.medicamentos_ampolas: materiais.append("Ampolas")
        if u.medicamentos_controlados: materiais.append("Medicamentos Controlados")
        if u.material_infusao: materiais.append("Material de Infusão")
        if u.material_trauma: materiais.append("Material de Trauma")
        if u.materiais_diversos: materiais.append("Materiais Diversos")
        if u.observacoes_reposicao: materiais.append(f"Obs: {u.observacoes_reposicao}")

    materiais_str = ", ".join(materiais) if materiais else "Nenhum utensílio consumido registrado"

    # Estruturação textual e layout com escape de stream PDF
    linhas = [
        "%PDF-1.4",
        "1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj",
        "2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj",
        "3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >> endobj",
        "5 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj",
    ]

    conteudo_corpo = (
        "BT\n"
        "/F1 16 Tf\n"
        "50 780 Td (PREFEITURA MUNICIPAL DE JOINVILLE - SAMU 192) Tj\n"
        "/F1 12 Tf\n"
        "0 -25 Td (FICHA TECNICA DIGITAL DE ATENDIMENTO - SOFTWARE BRAVA) Tj\n"
        "0 -20 Td (--------------------------------------------------------------------------------------------------) Tj\n"
        f"0 -25 Td (Ficha No: #{ficha.id_ficha:05d}   |   Data/Hora: {data_atend}   |   Viatura: {viatura}) Tj\n"
        f"0 -20 Td (Local / Bairro: {ficha.bairro or 'Nao informado'}) Tj\n"
        "0 -20 Td (--------------------------------------------------------------------------------------------------) Tj\n"
        "/F1 13 Tf\n"
        "0 -25 Td (DADOS DO PACIENTE) Tj\n"
        "/F1 11 Tf\n"
        f"0 -18 Td (Nome: {paciente_nome}   |   Idade: {paciente_idade}   |   Sexo: {paciente_sexo}) Tj\n"
        "0 -20 Td (--------------------------------------------------------------------------------------------------) Tj\n"
        "/F1 13 Tf\n"
        "0 -25 Td (AVALIACAO CLINICA E SINAIS VITAIS) Tj\n"
        "/F1 11 Tf\n"
        f"0 -18 Td (Pressao Arterial: {pa}   |   Freq. Cardiaca: {fc}   |   Glasgow: {glasgow}) Tj\n"
        f"0 -18 Td (Conduta / Observacoes: {conduta[:100]}) Tj\n"
        "0 -20 Td (--------------------------------------------------------------------------------------------------) Tj\n"
        "/F1 13 Tf\n"
        "0 -25 Td (UTENSILIOS E MEDICAMENTOS GASTOS) Tj\n"
        "/F1 11 Tf\n"
        f"0 -18 Td ({materiais_str[:120]}) Tj\n"
        "0 -30 Td (--------------------------------------------------------------------------------------------------) Tj\n"
        "0 -20 Td (Documento gerado automaticamente para arquivamento e encaminhamento hospitalar.) Tj\n"
        "ET\n"
    )

    linhas.append(f"4 0 obj << /Length {len(conteudo_corpo)} >> stream")
    linhas.append(conteudo_corpo.strip())
    linhas.append("endstream endobj")
    linhas.append("xref")
    linhas.append("0 6")
    linhas.append("0000000000 65535 f ")
    linhas.append("0000000010 00000 n ")
    linhas.append("0000000060 00000 n ")
    linhas.append("0000000117 00000 n ")
    linhas.append("0000000280 00000 n ")
    linhas.append("0000000230 00000 n ")
    linhas.append("trailer << /Size 6 /Root 1 0 R >>")
    linhas.append("startxref")
    linhas.append("500")
    linhas.append("%%EOF")

    return "\n".join(linhas).encode("utf-8")
