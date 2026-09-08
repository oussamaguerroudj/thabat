"""
Structured logging setup.

Rule: never log request bodies, tokens, passwords, or verification codes
wholesale. Individual modules are responsible for redacting before logging
their own domain objects — this only configures the format/sink.
"""
import logging
import sys

from pythonjsonlogger import jsonlogger

from app.core.config import get_settings


def configure_logging() -> None:
    settings = get_settings()

    handler = logging.StreamHandler(sys.stdout)
    formatter = jsonlogger.JsonFormatter(
        "%(asctime)s %(levelname)s %(name)s %(message)s"
    )
    handler.setFormatter(formatter)

    root = logging.getLogger()
    root.handlers = [handler]
    root.setLevel(settings.log_level.upper())

    # Quiet noisy third-party loggers unless we're actively debugging them.
    logging.getLogger("sqlalchemy.engine").setLevel(
        logging.INFO if settings.log_level.upper() == "DEBUG" else logging.WARNING
    )
