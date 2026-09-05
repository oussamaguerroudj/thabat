from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.auth.models import RefreshToken, User, VerificationCode


class AuthRepository:
    def __init__(self, db: AsyncSession):
        self._db = db

    async def get_user_by_email(self, email: str) -> User | None:
        result = await self._db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()

    async def get_user_by_id(self, user_id: str) -> User | None:
        result = await self._db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()

    def add_user(self, user: User) -> None:
        self._db.add(user)

    async def get_active_verification_code(
        self, user_id: str, purpose: str
    ) -> VerificationCode | None:
        result = await self._db.execute(
            select(VerificationCode)
            .where(
                VerificationCode.user_id == user_id,
                VerificationCode.purpose == purpose,
                VerificationCode.consumed_at.is_(None),
            )
            .order_by(VerificationCode.created_at.desc())
        )
        return result.scalars().first()

    def add_verification_code(self, code: VerificationCode) -> None:
        self._db.add(code)

    async def get_refresh_token_by_hash(self, token_hash: str) -> RefreshToken | None:
        result = await self._db.execute(
            select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        )
        return result.scalar_one_or_none()

    def add_refresh_token(self, token: RefreshToken) -> None:
        self._db.add(token)

    async def revoke_refresh_token(self, token: RefreshToken) -> None:
        token.revoked_at = datetime.now(UTC)

    async def commit(self) -> None:
        await self._db.commit()
