"""
Cohere embedding adapter (ADR-008). This is the ONLY file in the project
allowed to import the `cohere` SDK directly — everything else depends on
the `EmbeddingClient` protocol.
"""
import cohere

from app.core.config import get_settings


class CohereEmbeddingClient:
    def __init__(self) -> None:
        settings = get_settings()
        self._model = settings.embedding_model_name
        self._client = cohere.AsyncClientV2(api_key=settings.embedding_provider_api_key)

    async def embed(self, texts: list[str]) -> list[list[float]]:
        response = await self._client.embed(
            texts=texts,
            model=self._model,
            input_type="search_query",
            embedding_types=["float"],
        )
        return response.embeddings.float_
