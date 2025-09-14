from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
import argon2
from argon2 import PasswordHasher
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from .config import settings
from .database import get_db
from models import User
from models.session import RefreshToken

# Initialize Argon2 password hasher
password_hasher = PasswordHasher()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify password with backward compatibility.
    Supports both old passlib hashes and new argon2-cffi hashes.
    """
    try:
        # Try new argon2-cffi verification first
        password_hasher.verify(hashed_password, plain_password)
        return True
    except argon2.exceptions.VerifyMismatchError:
        return False
    except argon2.exceptions.InvalidHash:
        # Fallback to passlib for old hashes during transition period
        # This allows existing users to still login
        try:
            from passlib.context import CryptContext
            fallback_context = CryptContext(schemes=["argon2"], deprecated="auto")
            return fallback_context.verify(plain_password, hashed_password)
        except Exception:
            return False

def get_password_hash(password: str) -> str:
    """Generate password hash using modern argon2-cffi."""
    return password_hasher.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (
        expires_delta or timedelta(minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def create_refresh_token(user_id: str, db: Session) -> str:
    import secrets
    import uuid

    token = secrets.token_urlsafe(32)
    expires_at = datetime.utcnow() + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS)

    # Convert string to UUID if needed
    user_uuid = uuid.UUID(user_id) if isinstance(user_id, str) else user_id
    refresh_token = RefreshToken(token=token, user_id=user_uuid, expires_at=expires_at)
    db.add(refresh_token)
    db.commit()
    return token
def verify_refresh_token(token: str, db: Session) -> Optional[User]:
    rt = db.query(RefreshToken).filter(
        RefreshToken.token == token,
        RefreshToken.expires_at > datetime.utcnow(),
    ).first()
    if not rt:
        return None
    return db.query(User).filter(User.id == rt.user_id).first()

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    # Convert string to UUID for database query
    import uuid
    user_uuid = uuid.UUID(user_id) if isinstance(user_id, str) else user_id
    user = db.query(User).filter(User.id == user_uuid).first()
    if user is None:
        raise credentials_exception
    if not user.is_active:
        raise HTTPException(status_code=403, detail="User account is suspended")
    return user
async def get_current_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role not in ["admin", "moderator"]:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    return current_user
