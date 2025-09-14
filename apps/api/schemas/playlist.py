from pydantic import BaseModel
from typing import Optional, List
import uuid
from datetime import datetime

class PlaylistCreate(BaseModel):
    title: str
    description: Optional[str] = None
    is_public: bool = False

class PlaylistUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    is_public: Optional[bool] = None

class PlaylistItemAdd(BaseModel):
    idea_id: uuid.UUID
    position: Optional[int] = None

class PlaylistItemResponse(BaseModel):
    id: uuid.UUID
    playlist_id: uuid.UUID
    idea_id: uuid.UUID
    position: int

    class Config:
        from_attributes = True

class PlaylistResponse(BaseModel):
    id: uuid.UUID
    owner_id: uuid.UUID
    title: str
    description: Optional[str] = None
    is_public: bool
    created_at: datetime
    items: List[PlaylistItemResponse] = []

    class Config:
        from_attributes = True
