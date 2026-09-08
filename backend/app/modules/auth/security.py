"""
Security primitives: password hashing, JWT access/refresh tokens, and
verification-code generation. Nothing outside this file should call argon2
or jwt directly — keeps the crypto surface area in one reviewable place.
"""
import hashlib
import secrets
from datetime import UTC, datetime, timedelta

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

from app.core.config import get_settings

_hasher = PasswordHasher()


# ---- Passwords ----------------------------------------------------------

def hash_password(plain_password: str) -> str:
    return _hasher.hash(plain_password)


def verify_password(plain_password: str, password_hash: str) -> bool:
    try:
        return _hasher.verify(password_hash, plain_password)
    except VerifyMismatchError:
        return False


# ---- Verification codes --------------------------------------------------
# Codes are short (6-digit) for UX, but treated as secrets: hashed at rest,
# same as passwords/tokens, and generated with a CSPRNG, not `random`.

def generate_verification_code() -> str:
    return f"{secrets.randbelow(1_000_000):06d}"


def hash_verification_code(code: str) -> str:
    # SHA-256 is sufficient here (codes are short-lived, high-entropy-enough
    # for their threat model, and rate-limited) — argon2's cost is
    # unnecessary for a 6-digit code with expiry + attempt limiting.
    return hashlib.sha256(code.encode()).hexdigest()


# ---- Refresh tokens -------------------------------------------------------
# Raw refresh token = a random string handed to the client. Only its hash
# is stored, so a DB read alone can't be replayed as a valid session.

def generate_refresh_token() -> str:
    return secrets.token_urlsafe(48)


def hash_refresh_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


# ---- JWT access tokens -----------------------------------------------------

def create_access_token(*, user_id: str) -> str:
    settings = get_settings()
    now = datetime.now(UTC)
    payload = {
        "sub": user_id,
        "type": "access",
        "iat": now,
        "exp": now + timedelta(minutes=settings.jwt_access_ttl_minutes),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def decode_access_token(token: str) -> dict:
    """Raises jwt.PyJWTError (or a subclass) on any invalid/expired token —
    callers must catch this, never assume success."""
    settings = get_settings()
    payload = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
    if payload.get("type") != "access":
        raise jwt.InvalidTokenError("Not an access token")
    return payload
