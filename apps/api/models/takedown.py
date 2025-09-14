from sqlalchemy import Column, String, DateTime, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
import enum

from core.database import Base

class TakedownStatus(str, enum.Enum):
RECEIVED = "received"
REVIEWING = "reviewing"
ACTIONED = "actioned"
REJECTED = "rejected"

class Takedown(Base):
tablename = "takedowns"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
claimant_name = Column(String, nullable=False)
claimant_email = Column(String, nullable=False)
basis = Column(Text, nullable=False)
target_type = Column(String, nullable=False)
target_id = Column(UUID(as_uuid=True), nullable=False)
received_at = Column(DateTime, default=datetime.utcnow, nullable=False)
action = Column(Text, nullable=True)
status = Column(SQLEnum(TakedownStatus), default=TakedownStatus.RECEIVED, nullable=False)
notes = Column(Text, nullable=True)
