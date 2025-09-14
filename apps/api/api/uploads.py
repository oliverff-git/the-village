from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import mimetypes

from core.database import get_db
from core.security import get_current_user
from core.storage import generate_presigned_upload_url, generate_file_key
from models import User
from schemas.upload import PresignRequest, PresignResponse, CompleteUpload

router = APIRouter()

ALLOWED = {
    "image": ["image/jpeg", "image/png", "image/gif", "image/webp"],
    "audio": ["audio/mpeg", "audio/wav", "audio/ogg", "audio/webm"],
    "video": ["video/mp4", "video/webm", "video/ogg"],
}

def _classify_mime(filename: str) -> tuple[str, str]:
    mime, _ = mimetypes.guess_type(filename)
    for kind, mimes in ALLOWED.items():
        if mime in mimes:
            return kind, mime or "application/octet-stream"
    raise HTTPException(status_code=400, detail="File type not allowed")

@router.get("/presign", response_model=PresignResponse)
def presign_get(filename: str = Query(...), current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    kind, mime = _classify_mime(filename)
    file_key = generate_file_key(str(current_user.id), filename, folder=f"{kind}s")
    presigned = generate_presigned_upload_url(file_key, content_type=mime)
    return {"url": presigned["url"], "fields": presigned["fields"], "file_key": file_key}

@router.post("/presign", response_model=PresignResponse)
def presign_post(req: PresignRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return presign_get(filename=req.filename, current_user=current_user, db=db)

@router.post("/complete")
def complete_upload(data: CompleteUpload, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # MVP acknowledgement
    return {"message": "Upload recorded"}
