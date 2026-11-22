from sqlalchemy import Column, Integer, Boolean, Text, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from database import Base

class Utensilios(Base):
    __tablename__ = "utensilios"

    id_utensilios = Column(Integer, primary_key=True, index=True)
    id_ficha = Column(Integer, ForeignKey("ficha_atendimento.id_ficha", ondelete="CASCADE"), nullable=False, index=True)
    id_avaliacao = Column(Integer, ForeignKey("avaliacao_clinica.id_avaliacao", ondelete="SET NULL"), nullable=True, index=True)

    # Materiais e medicamentos utilizados durante o atendimento
    medicamentos_ampolas = Column(Boolean, default=False, nullable=True)
    medicamentos_controlados = Column(Boolean, default=False, nullable=True)
    medicamentos_comprimidos = Column(Boolean, default=False, nullable=True)
    medicamentos_frascoGotas = Column(Boolean, default=False, nullable=True)
    anestesico = Column(Boolean, default=False, nullable=True)
    material_infusao = Column(Boolean, default=False, nullable=True)
    material_sondagem = Column(Boolean, default=False, nullable=True)
    material_trauma = Column(Boolean, default=False, nullable=True)
    materiais_diversos = Column(Boolean, default=False, nullable=True)

    observacoes_reposicao = Column(Text, nullable=True) 
    reposto = Column(Boolean, default=False) 
    data_reposicao = Column(DateTime(timezone=True), nullable=True)
    criado_em = Column(DateTime(timezone=True), server_default=func.now())

    ficha_atendimento = relationship("FichaAtendimento", back_populates="utensilios_gastos")
    avaliacao_clinica = relationship("AvaliacaoClinica", back_populates="utensilios_gastos")

UtensiliosGastos = Utensilios
