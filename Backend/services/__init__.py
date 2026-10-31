# Backend/services/__init__.py
"""
Camada de Serviços de Negócio (Services Layer - Modelo C4)
Centraliza a lógica de domínio, segurança, validação clínica, relatórios e integrações.
"""
from .ficha_service import (
    listar_fichas_com_sinais_vitais,
    buscar_ficha_consolidada_reposicao,
    listar_fichas_para_reposicao,
    registrar_reposicao_utensilios,
    obter_metricas_reposicao_dashboard,
)
from .security_service import (
    gerar_hash_senha,
    verificar_senha,
    gerar_token_acesso,
    obter_redirecionamento_por_perfil,
    validar_permissao_perfil,
)
from .validation_service import (
    validar_regras_clinicas_ficha,
    validar_formato_pressao_arterial,
    ErroValidacaoClinica,
)
from .pdf_service import (
    gerar_pdf_ficha_atendimento,
)
from .integration_service import (
    enviar_ficha_para_prefeitura,
    enviar_fichas_para_prefeitura,
)
from .log_service import (
    registrar_auditoria,
    listar_logs_recentes,
)
from .sync_service import (
    processar_pacote_sync_offline,
)
from .report_service import (
    calcular_metricas_dashboard,
)

__all__ = [
    "listar_fichas_com_sinais_vitais",
    "buscar_ficha_consolidada_reposicao",
    "listar_fichas_para_reposicao",
    "registrar_reposicao_utensilios",
    "obter_metricas_reposicao_dashboard",
    "gerar_hash_senha",
    "verificar_senha",
    "gerar_token_acesso",
    "obter_redirecionamento_por_perfil",
    "validar_permissao_perfil",
    "validar_regras_clinicas_ficha",
    "validar_formato_pressao_arterial",
    "ErroValidacaoClinica",
    "gerar_pdf_ficha_atendimento",
    "enviar_ficha_para_prefeitura",
    "enviar_fichas_para_prefeitura",
    "registrar_auditoria",
    "listar_logs_recentes",
    "processar_pacote_sync_offline",
    "calcular_metricas_dashboard",
]
