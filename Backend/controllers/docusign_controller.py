from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from typing import Optional
from dependencies import get_usuario_atual
from services.docusign_service import DocuSignService

router = APIRouter(
    prefix="/docusign",
    tags=["DocuSign eSignature"],
    dependencies=[Depends(get_usuario_atual)],
)
docusign_service = DocuSignService()

class CriarEnvelopeRequest(BaseModel):
    numero_ocorrencia: str = Field(..., description="Número da ocorrência do SAMU")
    paciente_nome: str = Field(..., description="Nome do paciente ou responsável")
    paciente_cpf: Optional[str] = Field(None, description="CPF do signatário")
    email_destinatario: Optional[str] = Field(None, description="E-mail para envio de assinatura remota")
    telefone_destinatario: Optional[str] = Field(None, description="Telefone SMS/WhatsApp")
    conduta_resumo: Optional[str] = Field(None, description="Resumo clínico ou de conduta médica")

@router.post("/envelopes", status_code=status.HTTP_201_CREATED)
def criar_envelope_docusign(payload: CriarEnvelopeRequest):
    """
    Cria um envelope no DocuSign eSignature para coleta de assinatura digital do paciente
    ou envio remoto para formalização do termo de atendimento.
    """
    try:
        resultado = docusign_service.criar_envelope_termo_aph(
            numero_ocorrencia=payload.numero_ocorrencia,
            paciente_nome=payload.paciente_nome,
            paciente_cpf=payload.paciente_cpf,
            signatario_email=payload.email_destinatario,
            signatario_telefone=payload.telefone_destinatario,
            conduta_resumo=payload.conduta_resumo,
        )
        return resultado
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Falha na comunicação com o serviço DocuSign: {str(e)}"
        )

@router.get("/status/{envelope_id}")
def verificar_status_envelope(envelope_id: str):
    """Verifica o status de assinatura de um envelope no DocuSign."""
    return docusign_service.consultar_status_envelope(envelope_id)

