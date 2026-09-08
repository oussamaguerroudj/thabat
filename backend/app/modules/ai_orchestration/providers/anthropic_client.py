"""
Anthropic Claude adapter (ADR-007). This is the ONLY file in the project
allowed to import the `anthropic` SDK directly — everything else depends on
the `LLMClient` protocol.
"""
import anthropic

from app.core.config import get_settings


class AnthropicLLMClient:
    def __init__(self) -> None:
        settings = get_settings()
        self._model = settings.ai_model_name
        self._client = anthropic.AsyncAnthropic(api_key=settings.ai_provider_api_key)

    async def generate(self, *, system_prompt: str, user_message: str) -> str:
        response = await self._client.messages.create(
            model=self._model,
            max_tokens=1024,
            system=system_prompt,
            messages=[{"role": "user", "content": user_message}],
        )
        return "".join(block.text for block in response.content if block.type == "text")
