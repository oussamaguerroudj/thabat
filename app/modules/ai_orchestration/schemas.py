"""
Structured AI response contract.

Rule (project spec §8): the AI must distinguish between verified source
content, retrieved evidence, and AI-generated explanation. These schemas
exist so that distinction is enforced in code, not just in a prompt — a
caller literally cannot collapse "explanation" and "evidence" into one
untyped blob.
"""
from enum import Enum

from pydantic import BaseModel, Field


class EvidenceSourceType(str, Enum):
    quran = "quran"
    hadith = "hadith"
    scholarly_reference = "scholarly_reference"
    trusted_article = "trusted_article"


class RetrievedEvidence(BaseModel):
    """One retrieved chunk of trusted-source content. This is verified
    source content — never AI-generated — so it is never paraphrased by
    the model before being shown to the user."""

    chunk_id: str
    source_name: str
    source_type: EvidenceSourceType
    content: str
    similarity_score: float = Field(ge=0.0, le=1.0)
    source_url: str | None = None


class AIOrchestrationResponse(BaseModel):
    """What every AI-orchestrated feature (Ask Thabat, Verification) returns.

    `explanation` is always AI-generated and always clearly separated from
    `evidence`, which is always retrieved trusted-source content. `grounded`
    being False means evidence was insufficient — the caller must render
    this as an uncertainty state, never suppress it or fill the gap with
    an ungrounded answer.
    """

    explanation: str
    evidence: list[RetrievedEvidence]
    grounded: bool
    disclaimer: str = "مساعد معلوماتي وليس مفتياً"
