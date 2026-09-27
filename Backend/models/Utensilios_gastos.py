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

    # Controle de reposição pelo técnico de enfermagem
    observacoes_reposicao = Column(Text, nullable=True) # Ex: 2 ampolas de morfina, 1 cateter 18G
    reposto = Column(Boolean, default=False) # True quando o técnico realizou a reposição no estoque/ambulância
    data_reposicao = Column(DateTime, nullable=True)
    criado_em = Column(DateTime, server_default=func.now())

    # Relacionamentos com Ficha de Atendimento e Avaliação Clínica
    ficha_atendimento = relationship("FichaAtendimento", back_populates="utensilios_gastos")
    avaliacao_clinica = relationship("AvaliacaoClinica", back_populates="utensilios_gastos")

# Alias para compatibilidade
UtensiliosGastos = Utensilios

