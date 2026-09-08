"""
Async database session management.

Modules depend on `get_db` (a FastAPI dependency) to obtain a session —
nothing outside this file creates engines or raw connections, so connection
pooling and lifecycle stay in one place.
"""
from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import get_settings

settings = get_settings()

engine = create_async_engine(
    settings.database_url,
    echo=False,
    pool_pre_ping=True,
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    expire_on_commit=False,
    autoflush=False,
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session


async def check_db_connection() -> bool:
    """Used by the readiness health check — never raises, returns False on failure."""
    try:
        async with engine.connect() as conn:
            await conn.exec_driver_sql("SELECT 1")
        return True
    except Exception:  # noqa: BLE001 — intentional: readiness must never crash on a DB error
        return False
