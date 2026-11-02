# Módulo de Geração de PDF
import io
import html
from datetime import datetime
from typing import Optional

from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, HRFlowable

from schemas import FichaDetalhadaReposicaoResponse

def formatar_data(dt: Optional[datetime]) -> str:
    if not dt:
        return "N/A"
    return dt.strftime("%d/%m/%Y %H:%M:%S")

def _escape(texto: Optional[str]) -> str:
    if not texto:
        return ""
    return html.escape(str(texto))

def gerar_pdf_ficha_atendimento(ficha: FichaDetalhadaReposicaoResponse) -> bytes:

    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        rightMargin=36,
        leftMargin=36,
        topMargin=36,
        bottomMargin=36,
        pageCompression=0,  # Mantém os fluxos descompactados para inspeção e auditoria
    )

    styles = getSampleStyleSheet()

    style_title = ParagraphStyle(
        "SAMUTitle",
        parent=styles["Heading1"],
        fontName="Helvetica-Bold",
        fontSize=14,
        leading=17,
        textColor=colors.HexColor("#1E3A8A"),
        alignment=1,
    )
    style_subtitle = ParagraphStyle(
        "SAMUSubtitle",
        parent=styles["Normal"],
        fontName="Helvetica-Bold",
        fontSize=9,
        leading=12,
        textColor=colors.HexColor("#4B5563"),
        alignment=1,
    )
    style_section = ParagraphStyle(
        "SAMUSection",
        parent=styles["Heading2"],
        fontName="Helvetica-Bold",
        fontSize=10,
        leading=13,
        textColor=colors.HexColor("#1E3A8A"),
        spaceBefore=6,
        spaceAfter=3,
    )
    style_body = ParagraphStyle(
        "SAMUBody",
        parent=styles["Normal"],
        fontName="Helvetica",
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor("#1F2937"),
    )
    style_footer = ParagraphStyle(
        "SAMUFooter",
        parent=styles["Italic"],
        fontName="Helvetica-Oblique",
        fontSize=8,
        leading=10,
        textColor=colors.HexColor("#6B7280"),
        alignment=1,
    )

    story = []

    # 1. Cabeçalho Oficial
    story.append(Paragraph("<b>PREFEITURA MUNICIPAL DE JOINVILLE - SAMU 192</b>", style_title))
    story.append(Paragraph("FICHA TECNICA DIGITAL DE ATENDIMENTO - SOFTWARE BRAVA", style_subtitle))
    story.append(Spacer(1, 4))
    story.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor("#1E3A8A"), spaceAfter=6))

    # 2. Dados Operacionais
    data_atend = formatar_data(ficha.data_atendimento)
    viatura = ficha.placa_unidade or "Não identificada"
    bairro = ficha.bairro or "Não informado"
    uuid_offline = ficha.uuid_offline or "Não informado"

    story.append(Paragraph(
        f"Ficha No: #{ficha.id_ficha:05d}   |   Data/Hora: {data_atend}   |   Viatura: {_escape(viatura)}",
        style_body
    ))
    story.append(Paragraph(
        f"Local / Bairro: {_escape(bairro)}   |   UUID Offline: {_escape(uuid_offline)}",
        style_body
    ))
    story.append(Spacer(1, 4))
    story.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor("#D1D5DB"), spaceAfter=4))

    # 3. Dados do Paciente
    paciente_nome = ficha.nome_paciente or "Não informado"
    paciente_idade = f"{ficha.idade_paciente} anos" if ficha.idade_paciente is not None else "Não informada"
    paciente_sexo = ficha.sexo_paciente or "Não informado"

    story.append(Paragraph("DADOS DO PACIENTE", style_section))
    story.append(Paragraph(
        f"Nome: {_escape(paciente_nome)}   |   Idade: {_escape(paciente_idade)}   |   Sexo: {_escape(paciente_sexo)}",
        style_body
    ))
    story.append(Spacer(1, 4))
    story.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor("#D1D5DB"), spaceAfter=4))

    # 4. Avaliação Clínica e Sinais Vitais
    pa = "N/A"
    fc = "N/A"
    sat_o2 = "N/A"
    hgt = "N/A"
    glasgow = "N/A"
    ao = "N/A"
    rv = "N/A"
    rm = "N/A"

    avc_suspeito_txt = "Não informado"
    ictus_txt = "N/A"
    anticoag_txt = "N/A"
    sinais_avc_txt = "Nenhum sinal registrado"
    testemunha_txt = "N/A"
    conduta = "Nenhuma conduta registrada"

    if ficha.avaliacao_clinica:
        av = ficha.avaliacao_clinica
        pa = av.pressao_arterial or "N/A"
        fc = f"{av.frequencia_cardiaca} bpm" if av.frequencia_cardiaca is not None else "N/A"
        sat_o2 = f"{av.saturacao_o2}%" if av.saturacao_o2 is not None else "N/A"

        if av.hemoglicoteste is not None:
            hgt = f"{av.hemoglicoteste} mg/dL"
        elif av.glicemia is not None:
            hgt = f"{av.glicemia} mg/dL"

        glasgow = f"{av.escala_glasgow}/15" if av.escala_glasgow is not None else "N/A"
        ao = str(av.abertura_ocular) if av.abertura_ocular is not None else "N/A"
        rv = str(av.resposta_verbal) if av.resposta_verbal is not None else "N/A"
        rm = str(av.resposta_motora) if av.resposta_motora is not None else "N/A"

        if av.avc_suspeito is not None:
            avc_suspeito_txt = "SIM (SUSPEITO)" if av.avc_suspeito else "NAO (SEM CRITERIOS)"

        if av.hora_ictus:
            ictus_txt = formatar_data(av.hora_ictus)

        if av.usa_anticoagulante is not None:
            anticoag_txt = "SIM" if av.usa_anticoagulante else "NAO"

        sinais = []
        if av.assimetria_facial is not None:
            sinais.append(f"Assimetria Facial: {'SIM' if av.assimetria_facial else 'NAO'}")
        if av.queda_braco is not None:
            sinais.append(f"Queda Braco: {'SIM' if av.queda_braco else 'NAO'}")
        if av.fala is not None:
            sinais.append(f"Fala: {'SIM' if av.fala else 'NAO'}")
        if sinais:
            sinais_avc_txt = " | ".join(sinais)

        if av.nome_testemunha:
            testemunha_txt = av.nome_testemunha

        if av.conduta:
            conduta = av.conduta
        elif av.anotacao_CondutaEnfermeiro:
            conduta = av.anotacao_CondutaEnfermeiro

    story.append(Paragraph("AVALIACAO CLINICA E SINAIS VITAIS", style_section))
    story.append(Paragraph(
        f"Pressao Arterial: {_escape(pa)}   |   Freq. Cardiaca: {fc}   |   Sat. O2: {sat_o2}   |   HGT: {hgt}",
        style_body
    ))
    story.append(Paragraph(
        f"Glasgow: {glasgow}   |   Abertura Ocular: {ao}   |   Resp. Verbal: {rv}   |   Resp. Motora: {rm}",
        style_body
    ))
    story.append(Spacer(1, 4))
    story.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor("#D1D5DB"), spaceAfter=4))

    # 5. Avaliação de AVC / Escala de Cincinnati
    story.append(Paragraph("AVALIACAO DE AVC / ESCALA DE CINCINNATI", style_section))
    story.append(Paragraph(
        f"AVC Suspeito: {avc_suspeito_txt}   |   Hora Ictus: {ictus_txt}   |   Anticoagulante: {anticoag_txt}",
        style_body
    ))
    story.append(Paragraph(
        f"Sinais de AVC: {_escape(sinais_avc_txt)}",
        style_body
    ))
    story.append(Paragraph(
        f"Testemunha: {_escape(testemunha_txt)}",
        style_body
    ))
    story.append(Spacer(1, 4))
    story.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor("#D1D5DB"), spaceAfter=4))

    # 6. Conduta e Utensílios Gastos (com quebra de linha automática)
    materiais = []
    if ficha.utensilios_gastos:
        u = ficha.utensilios_gastos
        if u.medicamentos_ampolas: materiais.append("Ampolas")
        if u.medicamentos_controlados: materiais.append("Medicamentos Controlados")
        if u.medicamentos_comprimidos: materiais.append("Comprimidos")
        if u.medicamentos_frascoGotas: materiais.append("Frasco Gotas")
        if u.anestesico: materiais.append("Anestésico")
        if u.material_infusao: materiais.append("Material de Infusão")
        if u.material_sondagem: materiais.append("Material Sondagem")
        if u.material_trauma: materiais.append("Material de Trauma")
        if u.materiais_diversos: materiais.append("Materiais Diversos")
        if u.observacoes_reposicao: materiais.append(f"Obs: {u.observacoes_reposicao}")

    materiais_str = ", ".join(materiais) if materiais else "Nenhum utensílio consumido registrado"

    story.append(Paragraph("CONDUTA E UTENSILIOS GASTOS", style_section))
    story.append(Paragraph(f"<b>Conduta / Observações:</b> {_escape(conduta)}", style_body))
    story.append(Spacer(1, 2))
    story.append(Paragraph(f"<b>Utensílios / Medicamentos:</b> {_escape(materiais_str)}", style_body))
    story.append(Spacer(1, 8))

    # 7. Rodapé
    story.append(HRFlowable(width="100%", thickness=1.0, color=colors.HexColor("#1E3A8A"), spaceAfter=4))
    story.append(Paragraph("Documento gerado automaticamente para arquivamento e encaminhamento hospitalar.", style_footer))

    doc.build(story)
    return buffer.getvalue()
