from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
import uuid

class ReportCreate(BaseModel):
    target_type: str
    target_id: uuid.UUID
    reason: str

class ReportResponse(BaseModel):
    id: uuid.UUID
    reporter_id: uuid.UUID
    target_type: str
    target_id: uuid.UUID
    reason: str
    created_at: datetime
    status: str
    action_taken: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
