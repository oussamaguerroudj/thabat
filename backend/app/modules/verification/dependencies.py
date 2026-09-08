from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.modules.ai_orchestration.providers.anthropic_client import AnthropicLLMClient
from app.modules.ai_orchestration.providers.cohere_client import CohereEmbeddingClient
from app.modules.ai_orchestration.providers.pgvector_retriever import PgVectorRetriever
from app.modules.verification.repository import VerificationRepository
from app.modules.verification.service import VerificationService


def get_verification_service(db: AsyncSession = Depends(get_db)) -> VerificationService:
    return VerificationService(
        repo=VerificationRepository(db),
        llm=AnthropicLLMClient(),
        embedder=CohereEmbeddingClient(),
        retriever=PgVectorRetriever(db),
    )
