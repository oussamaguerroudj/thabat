from fastapi import APIRouter

from app.db.session import check_db_connection

router = APIRouter(prefix="/health", tags=["health"])


@router.get("/live")
async def liveness():
    """Process is up. No external dependency checked — used for basic uptime checks."""
    return {"status": "ok"}


@router.get("/ready")
async def readiness():
    """Process is up AND its dependencies (DB) are reachable."""
    db_ok = await check_db_connection()
    return {
        "status": "ok" if db_ok else "degraded",
        "dependencies": {"database": "ok" if db_ok else "unreachable"},
    }
