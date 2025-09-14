from pydantic import BaseModel
from typing import Dict

class PresignRequest(BaseModel):
filename: str

class PresignResponse(BaseModel):
url: str
fields: Dict[str, str]
file_key: str

class CompleteUpload(BaseModel):
file_key: str | None = None
type: str | None = None
object_name: str | None = None
content_type: str | None = None
