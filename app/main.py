from fastapi import FastAPI

from app.api.health import router as health_router
from app.core.config import get_settings
from app.core.errors import register_exception_handlers
from app.core.logging import configure_logging

settings = get_settings()
configure_logging()

app = FastAPI(
    title="THABAT API",
    description="تحقق قبل أن تنشر — backend for the THABAT mobile application.",
    version="0.1.0",
    # Docs disabled in prod: internal architecture shouldn't be publicly browsable.
    docs_url=None if settings.is_prod else "/docs",
    redoc_url=None if settings.is_prod else "/redoc",
)

register_exception_handlers(app)

app.include_router(health_router)

# Future module routers are included here as they're built:
#   app.include_router(auth_router)        -> Phase 3
#   app.include_router(verification_router) -> Phase 8
#   app.include_router(ai_router)           -> Phase 9
#   ...etc, one line per module, per the repo structure in docs/ARCHITECTURE.md
