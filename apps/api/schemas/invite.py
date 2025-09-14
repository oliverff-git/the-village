from pydantic import BaseModel, ConfigDict
from datetime import datetime
import uuid
from typing import Optional

class InviteCreate(BaseModel):
    pass

class InviteResponse(BaseModel):
    id: uuid.UUID
    token: str
    invited_by: uuid.UUID
    expires_at: datetime
    used_by: Optional[uuid.UUID] = None
    used_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class InviteValidateResponse(BaseModel):
    ok: bool
    token: str
