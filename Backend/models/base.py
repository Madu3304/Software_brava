from sqlalchemy import Column, Integer, String, Text, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class UnidadeMovel(Base):
    __tablename__ = "base"

    id_base = Column(Integer, primary_key=True, index=True)
    placa = Column(String(10), nullable=True)
    base_unidade = Column(String(50), default="DISPONIVEL")
    status = Column(String(30), default="DISPONIVEL") # 'DISPONIVEL', 'EM_ATENDIMENTO', 'PARADA', 'MANUTENCAO'
    motivo_parada = Column(Text, nullable=True)
    atualizado_em = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # Relacionamentos
    fichas = relationship("FichaAtendimento", back_populates="base")
