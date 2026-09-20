from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Paciente(Base):
    __tablename__ = "paciente"

    id_paciente = Column(Integer, primary_key=True, index=True)
    nome = Column(String(200), nullable=True)
    idade = Column(Integer, nullable=True)
    faixa_etaria = Column(String(50), nullable=True) # '0-12', '13-18', '19-59', '60+'
    sexo = Column(String(1), nullable=True) # 'M', 'F', 'O'
    documento = Column(String(30), nullable=True)
    criado_em = Column(DateTime, server_default=func.now())

    # Relacionamentos
    fichas = relationship("FichaAtendimento", back_populates="paciente")
