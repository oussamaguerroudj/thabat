"""
Verification engine data model.

Per project spec §10, the possible result states are exactly these four —
never freeform text, so a client can render/filter on the enum reliably:
موثوق (verified), يحتاج إلى تحقق (needs review), غير موثوق (unreliable),
تعذر التحقق (could not verify — insufficient evidence, not a fifth
"error" state; this is a legitimate, honest outcome, not a failure).
"""
import uuid
from datetime import datetime
from enum import Enum

from sqlalchemy import DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class VerificationStatus(str, Enum):
    verified = "verified"  # موثوق
    needs_review = "needs_review"  # يحتاج إلى تحقق
    unreliable = "unreliable"  # غير موثوق
    inconclusive = "inconclusive"  # تعذر التحقق


class VerificationRecord(Base):
    __tablename__ = "verification_records"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    submitted_content: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[str] = mapped_column(Text, nullable=False)
    explanation: Mapped[str] = mapped_column(Text, nullable=False)
    # Stored evidence is a JSON snapshot of what was retrieved at check
    # time (chunk id/source/content/similarity) — kept even though
    # source_chunks can change later, so a saved verification's evidence
    # stays exactly what was actually used to reach that verdict.
    evidence: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    user = relationship("User")
