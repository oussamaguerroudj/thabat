"""Fake providers for verification unit tests — no network calls."""
from app.modules.ai_orchestration.schemas import EvidenceSourceType, RetrievedEvidence


class FakeLLMClient:
    def __init__(self, canned_response: str):
        self.canned_response = canned_response
        self.last_system_prompt: str | None = None
        self.last_user_message: str | None = None
        self.call_count = 0

    async def generate(self, *, system_prompt: str, user_message: str) -> str:
        self.call_count += 1
        self.last_system_prompt = system_prompt
        self.last_user_message = user_message
        return self.canned_response


class FakeEmbeddingClient:
    def __init__(self, fixed_vector: list[float] | None = None):
        self._fixed_vector = fixed_vector

    async def embed(self, texts: list[str]) -> list[list[float]]:
        vector = self._fixed_vector if self._fixed_vector is not None else [0.1] * 8
        return [vector for _ in texts]


class FakeRetriever:
    def __init__(self, canned_evidence: list[RetrievedEvidence]):
        self.canned_evidence = canned_evidence

    async def retrieve(self, query_embedding: list[float], top_k: int = 5):
        return self.canned_evidence[:top_k]


def make_evidence(score: float, content: str = "نص تجريبي من مصدر موثوق") -> RetrievedEvidence:
    return RetrievedEvidence(
        chunk_id="c1",
        source_name="مصدر تجريبي",
        source_type=EvidenceSourceType.trusted_article,
        content=content,
        similarity_score=score,
    )
