from fastapi import APIRouter

from .auth_controller import router as auth_router
from .ficha_controller import router as ficha_router
from .sync_controller import router as sync_router
from .report_controller import router as report_router
from .cadastro_controller import router as cadastro_router
from .usuario_controller import router as usuario_router
from .log_controller import router as log_router

api_router = APIRouter(prefix="/api")

#Unifica todos os submódulos de controllers sob o prefixo global /api.

api_router.include_router(auth_router)
api_router.include_router(ficha_router)
api_router.include_router(sync_router)
api_router.include_router(report_router)
api_router.include_router(cadastro_router)
api_router.include_router(usuario_router)
api_router.include_router(log_router)

__all__ = [
    "api_router",
    "auth_router",
    "ficha_router",
    "sync_router",
    "report_router",
    "cadastro_router",
    "usuario_router",
    "log_router",
]
