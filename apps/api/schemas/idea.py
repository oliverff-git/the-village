from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Any
from datetime import datetime
import uuid

class IdeaCreate(BaseModel):
    type: str # "text" | "image" | "audio" | "video"
    title: str
    text: Optional[str] = None
    media_url: Optional[str] = None
    license: str # "CC0" | "CC_BY_4_0" | "CC_BY_SA_4_0"
    parent_id: Optional[uuid.UUID] = None
    visibility: str = "members" # "members" | "private"

class IdeaUpdate(BaseModel):
    title: Optional[str] = None
    text: Optional[str] = None
    visibility: Optional[str] = None

class IdeaFork(BaseModel):
    title: Optional[str] = None
    text: Optional[str] = None
    license: str
    visibility: Optional[str] = None

class StemResponse(BaseModel):
    id: uuid.UUID
    file_url: str
    license: str

    model_config = ConfigDict(from_attributes=True)

class IdeaResponse(BaseModel):
    id: uuid.UUID
    author_id: uuid.UUID
    type: str
    title: str
    text: Optional[str] = None
    media_url: Optional[str] = None
    thumb_url: Optional[str] = None
    duration_s: Optional[int] = None
    waveform_json_url: Optional[str] = None
    license: str
    created_at: datetime
    parent_id: Optional[uuid.UUID] = None
    provenance_json: Optional[Any] = None
    visibility: str
    status: str
    stems: List[StemResponse] = []

    model_config = ConfigDict(from_attributes=True)

class ProvenanceExport(BaseModel):
    id: str
    title: str
    author: str
    license: str
    created_at: str
    chain: list
