from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from core.database import get_db
from core.security import get_current_user
from models import User, Playlist, PlaylistItem, Idea
from schemas.playlist import PlaylistCreate, PlaylistUpdate, PlaylistResponse, PlaylistItemAdd, PlaylistItemResponse

router = APIRouter()

@router.get("/", response_model=List[PlaylistResponse])
def list_playlists(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    playlists = db.query(Playlist).filter(Playlist.owner_id == current_user.id).order_by(Playlist.created_at.desc()).all()
    return playlists

@router.get("/{playlist_id}", response_model=PlaylistResponse)
def get_playlist(playlist_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()
    if not playlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Playlist not found")
    if not playlist.is_public and playlist.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    return playlist

@router.post("/", response_model=PlaylistResponse)
def create_playlist(playlist_data: PlaylistCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    playlist = Playlist(owner_id=current_user.id, title=playlist_data.title, description=playlist_data.description, is_public=playlist_data.is_public)
    db.add(playlist)
    db.commit()
    db.refresh(playlist)
    return playlist

@router.patch("/{playlist_id}", response_model=PlaylistResponse)
def update_playlist(playlist_id: str, playlist_update: PlaylistUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()
    if not playlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Playlist not found")
    if playlist.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    update_data = playlist_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(playlist, field, value)

    db.commit()
    db.refresh(playlist)
    return playlist
@router.post("/{playlist_id}/items", response_model=PlaylistItemResponse)
def add_to_playlist(playlist_id: str, item_data: PlaylistItemAdd, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()
    if not playlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Playlist not found")
    if playlist.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    idea = db.query(Idea).filter(Idea.id == item_data.idea_id).first()
    if not idea:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Idea not found")

    max_position = db.query(PlaylistItem).filter(PlaylistItem.playlist_id == playlist_id).count()
    item = PlaylistItem(playlist_id=playlist_id, idea_id=item_data.idea_id, position=item_data.position if item_data.position is not None else max_position)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item
@router.delete("/{playlist_id}/items/{item_id}")
def remove_from_playlist(playlist_id: str, item_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()
    if not playlist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Playlist not found")
    if playlist.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    item = db.query(PlaylistItem).filter(PlaylistItem.id == item_id, PlaylistItem.playlist_id == playlist_id).first()
    if not item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")

    db.delete(item)
    db.commit()
    return {"message": "Item removed"}
