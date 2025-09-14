from sqlalchemy import Column, String, DateTime, ForeignKey, JSON
from core.types import GUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class AuditEvent(Base):
    __tablename__ = "audit_events"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    actor_id = Column(GUID(), ForeignKey("users.id"), nullable=True)
    action = Column(String, nullable=False)
    payload_json = Column(JSON, nullable=True)
    ts = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)

    actor = relationship("User")
