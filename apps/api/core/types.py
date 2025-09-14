from __future__ import annotations

import uuid
from typing import Any, Optional

from sqlalchemy.dialects import postgresql
from sqlalchemy.types import CHAR, TypeDecorator


class GUID(TypeDecorator):
    """Platform-independent GUID/UUID type.

    Uses PostgreSQL's UUID type, otherwise stores as CHAR(36) string.
    """

    impl = CHAR(36)
    cache_ok = True

    def load_dialect_impl(self, dialect):  # type: ignore[override]
        if dialect.name == "postgresql":
            return dialect.type_descriptor(postgresql.UUID(as_uuid=True))
        return dialect.type_descriptor(CHAR(36))

    def process_bind_param(self, value: Any, dialect) -> Optional[str]:  # type: ignore[override]
        if value is None:
            return None
        if dialect.name == "postgresql":
            # As uuid=True, SQLAlchemy handles native UUID objects
            return value
        if isinstance(value, uuid.UUID):
            return str(value)
        # Coerce string-like to canonical UUID string
        return str(uuid.UUID(str(value)))

    def process_result_value(self, value: Any, dialect) -> Optional[uuid.UUID]:  # type: ignore[override]
        if value is None:
            return None
        if isinstance(value, uuid.UUID):
            return value
        return uuid.UUID(str(value))


