from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from database import Base


class HospitalDestino(Base):
    __tablename__ = "hospital_destino"

    id_hospital = Column(Integer, primary_key=True, index=True)
    nome = Column(String(255), nullable=False)
    endereco = Column(String(255), nullable=True)

    fichas = relationship(
        "FichaAtendimento",
        back_populates="hospital_destino"
    )