from sqlalchemy import Column, Integer, String, Text, Numeric, Boolean, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from database import Base

class FichaAtendimento(Base):
    __tablename__ = "ficha_atendimento"

    id_ficha = Column(Integer, primary_key=True, index=True)
    uuid_offline = Column(String(64), unique=True, nullable=True) # UUID gerado no tablet em modo offline
    
    id_unidade = Column(Integer, ForeignKey("unidade_movel.id_unidade"), nullable=False)
    id_responsavel = Column(Integer, ForeignKey("usuario.id_usuario"), nullable=False)
    id_medico_plantao = Column(Integer, ForeignKey("usuario.id_usuario"), nullable=False)
    id_condutor = Column(Integer, ForeignKey("usuario.id_usuario"), nullable=True)
    id_paciente = Column(Integer, ForeignKey("paciente.id_paciente"), nullable=True)
    id_hospital_destino = Column(Integer, ForeignKey("hospital_destino.id_hospital"), nullable=True)
    
    # Localização / GPS
    cep = Column(String(10), nullable=True)
    logradouro = Column(String(255), nullable=True)
    bairro = Column(String(100), nullable=True)
    latitude = Column(Numeric(10, 7), nullable=True)
    longitude = Column(Numeric(10, 7), nullable=True)
    gps_pendente = Column(Boolean, default=False)
    
    # Horários operacionais
    hora_chamado = Column(DateTime, nullable=True)
    hora_saida_base = Column(DateTime, nullable=True)
    hora_chegada_local = Column(DateTime, nullable=True)
    hora_saida_local = Column(DateTime, nullable=True)
    hora_chegada_hospital = Column(DateTime, nullable=True)
    hora_conclusao = Column(DateTime, nullable=True)
    
    # Status e parada
    status = Column(String(30), default="EM_ANDAMENTO") # 'EM_ANDAMENTO', 'FINALIZADA', 'SINCRONIZADA'
    unidade_parada = Column(Boolean, default=False)
    motivo_unidade_parada = Column(Text, nullable=True)
    observacoes_gerais = Column(Text, nullable=True)
    criado_em = Column(DateTime, server_default=func.now())

    # Relacionamentos
    unidade_movel = relationship("UnidadeMovel", back_populates="fichas")
    responsavel = relationship("Usuario", foreign_keys=[id_responsavel], back_populates="fichas_responsaveis")
    medico_plantao = relationship("Usuario", foreign_keys=[id_medico_plantao], back_populates="fichas_medico_plantao")
    condutor = relationship("Usuario", foreign_keys=[id_condutor], back_populates="fichas_condutor")
    paciente = relationship("Paciente", back_populates="fichas")
    hospital_destino = relationship("HospitalDestino", back_populates="fichas")
    avaliacao_clinica = relationship("AvaliacaoClinica", uselist=False, back_populates="ficha_atendimento")
