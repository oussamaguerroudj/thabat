"""
End-to-end test through the real HTTP app: real registration+login (Phase
3), real trusted-source data seeded into real pgvector (Phase 2's schema),
and a real call to POST /verification/check. Only the LLM and embedding
clients are overridden with fakes — this sandbox has no real Anthropic/
Cohere API keys, same known gap as Phase 2/3's own integration tests.
"""
import uuid

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import delete

from app.db.session import AsyncSessionLocal, check_db_connection
from app.main import app
from app.modules.ai_orchestration.providers.pgvector_retriever import PgVectorRetriever
from app.modules.auth.dependencies import get_auth_service
from app.modules.auth.email import EmailSender
from app.modules.auth.models import RefreshToken, User, VerificationCode
from app.modules.auth.repository import AuthRepository
from app.modules.auth.service import AuthService
from app.modules.trusted_sources.models import SourceChunk, SourceDocument, TrustedSource
from app.modules.verification.dependencies import get_verification_service
from app.modules.verification.models import VerificationRecord
from app.modules.verification.repository import VerificationRepository
from app.modules.verification.service import VerificationService
from tests.verification.fakes import FakeEmbeddingClient, FakeLLMClient

pytestmark = pytest.mark.asyncio


class _CapturingEmailSender(EmailSender):
    def __init__(self):
        self.last_code: str | None = None

    async def send_verification_code(self, *, to, code, purpose):
        self.last_code = code


def _unique_email() -> str:
    return f"verify-e2e-{uuid.uuid4().hex[:10]}@thabat-integration-tests.com"


@pytest.fixture
async def registered_user_tokens():
    """Registers + verifies + logs in a real user via the real HTTP API,
    returning (email, access_token). Cleans up after itself."""
    if not await check_db_connection():
        pytest.skip("No live database available for this test")

    capturing_sender = _CapturingEmailSender()

    async def _override_auth_service():
        async with AsyncSessionLocal() as db:
            yield AuthService(repo=AuthRepository(db), email_sender=capturing_sender)

    app.dependency_overrides[get_auth_service] = _override_auth_service
    email = _unique_email()

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post("/auth/register", json={"email": email, "password": "verify-e2e-pass1"})
        assert resp.status_code == 201
        code = capturing_sender.last_code
        assert code is not None

        resp = await client.post("/auth/verify-email", json={"email": email, "code": code})
        assert resp.status_code == 204

        resp = await client.post("/auth/login", json={"email": email, "password": "verify-e2e-pass1"})
        assert resp.status_code == 200
        access_token = resp.json()["access_token"]

    app.dependency_overrides.pop(get_auth_service, None)

    yield email, access_token

    async with AsyncSessionLocal() as db:
        result = await db.execute(User.__table__.select().where(User.email == email))
        row = result.first()
        if row:
            await db.execute(delete(VerificationRecord).where(VerificationRecord.user_id == row.id))
            await db.execute(delete(VerificationCode).where(VerificationCode.user_id == row.id))
            await db.execute(delete(RefreshToken).where(RefreshToken.user_id == row.id))
            await db.execute(delete(User).where(User.id == row.id))
            await db.commit()


@pytest.fixture
async def seeded_source():
    """Seeds one real trusted source + chunk with a real pgvector
    embedding, so the endpoint's retrieval step has real data to find —
    not a fake retriever, the actual PgVectorRetriever from Phase 2."""
    from app.core.config import get_settings

    dim = get_settings().embedding_dimensions
    vector = [1.0] + [0.0] * (dim - 1)

    async with AsyncSessionLocal() as db:
        source = TrustedSource(id=uuid.uuid4(), name="مصدر اختبار شامل", source_type="trusted_article")
        document = SourceDocument(id=uuid.uuid4(), source=source, title="وثيقة اختبار شاملة")
        db.add_all([source, document])
        await db.flush()
        chunk = SourceChunk(
            id=uuid.uuid4(),
            document_id=document.id,
            content="نص مصدر تجريبي متعلق تمامًا بمحتوى الاختبار",
            embedding=vector,
        )
        db.add(chunk)
        await db.commit()

    yield vector

    async with AsyncSessionLocal() as db:
        await db.execute(delete(SourceChunk).where(SourceChunk.document_id == document.id))
        await db.execute(delete(SourceDocument).where(SourceDocument.id == document.id))
        await db.execute(delete(TrustedSource).where(TrustedSource.id == source.id))
        await db.commit()


async def test_verification_check_end_to_end_with_real_retrieval(
    registered_user_tokens, seeded_source
):
    email, access_token = registered_user_tokens
    matching_embedding = seeded_source

    fake_llm = FakeLLMClient(
        canned_response='{"status": "verified", "explanation": "الدليل يدعم هذا المحتوى بوضوح."}'
    )

    async def _override_verification_service():
        async with AsyncSessionLocal() as db:
            yield VerificationService(
                repo=VerificationRepository(db),
                llm=fake_llm,
                embedder=FakeEmbeddingClient(fixed_vector=matching_embedding),
                retriever=PgVectorRetriever(db),  # the REAL retriever
            )

    app.dependency_overrides[get_verification_service] = _override_verification_service

    transport = ASGITransport(app=app)
    try:
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            resp = await client.post(
                "/verification/check",
                json={"content": "محتوى ديني تجريبي للتحقق منه في الاختبار الشامل"},
                headers={"Authorization": f"Bearer {access_token}"},
            )
            assert resp.status_code == 200
            body = resp.json()
            assert body["status"] == "verified"
            assert len(body["evidence"]) == 1
            assert body["evidence"][0]["source_name"] == "مصدر اختبار شامل"
            assert fake_llm.call_count == 1

            # History reflects the real persisted record.
            resp = await client.get(
                "/verification/history", headers={"Authorization": f"Bearer {access_token}"}
            )
            assert resp.status_code == 200
            history = resp.json()
            assert len(history) == 1
            assert history[0]["status"] == "verified"

            # No auth token -> real 401, not silently allowed through.
            resp = await client.post("/verification/check", json={"content": "بدون توثيق"})
            assert resp.status_code == 401
    finally:
        app.dependency_overrides.pop(get_verification_service, None)
