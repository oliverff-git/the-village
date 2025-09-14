from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime

from core.database import get_db
from core.security import (
verify_password,
get_password_hash,
create_access_token,
create_refresh_token,
verify_refresh_token,
get_current_user,
)
from models import User, Invite
from schemas.auth import (
UserRegister,
UserLogin,
Token,
UserResponse,
RefreshTokenRequest,
)

router = APIRouter()

@router.post("/register", response_model=UserResponse)
def register(user_data: UserRegister, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == user_data.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    if db.query(User).filter(User.handle == user_data.handle).first():
        raise HTTPException(status_code=400, detail="Handle already taken")

    invite = None
    if user_data.invite_token:
        invite = (
            db.query(Invite)
            .filter(
                Invite.token == user_data.invite_token,
                Invite.used_by.is_(None),
                Invite.expires_at > datetime.utcnow(),
            )
            .first()
        )
        if not invite:
            raise HTTPException(status_code=400, detail="Invalid or expired invite token")

    user = User(
        email=user_data.email,
        handle=user_data.handle,
        password_hash=get_password_hash(user_data.password),
        age_confirmed_at=datetime.utcnow() if user_data.age_confirmed else None,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    if invite:
        invite.used_by = user.id
        invite.used_at = datetime.utcnow()
        db.commit()

    return user
@router.post("/login", response_model=Token)
def login(data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Incorrect email or password")

    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account suspended")

    access_token = create_access_token(data={"sub": str(user.id)})
    refresh_token = create_refresh_token(str(user.id), db)

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}
@router.post("/refresh", response_model=Token)
def refresh(token_data: RefreshTokenRequest, db: Session = Depends(get_db)):
    user = verify_refresh_token(token_data.refresh_token, db)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    access_token = create_access_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "refresh_token": token_data.refresh_token, "token_type": "bearer"}
@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user
