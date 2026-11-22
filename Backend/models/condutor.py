from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Condutor(Base):
    __tablename__ = "condutor"

    id_condutor = Column(Integer, primary_key=True, index=True)
    nome = Column(String(200), nullable=True)
    codigo_condutor = Column(Integer, nullable=True)
    cpf = Column(String(20), nullable=True)
    registro_conselho = Column(String(50), nullable=True)
    unidade = Column(String(100), nullable=True)
    matricula = Column(String(50), nullable=True)
    cargo = Column(String(100), nullable=True)
    status = Column(String(30), default="Disponível")
    criado_em = Column(DateTime(timezone=True), server_default=func.now())

    fichas = relationship("FichaAtendimento", back_populates="condutor")
