"""Email delivery boundary (ADR-009)."""
import logging
from typing import Protocol

from app.modules.auth.models import VerificationPurpose

logger = logging.getLogger(__name__)


class EmailSender(Protocol):
    async def send_verification_code(
        self, *, to: str, code: str, purpose: VerificationPurpose
    ) -> None: ...


class LoggingEmailSender:
    """Dev-only implementation — logs instead of sending real email. Never
    wire this into a production deployment; see ADR-009 for the tracked gap."""

    async def send_verification_code(
        self, *, to: str, code: str, purpose: VerificationPurpose
    ) -> None:
        logger.info(
            "verification_code_issued",
            extra={"to": to, "purpose": purpose.value},
        )
        # Deliberately not logging the code itself at INFO level in a real
        # deployment — printed here only because this IS the dev delivery
        # mechanism (there is no other channel until ADR-009 is resolved).
        print(f"[DEV EMAIL] To: {to} | Purpose: {purpose.value} | Code: {code}")
