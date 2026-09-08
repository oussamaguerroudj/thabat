from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.verification.models import VerificationRecord


class VerificationRepository:
    def __init__(self, db: AsyncSession):
        self._db = db

    def add(self, record: VerificationRecord) -> None:
        self._db.add(record)

    async def commit(self) -> None:
        await self._db.commit()

    async def list_for_user(self, user_id: str, *, limit: int = 20) -> list[VerificationRecord]:
        stmt = (
            select(VerificationRecord)
            .where(VerificationRecord.user_id == user_id)
            .order_by(VerificationRecord.created_at.desc())
            .limit(limit)
        )
        result = await self._db.execute(stmt)
        return list(result.scalars().all())
