from sqlalchemy import Column, String, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class MoodPost(Base):
tablename = "mood_posts"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
author_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
text = Column(Text, nullable=False)
media_url = Column(String, nullable=True)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
reply_to = Column(UUID(as_uuid=True), ForeignKey("mood_posts.id"), nullable=True)

author = relationship("User", backref="mood_posts")
parent = relationship("MoodPost", remote_side=[id], backref="replies")
