import os
import logging
from typing import Any, Dict, List, Optional
import httpx

logger = logging.getLogger("OllamaService")

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434").rstrip("/")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2:3b")

SYSTEM_PROMPT_SAMU = (
    "Você é um assistente local do sistema Software Brava (SAMU 192 Joinville), "
    "executado 100% offline via Ollama. Auxilie a equipe com dúvidas operacionais, "
    "padronização de preenchimento de fichas APH, escalas clínicas (Glasgow/Cincinnati) "
    "e suporte administrativo em português. Nunca solicite nem exponha CPF ou dados pessoais sensíveis."
)


class OllamaService:
    """Serviço de integração com o servidor Ollama local (http://localhost:11434)."""

    def __init__(
        self,
        base_url: str = OLLAMA_BASE_URL,
        default_model: str = OLLAMA_MODEL,
        timeout: float = 30.0,
    ):
        self.base_url = base_url.rstrip("/")
        self.default_model = default_model
        self.timeout = timeout

    def verificar_status(self) -> Dict[str, Any]:
        """Consulta /api/tags no Ollama local para verificar disponibilidade e modelos instalados."""
        try:
            with httpx.Client(timeout=5.0) as client:
                res = client.get(f"{self.base_url}/api/tags")
                res.raise_for_status()
                data = res.json()
                modelos: List[str] = [
                    m.get("name", "") for m in data.get("models", []) if isinstance(m, dict) and m.get("name")
                ]
                return {
                    "online": True,
                    "base_url": self.base_url,
                    "modelo_padrao": self.default_model,
                    "modelos_disponiveis": modelos,
                }
        except Exception as e:
            logger.warning(f"[OllamaService] Servidor Ollama inacessível em {self.base_url}: {e}")
            return {
                "online": False,
                "base_url": self.base_url,
                "modelo_padrao": self.default_model,
                "modelos_disponiveis": [],
                "erro": str(e),
            }

    def gerar_resposta(
        self,
        mensagem: str,
        contexto: Optional[str] = None,
        modelo: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Envia uma pergunta ao modelo local do Ollama via /api/chat."""
        modelo_uso = (modelo or self.default_model).strip()
        messages = [{"role": "system", "content": SYSTEM_PROMPT_SAMU}]
        if contexto and contexto.strip():
            messages.append({"role": "system", "content": f"Contexto operacional: {contexto.strip()}"})
        messages.append({"role": "user", "content": mensagem.strip()})

        payload = {
            "model": modelo_uso,
            "messages": messages,
            "stream": False,
        }

        with httpx.Client(timeout=self.timeout) as client:
            res = client.post(f"{self.base_url}/api/chat", json=payload)
            res.raise_for_status()
            data = res.json()
            conteudo = (data.get("message") or {}).get("content", "")
            return {
                "modelo": data.get("model", modelo_uso),
                "resposta": conteudo,
                "local": True,
            }
