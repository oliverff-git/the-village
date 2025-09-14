from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Enum as SQLEnum
from core.types import GUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from core.database import Base

class ReportStatus(str, enum.Enum):
    PENDING = "pending"
    REVIEWED = "reviewed"
    ACTIONED = "actioned"
    DISMISSED = "dismissed"

class Report(Base):
    __tablename__ = "reports"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    reporter_id = Column(GUID(), ForeignKey("users.id"), nullable=False)
    target_type = Column(String, nullable=False)  # 'idea', 'user', 'mood_post', etc.
    target_id = Column(GUID(), nullable=False)
    reason = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    status = Column(SQLEnum(ReportStatus), default=ReportStatus.PENDING, nullable=False)
    action_taken = Column(Text, nullable=True)

    reporter = relationship("User", backref="reports")
