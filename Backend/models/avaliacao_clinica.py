from sqlalchemy import Column, Integer, String, Text, Numeric, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class AvaliacaoClinica(Base):
    __tablename__ = "avaliacao_clinica"

    id_avaliacao = Column(Integer, primary_key=True, index=True)
    id_ficha = Column(Integer, ForeignKey("ficha_atendimento.id_ficha", ondelete="CASCADE"), nullable=False, unique=True)
    
    pressao_arterial = Column(String(20), nullable=True)
    frequencia_cardiaca = Column(Integer, nullable=True)
    frequencia_respiratoria = Column(Integer, nullable=True)
    saturacao_o2 = Column(Integer, nullable=True)
    glicemia = Column(Integer, nullable=True)
    temperatura = Column(Numeric(4, 1), nullable=True)
    escala_glasgow = Column(Integer, nullable=True)
    
    procedimentos_realizados = Column(Text, nullable=True)
    medicacoes_administradas = Column(Text, nullable=True)
    conduta = Column(Text, nullable=True)

    # Relacionamento
    ficha_atendimento = relationship("FichaAtendimento", back_populates="avaliacao_clinica")
