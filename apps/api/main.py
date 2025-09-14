from contextlib import asynccontextmanager
import uuid
import structlog

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from prometheus_fastapi_instrumentator import Instrumentator

from core.config import settings
from core.database import engine, Base
from core.storage import ensure_bucket_exists
from api import auth, invites, ideas, uploads, playlists, mood, reports, moderation, legal


class RequestIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        request_id = request.headers.get("X-Request-Id", str(uuid.uuid4()))
        response = await call_next(request)
        response.headers["X-Request-Id"] = request_id
        return response


structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ],
)
log = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    log.info("startup", service="the-village-api")
    Base.metadata.create_all(bind=engine)
    ensure_bucket_exists()
    yield
    log.info("shutdown", service="the-village-api")


app = FastAPI(
    title="The Village API",
    description="An invite-only creative commons for sharing ideas",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(RequestIdMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Instrumentator().instrument(app).expose(app, include_in_schema=False)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(invites.router, prefix="/invites", tags=["invites"])
app.include_router(ideas.router, prefix="/ideas", tags=["ideas"])
app.include_router(uploads.router, prefix="/uploads", tags=["uploads"])
app.include_router(playlists.router, prefix="/playlists", tags=["playlists"])
app.include_router(mood.router, prefix="/mood", tags=["mood"])
app.include_router(reports.router, prefix="/reports", tags=["reports"])
app.include_router(moderation.router, prefix="/mod", tags=["moderation"])
app.include_router(legal.router, prefix="/legal", tags=["legal"])


@app.get("/")

def read_root():
    return {"name": "The Village API", "version": "1.0.0", "status": "operational"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}
