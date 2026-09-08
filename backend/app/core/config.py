"""
Centralized application settings.

Every config value is read from the environment (see .env.example) — never
hardcoded, per project rule #6. This is the single place other modules pull
config from; nothing else should call os.environ directly.
"""
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # App
    env: str = "dev"  # dev | staging | prod
    log_level: str = "INFO"

    # Database
    database_url: str = "postgresql+asyncpg://thabat:thabat@localhost:5432/thabat"

    # Auth (values fixed in Phase 3 — names reserved here per Phase 0 §5)
    jwt_secret: str = "changeme-dev-only"
    jwt_refresh_secret: str = "changeme-dev-only-refresh"
    jwt_access_ttl_minutes: int = 15
    jwt_refresh_ttl_days: int = 30

    # AI provider (concrete provider selected in Phase 2 — ADR-007)
    ai_provider_api_key: str = ""
    ai_model_name: str = "claude-sonnet-4-6"

    # Embedding provider (ADR-008)
    embedding_provider_api_key: str = ""
    embedding_model_name: str = "embed-multilingual-v3.0"
    embedding_dimensions: int = 1024

    # Rate limiting (tuned in a later phase)
    rate_limit_per_minute: int = 60

    @property
    def is_prod(self) -> bool:
        return self.env == "prod"


@lru_cache
def get_settings() -> Settings:
    return Settings()
