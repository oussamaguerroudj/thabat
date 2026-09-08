"""Fake providers used only in tests — deterministic, no network calls."""


class FakeLLMClient:
    def __init__(self, canned_response: str = "إجابة تجريبية مبنية على الأدلة المرفقة."):
        self.canned_response = canned_response
        self.last_system_prompt: str | None = None
        self.last_user_message: str | None = None

    async def generate(self, *, system_prompt: str, user_message: str) -> str:
        self.last_system_prompt = system_prompt
        self.last_user_message = user_message
        return self.canned_response


class FakeEmbeddingClient:
    def __init__(self, dim: int = 8):
        self.dim = dim

    async def embed(self, texts: list[str]) -> list[list[float]]:
        # Deterministic fake vector — length-based, not semantically meaningful.
        return [[float(len(t) % 7)] * self.dim for t in texts]


class FakeRetriever:
    def __init__(self, canned_evidence: list):
        self.canned_evidence = canned_evidence

    async def retrieve(self, query_embedding: list[float], top_k: int = 5):
        return self.canned_evidence[:top_k]
