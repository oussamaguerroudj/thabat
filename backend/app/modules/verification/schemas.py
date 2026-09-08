from datetime import datetime

from pydantic import BaseModel, Field

from app.modules.ai_orchestration.schemas import RetrievedEvidence
from app.modules.verification.models import VerificationStatus


class VerificationRequest(BaseModel):
    content: str = Field(min_length=3, max_length=4000)


class VerificationResponse(BaseModel):
    id: str
    status: VerificationStatus
    explanation: str
    evidence: list[RetrievedEvidence]
    disclaimer: str = "مساعد معلوماتي وليس مفتياً — النتيجة مبنية على الأدلة المسترجعة فقط"
    created_at: datetime

    model_config = {"from_attributes": True}


class VerificationHistoryItem(BaseModel):
    id: str
    submitted_content: str
    status: VerificationStatus
    created_at: datetime

    model_config = {"from_attributes": True}
