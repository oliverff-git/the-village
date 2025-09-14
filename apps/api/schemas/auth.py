from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
import uuid

class UserRegister(BaseModel):
email: EmailStr
handle: str = Field(min_length=2, max_length=32)
password: str = Field(min_length=8)
age_confirmed: bool
invite_token: Optional[str] = None

class UserLogin(BaseModel):
email: EmailStr
password: str

class UserResponse(BaseModel):
id: uuid.UUID
email: EmailStr
handle: str
created_at: datetime
role: str
is_active: bool

class Config:
    from_attributes = True
class Token(BaseModel):
access_token: str
refresh_token: str
token_type: str = "bearer"

class RefreshTokenRequest(BaseModel):
refresh_token: str
