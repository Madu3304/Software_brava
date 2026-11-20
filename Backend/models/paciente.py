"""
Modelo ORM do Paciente — pseudonimização e proteção de dados sensíveis (LGPD)

Estratégia de pseudonimização do CPF (campo `documento`):
  - Armazenamento: o CPF é gravado no banco como hash HMAC-SHA256 hex (64 chars).
    Isso permite busca por igualdade (WHERE documento = hmac(cpf)) sem expor
    o número em texto claro na base de dados.
  - Exibição mascarada: a propriedade `documento_mascarado` retorna o formato
    ***.456.789-** apenas para fins de UI; o valor real nunca é reconstituído
    pela aplicação — somente o hash é persistido.
  - A função `pseudonimizar_cpf()` deve ser chamada pela camada de serviço
    (ficha_service.py / cadastro_controller.py) ANTES de gravar o paciente.

Nota sobre criptografia em repouso (TDE):
  - Em produção com PostgreSQL, habilite criptografia de disco / TDE no nível
    do sistema operacional ou do próprio PostgreSQL (pgcrypto / extensão EDB).
  - Para criptografia de coluna adicional (AES-GCM via Fernet), implemente na
    camada de serviço usando a biblioteca `cryptography` com a chave em variável
    de ambiente — NUNCA hardcoded.
  - SQLite (desenvolvimento local): sem TDE nativo; o banco de desenvolvimento
    contém apenas dados de seed fictícios, nunca dados reais de pacientes.
"""

import hashlib
import hmac as _hmac
import os
import re
from datetime import datetime

from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship

from database import Base

# Chave HMAC lida do ambiente. Se ausente em desenvolvimento, usa fallback estático
# com aviso explícito — em produção a ausência causa RuntimeError.
_HMAC_KEY_RAW = os.getenv("CPF_HMAC_KEY", "")
_APP_ENV = os.getenv("APP_ENV", "production").strip().lower()

if not _HMAC_KEY_RAW:
    if _APP_ENV == "production":
        raise RuntimeError(
            "[SEGURANÇA] CPF_HMAC_KEY não definida. "
            "Em produção essa variável é obrigatória para pseudonimização de CPF (LGPD)."
        )
    # Desenvolvimento: aviso visível, fallback com chave fixa documentada
    _HMAC_KEY_RAW = "dev_fallback_nao_usar_em_producao"
    import logging as _logging
    _logging.getLogger("BravaPaciente").warning(
        "[LGPD] CPF_HMAC_KEY não configurada. "
        "Usando fallback de desenvolvimento — NÃO use em produção."
    )

_HMAC_KEY: bytes = _HMAC_KEY_RAW.encode("utf-8")


def pseudonimizar_cpf(cpf: str | None) -> str | None:
    """
    Converte CPF em texto claro para HMAC-SHA256 hex (64 chars).

    Permite:
      - Busca por igualdade: WHERE documento = pseudonimizar_cpf(cpf_buscado)
      - Deduplicação de pacientes sem expor o CPF no banco

    Não permite:
      - Reverter o hash para o CPF original (pseudonimização one-way)

    Uso na camada de serviço:
        paciente.documento = pseudonimizar_cpf(dados.paciente.documento)
    """
    if not cpf:
        return None
    digitos = re.sub(r"\D", "", str(cpf))
    if not digitos:
        return None
    return _hmac.new(_HMAC_KEY, digitos.encode("utf-8"), hashlib.sha256).hexdigest()


def mascarar_cpf_exibicao(documento_hash: str | None) -> str | None:
    """
    Retorna representação mascarada para exibição em UI (***.xxx.xxx-**).
    Como o banco armazena apenas o hash, o mascaramento é simbólico —
    indica que o dado existe sem revelar a posição dos dígitos.
    """
    if not documento_hash:
        return None
    return "***.***.***-**"


class Paciente(Base):
    __tablename__ = "paciente"

    id_paciente = Column(Integer, primary_key=True, index=True)
    nome = Column(String(200), nullable=True)
    idade = Column(Integer, nullable=True)
    sexo = Column(String(1), nullable=True)   # 'M', 'F', 'O'
    # CPF armazenado como HMAC-SHA256 hex (64 chars) — pseudonimizado (LGPD art. 13 §4º)
    # Use pseudonimizar_cpf() antes de gravar; nunca armazene o número em texto claro.
    documento = Column(String(64), nullable=True)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())
    data_nascimento = Column(DateTime(timezone=True), nullable=True)
    acompanhante = Column(String(200), nullable=True)
    grau_parentesco = Column(String(50), nullable=True)
    telefone_acompanhante = Column(String(20), nullable=True)
    gravidade_previa = Column(String(20), nullable=True)
    historico_clinico = Column(String(255), nullable=True)
    alergias = Column(String(255), nullable=True)
    medicamentoUso_paciente = Column(String(255), nullable=True)
    observacao_paciente = Column(String(255), nullable=True)

    fichas = relationship("FichaAtendimento", back_populates="paciente")
    avaliacao_clinica = relationship("AvaliacaoClinica", back_populates="paciente")

    @property
    def idade_calculada(self) -> int | None:
        if self.data_nascimento:
            hoje = datetime.now().date()
            dt = self.data_nascimento.date() if hasattr(self.data_nascimento, "date") else self.data_nascimento
            return hoje.year - dt.year - ((hoje.month, hoje.day) < (dt.month, dt.day))
        return self.idade

    @property
    def documento_mascarado(self) -> str | None:
        """Retorna representação visual mascarada do CPF (somente para UI)."""
        return mascarar_cpf_exibicao(self.documento)
