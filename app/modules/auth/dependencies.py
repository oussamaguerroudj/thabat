import jwt
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import UnauthorizedError
from app.db.session import get_db
from app.modules.auth.email import LoggingEmailSender
from app.modules.auth.models import User
from app.modules.auth.repository import AuthRepository
from app.modules.auth.security import decode_access_token
from app.modules.auth.service import AuthService

_bearer_scheme = HTTPBearer(auto_error=False)


def get_auth_service(db: AsyncSession = Depends(get_db)) -> AuthService:
    # LoggingEmailSender per ADR-009 — swap for a real provider before prod.
    return AuthService(repo=AuthRepository(db), email_sender=LoggingEmailSender())


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    if credentials is None:
        raise UnauthorizedError("Missing authentication token.", code="missing_token")

    try:
        payload = decode_access_token(credentials.credentials)
    except jwt.PyJWTError as exc:
        raise UnauthorizedError("Invalid or expired token.", code="invalid_token") from exc

    repo = AuthRepository(db)
    user = await repo.get_user_by_id(payload["sub"])
    if user is None or not user.is_active:
        raise UnauthorizedError("Invalid or expired token.", code="invalid_token")
    return user
