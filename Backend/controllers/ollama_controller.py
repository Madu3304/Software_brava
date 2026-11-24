import logging
import os
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from dependencies import exigir_perfil
from services.ollama_service import OllamaService

logger = logging.getLogger("OllamaController")
_DEFAULT_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2:3b").strip()
_ALLOWED_MODELS = {
    m.strip()
    for m in os.getenv("ALLOWED_OLLAMA_MODELS", f"{_DEFAULT_MODEL},llama3.2,llama3.1,mistral,gemma2").split(",")
    if m.strip()
}

router = APIRouter(
    prefix="/ia",
    tags=["IA Local (Ollama)"],
    dependencies=[Depends(exigir_perfil("ADMINISTRADOR", "ENFERMEIRO", "TECNICO"))],
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
    if payload.modelo and payload.modelo.strip() not in _ALLOWED_MODELS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Modelo de IA solicitado não está na lista de modelos permitidos.",
        )
    try:
        return ollama_service.gerar_resposta(
            mensagem=payload.mensagem,
            contexto=payload.contexto,
            modelo=payload.modelo,
        )
    except Exception:
        logger.exception("[Ollama] Falha ao comunicar com o servidor local.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Serviço de IA local indisponível no momento.",
        )
