from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class BaseOperacional(Base):
    __tablename__ = "base"

    id_base = Column(Integer, primary_key=True, index=True)
    nome = Column(String(100), nullable=True) # Nome identificador da base (ex: 'Base Central SAMU')
    endereco = Column(String(255), nullable=True)
    bairro = Column(String(100), nullable=True)
    telefone = Column(String(30), nullable=True)
    ativo = Column(Boolean, default=True)

    # Campos legados mantidos como opcionais para evitar quebra de compatibilidade (B22)
    placa = Column(String(10), nullable=True)
    base_unidade = Column(String(50), nullable=True)
    status = Column(String(30), nullable=True)
    motivo_parada = Column(Text, nullable=True)

    atualizado_em = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relacionamentos
    fichas = relationship("FichaAtendimento", back_populates="base")
