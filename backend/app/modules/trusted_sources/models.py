"""
Foundational RAG schema: trusted sources, their documents, and embedded
chunks. This is intentionally minimal — full trusted-sources management
(admin CRUD, methodology pages, categorization UI) is Phase 20. Phase 2 only
needs enough schema for retrieval to function.
"""
import uuid
from datetime import datetime

from pgvector.sqlalchemy import Vector
from sqlalchemy import ForeignKey, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.config import get_settings
from app.db.base import Base

_EMBEDDING_DIM = get_settings().embedding_dimensions


class TrustedSource(Base):
    """A source THABAT is willing to cite — e.g. a specific mushaf edition,
    a hadith collection, a named scholarly reference work."""

    __tablename__ = "trusted_sources"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    source_type: Mapped[str] = mapped_column(Text, nullable=False)  # quran|hadith|scholarly_reference|trusted_article
    methodology_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    documents: Mapped[list["SourceDocument"]] = relationship(back_populates="source")


class SourceDocument(Base):
    """One ingested document belonging to a trusted source (e.g. one surah,
    one hadith-collection volume)."""

    __tablename__ = "source_documents"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    source_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("trusted_sources.id"), nullable=False)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    source: Mapped["TrustedSource"] = relationship(back_populates="documents")
    chunks: Mapped[list["SourceChunk"]] = relationship(back_populates="document")


class SourceChunk(Base):
    """A retrievable, embedded slice of a source document — the unit RAG
    actually searches over."""

    __tablename__ = "source_chunks"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    document_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("source_documents.id"), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    embedding: Mapped[list[float]] = mapped_column(Vector(_EMBEDDING_DIM), nullable=False)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    document: Mapped["SourceDocument"] = relationship(back_populates="chunks")
