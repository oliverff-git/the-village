from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class RefreshToken(Base):
tablename = "refresh_tokens"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
token = Column(String, unique=True, nullable=False, index=True)
user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
expires_at = Column(DateTime, nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

user = relationship("User", backref="refresh_tokens")
