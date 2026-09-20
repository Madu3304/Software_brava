from sqlalchemy import Column, Integer, String, Text, Numeric, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class AvaliacaoClinica(Base):
    __tablename__ = "avaliacao_clinica"

    id_avaliacao = Column(Integer, primary_key=True, index=True)
    id_ficha = Column(Integer, ForeignKey("ficha_atendimento.id_ficha", ondelete="CASCADE"), nullable=False, unique=True)
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente", ondelete="CASCADE"), nullable=False, unique=True)
    pressao_arterial = Column(String(20), nullable=True)
    frequencia_cardiaca = Column(Integer, nullable=True)
    frequencia_respiratoria = Column(Integer, nullable=True)
    saturacao_o2 = Column(Integer, nullable=True)
    glicemia = Column(Integer, nullable=True)
    temperatura = Column(Numeric(4, 1), nullable=True)
    escala_glasgow = Column(Integer, nullable=True)
    abertura_ocular = Column(Integer, nullable=True)
    resposta_verbal = Column(Integer, nullable=True)
    resposta_motora = Column(Integer, nullable=True)
    hemoglicoteste = Column(Integer, nullable=True)
    hora_ictus = Column(DateTime, nullable=True)
    nome_testemunha = Column(String(200), nullable=True)
    usa_anticoagulante = Column(Boolean, nullable=True)
    assimetria_facial = Column(Boolean, nullable=True)
    queda_braco = Column(Boolean, nullable=True)
    fala = Column(Boolean, nullable=True)
    avc_suspeito = Column(Boolean, nullable=True)
    material_retido = Column(Boolean, nullable=True)
    anotacao_CondutaEnfermeiro = Column(Text, nullable=True)
    
    procedimentos_realizados = Column(Text, nullable=True)
    medicacoes_administradas = Column(Text, nullable=True)
    conduta = Column(Text, nullable=True)

    # Relacionamento
    ficha_atendimento = relationship("FichaAtendimento", back_populates="avaliacao_clinica")
