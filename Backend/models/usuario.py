from sqlalchemy import Column, Integer, String, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Usuario(Base):
    __tablename__ = "usuario"

    id_usuario = Column(Integer, primary_key=True, index=True)
    nome = Column(String(200), nullable=False)
    email = Column(String(150), unique=True, nullable=True)
    login = Column(String(100), unique=True, nullable=False)
    senha_hash = Column(String(255), nullable=False)
    perfil = Column(String(50), nullable=False) # 'ADMINISTRADOR', 'ENFERMEIRO', 'TECNICO', 'CONDUTOR', 'MEDICO'
    registro_profissional = Column(String(50), nullable=True) # CRM, COREN, CNH
    ativo = Column(Boolean, default=True)
    criado_em = Column(DateTime, server_default=func.now())

    # Relacionamentos
    fichas_responsaveis = relationship("FichaAtendimento", foreign_keys="FichaAtendimento.id_responsavel", back_populates="responsavel")
    fichas_medico_plantao = relationship("FichaAtendimento", foreign_keys="FichaAtendimento.id_medico_plantao", back_populates="medico_plantao")
    fichas_condutor = relationship("FichaAtendimento", foreign_keys="FichaAtendimento.id_condutor", back_populates="condutor")
    logs = relationship("LogAuditoria", back_populates="usuario")
