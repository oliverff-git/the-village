from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from core.database import get_db
from core.security import get_current_user
from models import MoodPost, User
from schemas.mood import MoodCreate, MoodResponse

router = APIRouter()

@router.get("/", response_model=List[MoodResponse])
def list_mood(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
posts = db.query(MoodPost).order_by(MoodPost.created_at.desc()).limit(100).all()
return posts

@router.post("/", response_model=MoodResponse)
def create_mood(data: MoodCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
post = MoodPost(author_id=current_user.id, text=data.text, media_url=data.media_url, reply_to=data.reply_to)
db.add(post)
db.commit()
db.refresh(post)
return post
