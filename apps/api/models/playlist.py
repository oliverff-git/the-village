from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class Playlist(Base):
tablename = "playlists"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
title = Column(String(255), nullable=False)
description = Column(Text, nullable=True)
is_public = Column(Boolean, default=False, nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

owner = relationship("User", backref="playlists")
items = relationship("PlaylistItem", back_populates="playlist", cascade="all, delete-orphan", order_by="PlaylistItem.position")
class PlaylistItem(Base):
tablename = "playlist_items"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
playlist_id = Column(UUID(as_uuid=True), ForeignKey("playlists.id"), nullable=False)
idea_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=False)
position = Column(Integer, nullable=False)

playlist = relationship("Playlist", back_populates="items")
idea = relationship("Idea")
