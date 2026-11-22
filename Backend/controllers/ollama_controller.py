from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from dependencies import get_usuario_atual
from services.ollama_service import OllamaService

router = APIRouter(
    prefix="/ia",
    tags=["IA Local (Ollama)"],
    dependencies=[Depends(get_usuario_atual)],
)

ollama_service = OllamaService()


class ChatOllamaRequest(BaseModel):
    mensagem: str = Field(..., min_length=1, max_length=4000, description="Pergunta ou comando para o modelo local")
    contexto: Optional[str] = Field(None, max_length=2000, description="Contexto operacional opcional (sem PII)")
    modelo: Optional[str] = Field(None, description="Nome do modelo Ollama (ex: llama3.2:3b)")


@router.get("/status")
def status_ollama():
    """Verifica a conexão com o Ollama local e lista os modelos disponíveis."""
    return ollama_service.verificar_status()


@router.post("/chat")
def chat_ollama(payload: ChatOllamaRequest):
    """Envia mensagem para o modelo Ollama local e retorna a resposta gerada."""
    try:
        return ollama_service.gerar_resposta(
            mensagem=payload.mensagem,
            contexto=payload.contexto,
            modelo=payload.modelo,
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Falha ao comunicar com o Ollama local: {str(e)}",
        )
