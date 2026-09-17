from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from database import Base

class LogAuditoria(Base):
    __tablename__ = "log_auditoria"

    id_log = Column(Integer, primary_key=True, index=True)
    id_usuario = Column(Integer, ForeignKey("usuario.id_usuario"), nullable=True)
    acao = Column(String(100), nullable=False)
    detalhes_metadados = Column(String(255), nullable=True)
    ip_origem = Column(String(45), nullable=True)
    data_hora = Column(DateTime, server_default=func.now())

    # Relacionamento
    usuario = relationship("Usuario", back_populates="logs")
