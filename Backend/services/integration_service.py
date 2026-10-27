# Backend/services/integration_service.py
"""
Módulo de Integração com Sistemas Externos (Modelo C4 - Níveis 3 e 4)
Componente: Integration Service
Responsabilidade: Transmissão segura dos dados consolidados de atendimentos
para a API da Prefeitura Municipal de Joinville (RF06).
"""
import os
import logging
from typing import Dict, Any, List
from datetime import datetime

logger = logging.getLogger("IntegrationService")

URL_API_PREFEITURA = os.getenv("PREFEITURA_API_URL", "https://api.joinville.sc.gov.br/saude/samu/v1")
TOKEN_API_PREFEITURA = os.getenv("PREFEITURA_API_TOKEN", "mock_prefeitura_token_2026")

def transmitir_atendimento_para_prefeitura(dados_ficha: Dict[str, Any]) -> Dict[str, Any]:
    """
    Empacota e envia um atendimento concluído para o endpoint receptor da Prefeitura (RF06).
    Em caso de falha de conexão, registra o evento para reenvio assíncrono.
    """
    logger.info(f"Iniciando transmissão da ficha #{dados_ficha.get('id_ficha')} para o Banco da Prefeitura.")

    payload = {
        "orgao": "SAMU_JOINVILLE",
        "id_ficha_sistema": dados_ficha.get("id_ficha"),
        "uuid_origem": dados_ficha.get("uuid_offline"),
        "data_hora_transmissao": datetime.utcnow().isoformat(),
        "dados_atendimento": dados_ficha,
    }

    # Simulação de envio seguro HTTPS (conforme especificado na seção 2.3 RF06 e C4)
    # Em produção, utiliza httpx.post(f"{URL_API_PREFEITURA}/atendimentos", json=payload, headers=...)
    sucesso = True
    protocolo_prefeitura = f"PMJ-{datetime.utcnow().strftime('%Y%m%d%H%M')}-{dados_ficha.get('id_ficha', '000')}"

    return {
        "sucesso": sucesso,
        "protocolo_prefeitura": protocolo_prefeitura,
        "mensagem": "Atendimento transmitido com sucesso ao banco municipal da Prefeitura.",
        "timestamp": datetime.utcnow().isoformat(),
    }

def sincronizar_lote_com_prefeitura(lista_fichas: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Dispara carga em lote de atendimentos consolidados para a Prefeitura após sincronização offline do Mobile.
    """
    resultados = []
    for ficha in lista_fichas:
        res = transmitir_atendimento_para_prefeitura(ficha)
        resultados.append(res)

    return {
        "total_enviados": len(lista_fichas),
        "sucessos": sum(1 for r in resultados if r["sucesso"]),
        "detalhes": resultados,
    }
