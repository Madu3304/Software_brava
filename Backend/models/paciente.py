from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Paciente(Base):
    __tablename__ = "paciente"

    id_paciente = Column(Integer, primary_key=True, index=True)
    nome = Column(String(200), nullable=True)
    idade = Column(Integer, nullable=True)
    sexo = Column(String(1), nullable=True) # 'M', 'F', 'O'
    documento = Column(String(30), nullable=True)
    criado_em = Column(DateTime, server_default=func.now())
    data_nascimento = Column(DateTime, nullable=True)
    acompanhante = Column(String(200), nullable=True)
    grau_parentesco = Column(String(50), nullable=True)
    telefone_acompanhante = Column(String(20), nullable=True)
    gravidade_previa = Column(String(20), nullable=True)
    historico_clinico = Column(String(255), nullable=True)
    alergias = Column(String(255), nullable=True)
    medicamentoUso_paciente = Column(String(255), nullable=True)
    observacao_paciente = Column(String(255), nullable=True)


    # Relacionamentos
    fichas = relationship("FichaAtendimento", back_populates="paciente")
