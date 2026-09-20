# Backend/services/ficha_service.py
from sqlalchemy.orm import Session
from models import FichaAtendimento, Paciente, AvaliacaoClinica
from schemas import FichaResumoResponse

def listar_fichas_com_sinais_vitais(db: Session) -> list[FichaResumoResponse]:
    resultados = (
        db.query(FichaAtendimento, Paciente, AvaliacaoClinica)
        .outerjoin(Paciente, FichaAtendimento.id_paciente == Paciente.id_paciente)
        .outerjoin(AvaliacaoClinica, FichaAtendimento.id_ficha == AvaliacaoClinica.id_ficha)
        .all()
    )

    lista_formatada = []
    for ficha, paciente, avaliacao in resultados:
        lista_formatada.append(
            FichaResumoResponse(
                id_ficha=ficha.id_ficha,
                nome_paciente=paciente.nome if (paciente and paciente.nome) else "Não informado",
                pressao_arterial=avaliacao.pressao_arterial if (avaliacao and avaliacao.pressao_arterial) else "N/A"
            )
        )
    
    return lista_formatada