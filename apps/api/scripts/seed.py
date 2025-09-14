from core.database import SessionLocal
from core.security import get_password_hash
from models import User, Invite, Idea
from datetime import datetime, timedelta
import secrets

def main():
    db = SessionLocal()
    try:
        # Users
        users = []
        for i in range(1, 3 + 1):
            email = f"user{i}@thevillage.local"
            u = db.query(User).filter(User.email == email).first()
            if not u:
                u = User(email=email, handle=f"user{i}", password_hash=get_password_hash("password123"))
                db.add(u)
                db.commit()
                db.refresh(u)
            users.append(u)

        # Invites
        for u in users:
            inv = Invite(
                token=secrets.token_urlsafe(12),
                invited_by=u.id,
                expires_at=datetime.utcnow() + timedelta(days=14),
            )
            db.add(inv)
        db.commit()

        # Ideas
        samples = [
            ("Open Drum Loop (90bpm)", "audio", "CC_BY_4_0", None),
            (
                "Lyric seed: 'It takes a village'",
                "text",
                "CC0",
                "A chorus hook: It takes a village, hold me up tonight...",
            ),
            ("Cover artwork mood", "image", "CC0", None),
        ]
        for title, t, lic, text in samples:
            idea = Idea(
                author_id=users[0].id,
                type=t,
                title=title,
                text=text,
                license=lic,
                status="published" if t != "audio" else "held",
            )
            db.add(idea)
        db.commit()
        print("Seed complete.")
    finally:
        db.close()

if __name__ == "__main__":
    main()
