from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class Invite(Base):
tablename = "invites"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
token = Column(String, unique=True, nullable=False, index=True)
invited_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
expires_at = Column(DateTime, nullable=False)
used_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
used_at = Column(DateTime, nullable=True)

inviter = relationship("User", foreign_keys=[invited_by], backref="sent_invites")
invitee = relationship("User", foreign_keys=[used_by], backref="received_invite")
