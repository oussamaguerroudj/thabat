from fastapi import APIRouter, Depends

from app.modules.auth.dependencies import get_auth_service, get_current_user
from app.modules.auth.models import User
from app.modules.auth.schemas import (
    ForgotPasswordRequest,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    ResendVerificationRequest,
    ResetPasswordRequest,
    TokenPairResponse,
    UserResponse,
    VerifyEmailRequest,
)
from app.modules.auth.service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserResponse, status_code=201)
async def register(body: RegisterRequest, service: AuthService = Depends(get_auth_service)):
    user = await service.register(
        email=body.email, password=body.password, display_name=body.display_name
    )
    return UserResponse.model_validate(user)


@router.post("/verify-email", status_code=204)
async def verify_email(body: VerifyEmailRequest, service: AuthService = Depends(get_auth_service)):
    await service.verify_email(email=body.email, code=body.code)


@router.post("/resend-verification", status_code=204)
async def resend_verification(
    body: ResendVerificationRequest, service: AuthService = Depends(get_auth_service)
):
    await service.resend_verification(email=body.email)


@router.post("/login", response_model=TokenPairResponse)
async def login(body: LoginRequest, service: AuthService = Depends(get_auth_service)):
    return await service.login(email=body.email, password=body.password)


@router.post("/refresh", response_model=TokenPairResponse)
async def refresh(body: RefreshRequest, service: AuthService = Depends(get_auth_service)):
    return await service.refresh(raw_refresh_token=body.refresh_token)


@router.post("/logout", status_code=204)
async def logout(body: RefreshRequest, service: AuthService = Depends(get_auth_service)):
    await service.logout(raw_refresh_token=body.refresh_token)


@router.post("/forgot-password", status_code=204)
async def forgot_password(
    body: ForgotPasswordRequest, service: AuthService = Depends(get_auth_service)
):
    await service.forgot_password(email=body.email)


@router.post("/reset-password", status_code=204)
async def reset_password(body: ResetPasswordRequest, service: AuthService = Depends(get_auth_service)):
    await service.reset_password(email=body.email, code=body.code, new_password=body.new_password)


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    """Proves the protected-route dependency actually works end to end."""
    return UserResponse.model_validate(current_user)
