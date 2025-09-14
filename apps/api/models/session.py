from sqlalchemy import Column, String, DateTime, ForeignKey
from core.types import GUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    token = Column(String, unique=True, nullable=False, index=True)
    user_id = Column(GUID(), ForeignKey("users.id"), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", backref="refresh_tokens")
