from database import SessionLocal
from models import FichaAtendimento, Paciente, AvaliacaoClinica

db = SessionLocal()
try:
    resultados = (
        db.query(FichaAtendimento, Paciente, AvaliacaoClinica)
        .outerjoin(Paciente, FichaAtendimento.id_paciente == Paciente.id_paciente)
        .outerjoin(AvaliacaoClinica, FichaAtendimento.id_ficha == AvaliacaoClinica.id_ficha)
        .all()
    )
    for ficha, paciente, avaliacao in resultados:
        nome = paciente.nome if paciente else "Não informado"
        pa = avaliacao.pressao_arterial if avaliacao else "N/A"
        print(f"Ficha #{ficha.id_ficha} | Paciente: {nome} | PA: {pa}")
finally:
    db.close()