"""
Integration test against a real PostgreSQL + pgvector instance (not mocked).
Skips automatically if no DB is reachable, so this doesn't break CI
environments without a database — but it DOES run and prove real cosine
similarity search here whenever a DB is available, which it is in this
sandbox.
"""
import uuid

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.db.session import AsyncSessionLocal, check_db_connection
from app.modules.ai_orchestration.providers.pgvector_retriever import PgVectorRetriever
from app.modules.trusted_sources.models import SourceChunk, SourceDocument, TrustedSource

pytestmark = pytest.mark.asyncio


async def _db_available() -> bool:
    return await check_db_connection()


@pytest.fixture
async def db_session():
    if not await _db_available():
        pytest.skip("No live database available for this integration test")
    async with AsyncSessionLocal() as session:
        yield session
        await session.rollback()


async def _seed_source_with_chunks(db: AsyncSession, vectors_and_texts: list[tuple[list[float], str]]):
    source = TrustedSource(id=uuid.uuid4(), name="مصدر اختبار", source_type="trusted_article")
    document = SourceDocument(id=uuid.uuid4(), source=source, title="وثيقة اختبار")
    db.add_all([source, document])
    await db.flush()

    for vector, text in vectors_and_texts:
        chunk = SourceChunk(id=uuid.uuid4(), document_id=document.id, content=text, embedding=vector)
        db.add(chunk)
    await db.commit()
    return source, document


async def _delete_seeded(db: AsyncSession, source: TrustedSource, document: SourceDocument) -> None:
    """Test data is committed (not just flushed) so the retriever can see it
    in a fresh connection — that means the fixture's rollback-on-teardown
    does nothing. Clean up explicitly so runs don't accumulate stale rows
    that pollute later similarity-search results."""
    await db.execute(SourceChunk.__table__.delete().where(SourceChunk.document_id == document.id))
    await db.execute(SourceDocument.__table__.delete().where(SourceDocument.id == document.id))
    await db.execute(TrustedSource.__table__.delete().where(TrustedSource.id == source.id))
    await db.commit()


async def test_pgvector_retriever_returns_closest_chunk_first(db_session: AsyncSession):
    dim = get_settings().embedding_dimensions
    close_vector = [1.0] + [0.0] * (dim - 1)
    far_vector = [0.0] * (dim - 1) + [1.0]

    source, document = await _seed_source_with_chunks(
        db_session,
        [
            (close_vector, "هذا النص هو الأقرب دلالياً للاستعلام"),
            (far_vector, "هذا النص بعيد دلالياً عن الاستعلام"),
        ],
    )

    try:
        retriever = PgVectorRetriever(db_session)
        query_embedding = [1.0] + [0.0] * (dim - 1)  # identical to close_vector
        results = await retriever.retrieve(query_embedding, top_k=2)

        assert len(results) == 2
        assert results[0].content == "هذا النص هو الأقرب دلالياً للاستعلام"
        assert results[0].similarity_score > results[1].similarity_score
        assert results[0].similarity_score > 0.99  # near-identical vectors -> near-1.0 similarity
    finally:
        await _delete_seeded(db_session, source, document)
