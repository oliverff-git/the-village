from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Integer, Enum as SQLEnum, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from core.database import Base

class IdeaType(str, enum.Enum):
    TEXT = "text"
    IMAGE = "image"
    AUDIO = "audio"
    VIDEO = "video"

class License(str, enum.Enum):
    CC0 = "CC0"
    CC_BY_4_0 = "CC_BY_4_0"
    CC_BY_SA_4_0 = "CC_BY_SA_4_0"

class Visibility(str, enum.Enum):
    MEMBERS = "members"
    PRIVATE = "private"

class IdeaStatus(str, enum.Enum):
    PUBLISHED = "published"
    HELD = "held"
    REMOVED = "removed"

class Idea(Base):
    __tablename__ = "ideas"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    type = Column(SQLEnum(IdeaType), nullable=False)
    title = Column(String(255), nullable=False, index=True)
    text = Column(Text, nullable=True)
    media_url = Column(String, nullable=True)
    thumb_url = Column(String, nullable=True)
    duration_s = Column(Integer, nullable=True)
    waveform_json_url = Column(String, nullable=True)
    license = Column(SQLEnum(License), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    parent_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=True, index=True)
    provenance_json = Column(JSON, nullable=True)
    visibility = Column(SQLEnum(Visibility), default=Visibility.MEMBERS, nullable=False)
    status = Column(SQLEnum(IdeaStatus), default=IdeaStatus.PUBLISHED, nullable=False)

    author = relationship("User", backref="ideas")
    parent = relationship("Idea", remote_side=[id], backref="forks")
    stems = relationship("Stem", back_populates="idea", cascade="all, delete-orphan")
class Stem(Base):
    __tablename__ = "stems"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    idea_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=False)
    file_url = Column(String, nullable=False)
    license = Column(SQLEnum(License), nullable=False)

    idea = relationship("Idea", back_populates="stems")
