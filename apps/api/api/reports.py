from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from core.database import get_db
from core.security import get_current_user, get_current_admin
from models import Report, User
from schemas.report import ReportCreate, ReportResponse

router = APIRouter()

@router.post("/", response_model=ReportResponse)
def create_report(data: ReportCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
report = Report(reporter_id=current_user.id, target_type=data.target_type, target_id=data.target_id, reason=data.reason)
db.add(report)
db.commit()
db.refresh(report)
return report

@router.get("/", response_model=List[ReportResponse])
def list_reports(current_user: User = Depends(get_current_admin), db: Session = Depends(get_db)):
reports = db.query(Report).order_by(Report.created_at.desc()).all()
return reports
