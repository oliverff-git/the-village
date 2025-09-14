from sqlalchemy import Column, String, DateTime, ForeignKey
from core.types import GUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class Invite(Base):
    __tablename__ = "invites"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    token = Column(String, unique=True, nullable=False, index=True)
    invited_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    used_by = Column(GUID(), ForeignKey("users.id"), nullable=True)
    used_at = Column(DateTime, nullable=True)

    inviter = relationship("User", foreign_keys=[invited_by], backref="sent_invites")
    invitee = relationship("User", foreign_keys=[used_by], backref="received_invite")
