from sqlalchemy import Column, Integer, String, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Usuario(Base):
    __tablename__ = "utensilios"

    id_utensilios = Column(Integer, primary_key=True, index=True)
    medicamentos_ampolas = Column(Boolean, nullable=True)
    medicamentos_controlados = Column(Boolean, nullable=True)
    medicamentos_comprimidos = Column(Boolean, nullable=True)
    medicamentos_frascoGotas = Column(Boolean, nullable=True)
    anestesico = Column(Boolean, nullable=True)
    material_infusao = Column(Boolean, nullable=True)
    material_sondagem = Column(Boolean, nullable=True)
    material_trauma = Column(Boolean, nullable=True)
    materiais_diversos = Column(Boolean, nullable=True)

    # Relacionamentos
    fichas_responsaveis = relationship("FichaAtendimento", foreign_keys="FichaAtendimento.id_responsavel", back_populates="responsavel")
    fichas_paciente = relationship("FichaAtendimento", foreign_keys="FichaAtendimento.id_paciente", back_populates="paciente")
    logs = relationship("LogAuditoria", back_populates="usuario")
