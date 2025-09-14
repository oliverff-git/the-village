from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional
from datetime import datetime

from core.database import get_db
from core.security import get_current_user
from core.queue import enqueue_job
from models import User, Idea, Stem, AuditEvent
from models.idea import IdeaStatus, License, Visibility
from schemas.idea import (
    IdeaCreate,
    IdeaUpdate,
    IdeaResponse,
    IdeaFork,
    ProvenanceExport,
)
from workers.media import process_audio_upload

router = APIRouter()


@router.get("/", response_model=List[IdeaResponse])
def list_ideas(
    q: Optional[str] = Query(None),
    type: Optional[str] = Query(None),
    license: Optional[str] = Query(None),
    parent_id: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(Idea).filter(
        Idea.status == IdeaStatus.PUBLISHED, Idea.visibility == Visibility.MEMBERS
    )
    if q:
        query = query.filter(or_(Idea.title.ilike(f"%{q}%"), Idea.text.ilike(f"%{q}%")))
    if type:
        query = query.filter(Idea.type == type)
    if license:
        query = query.filter(Idea.license == license)
    if parent_id:
        query = query.filter(Idea.parent_id == parent_id)
    return query.order_by(Idea.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/{idea_id}", response_model=IdeaResponse)
def get_idea(
    idea_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    import uuid
    # Convert string to UUID for database query
    idea_uuid = uuid.UUID(idea_id) if isinstance(idea_id, str) else idea_id
    idea = db.query(Idea).filter(Idea.id == idea_uuid).first()
    if not idea:
        raise HTTPException(status_code=404, detail="Idea not found")
    if idea.visibility == Visibility.PRIVATE and idea.author_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    return idea


@router.post("/", response_model=IdeaResponse)
def create_idea(
    idea_data: IdeaCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if idea_data.parent_id:
        import uuid
        parent_uuid = uuid.UUID(str(idea_data.parent_id)) if idea_data.parent_id else None
        parent = db.query(Idea).filter(Idea.id == parent_uuid).first()
        if (
            parent
            and parent.license == License.CC_BY_SA_4_0
            and idea_data.license != "CC_BY_SA_4_0"
        ):
            raise HTTPException(
                status_code=400,
                detail="Share-alike license must be preserved in derivatives",
            )

    idea = Idea(
        author_id=current_user.id,
        type=idea_data.type,
        title=idea_data.title,
        text=idea_data.text,
        media_url=idea_data.media_url,
        license=idea_data.license,
        parent_id=idea_data.parent_id,
        visibility=idea_data.visibility,
        status=(
            IdeaStatus.HELD
            if idea_data.type == "audio" and idea_data.media_url
            else IdeaStatus.PUBLISHED
        ),
    )

    if idea_data.parent_id:
        # Reuse the parent_uuid from above if it exists
        if 'parent_uuid' not in locals():
            import uuid
            parent_uuid = uuid.UUID(str(idea_data.parent_id))
        parent = db.query(Idea).filter(Idea.id == parent_uuid).first()
        if parent:
            idea.provenance_json = (parent.provenance_json or []) + [
                {
                    "id": str(parent.id),
                    "title": parent.title,
                    "author": parent.author.handle,
                    "license": parent.license,
                }
            ]

    db.add(idea)
    db.commit()
    db.refresh(idea)

    if idea.type == "audio" and idea.media_url:
        enqueue_job(process_audio_upload, str(idea.id))

    audit = AuditEvent(
        actor_id=current_user.id,
        action="idea_created",
        payload_json={"idea_id": str(idea.id)},
    )
    db.add(audit)
    db.commit()
    return idea


@router.post("/{idea_id}/fork", response_model=IdeaResponse)
def fork_idea(
    idea_id: str,
    fork_data: IdeaFork,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    import uuid
    # Convert string to UUID for database query
    idea_uuid = uuid.UUID(idea_id) if isinstance(idea_id, str) else idea_id
    parent = db.query(Idea).filter(Idea.id == idea_uuid).first()
    if not parent:
        raise HTTPException(status_code=404, detail="Parent idea not found")

    lic = fork_data.license
    if parent.license == License.CC_BY_SA_4_0:
        lic = "CC_BY_SA_4_0"

    fork = Idea(
        author_id=current_user.id,
        type=parent.type,
        title=fork_data.title or f"Fork of {parent.title}",
        text=fork_data.text or parent.text,
        media_url=parent.media_url,
        license=lic,
        parent_id=parent.id,
        visibility=fork_data.visibility or parent.visibility,
        status=IdeaStatus.PUBLISHED,
    )

    fork.provenance_json = (parent.provenance_json or []) + [
        {
            "id": str(parent.id),
            "title": parent.title,
            "author": parent.author.handle,
            "license": parent.license,
        }
    ]

    db.add(fork)
    db.commit()
    db.refresh(fork)
    return fork


@router.patch("/{idea_id}", response_model=IdeaResponse)
def update_idea(
    idea_id: str,
    idea_update: IdeaUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    idea = db.query(Idea).filter(Idea.id == idea_id).first()
    if not idea:
        raise HTTPException(status_code=404, detail="Idea not found")
    if idea.author_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this idea")

    data = idea_update.dict(exclude_unset=True)
    for k, v in data.items():
        setattr(idea, k, v)
    db.commit()
    db.refresh(idea)
    return idea


@router.delete("/{idea_id}")
def delete_idea(
    idea_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    idea = db.query(Idea).filter(Idea.id == idea_id).first()
    if not idea:
        raise HTTPException(status_code=404, detail="Idea not found")
    if idea.author_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=403, detail="Not authorized to delete this idea"
        )
    idea.status = IdeaStatus.REMOVED
    db.commit()
    return {"message": "Idea removed"}


@router.get("/{idea_id}/provenance", response_model=ProvenanceExport)
def get_provenance(
    idea_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    idea = db.query(Idea).filter(Idea.id == idea_id).first()
    if not idea:
        raise HTTPException(status_code=404, detail="Idea not found")
    prov = {
        "id": str(idea.id),
        "title": idea.title,
        "author": idea.author.handle,
        "license": idea.license,
        "created_at": idea.created_at.isoformat(),
        "chain": idea.provenance_json or [],
    }
    return prov
