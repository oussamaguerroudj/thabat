"""
Full end-to-end auth flow against the real app and real database — no
mocks. This is the test that actually proves Phase 3 works, not just that
its pieces compile.
"""
import uuid

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import delete

from app.db.session import AsyncSessionLocal, check_db_connection
from app.main import app
from app.modules.auth.dependencies import get_auth_service
from app.modules.auth.email import EmailSender
from app.modules.auth.models import RefreshToken, User, VerificationCode
from app.modules.auth.repository import AuthRepository
from app.modules.auth.service import AuthService

pytestmark = pytest.mark.asyncio


class _CapturingEmailSender(EmailSender):
    """Test double that records the last code issued instead of sending
    real email — installed via FastAPI dependency override so the actual
    /auth/register and /auth/forgot-password endpoints use it, with no
    reliance on the resend-cooldown window."""

    def __init__(self):
        self.last_code: str | None = None

    async def send_verification_code(self, *, to, code, purpose):
        self.last_code = code


@pytest.fixture
async def client():
    if not await check_db_connection():
        pytest.skip("No live database available for this integration test")

    capturing_sender = _CapturingEmailSender()

    async def _override_auth_service():
        async with AsyncSessionLocal() as db:
            yield AuthService(repo=AuthRepository(db), email_sender=capturing_sender)

    app.dependency_overrides[get_auth_service] = _override_auth_service
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        c.captured_sender = capturing_sender  # type: ignore[attr-defined]
        yield c
    app.dependency_overrides.pop(get_auth_service, None)


@pytest.fixture
async def cleanup_users():
    created_emails: list[str] = []
    yield created_emails
    if created_emails:
        async with AsyncSessionLocal() as db:
            result = await db.execute(User.__table__.select().where(User.email.in_(created_emails)))
            user_ids = [row.id for row in result]
            if user_ids:
                await db.execute(delete(VerificationCode).where(VerificationCode.user_id.in_(user_ids)))
                await db.execute(delete(RefreshToken).where(RefreshToken.user_id.in_(user_ids)))
                await db.execute(delete(User).where(User.id.in_(user_ids)))
                await db.commit()


def _unique_email() -> str:
    # NOTE: RFC 2606 reserved domains (.test, .example, .invalid, .localhost,
    # example.com/.org/.net) are rejected by email-validator as
    # special-use/undeliverable — use a plausible-looking but clearly
    # non-reserved domain instead.
    return f"test-{uuid.uuid4().hex[:12]}@thabat-integration-tests.com"


async def test_full_registration_verification_login_flow(client: AsyncClient, cleanup_users):
    email = _unique_email()
    cleanup_users.append(email)

    # 1. Register
    resp = await client.post(
        "/auth/register", json={"email": email, "password": "correct horse battery staple"}
    )
    assert resp.status_code == 201
    assert resp.json()["account_status"] == "pending_verification"
    issued_code = client.captured_sender.last_code
    assert issued_code is not None

    # 2. Login before verification must fail
    resp = await client.post(
        "/auth/login", json={"email": email, "password": "correct horse battery staple"}
    )
    assert resp.status_code == 401
    assert resp.json()["error"]["code"] == "unverified"

    # 3. Verify with wrong code must fail
    resp = await client.post("/auth/verify-email", json={"email": email, "code": "000000"})
    assert resp.status_code == 422
    assert resp.json()["error"]["code"] == "invalid_code"

    # 4. Verify with the real code succeeds
    resp = await client.post("/auth/verify-email", json={"email": email, "code": issued_code})
    assert resp.status_code == 204

    # 5. Login now succeeds and returns a token pair
    resp = await client.post(
        "/auth/login", json={"email": email, "password": "correct horse battery staple"}
    )
    assert resp.status_code == 200
    tokens = resp.json()
    assert tokens["access_token"] and tokens["refresh_token"]

    # 6. Protected route works with the access token
    resp = await client.get(
        "/auth/me", headers={"Authorization": f"Bearer {tokens['access_token']}"}
    )
    assert resp.status_code == 200
    assert resp.json()["email"] == email

    # 7. Protected route rejects missing/garbage tokens
    resp = await client.get("/auth/me")
    assert resp.status_code == 401
    resp = await client.get("/auth/me", headers={"Authorization": "Bearer garbage"})
    assert resp.status_code == 401

    # 8. Refresh rotates tokens; the OLD refresh token can no longer be used
    resp = await client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert resp.status_code == 200
    new_tokens = resp.json()
    assert new_tokens["refresh_token"] != tokens["refresh_token"]

    resp = await client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert resp.status_code == 401  # old token, already rotated away

    # 9. Logout revokes the current refresh token
    resp = await client.post("/auth/logout", json={"refresh_token": new_tokens["refresh_token"]})
    assert resp.status_code == 204
    resp = await client.post("/auth/refresh", json={"refresh_token": new_tokens["refresh_token"]})
    assert resp.status_code == 401


async def test_duplicate_registration_rejected(client: AsyncClient, cleanup_users):
    email = _unique_email()
    cleanup_users.append(email)

    resp = await client.post("/auth/register", json={"email": email, "password": "first password!"})
    assert resp.status_code == 201

    resp = await client.post("/auth/register", json={"email": email, "password": "second password!"})
    assert resp.status_code == 409


async def test_password_reset_flow(client: AsyncClient, cleanup_users):
    email = _unique_email()
    cleanup_users.append(email)

    resp = await client.post("/auth/register", json={"email": email, "password": "original-password1"})
    assert resp.status_code == 201

    resp = await client.post("/auth/forgot-password", json={"email": email})
    assert resp.status_code == 204
    reset_code = client.captured_sender.last_code
    assert reset_code is not None

    resp = await client.post(
        "/auth/reset-password",
        json={"email": email, "code": reset_code, "new_password": "brand-new-password1"},
    )
    assert resp.status_code == 204

    # forgot_password for a NON-existent email must not error (no account-existence leak)
    resp = await client.post("/auth/forgot-password", json={"email": _unique_email()})
    assert resp.status_code == 204

