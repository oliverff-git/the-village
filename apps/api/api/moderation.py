from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from core.database import get_db
from core.security import get_current_admin
from models import Idea, Report, Takedown, User
from schemas.report import ReportResponse

router = APIRouter()

@router.get("/queue", response_model=list[ReportResponse])
def moderation_queue(current_user: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    reports = db.query(Report).order_by(Report.created_at.asc()).all()
    return reports

@router.post("/takedown")
def file_takedown(
    claimant_name: str,
    claimant_email: str,
    basis: str,
    target_type: str,
    target_id: str,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    td = Takedown(
        claimant_name=claimant_name,
        claimant_email=claimant_email,
        basis=basis,
        target_type=target_type,
        target_id=target_id,
    )
    if target_type == "idea":
        idea = db.query(Idea).filter(Idea.id == target_id).first()
        if idea:
            idea.status = "removed"
    db.add(td)
    db.commit()
    return {"ok": True}
