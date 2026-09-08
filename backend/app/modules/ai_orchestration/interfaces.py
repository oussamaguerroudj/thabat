"""
Provider-agnostic interfaces (ADR-006).

Orchestration logic (service.py) depends only on these Protocols — never on
a concrete SDK. Swapping Anthropic for another LLM vendor, or Cohere for
another embedding vendor, means writing one new class in providers/ and
changing one line of dependency wiring. Nothing in this module's business
logic should ever import `anthropic` or `cohere` directly.
"""
from typing import Protocol


class LLMClient(Protocol):
    async def generate(self, *, system_prompt: str, user_message: str) -> str:
        """Return the raw model completion for a single-turn request."""
        ...


class EmbeddingClient(Protocol):
    async def embed(self, texts: list[str]) -> list[list[float]]:
        """Return one embedding vector per input text, same order."""
        ...


class Retriever(Protocol):
    async def retrieve(self, query_embedding: list[float], top_k: int) -> list:
        """Return the top_k most relevant RetrievedEvidence items for a query embedding."""
        ...
