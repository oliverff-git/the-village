from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid

class MoodCreate(BaseModel):
text: str
media_url: Optional[str] = None
reply_to: Optional[uuid.UUID] = None

class MoodResponse(BaseModel):
id: uuid.UUID
author_id: uuid.UUID
text: str
media_url: Optional[str] = None
created_at: datetime
reply_to: Optional[uuid.UUID] = None

class Config:
    from_attributes = True
