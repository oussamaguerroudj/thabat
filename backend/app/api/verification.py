from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.modules.auth.dependencies import get_current_user
from app.modules.auth.models import User
from app.modules.verification.dependencies import get_verification_service
from app.modules.verification.repository import VerificationRepository
from app.modules.verification.schemas import (
    VerificationHistoryItem,
    VerificationRequest,
    VerificationResponse,
)
from app.modules.verification.service import VerificationService

router = APIRouter(prefix="/verification", tags=["verification"])


@router.post("/check", response_model=VerificationResponse)
async def check_content(
    body: VerificationRequest,
    current_user: User = Depends(get_current_user),
    service: VerificationService = Depends(get_verification_service),
):
    return await service.check(user_id=str(current_user.id), raw_content=body.content)


@router.get("/history", response_model=list[VerificationHistoryItem])
async def get_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = VerificationRepository(db)
    records = await repo.list_for_user(str(current_user.id))
    return [
        VerificationHistoryItem(
            id=str(r.id),
            submitted_content=r.submitted_content,
            status=r.status,
            created_at=r.created_at,
        )
        for r in records
    ]
