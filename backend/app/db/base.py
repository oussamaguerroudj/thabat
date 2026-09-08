"""
Shared declarative base. Every module's ORM models inherit from `Base` so
Alembic's autogenerate can discover all tables from one metadata object.

Future modules (auth, verification, content, etc.) import Base from here —
do not create a second declarative base anywhere in the project.
"""
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass
