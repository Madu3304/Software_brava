# Backend/services/integration_service.py
"""
Módulo de Integração com Sistemas Externos (Modelo C4 - Níveis 3 e 4)
Componente: Integration Service
Responsabilidade: Transmissão segura dos dados consolidados de atendimentos
para a API da Prefeitura Municipal de Joinville (RF06).

O envio acontece DEPOIS do commit da ficha, em segundo plano (BackgroundTasks),
e o resultado fica gravado na própria ficha (status_envio_prefeitura):
- PENDENTE: ainda não enviada (ou integração não configurada)
- ENVIADO: a Prefeitura confirmou o recebimento (protocolo_prefeitura preenchido)
- ERRO: o envio falhou; pode ser reenviado por POST /api/fichas/integracao/reenviar
"""
import os
import logging
from datetime import datetime, timezone
from typing import Any, Dict, Iterable, Optional

import httpx

from database import SessionLocal
from models import FichaAtendimento

logger = logging.getLogger("IntegrationService")

STATUS_PENDENTE = "PENDENTE"
STATUS_ENVIADO = "ENVIADO"
STATUS_ERRO = "ERRO"

def obter_configuracao() -> Optional[Dict[str, Any]]:
    """
    Lê a configuração da integração do .env a cada envio.
    Retorna None se PREFEITURA_API_URL ou PREFEITURA_API_TOKEN não estiverem configurados.
    """
    url = (os.getenv("PREFEITURA_API_URL") or "").strip().rstrip("/")
    token = (os.getenv("PREFEITURA_API_TOKEN") or "").strip()
    if not url or not token:
        return None
    return {
        "url": url,
        "token": token,
        "timeout": float(os.getenv("PREFEITURA_API_TIMEOUT", "10")),
    }

def criar_cliente_http(timeout: float) -> httpx.Client:
    """Cria o cliente HTTP da integração (isolado para facilitar testes)."""
    return httpx.Client(timeout=timeout)

def montar_payload(ficha: FichaAtendimento) -> Dict[str, Any]:
    """Empacota os dados consolidados do atendimento para a Prefeitura (RF06)."""
    return {
        "orgao": "SAMU_JOINVILLE",
        "id_ficha_sistema": ficha.id_ficha,
        "uuid_origem": ficha.uuid_offline,
        "data_hora_transmissao": datetime.now(timezone.utc).isoformat(),
        "dados_atendimento": {
            "id_ficha": ficha.id_ficha,
            "uuid_offline": ficha.uuid_offline,
            "id_unidade": ficha.id_unidade,
            "data": ficha.data_atendimento.isoformat() if ficha.data_atendimento else None,
        },
    }

def enviar_ficha_para_prefeitura(id_ficha: int) -> Optional[str]:
    """
    Envia uma ficha já gravada (commit feito) para a API da Prefeitura e grava o resultado na ficha.
    Abre a própria sessão de banco, pois roda em segundo plano depois da resposta da requisição.
    Retorna o status final da ficha (ou None se a ficha não existir).
    """
    db = SessionLocal()
    try:
        ficha = db.query(FichaAtendimento).filter(FichaAtendimento.id_ficha == id_ficha).first()
        if not ficha:
            logger.warning(f"Ficha #{id_ficha} não encontrada para envio à Prefeitura.")
            return None
        if ficha.status_envio_prefeitura == STATUS_ENVIADO:
            return STATUS_ENVIADO

        config = obter_configuracao()
        if not config:
            logger.warning(
                f"Integração com a Prefeitura não configurada (PREFEITURA_API_URL / PREFEITURA_API_TOKEN). "
                f"Ficha #{id_ficha} permanece {STATUS_PENDENTE}."
            )
            return ficha.status_envio_prefeitura

        ficha.tentativas_envio = (ficha.tentativas_envio or 0) + 1
        ficha.ultima_tentativa_envio = datetime.now(timezone.utc)
        logger.info(f"Enviando ficha #{id_ficha} para a Prefeitura (tentativa {ficha.tentativas_envio}).")

        try:
            with criar_cliente_http(config["timeout"]) as cliente:
                resposta = cliente.post(
                    f"{config['url']}/atendimentos",
                    json=montar_payload(ficha),
                    headers={"Authorization": f"Bearer {config['token']}"},
                )
            resposta.raise_for_status()

            try:
                corpo = resposta.json()
            except ValueError:
                corpo = {}
            ficha.status_envio_prefeitura = STATUS_ENVIADO
            ficha.protocolo_prefeitura = str(corpo.get("protocolo") or "")[:64] or None
            ficha.erro_envio = None
            logger.info(f"Ficha #{id_ficha} enviada à Prefeitura. Protocolo: {ficha.protocolo_prefeitura}")

        except httpx.HTTPStatusError as e:
            ficha.status_envio_prefeitura = STATUS_ERRO
            ficha.erro_envio = f"HTTP {e.response.status_code}: {e.response.text[:200]}"
            logger.error(f"Prefeitura recusou a ficha #{id_ficha}: {ficha.erro_envio}")
        except httpx.HTTPError as e:
            ficha.status_envio_prefeitura = STATUS_ERRO
            ficha.erro_envio = f"Falha de comunicação: {type(e).__name__}: {str(e)[:200]}"
            logger.error(f"Falha ao enviar a ficha #{id_ficha} para a Prefeitura: {ficha.erro_envio}")

        db.commit()
        return ficha.status_envio_prefeitura
    finally:
        db.close()

def enviar_fichas_para_prefeitura(ids_fichas: Iterable[int]) -> Dict[str, int]:
    """Envia várias fichas (ex.: lote do sync ou reenvio) e devolve a contagem por status."""
    resumo = {STATUS_ENVIADO: 0, STATUS_ERRO: 0, STATUS_PENDENTE: 0}
    for id_ficha in ids_fichas:
        status_final = enviar_ficha_para_prefeitura(id_ficha)
        if status_final in resumo:
            resumo[status_final] += 1
    return resumo
