"""
pgvector-backed retriever — the concrete implementation behind the
`Retriever` protocol (ADR-003: embeddings live in PostgreSQL, not a
separate vector DB).
"""
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.ai_orchestration.schemas import EvidenceSourceType, RetrievedEvidence
from app.modules.trusted_sources.models import SourceChunk, SourceDocument, TrustedSource


class PgVectorRetriever:
    def __init__(self, db: AsyncSession) -> None:
        self._db = db

    async def retrieve(self, query_embedding: list[float], top_k: int = 5) -> list[RetrievedEvidence]:
        # Cosine distance operator from pgvector; smaller distance = more similar.
        distance = SourceChunk.embedding.cosine_distance(query_embedding)
        stmt = (
            select(SourceChunk, SourceDocument, TrustedSource, distance.label("distance"))
            .join(SourceDocument, SourceChunk.document_id == SourceDocument.id)
            .join(TrustedSource, SourceDocument.source_id == TrustedSource.id)
            .order_by(distance)
            .limit(top_k)
        )
        rows = (await self._db.execute(stmt)).all()

        results = []
        for chunk, _document, source, dist in rows:
            similarity = max(0.0, 1.0 - float(dist))  # cosine distance -> similarity, clamped
            results.append(
                RetrievedEvidence(
                    chunk_id=str(chunk.id),
                    source_name=source.name,
                    source_type=EvidenceSourceType(source.source_type),
                    content=chunk.content,
                    similarity_score=round(similarity, 4),
                )
            )
        return results
