"""
The verification engine (project spec §10):

    content -> normalize -> embed -> retrieve evidence -> evidence check
            -> [insufficient: inconclusive, no LLM call]
            -> [sufficient: LLM verdict call, strict JSON] -> structured result

Deliberately separate from `ai_orchestration/service.py`'s `AIOrchestrationService`
(Ask Thabat) even though both share the same retrieval/LLM provider
interfaces — verification needs a parseable status verdict, not a
conversational answer, and the two must never be conflated per the
project's own distinction between "informational assistant" and
"verification engine".
"""
import json
import logging
import uuid
from datetime import UTC, datetime

from app.modules.ai_orchestration.interfaces import EmbeddingClient, LLMClient, Retriever
from app.modules.ai_orchestration.schemas import RetrievedEvidence
from app.modules.verification.models import VerificationRecord, VerificationStatus
from app.modules.verification.prompts import (
    VERIFICATION_SYSTEM_PROMPT,
    build_verification_user_prompt,
)
from app.modules.verification.repository import VerificationRepository
from app.modules.verification.schemas import VerificationResponse

logger = logging.getLogger(__name__)

MIN_SIMILARITY_TO_TRUST = 0.3
MIN_EVIDENCE_ITEMS = 1

_INCONCLUSIVE_NO_EVIDENCE = (
    "لم يتم العثور على أدلة كافية من المصادر الموثوقة لتقييم هذا المحتوى. "
    "هذا لا يعني أن المحتوى خاطئ — فقط أن ثبات لا يملك حالياً مصدراً موثوقاً كافياً للحكم عليه."
)
_INCONCLUSIVE_BAD_MODEL_OUTPUT = (
    "تعذّر إصدار نتيجة تحقق موثوقة لهذا المحتوى في الوقت الحالي. يُرجى المحاولة لاحقاً."
)


def _normalize_content(raw: str) -> str:
    """Basic normalization only — collapsing whitespace. A real content
    classifier (distinguishing hadith text from a general claim, etc.) is
    intentionally not built here; the project brief warns against building
    fake functionality, and a real classifier needs labeled data this
    project doesn't have yet. Every submission is treated uniformly."""
    return " ".join(raw.split())


def _format_evidence_block(evidence: list[RetrievedEvidence]) -> str:
    if not evidence:
        return "(لا توجد أدلة مسترجعة ذات صلة)"
    lines = []
    for i, item in enumerate(evidence, start=1):
        lines.append(f"[{i}] المصدر: {item.source_name} ({item.source_type.value})\n{item.content}")
    return "\n\n".join(lines)


class VerificationService:
    def __init__(
        self,
        repo: VerificationRepository,
        llm: LLMClient,
        embedder: EmbeddingClient,
        retriever: Retriever,
    ) -> None:
        self._repo = repo
        self._llm = llm
        self._embedder = embedder
        self._retriever = retriever

    async def check(self, *, user_id: str, raw_content: str, top_k: int = 5) -> VerificationResponse:
        content = _normalize_content(raw_content)

        [query_embedding] = await self._embedder.embed([content])
        evidence = await self._retriever.retrieve(query_embedding, top_k=top_k)
        strong_evidence = [e for e in evidence if e.similarity_score >= MIN_SIMILARITY_TO_TRUST]

        if len(strong_evidence) < MIN_EVIDENCE_ITEMS:
            # No confident model call — same principle as AIOrchestrationService:
            # don't spend a generation call dressing up "no evidence" as a
            # confident-sounding verdict. Also: return strong_evidence (empty
            # here), never the raw, below-threshold `evidence` — showing
            # weak/irrelevant matches as if they were "the evidence" would be
            # misleading, not transparent.
            return await self._persist_and_respond(
                user_id=user_id,
                content=content,
                status=VerificationStatus.inconclusive,
                explanation=_INCONCLUSIVE_NO_EVIDENCE,
                evidence=strong_evidence,
            )

        user_prompt = build_verification_user_prompt(
            content=content, evidence_block=_format_evidence_block(strong_evidence)
        )
        raw_response = await self._llm.generate(
            system_prompt=VERIFICATION_SYSTEM_PROMPT, user_message=user_prompt
        )

        status, explanation = self._parse_verdict(raw_response)

        return await self._persist_and_respond(
            user_id=user_id,
            content=content,
            status=status,
            explanation=explanation,
            evidence=strong_evidence,
        )

    def _parse_verdict(self, raw_response: str) -> tuple[VerificationStatus, str]:
        try:
            parsed = json.loads(raw_response.strip())
            status_value = parsed["status"]
            explanation = parsed["explanation"]
            status = VerificationStatus(status_value)
            if not isinstance(explanation, str) or not explanation.strip():
                raise ValueError("empty explanation")
            return status, explanation
        except (json.JSONDecodeError, KeyError, ValueError) as exc:
            # Never crash, never guess a verdict from malformed output —
            # fall back to the same honest "inconclusive" state used for
            # insufficient evidence.
            logger.warning("verification_verdict_parse_failed", extra={"error": str(exc)})
            return VerificationStatus.inconclusive, _INCONCLUSIVE_BAD_MODEL_OUTPUT

    async def _persist_and_respond(
        self,
        *,
        user_id: str,
        content: str,
        status: VerificationStatus,
        explanation: str,
        evidence: list[RetrievedEvidence],
    ) -> VerificationResponse:
        now = datetime.now(UTC)
        record = VerificationRecord(
            id=uuid.uuid4(),
            user_id=user_id,
            submitted_content=content,
            status=status.value,
            explanation=explanation,
            evidence=[e.model_dump(mode="json") for e in evidence],
            created_at=now,
        )
        self._repo.add(record)
        await self._repo.commit()

        return VerificationResponse(
            id=str(record.id),
            status=status,
            explanation=explanation,
            evidence=evidence,
            created_at=now,
        )
