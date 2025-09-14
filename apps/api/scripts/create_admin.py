from core.database import SessionLocal
from models import User
from core.security import get_password_hash
from core.config import settings

def main():
    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == settings.ADMIN_EMAIL).first()
        if existing:
            print("Admin already exists:", settings.ADMIN_EMAIL)
            return
        admin = User(
            email=settings.ADMIN_EMAIL,
            handle="admin",
            password_hash=get_password_hash(settings.ADMIN_PASSWORD),
            role="admin",
            is_active=True,
        )
        db.add(admin)
        db.commit()
        print("Admin created:", settings.ADMIN_EMAIL)
    finally:
        db.close()

if __name__ == "__main__":
    main()
