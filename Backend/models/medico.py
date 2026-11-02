from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Medico(Base):
    __tablename__ = "medico"

    id_medico = Column(Integer, primary_key=True, index=True)
    nome = Column(String(200), nullable=True)
    codigo_medico = Column(Integer, nullable=True)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())

    fichas = relationship("FichaAtendimento", back_populates="medico")
