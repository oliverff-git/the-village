from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import secrets
from typing import List

from core.database import get_db
from core.security import get_current_user, get_current_admin
from models import User, Invite
from schemas.invite import InviteResponse, InviteValidateResponse

router = APIRouter()

@router.post("/", response_model=InviteResponse)
def create_invite(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
from core.config import settings

active = (
    db.query(Invite)
    .filter(
        Invite.invited_by == current_user.id,
        Invite.used_by.is_(None),
        Invite.expires_at > datetime.utcnow(),
    )
    .count()
)
if active >= settings.RATE_LIMIT_INVITES_PER_USER:
    raise HTTPException(status_code=429, detail="Invite quota exceeded")

invite = Invite(
    token=secrets.token_urlsafe(16),
    invited_by=current_user.id,
    expires_at=datetime.utcnow() + timedelta(days=7),
)
db.add(invite)
db.commit()
db.refresh(invite)
return invite
@router.get("/mine", response_model=List[InviteResponse])
def get_my_invites(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
invites = (
db.query(Invite)
.filter(Invite.invited_by == current_user.id)
.order_by(Invite.expires_at.desc())
.all()
)
return invites

@router.post("/admin", response_model=InviteResponse)
def create_admin_invite(current_user: User = Depends(get_current_admin), db: Session = Depends(get_db)):
invite = Invite(token=secrets.token_urlsafe(16), invited_by=current_user.id, expires_at=datetime.utcnow() + timedelta(days=30))
db.add(invite)
db.commit()
db.refresh(invite)
return invite

@router.post("/join/{token}", response_model=InviteValidateResponse)
def validate_join(token: str, db: Session = Depends(get_db)):
invite = (
db.query(Invite)
.filter(Invite.token == token, Invite.expires_at > datetime.utcnow(), Invite.used_by.is_(None))
.first()
)
if not invite:
raise HTTPException(status_code=400, detail="Invalid or expired invite")
return InviteValidateResponse(ok=True, token=token)
