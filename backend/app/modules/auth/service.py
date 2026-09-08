"""
Auth business logic. Routers call this; this calls the repository. Never
the other way around, and routers never touch SQLAlchemy directly.
"""
import uuid
from datetime import UTC, datetime, timedelta

from app.core.config import get_settings
from app.core.errors import ConflictError, UnauthorizedError, ValidationFailedError
from app.modules.auth.email import EmailSender
from app.modules.auth.models import (
    AccountStatus,
    RefreshToken,
    User,
    VerificationCode,
    VerificationPurpose,
)
from app.modules.auth.repository import AuthRepository
from app.modules.auth.schemas import TokenPairResponse
from app.modules.auth.security import (
    create_access_token,
    generate_refresh_token,
    generate_verification_code,
    hash_password,
    hash_refresh_token,
    hash_verification_code,
    verify_password,
)

VERIFICATION_CODE_TTL_MINUTES = 15
RESEND_COOLDOWN_SECONDS = 60


class AuthService:
    def __init__(self, repo: AuthRepository, email_sender: EmailSender):
        self._repo = repo
        self._email_sender = email_sender

    # ---- Registration -----------------------------------------------------

    async def register(self, *, email: str, password: str, display_name: str | None) -> User:
        existing = await self._repo.get_user_by_email(email)
        if existing is not None:
            # Same message whether the email exists as verified or
            # pending — do not leak account existence via error detail.
            raise ConflictError("Unable to register with this email.", code="registration_failed")

        now = datetime.now(UTC)
        user = User(
            id=uuid.uuid4(),
            email=email,
            password_hash=hash_password(password),
            display_name=display_name,
            account_status=AccountStatus.pending_verification.value,
            created_at=now,
            updated_at=now,
        )
        self._repo.add_user(user)
        await self._repo.commit()

        await self._issue_and_send_code(user, VerificationPurpose.email_verification)
        return user

    async def _issue_and_send_code(self, user: User, purpose: VerificationPurpose) -> None:
        now = datetime.now(UTC)
        existing = await self._repo.get_active_verification_code(str(user.id), purpose.value)
        if existing is not None:
            elapsed = (now - existing.last_sent_at.replace(tzinfo=UTC)).total_seconds()
            if elapsed < RESEND_COOLDOWN_SECONDS:
                raise ValidationFailedError(
                    "Please wait before requesting another code.", code="resend_cooldown"
                )
            existing.consumed_at = now  # invalidate the old one before issuing a new one

        code = generate_verification_code()
        record = VerificationCode(
            id=uuid.uuid4(),
            user_id=user.id,
            purpose=purpose.value,
            code_hash=hash_verification_code(code),
            expires_at=now + timedelta(minutes=VERIFICATION_CODE_TTL_MINUTES),
            last_sent_at=now,
            created_at=now,
        )
        self._repo.add_verification_code(record)
        await self._repo.commit()
        await self._email_sender.send_verification_code(to=user.email, code=code, purpose=purpose)

    async def resend_verification(self, *, email: str) -> None:
        user = await self._repo.get_user_by_email(email)
        if user is None or user.account_status != AccountStatus.pending_verification.value:
            return  # do not reveal whether the email exists / is already verified
        await self._issue_and_send_code(user, VerificationPurpose.email_verification)

    async def verify_email(self, *, email: str, code: str) -> None:
        user = await self._repo.get_user_by_email(email)
        if user is None:
            raise ValidationFailedError("Invalid or expired code.", code="invalid_code")

        record = await self._repo.get_active_verification_code(
            str(user.id), VerificationPurpose.email_verification.value
        )
        self._check_code(record, code)

        record.consumed_at = datetime.now(UTC)
        user.account_status = AccountStatus.active.value
        user.updated_at = datetime.now(UTC)
        await self._repo.commit()

    def _check_code(self, record: VerificationCode | None, code: str) -> None:
        now = datetime.now(UTC)
        if (
            record is None
            or not record.is_usable
            or record.expires_at.replace(tzinfo=UTC) < now
            or record.code_hash != hash_verification_code(code)
        ):
            raise ValidationFailedError("Invalid or expired code.", code="invalid_code")

    # ---- Login / tokens -----------------------------------------------------

    async def login(self, *, email: str, password: str) -> TokenPairResponse:
        user = await self._repo.get_user_by_email(email)
        if user is None or not verify_password(password, user.password_hash):
            raise UnauthorizedError("Invalid email or password.", code="invalid_credentials")
        if user.account_status == AccountStatus.pending_verification.value:
            raise UnauthorizedError("Please verify your email before logging in.", code="unverified")
        if user.account_status != AccountStatus.active.value:
            raise UnauthorizedError("This account is not active.", code="account_inactive")

        return await self._issue_token_pair(user)

    async def _issue_token_pair(self, user: User) -> TokenPairResponse:
        settings = get_settings()
        access_token = create_access_token(user_id=str(user.id))

        raw_refresh = generate_refresh_token()
        now = datetime.now(UTC)
        token_record = RefreshToken(
            id=uuid.uuid4(),
            user_id=user.id,
            token_hash=hash_refresh_token(raw_refresh),
            expires_at=now + timedelta(days=settings.jwt_refresh_ttl_days),
            created_at=now,
        )
        self._repo.add_refresh_token(token_record)
        await self._repo.commit()

        return TokenPairResponse(access_token=access_token, refresh_token=raw_refresh)

    async def refresh(self, *, raw_refresh_token: str) -> TokenPairResponse:
        token_hash = hash_refresh_token(raw_refresh_token)
        record = await self._repo.get_refresh_token_by_hash(token_hash)
        now = datetime.now(UTC)

        if (
            record is None
            or record.is_revoked
            or record.expires_at.replace(tzinfo=UTC) < now
        ):
            raise UnauthorizedError("Invalid or expired refresh token.", code="invalid_refresh_token")

        # Rotate: revoke the used token, issue a new pair. Prevents replay
        # of a stolen-but-already-used refresh token.
        await self._repo.revoke_refresh_token(record)
        user = await self._repo.get_user_by_id(str(record.user_id))
        if user is None:
            raise UnauthorizedError("Invalid or expired refresh token.", code="invalid_refresh_token")

        return await self._issue_token_pair(user)

    async def logout(self, *, raw_refresh_token: str) -> None:
        token_hash = hash_refresh_token(raw_refresh_token)
        record = await self._repo.get_refresh_token_by_hash(token_hash)
        if record is not None and not record.is_revoked:
            await self._repo.revoke_refresh_token(record)
            await self._repo.commit()

    # ---- Password reset -----------------------------------------------------

    async def forgot_password(self, *, email: str) -> None:
        user = await self._repo.get_user_by_email(email)
        if user is None:
            return  # do not reveal whether the email is registered
        await self._issue_and_send_code(user, VerificationPurpose.password_reset)

    async def reset_password(self, *, email: str, code: str, new_password: str) -> None:
        user = await self._repo.get_user_by_email(email)
        if user is None:
            raise ValidationFailedError("Invalid or expired code.", code="invalid_code")

        record = await self._repo.get_active_verification_code(
            str(user.id), VerificationPurpose.password_reset.value
        )
        self._check_code(record, code)

        record.consumed_at = datetime.now(UTC)
        user.password_hash = hash_password(new_password)
        user.updated_at = datetime.now(UTC)
        await self._repo.commit()
