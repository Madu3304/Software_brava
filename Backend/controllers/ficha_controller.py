from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from schemas import FichaResumoResponse
from services.ficha_service import listar_fichas_com_sinais_vitais

router = APIRouter()

@router.get("/resumo", response_model=list[FichaResumoResponse])
def get_resumo_fichas(db: Session = Depends(get_db)):
    """
    Retorna a listagem resumida de atendimentos com dados do paciente e PA
    utilizando junção relacional das tabelas.
    """
    return listar_fichas_com_sinais_vitais(db)