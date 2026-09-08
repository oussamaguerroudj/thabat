"""
Centralized error handling.

Every module raises these instead of raw HTTPException, so error shape is
consistent across the whole API and callers (Flutter) can rely on one
envelope regardless of which module produced the error.
"""
import logging

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

logger = logging.getLogger(__name__)


class ThabatError(Exception):
    """Base class for all application-level errors."""

    status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR
    code: str = "internal_error"

    def __init__(self, message: str, *, code: str | None = None):
        self.message = message
        if code:
            self.code = code
        super().__init__(message)


class NotFoundError(ThabatError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "not_found"


class ValidationFailedError(ThabatError):
    status_code = status.HTTP_422_UNPROCESSABLE_CONTENT
    code = "validation_failed"


class UnauthorizedError(ThabatError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "unauthorized"


class ForbiddenError(ThabatError):
    status_code = status.HTTP_403_FORBIDDEN
    code = "forbidden"


class ConflictError(ThabatError):
    status_code = status.HTTP_409_CONFLICT
    code = "conflict"


def _error_envelope(code: str, message: str) -> dict:
    return {"error": {"code": code, "message": message}}


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(ThabatError)
    async def handle_thabat_error(request: Request, exc: ThabatError):
        logger.warning("handled_error", extra={"code": exc.code, "path": request.url.path})
        return JSONResponse(
            status_code=exc.status_code,
            content=_error_envelope(exc.code, exc.message),
        )

    @app.exception_handler(Exception)
    async def handle_unexpected_error(request: Request, exc: Exception):
        # Never leak internal exception details to the client.
        logger.error(
            "unhandled_error", extra={"path": request.url.path}, exc_info=exc
        )
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content=_error_envelope("internal_error", "An unexpected error occurred."),
        )
