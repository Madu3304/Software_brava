from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Tecnico(Base):
    __tablename__ = "tecnico"

    id_tecnico = Column(Integer, primary_key=True, index=True)
    nome = Column(String(200), nullable=True)
    codigo_medico = Column(Integer, nullable=True)
    criado_em = Column(DateTime, server_default=func.now())

    # Relacionamentos
    fichas = relationship("FichaAtendimento", back_populates="tecnico")
