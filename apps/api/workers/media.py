from sqlalchemy.orm import Session
from core.database import SessionLocal
from models import Idea
from models.idea import IdeaStatus

def process_audio_upload(idea_id: str):
"""MVP: mark audio ideas as published (stub for ffmpeg+ACR). Extend later."""
db: Session = SessionLocal()
try:
idea = db.query(Idea).filter(Idea.id == idea_id).first()
if not idea:
return
idea.status = IdeaStatus.PUBLISHED
db.commit()
finally:
db.close()
