from sqlalchemy import Column, Integer, String, Text, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class UnidadeMovel(Base):
    __tablename__ = "unidade_movel"

    id_unidade = Column(Integer, primary_key=True, index=True)
    nome_unidade = Column(String(50), unique=True, nullable=False) # 'Brava 1', 'Brava 2', 'Brava 3', 'Brava 4'
    placa = Column(String(10), nullable=True)
    status = Column(String(30), default="DISPONIVEL") # 'DISPONIVEL', 'EM_ATENDIMENTO', 'PARADA', 'MANUTENCAO'
    motivo_parada = Column(Text, nullable=True)
    atualizado_em = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # Relacionamentos
    fichas = relationship("FichaAtendimento", back_populates="unidade_movel")
