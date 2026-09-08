"""
AI orchestration service — implements the pipeline fixed in Phase 0 §8:

    query -> embed -> retrieve trusted-source evidence -> evidence check
          -> LLM call grounded in that evidence -> structured response

This is feature-agnostic: both "اسأل ثبات" (Phase 9) and the verification
engine (Phase 8) will call this with different prompts/framing on top, not
duplicate this pipeline.
"""
from app.modules.ai_orchestration.interfaces import EmbeddingClient, LLMClient, Retriever
from app.modules.ai_orchestration.prompts import BASE_SYSTEM_PROMPT, build_user_prompt
from app.modules.ai_orchestration.schemas import AIOrchestrationResponse, RetrievedEvidence

MIN_EVIDENCE_ITEMS = 1
MIN_SIMILARITY_TO_TRUST = 0.3


def _format_evidence_block(evidence: list[RetrievedEvidence]) -> str:
    if not evidence:
        return "(لا توجد أدلة مسترجعة ذات صلة)"
    lines = []
    for i, item in enumerate(evidence, start=1):
        lines.append(f"[{i}] المصدر: {item.source_name} ({item.source_type.value})\n{item.content}")
    return "\n\n".join(lines)


class AIOrchestrationService:
    def __init__(self, llm: LLMClient, embedder: EmbeddingClient, retriever: Retriever) -> None:
        self._llm = llm
        self._embedder = embedder
        self._retriever = retriever

    async def ask(self, question: str, *, top_k: int = 5) -> AIOrchestrationResponse:
        [query_embedding] = await self._embedder.embed([question])
        evidence = await self._retriever.retrieve(query_embedding, top_k=top_k)

        strong_evidence = [e for e in evidence if e.similarity_score >= MIN_SIMILARITY_TO_TRUST]
        grounded = len(strong_evidence) >= MIN_EVIDENCE_ITEMS

        if not grounded:
            # No confident model call at all — don't spend a generation call
            # dressing up "no evidence" as a fluent-sounding answer.
            return AIOrchestrationResponse(
                explanation=(
                    "لم أجد أدلة كافية من المصادر الموثوقة للإجابة على هذا السؤال بثقة. "
                    "يُرجى إعادة صياغة السؤال أو استشارة أهل العلم مباشرة."
                ),
                evidence=evidence,
                grounded=False,
            )

        user_prompt = build_user_prompt(
            question=question, evidence_block=_format_evidence_block(strong_evidence)
        )
        raw_answer = await self._llm.generate(
            system_prompt=BASE_SYSTEM_PROMPT, user_message=user_prompt
        )

        return AIOrchestrationResponse(
            explanation=raw_answer,
            evidence=strong_evidence,
            grounded=True,
        )
