from sqlalchemy import Column, Integer, String, DateTime, func
from database import Base


class TokenRevogado(Base):
    """
    Blocklist de JWTs revogados no logout.

    Armazena o jti (JWT ID) de cada token invalidado pelo endpoint POST /auth/logout
    até a data de expiração original do token. A verificação é feita em get_usuario_atual
    antes de processar qualquer requisição autenticada.

    Manutenção automática: tokens expirados podem ser removidos periodicamente
    (ex.: tarefa agendada DELETE FROM token_revogado WHERE expira_em < NOW()).
    """

    __tablename__ = "token_revogado"

    id = Column(Integer, primary_key=True, index=True)
    # jti — valor único gerado em gerar_token_acesso() com secrets.token_urlsafe(32)
    jti = Column(String(64), nullable=False, unique=True, index=True)
    # id do usuário que fez logout (para auditoria e limpeza seletiva)
    id_usuario = Column(Integer, nullable=True, index=True)
    # momento em que o token original expiraria — usado para limpeza da tabela
    expira_em = Column(DateTime(timezone=True), nullable=False)
    # momento do logout
    revogado_em = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
