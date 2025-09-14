from sqlalchemy import Column, String, DateTime, ForeignKey, Text
from core.types import GUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class MoodPost(Base):
    __tablename__ = "mood_posts"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    author_id = Column(GUID(), ForeignKey("users.id"), nullable=False)
    text = Column(Text, nullable=False)
    media_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    reply_to = Column(GUID(), ForeignKey("mood_posts.id"), nullable=True)

    author = relationship("User", backref="mood_posts")
    parent = relationship("MoodPost", remote_side=[id], backref="replies")
