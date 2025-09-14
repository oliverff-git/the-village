from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Boolean, Integer
from core.types import GUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class Playlist(Base):
    __tablename__ = "playlists"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    owner_id = Column(GUID(), ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    is_public = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    owner = relationship("User", backref="playlists")
    items = relationship("PlaylistItem", back_populates="playlist", cascade="all, delete-orphan", order_by="PlaylistItem.position")
class PlaylistItem(Base):
    __tablename__ = "playlist_items"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    playlist_id = Column(GUID(), ForeignKey("playlists.id"), nullable=False)
    idea_id = Column(GUID(), ForeignKey("ideas.id"), nullable=False)
    position = Column(Integer, nullable=False)

    playlist = relationship("Playlist", back_populates="items")
    idea = relationship("Idea")
