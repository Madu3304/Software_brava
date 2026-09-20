from pydantic import BaseModel
from typing import Optional

class FichaResumoResponse(BaseModel):
    id_ficha: int
    nome_paciente: str
    pressao_arterial: Optional[str] = "N/A"

    class Config:
        from_attributes = True