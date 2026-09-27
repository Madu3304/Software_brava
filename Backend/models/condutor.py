from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Condutor(Base):
    __tablename__ = "condutor"

    id_condutor = Column(Integer, primary_key=True, index=True)
    nome = Column(String(200), nullable=True)
    codigo_condutor = Column(Integer, nullable=True)
    criado_em = Column(DateTime, server_default=func.now())

    # Nota: ficha_atendimento referencia o condutor via usuario.id_usuario (perfil CONDUTOR)
    # fichas = relationship("FichaAtendimento", back_populates="condutor")
