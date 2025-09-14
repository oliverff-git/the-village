
SCRIPT REQUIREMENTS
- Shebang + safety flags: #!/usr/bin/env bash and set -euo pipefail
- Detect repo root: ROOT="$(pwd)"
- Utility helpers:
  - mkd() to mkdir -p.
  - emit() path <<'EOF' … EOF to write exact file contents.
  - x() to echo+run commands.
- Create all directories before writing files.
- For every file from the Spec, write its exact content with a single-quoted heredoc (<<'EOF') so characters are not interpolated.
- Set chmod +x on:
  - scripts/*.sh, scripts/*.py as needed
  - .husky/*
  - apps/api/Dockerfile* (not executable, but leave as regular files)
  - Any *.sh you add (e.g., sbom, merge scripts)
- Run minimal sanity:
  - git init -b main (if not already a git repo)
  - git add . && git commit -m "chore: bootstrap repo" (if clean)
- DO NOT run package managers by default; just print next steps.
- Keep paths exactly as in Spec (root files, apps/api, apps/web, docs, .github/workflows, etc).
- If the Spec contained duplicates for the same path, prefer the LAST occurrence.
- If the Spec mentioned an Alembic “init” but omitted the generated migration file, create a placeholder migration at apps/api/alembic/versions/0001_init.py with a minimal upgrade/downgrade that creates nothing (so alembic upgrade head still runs). The runtime Base.metadata.create_all already creates tables for dev.
- Preserve UK English copy everywhere.
POST-SCRIPT ECHO
At the end, printf a concise checklist:
1) cp .env.example .env
2) docker compose up -d
3) docker compose exec api alembic upgrade head
4) docker compose exec api python -m scripts.create_admin
5) docker compose exec api python -m scripts.seed
Open:
- Web: http://localhost:3000
- API: http://localhost:8000 (docs at /docs)
- MinIO: http://localhost:9001 (minioadmin/minioadmin)
CONTENT SOURCE (VERY IMPORTANT)
Use ONLY the files and contents provided in the Spec in this chat (root configs, docker-compose, Makefile, .husky, .lintstagedrc, CI workflow, apps/api code incl. models/schemas/routes/core/workers/scripts/alembic, apps/web Next.js files, UI components, docs). Where the Spec included “UPDATED”, “PATCH” or “REPLACED” versions, emit the updated/patch content. Do not invent additional code or restructure.
ACCEPTANCE
- Running bash bootstrap_village.sh on a clean folder creates all files.
- docker compose up -d + the printed commands result in a working local stack.
- No extra commentary was printed by you outside the single script code block.
Now output ONLY the one Bash file in a single 
bash fenced block, named bootstrap_village.sh, implementing everything above.

bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
mkd() { mkdir -p "$@"; }
emit() { local path="$1"; shift; cat > "$path"; }
x() { echo "Running: $*"; "$@"; }

echo "Bootstrapping The Village repository..."

# Root structure
mkd .github/workflows .husky apps/api/{alembic/{versions,},api,core,models,schemas,scripts,tests,workers} apps/web/{src/{app/{admin/moderation,auth/{login,register},ideas/{new,'[id]'},invite/{'[token]',},mood,playlists},components/ui,lib},tests,tests-e2e} docs packages sbom scripts

# Root files
emit .editorconfig <<'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.py]
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EOF

emit .gitignore <<'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
.nyc_output
.pytest_cache/
htmlcov/
*.cover
.coverage
.coverage.*

# Production
build/
dist/
out/
*.egg-info/

# Environment
.env
.env.local
.env.*.local
*.env
!.env.example

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Next.js
.next/
*.next/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/

# Database
*.db
*.sqlite
*.sqlite3

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

# OS
Thumbs.db

# Testing artifacts
playwright-report/
test-results/

# Build artifacts
.turbo/
EOF

emit LICENSE <<'EOF'
MIT License

Copyright (c) 2025 The Village

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

emit README.md <<'EOF'
# The Village

An invite-only creative commons for sharing ideas, images, and audio under open licences.

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ and PNPM (for local development)
- Python 3.11+ (for local development)

### Running with Docker

1. Clone the repository:
bash
git clone https://github.com/your-org/the-village.git
cd the-village
Copy environment variables:
bash
cp .env.example .env
Start all services:
bash
docker compose up -d
Run database migrations:
bash
docker compose exec api alembic upgrade head
Create first admin user:
bash
docker compose exec api python -m scripts.create_admin
Seed demo data (optional):
bash
docker compose exec api python -m scripts.seed
Access Points
Web App: http://localhost:3000
API: http://localhost:8000
API Docs: http://localhost:8000/docs
MinIO Console: http://localhost:9001
Default credentials: minioadmin / minioadmin
Local Development
bash
# Install dependencies
pnpm install

# Start database and services
docker compose up postgres redis minio

# Run API (in apps/api)
cd apps/api
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
alembic upgrade head
uvicorn main:app --reload

# Run Web (in apps/web)
cd apps/web
pnpm dev
Architecture
See ARCHITECTURE.md for system design details.

Contributing
See CONTRIBUTING.md for development guidelines.

Licence
MIT - See LICENSE file.

Content uploaded to The Village is licensed under Creative Commons licences as chosen by users (CC0, CC BY 4.0, or CC BY-SA 4.0).
EOF

emit .env.example <<'EOF'

Database
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=thevillage
POSTGRES_USER=village_user
POSTGRES_PASSWORD=change_me_in_production

Redis
REDIS_URL=redis://redis:6379/0

S3/MinIO
S3_ENDPOINT=http://minio:9000 S3_ACCESS_KEY=minioadmin S3_SECRET_KEY=minioadmin S3_BUCKET_UPLOADS=village-uploads S3_REGION=us-east-1 S3_PUBLIC_BASE_URL=http://localhost:9000

JWT
JWT_SECRET=change_me_very_secret_key_minimum_32_chars_long
JWT_REFRESH_SECRET=change_me_another_very_secret_key_minimum_32
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=30

App
APP_BASE_URL=http://localhost:3000 API_BASE_URL=http://localhost:8000 CORS_ORIGINS=http://localhost:3000,http://localhost:3001

ACRCloud (Optional - stub mode if not set)
ACRCLOUD_HOST=
ACRCLOUD_ACCESS_KEY=
ACRCLOUD_ACCESS_SECRET=

Rate Limiting
RATE_LIMIT_SIGNUP_PER_DAY=10
RATE_LIMIT_INVITES_PER_USER=5
RATE_LIMIT_UPLOADS_PER_HOUR=20

Admin
ADMIN_EMAIL=admin@thevillage.local ADMIN_PASSWORD=change_me_admin_password EOF

emit package.json <<'EOF' { "name": "the-village", "version": "1.0.0", "private": true, "description": "An invite-only creative commons", "scripts": { "dev": "turbo dev", "build": "turbo build", "test": "turbo test", "test:e2e": "turbo test:e2e", "lint": "turbo lint", "format": "turbo format", "prepare": "husky install" }, "devDependencies": { "@commitlint/cli": "^18.4.3", "@commitlint/config-conventional": "^18.4.3", "husky": "^8.0.3", "lint-staged": "^15.2.0", "turbo": "^1.11.2" }, "engines": { "node": ">=18.0.0", "pnpm": ">=8.0.0" }, "packageManager": "pnpm@8.14.0" } EOF

emit pnpm-workspace.yaml <<'EOF'
packages:

'apps/*'
'packages/*' EOF
emit turbo.json <<'EOF' { "$schema": "https://turbo.build/schema.json", "globalDependencies": ["/.env.*local"], "pipeline": { "build": { "dependsOn": ["^build"], "outputs": [".next/", "!.next/cache/", "dist/"] }, "dev": { "cache": false, "persistent": true }, "lint": {}, "format": {}, "test": { "dependsOn": ["build"] }, "test:e2e": { "dependsOn": ["build"] } } } EOF

emit .husky/pre-commit <<'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
EOF

emit .lintstagedrc.json <<'EOF' { ".{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"], ".{json,md,yml,yaml}": ["prettier --write"], "*.py": ["black", "ruff --fix"] } EOF

emit commitlint.config.js <<'EOF'
module.exports = {
extends: ['@commitlint/config-conventional'],
rules: {
'type-enum': [
2,
'always',
[
'feat',
'fix',
'docs',
'style',
'refactor',
'perf',
'test',
'build',
'ci',
'chore',
'revert'
]
]
}
};
EOF

emit docker-compose.yml <<'EOF'
version: '3.8'

services: postgres: image: postgres:15-alpine environment: POSTGRES_DB: ${POSTGRES_DB:-thevillage} POSTGRES_USER: ${POSTGRES_USER:-village_user} POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-change_me} ports: - "5432:5432" volumes: - postgres_data:/var/lib/postgresql/data healthcheck: test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-village_user}"] interval: 10s timeout: 5s retries: 5

redis: image: redis:7-alpine ports: - "6379:6379" volumes: - redis_data:/data healthcheck: test: ["CMD", "redis-cli", "ping"] interval: 10s timeout: 5s retries: 5

minio: image: minio/minio:latest command: server /data --console-address ":9001" environment: MINIO_ROOT_USER: ${S3_ACCESS_KEY:-minioadmin} MINIO_ROOT_PASSWORD: ${S3_SECRET_KEY:-minioadmin} ports: - "9000:9000" - "9001:9001" volumes: - minio_data:/data healthcheck: test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"] interval: 30s timeout: 20s retries: 3

api: build: context: ./apps/api dockerfile: Dockerfile environment: - POSTGRES_HOST=postgres - REDIS_URL=redis://redis:6379/0 - S3_ENDPOINT=http://minio:9000 env_file: - .env ports: - "8000:8000" depends_on: postgres: condition: service_healthy redis: condition: service_healthy minio: condition: service_healthy volumes: - ./apps/api:/app command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

worker: build: context: ./apps/api dockerfile: Dockerfile.worker environment: - POSTGRES_HOST=postgres - REDIS_URL=redis://redis:6379/0 - S3_ENDPOINT=http://minio:9000 env_file: - .env depends_on: - redis - postgres - minio volumes: - ./apps/api:/app command: python -m worker

web: build: context: ./apps/web dockerfile: Dockerfile environment: - NEXT_PUBLIC_API_URL=http://localhost:8000 ports: - "3000:3000" depends_on: - api volumes: - ./apps/web:/app - /app/node_modules - /app/.next

volumes:
postgres_data:
redis_data:
minio_data:
EOF

emit .nvmrc <<'EOF'
18.19.0
EOF

emit .python-version <<'EOF'
3.11.9
EOF

emit .pre-commit-config.yaml <<'EOF'
repos:

repo: https://github.com/psf/black rev: 24.8.0 hooks: [{ id: black }]
repo: https://github.com/astral-sh/ruff-pre-commit rev: v0.6.4 hooks:
id: ruff args: [--fix]
id: ruff-format
repo: https://github.com/pre-commit/mirrors-mypy rev: v1.11.2 hooks:
id: mypy additional_dependencies: [pydantic==2.7.3, types-requests] files: ^apps/api/
repo: https://github.com/gitleaks/gitleaks rev: v8.18.4 hooks:
id: gitleaks EOF
emit Makefile <<'EOF'
.PHONY: setup format lint typecheck test coverage build run docker-up docker-down sbom

setup:
pnpm install
pre-commit install

format:
pnpm format || true
cd apps/api && black .

lint:
pnpm lint || true
cd apps/api && ruff .

typecheck:
cd apps/api && mypy .

test:
pnpm --filter web test || true
cd apps/api && pytest -q

coverage:
cd apps/api && pytest --cov=./ --cov-report=term-missing --cov-fail-under=85

build:
pnpm build

run:
docker compose up -d

docker-up:
docker compose up -d

docker-down:
docker compose down -v

sbom:
./scripts/gen-sbom.sh
EOF

emit scripts/gen-sbom.sh <<'EOF' #!/usr/bin/env bash set -euo pipefail mkdir -p sbom if ! command -v syft >/dev/null 2>&1; then curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin fi syft . -o cyclonedx-json > sbom/repo.cdx.json echo "SBOM at sbom/repo.cdx.json" EOF

API files
emit apps/api/Dockerfile <<'EOF' FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y
gcc
postgresql-client
ffmpeg
&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"] EOF

emit apps/api/Dockerfile.worker <<'EOF' FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y
gcc
postgresql-client
ffmpeg
&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "-m", "worker"]
EOF

emit apps/api/requirements.txt <<'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
gunicorn==21.2.0
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
pydantic==2.5.2
pydantic-settings==2.1.0
python-jose[cryptography]==3.3.0
passlib[argon2]==1.7.4
python-multipart==0.0.6
httpx==0.25.2
redis==5.0.1
rq==1.15.1
boto3==1.34.7
Pillow==10.1.0
python-magic==0.4.27
email-validator==2.1.0
pytest==7.4.3
pytest-cov==4.1.0
pytest-asyncio==0.21.1
black==23.12.0
ruff==0.1.8
prometheus-fastapi-instrumentator==7.0.0
structlog==24.4.0
EOF

emit apps/api/pyproject.toml <<'EOF'
[tool.black]
line-length = 88
target-version = ['py311']

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "UP", "S", "B", "A", "C4", "T20"]
ignore = ["E501"]
target-version = "py311"

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = "-v --cov=. --cov-report=html --cov-report=term"
EOF

emit apps/api/main.py <<'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import structlog
from prometheus_fastapi_instrumentator import Instrumentator
from starlette.middleware.base import BaseHTTPMiddleware
import uuid
import logging

from core.config import settings
from core.database import engine, Base
from api import auth, invites, ideas, uploads, playlists, mood, reports, moderation, legal
from core.storage import ensure_bucket_exists

Setup JSON logging
structlog.configure(
processors=[structlog.processors.TimeStamper(fmt="iso"), structlog.processors.JSONRenderer()],
)
log = structlog.get_logger()

class RequestIdMiddleware(BaseHTTPMiddleware):
async def dispatch(self, request, call_next):
request_id = request.headers.get("X-Request-Id", str(uuid.uuid4()))
response = await call_next(request)
response.headers["X-Request-Id"] = request_id
return response

@asynccontextmanager
async def lifespan(app: FastAPI):
# Startup
log.info("startup", service="the-village-api")

# Create database tables
Base.metadata.create_all(bind=engine)

# Ensure S3 bucket exists
ensure_bucket_exists()

yield

# Shutdown
log.info("shutdown", service="the-village-api")
app = FastAPI(
title="The Village API",
description="An invite-only creative commons for sharing ideas",
version="1.0.0",
lifespan=lifespan,
)

Add middleware
app.add_middleware(RequestIdMiddleware)

CORS middleware
app.add_middleware( CORSMiddleware, allow_origins=settings.CORS_ORIGINS, allow_credentials=True, allow_methods=[""], allow_headers=[""], )

Metrics
Instrumentator().instrument(app).expose(app, include_in_schema=False)

Include routers
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
return {
"name": "The Village API",
"version": "1.0.0",
"status": "operational"
}

@app.get("/health")
def health_check():
return {"status": "healthy"}
EOF

emit apps/api/core/init.py <<'EOF'

Core module initialization
EOF

emit apps/api/core/config.py <<'EOF'
from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
# Database
POSTGRES_HOST: str = "localhost"
POSTGRES_PORT: int = 5432
POSTGRES_DB: str = "thevillage"
POSTGRES_USER: str = "village_user"
POSTGRES_PASSWORD: str = ""

# Redis
REDIS_URL: str = "redis://localhost:6379/0"

# S3/MinIO
S3_ENDPOINT: str = "http://localhost:9000"
S3_ACCESS_KEY: str = "minioadmin"
S3_SECRET_KEY: str = "minioadmin"
S3_BUCKET_UPLOADS: str = "village-uploads"
S3_REGION: str = "us-east-1"
S3_PUBLIC_BASE_URL: str = "http://localhost:9000"

# JWT
JWT_SECRET: str = "change_me_very_secret_key"
JWT_REFRESH_SECRET: str = "change_me_refresh_secret"
JWT_ALGORITHM: str = "HS256"
JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30

# App
APP_BASE_URL: str = "http://localhost:3000"
API_BASE_URL: str = "http://localhost:8000"

# ACRCloud (Optional)
ACRCLOUD_HOST: str = ""
ACRCLOUD_ACCESS_KEY: str = ""
ACRCLOUD_ACCESS_SECRET: str = ""

# Rate Limiting
RATE_LIMIT_SIGNUP_PER_DAY: int = 10
RATE_LIMIT_INVITES_PER_USER: int = 5
RATE_LIMIT_UPLOADS_PER_HOUR: int = 20

@property
def DATABASE_URL(self) -> str:
    return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

@property
def CORS_ORIGINS(self) -> List[str]:
    origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
    return [origin.strip() for origin in origins]

class Config:
    env_file = ".env"
    case_sensitive = True
settings = Settings()
EOF

emit apps/api/core/database.py <<'EOF'
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from .config import settings

engine = create_engine(settings.DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
db = SessionLocal()
try:
yield db
finally:
db.close()
EOF

emit apps/api/core/security.py <<'EOF'
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
import secrets

from .config import settings
from .database import get_db
from models import User, RefreshToken

pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def verify_password(plain_password: str, hashed_password: str) -> bool:
return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
to_encode = data.copy()
if expires_delta:
expire = datetime.utcnow() + expires_delta
else:
expire = datetime.utcnow() + timedelta(minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES)
to_encode.update({"exp": expire})
encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
return encoded_jwt

def create_refresh_token(user_id: str, db: Session) -> str:
token = secrets.token_urlsafe(32)
expires_at = datetime.utcnow() + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS)

refresh_token = RefreshToken(
    token=token,
    user_id=user_id,
    expires_at=expires_at
)
db.add(refresh_token)
db.commit()

return token
def verify_refresh_token(token: str, db: Session) -> Optional[User]:
refresh_token = db.query(RefreshToken).filter(
RefreshToken.token == token,
RefreshToken.expires_at > datetime.utcnow()
).first()

if not refresh_token:
    return None

return db.query(User).filter(User.id == refresh_token.user_id).first()
async def get_current_user(
token: str = Depends(oauth2_scheme),
db: Session = Depends(get_db)
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

user = db.query(User).filter(User.id == user_id).first()
if user is None:
    raise credentials_exception

if not user.is_active:
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="User account is suspended"
    )

return user
async def get_current_admin(
current_user: User = Depends(get_current_user)
) -> User:
if current_user.role not in ["admin", "moderator"]:
raise HTTPException(
status_code=status.HTTP_403_FORBIDDEN,
detail="Not enough permissions"
)
return current_user
EOF

emit apps/api/core/storage.py <<'EOF'
import boto3
from botocore.client import Config
from typing import Optional
import hashlib
from datetime import datetime
import mimetypes

from .config import settings

def get_s3_client():
return boto3.client(
's3',
endpoint_url=settings.S3_ENDPOINT,
aws_access_key_id=settings.S3_ACCESS_KEY,
aws_secret_access_key=settings.S3_SECRET_KEY,
config=Config(signature_version='s3v4'),
region_name=settings.S3_REGION
)

def ensure_bucket_exists(): s3 = get_s3_client() try: s3.head_bucket(Bucket=settings.S3_BUCKET_UPLOADS) except Exception: s3.create_bucket(Bucket=settings.S3_BUCKET_UPLOADS) s3.put_bucket_policy( Bucket=settings.S3_BUCKET_UPLOADS, Policy=f'''{{ "Version": "2012-10-17", "Statement": [{{ "Sid": "PublicRead", "Effect": "Allow", "Principal": "", "Action": ["s3:GetObject"], "Resource": "arn:aws:s3:::{settings.S3_BUCKET_UPLOADS}/" }}] }}''' )

def generate_presigned_upload_url(file_key: str, content_type: Optional[str] = None, expires_in: int = 3600) -> dict:
s3 = get_s3_client()
fields = {}
if content_type:
fields["Content-Type"] = content_type
post = s3.generate_presigned_post(
Bucket=settings.S3_BUCKET_UPLOADS,
Key=file_key,
Fields=fields or None,
Conditions=[["content-length-range", 0, 10485760]],
ExpiresIn=expires_in
)
return post

def generate_file_key(user_id: str, filename: str, folder: str = "uploads") -> str: ext = filename.split('.')[-1] if '.' in filename else '' hash_input = f"{user_id}-{filename}-{datetime.utcnow().isoformat()}" file_hash = hashlib.sha256(hash_input.encode()).hexdigest()[:12] return f"{folder}/{user_id}/{file_hash}.{ext}" if ext else f"{folder}/{user_id}/{file_hash}"

def get_public_url(file_key: str) -> str:
return f"{settings.S3_PUBLIC_BASE_URL}/{settings.S3_BUCKET_UPLOADS}/{file_key}"

def delete_file(file_key: str):
s3 = get_s3_client()
s3.delete_object(Bucket=settings.S3_BUCKET_UPLOADS, Key=file_key)
EOF

emit apps/api/core/acrcloud.py <<'EOF'
import hashlib
import hmac
import base64
import time
import httpx
from typing import Optional, Dict

from .config import settings

class ACRCloudClient: def init(self): self.host = settings.ACRCLOUD_HOST self.access_key = settings.ACRCLOUD_ACCESS_KEY self.access_secret = settings.ACRCLOUD_ACCESS_SECRET self.enabled = bool(self.host and self.access_key and self.access_secret)

def scan_audio(self, audio_data: bytes) -> Optional[Dict]:
    """
    Scan audio for copyrighted content.
    Returns None if no match, or dict with match info.
    """
    if not self.enabled:
        # Stub mode - always return no match
        return None

    # Real implementation would go here
    # For MVP, we're stubbing this
    return self._mock_scan()

def _mock_scan(self) -> Optional[Dict]:
    """Mock implementation for local development"""
    # Randomly return a match for testing (10% chance)
    import random
    if random.random() < 0.1:
        return {
            "status": "match",
            "confidence": 0.95,
            "track": {
                "title": "Mock Copyrighted Song",
                "artist": "Mock Artist",
                "album": "Mock Album"
            }
        }
    return None

def _generate_signature(self, string_to_sign: str) -> str:
    """Generate HMAC signature for ACRCloud API"""
    return base64.b64encode(
        hmac.new(
            self.access_secret.encode('utf-8'),
            string_to_sign.encode('utf-8'),
            hashlib.sha1
        ).digest()
    ).decode('utf-8')
Global instance
acrcloud = ACRCloudClient()
EOF

emit apps/api/core/queue.py <<'EOF'
from rq import Queue
from redis import Redis
from .config import settings

redis_conn = Redis.from_url(settings.REDIS_URL)
queue = Queue(connection=redis_conn)

def enqueue_job(func, *args, **kwargs):
"""Enqueue a job to be processed by workers"""
return queue.enqueue(func, *args, **kwargs)
EOF

Models
emit apps/api/models/init.py <<'EOF' from .user import User from .invite import Invite from .idea import Idea, Stem from .playlist import Playlist, PlaylistItem from .mood import MoodPost from .report import Report from .takedown import Takedown from .audit import AuditEvent from .session import RefreshToken

all = [ "User", "Invite", "Idea", "Stem", "Playlist", "PlaylistItem", "MoodPost", "Report", "Takedown", "AuditEvent", "RefreshToken", ] EOF

emit apps/api/models/user.py <<'EOF'
from sqlalchemy import Column, String, DateTime, Boolean, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
import enum

from core.database import Base

class UserRole(str, enum.Enum):
USER = "user"
MODERATOR = "moderator"
ADMIN = "admin"

class User(Base): tablename = "users"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
email = Column(String, unique=True, nullable=False, index=True)
password_hash = Column(String, nullable=False)
handle = Column(String, unique=True, nullable=False, index=True)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
role = Column(SQLEnum(UserRole), default=UserRole.USER, nullable=False)
is_active = Column(Boolean, default=True, nullable=False)
age_confirmed_at = Column(DateTime, nullable=True)
EOF

emit apps/api/models/invite.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class Invite(Base): tablename = "invites"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
token = Column(String, unique=True, nullable=False, index=True)
invited_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
expires_at = Column(DateTime, nullable=False)
used_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
used_at = Column(DateTime, nullable=True)

inviter = relationship("User", foreign_keys=[invited_by], backref="sent_invites")
invitee = relationship("User", foreign_keys=[used_by], backref="received_invite")
EOF

emit apps/api/models/idea.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Integer, Enum as SQLEnum, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from core.database import Base

class IdeaType(str, enum.Enum):
TEXT = "text"
IMAGE = "image"
AUDIO = "audio"
VIDEO = "video"

class License(str, enum.Enum):
CC0 = "CC0"
CC_BY_4_0 = "CC_BY_4_0"
CC_BY_SA_4_0 = "CC_BY_SA_4_0"

class Visibility(str, enum.Enum):
MEMBERS = "members"
PRIVATE = "private"

class IdeaStatus(str, enum.Enum):
PUBLISHED = "published"
HELD = "held"
REMOVED = "removed"

class Idea(Base): tablename = "ideas"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
author_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
type = Column(SQLEnum(IdeaType), nullable=False)
title = Column(String(255), nullable=False, index=True)
text = Column(Text, nullable=True)
media_url = Column(String, nullable=True)
thumb_url = Column(String, nullable=True)
duration_s = Column(Integer, nullable=True)
waveform_json_url = Column(String, nullable=True)
license = Column(SQLEnum(License), nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
parent_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=True, index=True)
provenance_json = Column(JSON, nullable=True)
visibility = Column(SQLEnum(Visibility), default=Visibility.MEMBERS, nullable=False)
status = Column(SQLEnum(IdeaStatus), default=IdeaStatus.PUBLISHED, nullable=False)

author = relationship("User", backref="ideas")
parent = relationship("Idea", remote_side=[id], backref="forks")
stems = relationship("Stem", back_populates="idea", cascade="all, delete-orphan")
class Stem(Base): tablename = "stems"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
idea_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=False)
file_url = Column(String, nullable=False)
license = Column(SQLEnum(License), nullable=False)

idea = relationship("Idea", back_populates="stems")
EOF

emit apps/api/models/playlist.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class Playlist(Base): tablename = "playlists"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
title = Column(String(255), nullable=False)
description = Column(Text, nullable=True)
is_public = Column(Boolean, default=False, nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

owner = relationship("User", backref="playlists")
items = relationship("PlaylistItem", back_populates="playlist", cascade="all, delete-orphan", order_by="PlaylistItem.position")
class PlaylistItem(Base): tablename = "playlist_items"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
playlist_id = Column(UUID(as_uuid=True), ForeignKey("playlists.id"), nullable=False)
idea_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=False)
position = Column(Integer, nullable=False)

playlist = relationship("Playlist", back_populates="items")
idea = relationship("Idea")
EOF

emit apps/api/models/mood.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class MoodPost(Base): tablename = "mood_posts"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
author_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
text = Column(Text, nullable=False)
media_url = Column(String, nullable=True)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
reply_to = Column(UUID(as_uuid=True), ForeignKey("mood_posts.id"), nullable=True)

author = relationship("User", backref="mood_posts")
parent = relationship("MoodPost", remote_side=[id], backref="replies")
EOF

emit apps/api/models/report.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from core.database import Base

class ReportStatus(str, enum.Enum):
PENDING = "pending"
REVIEWED = "reviewed"
ACTIONED = "actioned"
DISMISSED = "dismissed"

class Report(Base): tablename = "reports"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
reporter_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
target_type = Column(String, nullable=False)  # 'idea', 'user', 'mood_post', etc.
target_id = Column(UUID(as_uuid=True), nullable=False)
reason = Column(Text, nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
status = Column(SQLEnum(ReportStatus), default=ReportStatus.PENDING, nullable=False)
action_taken = Column(Text, nullable=True)

reporter = relationship("User", backref="reports")
EOF

emit apps/api/models/takedown.py <<'EOF'
from sqlalchemy import Column, String, DateTime, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
import enum

from core.database import Base

class TakedownStatus(str, enum.Enum):
RECEIVED = "received"
REVIEWING = "reviewing"
ACTIONED = "actioned"
REJECTED = "rejected"

class Takedown(Base): tablename = "takedowns"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
claimant_name = Column(String, nullable=False)
claimant_email = Column(String, nullable=False)
basis = Column(Text, nullable=False)
target_type = Column(String, nullable=False)
target_id = Column(UUID(as_uuid=True), nullable=False)
received_at = Column(DateTime, default=datetime.utcnow, nullable=False)
action = Column(Text, nullable=True)
status = Column(SQLEnum(TakedownStatus), default=TakedownStatus.RECEIVED, nullable=False)
notes = Column(Text, nullable=True)
EOF

emit apps/api/models/audit.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class AuditEvent(Base): tablename = "audit_events"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
actor_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
action = Column(String, nullable=False)
payload_json = Column(JSON, nullable=True)
ts = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)

actor = relationship("User")
EOF

emit apps/api/models/session.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class RefreshToken(Base): tablename = "refresh_tokens"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
token = Column(String, unique=True, nullable=False, index=True)
user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
expires_at = Column(DateTime, nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

user = relationship("User", backref="refresh_tokens")
EOF

Schemas
emit apps/api/schemas/init.py <<'EOF' from .auth import * from .invite import * from .idea import * from .playlist import * from .mood import * from .report import * from .upload import * EOF

emit apps/api/schemas/auth.py <<'EOF'
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
import uuid

class UserRegister(BaseModel):
email: EmailStr
handle: str = Field(min_length=2, max_length=32)
password: str = Field(min_length=8)
age_confirmed: bool
invite_token: Optional[str] = None

class UserLogin(BaseModel):
email: EmailStr
password: str

class UserResponse(BaseModel):
id: uuid.UUID
email: EmailStr
handle: str
created_at: datetime
role: str
is_active: bool

class Config:
    from_attributes = True
class Token(BaseModel):
access_token: str
refresh_token: str
token_type: str = "bearer"

class RefreshTokenRequest(BaseModel):
refresh_token: str
EOF

emit apps/api/schemas/invite.py <<'EOF'
from pydantic import BaseModel
from datetime import datetime
import uuid
from typing import Optional

class InviteCreate(BaseModel):
pass

class InviteResponse(BaseModel):
id: uuid.UUID
token: str
invited_by: uuid.UUID
expires_at: datetime
used_by: Optional[uuid.UUID] = None
used_at: Optional[datetime] = None

class Config:
    from_attributes = True
class InviteValidateResponse(BaseModel):
ok: bool
token: str
EOF

emit apps/api/schemas/idea.py <<'EOF'
from pydantic import BaseModel, Field
from typing import Optional, List, Any
from datetime import datetime
import uuid

class IdeaCreate(BaseModel):
type: str  # "text" | "image" | "audio" | "video"
title: str
text: Optional[str] = None
media_url: Optional[str] = None
license: str  # "CC0" | "CC_BY_4_0" | "CC_BY_SA_4_0"
parent_id: Optional[uuid.UUID] = None
visibility: str = "members"  # "members" | "private"

class IdeaUpdate(BaseModel):
title: Optional[str] = None
text: Optional[str] = None
visibility: Optional[str] = None

class IdeaFork(BaseModel):
title: Optional[str] = None
text: Optional[str] = None
license: str
visibility: Optional[str] = None

class StemResponse(BaseModel):
id: uuid.UUID
file_url: str
license: str

class Config:
    from_attributes = True
class IdeaResponse(BaseModel):
id: uuid.UUID
author_id: uuid.UUID
type: str
title: str
text: Optional[str] = None
media_url: Optional[str] = None
thumb_url: Optional[str] = None
duration_s: Optional[int] = None
waveform_json_url: Optional[str] = None
license: str
created_at: datetime
parent_id: Optional[uuid.UUID] = None
provenance_json: Optional[Any] = None
visibility: str
status: str
stems: List[StemResponse] = []

class Config:
    from_attributes = True
class ProvenanceExport(BaseModel):
id: str
title: str
author: str
license: str
created_at: str
chain: list
EOF

emit apps/api/schemas/playlist.py <<'EOF'
from pydantic import BaseModel
from typing import Optional, List
import uuid
from datetime import datetime

class PlaylistCreate(BaseModel):
title: str
description: Optional[str] = None
is_public: bool = False

class PlaylistUpdate(BaseModel):
title: Optional[str] = None
description: Optional[str] = None
is_public: Optional[bool] = None

class PlaylistItemAdd(BaseModel):
idea_id: uuid.UUID
position: Optional[int] = None

class PlaylistItemResponse(BaseModel):
id: uuid.UUID
playlist_id: uuid.UUID
idea_id: uuid.UUID
position: int

class Config:
    from_attributes = True
class PlaylistResponse(BaseModel):
id: uuid.UUID
owner_id: uuid.UUID
title: str
description: Optional[str] = None
is_public: bool
created_at: datetime
items: List[PlaylistItemResponse] = []

class Config:
    from_attributes = True
EOF

emit apps/api/schemas/mood.py <<'EOF'
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import uuid

class MoodCreate(BaseModel):
text: str
media_url: Optional[str] = None
reply_to: Optional[uuid.UUID] = None

class MoodResponse(BaseModel):
id: uuid.UUID
author_id: uuid.UUID
text: str
media_url: Optional[str] = None
created_at: datetime
reply_to: Optional[uuid.UUID] = None

class Config:
    from_attributes = True
EOF

emit apps/api/schemas/report.py <<'EOF'
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid

class ReportCreate(BaseModel):
target_type: str
target_id: uuid.UUID
reason: str

class ReportResponse(BaseModel):
id: uuid.UUID
reporter_id: uuid.UUID
target_type: str
target_id: uuid.UUID
reason: str
created_at: datetime
status: str
action_taken: Optional[str] = None

class Config:
    from_attributes = True
EOF

emit apps/api/schemas/upload.py <<'EOF'
from pydantic import BaseModel
from typing import Dict

class PresignRequest(BaseModel):
filename: str

class PresignResponse(BaseModel):
url: str
fields: Dict[str, str]
file_key: str

class CompleteUpload(BaseModel):
# support both shapes for simplicity
file_key: str | None = None
type: str | None = None
object_name: str | None = None
content_type: str | None = None
EOF

API Routes
emit apps/api/api/init.py <<'EOF'

API module initialization
EOF

emit apps/api/api/auth.py <<'EOF'
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
get_current_user
)
from models import User, Invite
from schemas.auth import (
UserRegister,
UserLogin,
Token,
UserResponse,
RefreshTokenRequest
)

router = APIRouter()

@router.post("/register", response_model=UserResponse)
def register(
user_data: UserRegister,
db: Session = Depends(get_db)
):
if db.query(User).filter(User.email == user_data.email).first():
raise HTTPException(status_code=400, detail="Email already registered")

if db.query(User).filter(User.handle == user_data.handle).first():
    raise HTTPException(status_code=400, detail="Handle already taken")

invite = None
if user_data.invite_token:
    invite = db.query(Invite).filter(
        Invite.token == user_data.invite_token,
        Invite.used_by.is_(None),
        Invite.expires_at > datetime.utcnow()
    ).first()
    if not invite:
        raise HTTPException(status_code=400, detail="Invalid or expired invite token")

user = User(
    email=user_data.email,
    handle=user_data.handle,
    password_hash=get_password_hash(user_data.password),
    age_confirmed_at=datetime.utcnow() if user_data.age_confirmed else None
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
EOF

emit apps/api/api/invites.py <<'EOF'
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
active = db.query(Invite).filter(
Invite.invited_by == current_user.id,
Invite.used_by.is_(None),
Invite.expires_at > datetime.utcnow()
).count()
if active >= settings.RATE_LIMIT_INVITES_PER_USER:
raise HTTPException(status_code=429, detail="Invite quota exceeded")

invite = Invite(
    token=secrets.token_urlsafe(16),
    invited_by=current_user.id,
    expires_at=datetime.utcnow() + timedelta(days=7)
)
db.add(invite)
db.commit()
db.refresh(invite)
return invite
@router.get("/mine", response_model=List[InviteResponse])
def get_my_invites(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
invites = db.query(Invite).filter(Invite.invited_by == current_user.id).order_by(Invite.expires_at.desc()).all()
return invites

@router.post("/admin", response_model=InviteResponse)
def create_admin_invite(current_user: User = Depends(get_current_admin), db: Session = Depends(get_db)):
invite = Invite(
token=secrets.token_urlsafe(16),
invited_by=current_user.id,
expires_at=datetime.utcnow() + timedelta(days=30)
)
db.add(invite)
db.commit()
db.refresh(invite)
return invite

@router.post("/join/{token}", response_model=InviteValidateResponse)
def validate_join(token: str, db: Session = Depends(get_db)):
invite = db.query(Invite).filter(
Invite.token == token,
Invite.expires_at > datetime.utcnow(),
Invite.used_by.is_(None)
).first()
if not invite:
raise HTTPException(status_code=400, detail="Invalid or expired invite")
return InviteValidateResponse(ok=True, token=token)
EOF

emit apps/api/api/ideas.py <<'EOF'
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional
from datetime import datetime

from core.database import get_db
from core.security import get_current_user
from core.queue import enqueue_job
from models import User, Idea, Stem, AuditEvent
from models.idea import IdeaStatus, License, Visibility
from schemas.idea import IdeaCreate, IdeaUpdate, IdeaResponse, IdeaFork, ProvenanceExport
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
db: Session = Depends(get_db)
):
query = db.query(Idea).filter(Idea.status == IdeaStatus.PUBLISHED, Idea.visibility == Visibility.MEMBERS)
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
def get_idea(idea_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
idea = db.query(Idea).filter(Idea.id == idea_id).first()
if not idea:
raise HTTPException(status_code=404, detail="Idea not found")
if idea.visibility == Visibility.PRIVATE and idea.author_id != current_user.id:
raise HTTPException(status_code=403, detail="Access denied")
return idea

@router.post("/", response_model=IdeaResponse)
def create_idea(idea_data: IdeaCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
if idea_data.parent_id:
parent = db.query(Idea).filter(Idea.id == idea_data.parent_id).first()
if parent and parent.license == License.CC_BY_SA_4_0 and idea_data.license != "CC_BY_SA_4_0":
raise HTTPException(status_code=400, detail="Share-alike license must be preserved in derivatives")

idea = Idea(
    author_id=current_user.id,
    type=idea_data.type,
    title=idea_data.title,
    text=idea_data.text,
    media_url=idea_data.media_url,
    license=idea_data.license,
    parent_id=idea_data.parent_id,
    visibility=idea_data.visibility,
    status=IdeaStatus.HELD if idea_data.type == "audio" and idea_data.media_url else IdeaStatus.PUBLISHED
)

if idea_data.parent_id:
    parent = db.query(Idea).filter(Idea.id == idea_data.parent_id).first()
    if parent:
        idea.provenance_json = (parent.provenance_json or []) + [{
            "id": str(parent.id), "title": parent.title, "author": parent.author.handle, "license": parent.license
        }]

db.add(idea)
db.commit()
db.refresh(idea)

if idea.type == "audio" and idea.media_url:
    enqueue_job(process_audio_upload, str(idea.id))

audit = AuditEvent(actor_id=current_user.id, action="idea_created", payload_json={"idea_id": str(idea.id)})
db.add(audit)
db.commit()
return idea
@router.post("/{idea_id}/fork", response_model=IdeaResponse)
def fork_idea(idea_id: str, fork_data: IdeaFork, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
parent = db.query(Idea).filter(Idea.id == idea_id).first()
if not parent:
raise HTTP

Continue

bash
Exception(status_code=404, detail="Parent idea not found")

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
        status=IdeaStatus.PUBLISHED
    )

    fork.provenance_json = (parent.provenance_json or []) + [{
        "id": str(parent.id), "title": parent.title, "author": parent.author.handle, "license": parent.license
    }]

    db.add(fork)
    db.commit()
    db.refresh(fork)
    return fork

@router.patch("/{idea_id}", response_model=IdeaResponse)
def update_idea(idea_id: str, idea_update: IdeaUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
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
def delete_idea(idea_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    idea = db.query(Idea).filter(Idea.id == idea_id).first()
    if not idea:
        raise HTTPException(status_code=404, detail="Idea not found")
    if idea.author_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized to delete this idea")
    idea.status = IdeaStatus.REMOVED
    db.commit()
    return {"message": "Idea removed"}

@router.get("/{idea_id}/provenance", response_model=ProvenanceExport)
def get_provenance(idea_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    idea = db.query(Idea).filter(Idea.id == idea_id).first()
    if not idea:
        raise HTTPException(status_code=404, detail="Idea not found")
    prov = {
        "id": str(idea.id),
        "title": idea.title,
        "author": idea.author.handle,
        "license": idea.license,
        "created_at": idea.created_at.isoformat(),
        "chain": idea.provenance_json or []
    }
    return prov
EOF

emit apps/api/api/uploads.py <<'EOF'
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import mimetypes

from core.database import get_db
from core.security import get_current_user
from core.storage import generate_presigned_upload_url, generate_file_key
from models import User
from schemas.upload import PresignRequest, PresignResponse, CompleteUpload

router = APIRouter()

ALLOWED = {
    "image": ["image/jpeg", "image/png", "image/gif", "image/webp"],
    "audio": ["audio/mpeg", "audio/wav", "audio/ogg", "audio/webm"],
    "video": ["video/mp4", "video/webm", "video/ogg"]
}


def _classify_mime(filename: str) -> tuple[str, str]:
    mime, _ = mimetypes.guess_type(filename)
    for kind, mimes in ALLOWED.items():
        if mime in mimes:
            return kind, mime or "application/octet-stream"
    raise HTTPException(status_code=400, detail="File type not allowed")


@router.get("/presign", response_model=PresignResponse)
def presign_get(
    filename: str = Query(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    kind, mime = _classify_mime(filename)
    file_key = generate_file_key(str(current_user.id), filename, folder=f"{kind}s")
    presigned = generate_presigned_upload_url(file_key, content_type=mime)
    return {"url": presigned["url"], "fields": presigned["fields"], "file_key": file_key}


@router.post("/presign", response_model=PresignResponse)
def presign_post(
    req: PresignRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return presign_get(filename=req.filename, current_user=current_user, db=db)  # reuse


@router.post("/complete")
def complete_upload(
    data: CompleteUpload,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # In MVP we just acknowledge; audio processing happens when idea is created.
    return {"message": "Upload recorded"}
EOF

emit apps/api/api/playlists.py <<'EOF'
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from core.database import get_db
from core.security import get_current_user
from models import User, Playlist, PlaylistItem, Idea
from schemas.playlist import (
    PlaylistCreate,
    PlaylistUpdate,
    PlaylistResponse,
    PlaylistItemAdd,
    PlaylistItemResponse
)

router = APIRouter()


@router.get("/", response_model=List[PlaylistResponse])
def list_playlists(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    playlists = db.query(Playlist).filter(
        Playlist.owner_id == current_user.id
    ).order_by(Playlist.created_at.desc()).all()

    return playlists


@router.get("/{playlist_id}", response_model=PlaylistResponse)
def get_playlist(
    playlist_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()

    if not playlist:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Playlist not found"
        )

    if not playlist.is_public and playlist.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )

    return playlist


@router.post("/", response_model=PlaylistResponse)
def create_playlist(
    playlist_data: PlaylistCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    playlist = Playlist(
        owner_id=current_user.id,
        title=playlist_data.title,
        description=playlist_data.description,
        is_public=playlist_data.is_public
    )

    db.add(playlist)
    db.commit()
    db.refresh(playlist)

    return playlist


@router.patch("/{playlist_id}", response_model=PlaylistResponse)
def update_playlist(
    playlist_id: str,
    playlist_update: PlaylistUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()

    if not playlist:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Playlist not found"
        )

    if playlist.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized"
        )

    update_data = playlist_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(playlist, field, value)

    db.commit()
    db.refresh(playlist)

    return playlist


@router.post("/{playlist_id}/items", response_model=PlaylistItemResponse)
def add_to_playlist(
    playlist_id: str,
    item_data: PlaylistItemAdd,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()

    if not playlist:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Playlist not found"
        )

    if playlist.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized"
        )

    # Check idea exists
    idea = db.query(Idea).filter(Idea.id == item_data.idea_id).first()
    if not idea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Idea not found"
        )

    # Get next position
    max_position = db.query(PlaylistItem).filter(
        PlaylistItem.playlist_id == playlist_id
    ).count()

    item = PlaylistItem(
        playlist_id=playlist_id,
        idea_id=item_data.idea_id,
        position=item_data.position if item_data.position is not None else max_position
    )

    db.add(item)
    db.commit()
    db.refresh(item)

    return item


@router.delete("/{playlist_id}/items/{item_id}")
def remove_from_playlist(
    playlist_id: str,
    item_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()

    if not playlist:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Playlist not found"
        )

    if playlist.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized"
        )

    item = db.query(PlaylistItem).filter(
        PlaylistItem.id == item_id,
        PlaylistItem.playlist_id == playlist_id
    ).first()

    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    db.delete(item)
    db.commit()

    return {"message": "Item removed"}
EOF

emit apps/api/api/mood.py <<'EOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from core.database import get_db
from core.security import get_current_user
from models import MoodPost, User
from schemas.mood import MoodCreate, MoodResponse

router = APIRouter()


@router.get("/", response_model=List[MoodResponse])
def list_mood(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    posts = db.query(MoodPost).order_by(MoodPost.created_at.desc()).limit(100).all()
    return posts


@router.post("/", response_model=MoodResponse)
def create_mood(data: MoodCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = MoodPost(author_id=current_user.id, text=data.text, media_url=data.media_url, reply_to=data.reply_to)
    db.add(post)
    db.commit()
    db.refresh(post)
    return post
EOF

emit apps/api/api/reports.py <<'EOF'
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
    report = Report(
        reporter_id=current_user.id,
        target_type=data.target_type,
        target_id=data.target_id,
        reason=data.reason
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report


@router.get("/", response_model=List[ReportResponse])
def list_reports(current_user: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    reports = db.query(Report).order_by(Report.created_at.desc()).all()
    return reports
EOF

emit apps/api/api/moderation.py <<'EOF'
from fastapi import APIRouter, Depends, HTTPException
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
    db: Session = Depends(get_db)
):
    td = Takedown(
        claimant_name=claimant_name,
        claimant_email=claimant_email,
        basis=basis,
        target_type=target_type,
        target_id=target_id
    )
    # auto-hide the content if it's an idea
    if target_type == "idea":
        idea = db.query(Idea).filter(Idea.id == target_id).first()
        if idea:
            idea.status = "removed"
    db.add(td)
    db.commit()
    return {"ok": True}
EOF

emit apps/api/api/legal.py <<'EOF'
from fastapi import APIRouter

router = APIRouter()

docs = {
    "terms": "# Terms\nSee docs/TERMS.md in the repo.",
    "privacy": "# Privacy\nSee docs/PRIVACY.md.",
    "charter": "# Village Charter\nShare generously. Credit upstream.",
    "notice-takedown": "# Notice & Takedown\nEmail takedown@thevillage.local with details.",
    "illegal-content": "# Illegal Content Policy\nWe remove illegal content swiftly.",
    "licenses": "# Licences\nCC0, CC BY 4.0, CC BY-SA 4.0",
}

@router.get("/{slug}")
def get_legal(slug: str):
    return {"slug": slug, "markdown": docs.get(slug, "# Not found")}
EOF

# Workers and Scripts
emit apps/api/workers/media.py <<'EOF'
from sqlalchemy.orm import Session
from core.database import SessionLocal
from models import Idea, IdeaStatus

# MVP: mark audio ideas as published (stub for ffmpeg+ACR). Extend later.
def process_audio_upload(idea_id: str):
    db: Session = SessionLocal()
    try:
        idea = db.query(Idea).filter(Idea.id == idea_id).first()
        if not idea:
            return
        idea.status = IdeaStatus.PUBLISHED
        db.commit()
    finally:
        db.close()
EOF

emit apps/api/worker.py <<'EOF'
from rq import Worker
from core.queue import redis_conn, queue

if __name__ == "__main__":
    w = Worker([queue], connection=redis_conn)
    w.work()
EOF

emit apps/api/scripts/create_admin.py <<'EOF'
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
            is_active=True
        )
        db.add(admin)
        db.commit()
        print("Admin created:", settings.ADMIN_EMAIL)
    finally:
        db.close()

if __name__ == "__main__":
    main()
EOF

emit apps/api/scripts/seed.py <<'EOF'
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
        for i in range(1, 3+1):
            email = f"user{i}@thevillage.local"
            u = db.query(User).filter(User.email == email).first()
            if not u:
                u = User(
                    email=email,
                    handle=f"user{i}",
                    password_hash=get_password_hash("password123"),
                )
                db.add(u)
                db.commit()
                db.refresh(u)
            users.append(u)

        # Invites
        for u in users:
            inv = Invite(
                token=secrets.token_urlsafe(12),
                invited_by=u.id,
                expires_at=datetime.utcnow() + timedelta(days=14)
            )
            db.add(inv)
        db.commit()

        # Ideas
        samples = [
            ("Open Drum Loop (90bpm)", "audio", "CC_BY_4_0", None),
            ("Lyric seed: 'It takes a village'", "text", "CC0", "A chorus hook: It takes a village, hold me up tonight..."),
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
EOF

# Alembic
emit apps/api/alembic.ini <<'EOF'
[alembic]
script_location = alembic
sqlalchemy.url = driver://placeholder

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
EOF

emit apps/api/alembic/env.py <<'EOF'
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context

from core.config import settings
from core.database import Base
import models  # noqa: F401

config = context.config
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline():
    context.configure(
        url=settings.DATABASE_URL,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online():
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
        url=settings.DATABASE_URL,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
EOF

emit apps/api/alembic/versions/0001_init.py <<'EOF'
"""init

Revision ID: 0001
Revises:
Create Date: 2025-01-01 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers
revision = '0001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Tables are created by Base.metadata.create_all in main.py
    # This is a placeholder migration for CI compatibility
    pass


def downgrade() -> None:
    # Placeholder downgrade
    pass
EOF

# API Tests
emit apps/api/tests/conftest.py <<'EOF'
import os, pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from apps.api.main import app
from apps.api.core.database import Base, get_db

TEST_DB = "sqlite:///./test.db"
engine = create_engine(TEST_DB, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="session", autouse=True)
def setup_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture()
def client():
    return TestClient(app)
EOF

emit apps/api/tests/test_auth_invite.py <<'EOF'
from datetime import datetime
def test_register_login_flow(client):
    # register
    r = client.post("/auth/register", json={
        "email":"u1@example.com","handle":"u1",
        "password":"password123","age_confirmed":True
    })
    assert r.status_code == 200
    uid = r.json()["id"]

    # login
    r = client.post("/auth/login", json={"email":"u1@example.com","password":"password123"})
    assert r.status_code == 200
    tok = r.json()["access_token"]
    assert tok

def test_invite_create_and_validate(client):
    # seed user
    client.post("/auth/register", json={
        "email":"u2@example.com","handle":"u2",
        "password":"password123","age_confirmed":True
    })
    tok = client.post("/auth/login", json={"email":"u2@example.com","password":"password123"}).json()["access_token"]
    # create invite
    r = client.post("/invites/", headers={"Authorization": f"Bearer {tok}"})
    assert r.status_code == 200
    token = r.json()["token"]
    # validate invite
    r = client.post(f"/invites/join/{token}")
    assert r.status_code == 200
    assert r.json()["ok"] is True
EOF

emit apps/api/tests/test_ideas_licenses.py <<'EOF'
def auth(client, email="u3@example.com", handle="u3"):
    client.post("/auth/register", json={
        "email": email, "handle": handle, "password": "password123", "age_confirmed": True
    })
    tok = client.post("/auth/login", json={"email": email, "password": "password123"}).json()["access_token"]
    return {"Authorization": f"Bearer {tok}"}

def test_create_and_fork_with_by_sa_propagation(client):
    hdrs = auth(client)
    # Parent BY-SA
    p = client.post("/ideas/", json={
        "type":"text","title":"BYSA parent","text":"t","license":"CC_BY_SA_4_0","visibility":"members"
    }, headers=hdrs).json()

    # Try to fork with CC BY (should be forced to BY-SA)
    f = client.post(f"/ideas/{p['id']}/fork", json={"license":"CC_BY_4_0","title":"child"}, headers=hdrs).json()
    assert f["license"] == "CC_BY_SA_4_0"
EOF

# Web App
emit apps/web/package.json <<'EOF'
{
  "name": "web",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint",
    "test": "vitest run",
    "test:e2e": "playwright test"
  },
  "dependencies": {
    "next": "14.2.4",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.1",
    "zod": "^3.23.8"
  },
  "devDependencies": {
    "@types/node": "^20.14.2",
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.41",
    "tailwindcss": "^3.4.10",
    "typescript": "^5.5.4",
    "@playwright/test": "^1.45.3",
    "vitest": "^2.0.4",
    "eslint": "^8.57.0",
    "eslint-config-next": "^14.2.4"
  }
}
EOF

emit apps/web/next.config.js <<'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: { appDir: true },
}

module.exports = nextConfig
EOF

emit apps/web/tailwind.config.ts <<'EOF'
import type { Config } from "tailwindcss"

const config: Config = {
  content: [
    "./src/app/**/*.{ts,tsx}",
    "./src/components/**/*.{ts,tsx}"
  ],
  theme: { extend: {} },
  plugins: []
}
export default config
EOF

emit apps/web/postcss.config.js <<'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

emit apps/web/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["DOM", "ES2022"],
    "jsx": "preserve",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "strict": true,
    "allowJs": false,
    "noEmit": true,
    "esModuleInterop": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },
    "types": ["@types/node"]
  },
  "include": ["next-env.d.ts", "src/**/*.ts", "src/**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

emit apps/web/.eslintrc.json <<'EOF'
{
  "extends": ["next/core-web-vitals"],
  "rules": {
    "@next/next/no-img-element": "off"
  }
}
EOF

emit apps/web/playwright.config.ts <<'EOF'
import { defineConfig, devices } from '@playwright/test';
export default defineConfig({
  testDir: './tests-e2e',
  retries: 0,
  use: { baseURL: 'http://localhost:3000', trace: 'retain-on-failure' },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }]
});
EOF

emit apps/web/Dockerfile <<'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN npm i -g pnpm && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build
EXPOSE 3000
CMD ["pnpm","start"]
EOF

emit apps/web/src/app/globals.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root { color-scheme: light; }
body { @apply bg-white text-gray-900; }
EOF

emit apps/web/src/app/layout.tsx <<'EOF'
import './globals.css'
import Link from 'next/link'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <header className="border-b">
          <div className="container mx-auto flex items-center justify-between p-4">
            <Link href="/feed" className="font-bold">The Village</Link>
            <nav className="text-sm space-x-4">
              <Link href="/ideas/new">Share</Link>
              <Link href="/mood">Mood</Link>
              <Link href="/playlists">Playlists</Link>
            </nav>
          </div>
        </header>
        <main>{children}</main>
      </body>
    </html>
  )
}
EOF

emit apps/web/src/app/page.tsx <<'EOF'
import { redirect } from 'next/navigation'
export default function Home() { redirect('/feed') }
EOF

emit apps/web/src/lib/utils.ts <<'EOF'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF

emit apps/web/src/lib/api.ts <<'EOF'
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export interface LoginData {
  email: string
  password: string
}

export interface RegisterData {
  email: string
  handle: string
  password: string
  age_confirmed: boolean
  invite_token?: string
}

export interface TokenResponse {
  access_token: string
  refresh_token: string
  token_type: string
}

class ApiClient {
  private token: string | null = null

  setToken(token: string) {
    this.token = token
    if (typeof window !== 'undefined') {
      localStorage.setItem('token', token)
    }
  }

  getToken(): string | null {
    if (typeof window !== 'undefined' && !this.token) {
      this.token = localStorage.getItem('token')
    }
    return this.token
  }

  clearToken() {
    this.token = null
    if (typeof window !== 'undefined') {
      localStorage.removeItem('token')
      localStorage.removeItem('refresh_token')
    }
  }

  async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = ${API_URL}${endpoint}
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    }

    if (this.getToken()) {
      headers['Authorization'] = Bearer ${this.getToken()}
    }

    const response = await fetch(url, {
      ...options,
      headers,
    })

    if (!response.ok) {
      if (response.status === 401) {
        this.clearToken()
        window.location.href = '/auth/login'
      }
      throw new Error(API Error: ${response.statusText})
    }

    return response.json()
  }

  async login(data: LoginData): Promise<TokenResponse> {
    const response = await this.request<TokenResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(data),
    })

    this.setToken(response.access_token)
    if (typeof window !== 'undefined') {
      localStorage.setItem('refresh_token', response.refresh_token)
    }

    return response
  }

  async register(data: RegisterData): Promise<any> {
    return this.request('/auth/register', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async getMe(): Promise<any> {
    return this.request('/auth/me')
  }

  async getIdeas(params?: any): Promise<any> {
    const queryString = params ? ?${new URLSearchParams(params)} : ''
    return this.request(/ideas${queryString})
  }

  async createIdea(data: any): Promise<any> {
    return this.request('/ideas', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async forkIdea(ideaId: string): Promise<any> {
    return this.request(/ideas/${ideaId}/fork, {
      method: 'POST',
      body: JSON.stringify({ license: 'CC_BY_4_0' }),
    })
  }

  async createInvite(): Promise<any> {
    return this.request('/invites', {
      method: 'POST',
    })
  }

  async validateInvite(token: string): Promise<any> {
    return this.request(/invites/join/${token}, {
      method: 'POST',
    })
  }
}

export const api = new ApiClient()
EOF

emit apps/web/src/components/ui/button.tsx <<'EOF'
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
EOF

emit apps/web/src/components/ui/input.tsx <<'EOF'
import * as React from "react"
import { cn } from "@/lib/utils"

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Input.displayName = "Input"

export { Input }
EOF

emit apps/web/src/components/ui/label.tsx <<'EOF'
"use client"

import * as React from "react"
import * as LabelPrimitive from "@radix-ui/react-label"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const labelVariants = cva(
  "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
)

const Label = React.forwardRef
  React.ElementRef<typeof LabelPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof LabelPrimitive.Root> &
    VariantProps<typeof labelVariants>
>(({ className, ...props }, ref) => (
  <LabelPrimitive.Root
    ref={ref}
    className={cn(labelVariants(), className)}
    {...props}
  />
))
Label.displayName = LabelPrimitive.Root.displayName

export { Label }
EOF

emit apps/web/src/app/auth/login/page.tsx <<'EOF'
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { api } from '@/lib/api'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      await api.login({ email, password })
      router.push('/feed')
    } catch (err) {
      setError('Invalid email or password')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="w-full max-w-md space-y-8 p-8">
        <div className="text-center">
          <h1 className="text-2xl font-bold">Welcome back</h1>
          <p className="text-muted-foreground mt-2">
            Sign in to your Village account
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div>
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          {error && (
            <div className="text-sm text-destructive">{error}</div>
          )}

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? 'Signing in...' : 'Sign in'}
          </Button>
        </form>

        <div className="text-center text-sm">
          <span className="text-muted-foreground">Don't have an account? </span>
          <Link href="/invite" className="text-primary hover:underline">
            Join with invite
          </Link>
        </div>
      </div>
    </div>
  )
}
EOF

emit apps/web/src/app/auth/register/page.tsx <<'EOF'
'use client'

import { useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { api } from '@/lib/api'

export default function RegisterPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const inviteToken = searchParams.get('token')

  const [email, setEmail] = useState('')
  const [handle, setHandle] = useState('')
  const [password, setPassword] = useState('')
  const [ageConfirmed, setAgeConfirmed] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    if (!ageConfirmed) {
      setError('You must be 18 or older to use The Village')
      setLoading(false)
      return
    }

    try {
      await api.register({
        email,
        handle,
        password,
        age_confirmed: ageConfirmed,
        invite_token: inviteToken || undefined
      })

      await api.login({ email, password })
      router.push('/feed')
    } catch (err: any) {
      setError(err.message || 'Registration failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="w-full max-w-md space-y-8 p-8">
        <div className="text-center">
          <h1 className="text-2xl font-bold">Join The Village</h1>
          <p className="text-muted-foreground mt-2">
            Create your account to start sharing
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div>
            <Label htmlFor="handle">Handle</Label>
            <Input
              id="handle"
              value={handle}
              onChange={(e) => setHandle(e.target.value)}
              placeholder="@yourhandle"
              required
            />
          </div>

          <div>
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          <div className="flex items-center space-x-2">
            <input
              type="checkbox"
              id="age"
              checked={ageConfirmed}
              onChange={(e) => setAgeConfirmed(e.target.checked)}
              className="rounded border-gray-300"
            />
            <Label htmlFor="age" className="text-sm">
              I confirm that I am 18 years or older
            </Label>
          </div>

          {error && (
            <div className="text-sm text-destructive">{error}</div>
          )}

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? 'Creating account...' : 'Create account'}
          </Button>
        </form>
      </div>
    </div>
  )
}
EOF

emit apps/web/src/app/invite/\[token\]/page.tsx <<'EOF'
'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { api } from '@/lib/api'

export default function InvitePage({ params }: { params: { token: string } }) {
  const router = useRouter()
  const [validating, setValidating] = useState(true)
  const [valid, setValid] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    validateInvite()
  }, [])

  const validateInvite = async () => {
    try {
      await api.validateInvite(params.token)
      setValid(true)
    } catch (err) {
      setError('This invite is invalid or has expired')
    } finally {
      setValidating(false)
    }
  }

  if (validating) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center">
          <p>Validating invite...</p>
        </div>
      </div>
    )
  }

  if (!valid) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center space-y-4">
          <h1 className="text-2xl font-bold">Invalid Invite</h1>
          <p className="text-muted-foreground">{error}</p>
          <Button onClick={() => router.push('/')}>
            Return Home
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center space-y-4 max-w-md">
        <h1 className="text-2xl font-bold">Welcome to The Village!</h1>
        <p className="text-muted-foreground">
          You've been invited to join our creative community.
          Click below to create your account.
        </p>
        <Button onClick={() => router.push(/auth/register?token=${params.token})}>
          Create Account
        </Button>
      </div>
    </div>
  )
}
EOF

emit apps/web/src/app/invite/page.tsx <<'EOF'
'use client'
import { useState } from 'react'
import { api } from '@/lib/api'
import { Button } from '@/components/ui/button'

export default function InviteIndex() {
  const [link, setLink] = useState<string | null>(null)
  const [wa, setWa] = useState<string | null>(null)

  return (
    <div className="container mx-auto py-8 space-y-4">
      <h1 className="text-2xl font-bold">Invite a friend</h1>
      <Button onClick={async ()=>{
        const inv = await api.createInvite()
        const url = ${window.location.origin}/invite/${inv.token}
        setLink(url)
        const msg = encodeURIComponent(Join The Village: ${url})
        setWa(https://wa.me/?text=${msg})
      }}>Generate Invite</Button>

      {link && (
        <div className="space-y-2">
          <div className="text-sm">Invite link:</div>
          <code className="block p-2 bg-gray-100 rounded">{link}</code>
          <a href={wa!} className="inline-block underline text-blue-600" target="_blank" rel="noreferrer">Share via WhatsApp</a>
        </div>
      )}
    </div>
  )
}
EOF

emit apps/web/src/app/feed/page.tsx <<'EOF'
'use client'

import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/button'
import { api } from '@/lib/api'
import Link from 'next/link'

export default function FeedPage() {
  const [ideas, setIdeas] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadIdeas()
  }, [])

  const loadIdeas = async () => {
    try {
      const data = await api.getIdeas()
      setIdeas(data)
    } catch (err) {
      console.error('Failed to load ideas:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleFork = async (ideaId: string) => {
    try {
      await api.forkIdea(ideaId)
      loadIdeas() // Reload to show new fork
    } catch (err) {
      console.error('Failed to fork idea:', err)
    }
  }

  if (loading) {
    return (
      <div className="container mx-auto py-8">
        <p>Loading ideas...</p>
      </div>
    )
  }

  return (
    <div className="container mx-auto py-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">The Village Feed</h1>
        <Link href="/ideas/new">
          <Button>Share Idea</Button>
        </Link>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {ideas.map((idea) => (
          <div key={idea.id} className="border rounded-lg p-6 space-y-4">
            <h2 className="text-xl font-semibold">{idea.title}</h2>
            {idea.text && <p className="text-muted-foreground">{idea.text}</p>}

            <div className="flex items-center justify-between text-sm">
              <span className="inline-flex items-center px-2 py-1 rounded-full text-xs bg-secondary">
                {idea.license}
              </span>
              <span className="text-muted-foreground">
                {idea.type}
              </span>
            </div>

            {idea.parent_id && (
              <div className="text-sm text-muted-foreground">
                Forked from another idea
              </div>
            )}

            <div className="flex gap-2">
              <Button
                size="sm"
                variant="outline"
                onClick={() => handleFork(idea.id)}
              >
                Fork
              </Button>
              <Link href={/ideas/${idea.id}}>
                <Button size="sm" variant="outline">
                  View
                </Button>
              </Link>
            </div>
          </div>
        ))}
      </div>

      {ideas.length === 0 && (
        <div className="text-center py-12">
          <p className="text-muted-foreground">No ideas yet. Be the first to share!</p>
        </div>
      )}
    </div>
  )
}
EOF

emit apps/web/src/app/ideas/new/page.tsx <<'EOF'
'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { api } from '@/lib/api'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'

export default function NewIdea() {
  const router = useRouter()
  const [title, setTitle] = useState('')
  const [text, setText] = useState('')
  const [type, setType] = useState<'text'|'image'|'audio'|'video'>('text')
  const [license, setLicense] = useState<'CC0'|'CC_BY_4_0'|'CC_BY_SA_4_0'>('CC0')
  const [error, setError] = useState<string>('')

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    try {
      await api.createIdea({
        type, title,
        text: type === 'text' ? text : undefined,
        license
      })
      router.push('/feed')
    } catch (err: any) {
      setError(err.message ?? 'Failed to create idea')
    }
  }

  return (
    <div className="container mx-auto max-w-2xl py-8">
      <h1 className="text-2xl font-bold mb-6">Share an Idea</h1>
      <form onSubmit={submit} className="space-y-4">
        <div>
          <Label>Type</Label>
          <select value={type} onChange={e => setType(e.target.value as any)} className="border rounded p-2 w-full">
            <option value="text">Text</option>
            <option value="image">Image (URL later)</option>
            <option value="audio">Audio (URL later)</option>
            <option value="video">Video (URL later)</option>
          </select>
        </div>
        <div>
          <Label>Title</Label>
          <Input value={title} onChange={e=>setTitle(e.target.value)} required />
        </div>
        {type === 'text' && (
          <div>
            <Label>Text</Label>
            <textarea className="border rounded p-2 w-full min-h-[120px]" value={text} onChange={e=>setText(e.target.value)} />
          </div>
        )}
        <div>
          <Label>Licence</Label>
          <select value={license} onChange={e => setLicense(e.target.value as any)} className="border rounded p-2 w-full">
            <option value="CC0">CC0 (Public Domain)</option>
            <option value="CC_BY_4_0">CC BY 4.0 (Credit required)</option>
            <option value="CC_BY_SA_4_0">CC BY-SA 4.0 (ShareAlike)</option>
          </select>
          <p className="text-xs text-gray-500 mt-1">We disallow ND/NC. Share freely; credit where needed.</p>
        </div>

        {error && <p className="text-red-600 text-sm">{error}</p>}
        <Button type="submit">Publish</Button>
      </form>
    </div>
  )
}
EOF

emit apps/web/src/app/ideas/\[id\]/page.tsx <<'EOF'
'use client'
import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { api } from '@/lib/api'

export default function IdeaDetail() {
  const params = useParams<{ id: string }>()
  const [idea, setIdea] = useState<any | null>(null)

  useEffect(() => {
    (async () => {
      const res = await fetch(${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/ideas/${params.id}, {
        headers: { Authorization: Bearer ${localStorage.getItem('token') || ''} }
      })
      if (res.ok) setIdea(await res.json())
    })()
  }, [params.id])

  if (!idea) return <div className="container mx-auto py-8">Loading…</div>

  return (
    <div className="container mx-auto py-8 space-y-4">
      <h1 className="text-2xl font-bold">{idea.title}</h1>
      {idea.text && <p className="text-gray-700">{idea.text}</p>}
      <div className="flex items-center gap-2 text-sm">
        <span className="px-2 py-1 rounded bg-gray-100">{idea.license}</span>
        <span className="text-gray-500">{idea.type}</span>
      </div>
      <div className="flex gap-2">
        <Button onClick={async () => {
          await fetch(${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/ideas/${idea.id}/fork, {
            method: 'POST',
            headers: {
              Authorization: Bearer ${localStorage.getItem('token') || ''},
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ license: idea.license })
          })
          window.location.href = '/feed'
        }}>Fork</Button>
        <Link href="/feed"><Button variant="outline">Back</Button></Link>
      </div>
    </div>
  )
}
EOF

emit apps/web/src/app/mood/page.tsx <<'EOF'
'use client'
import { useEffect, useState } from 'react'
import { api } from '@/lib/api'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

export default function Mood() {
  const [posts, setPosts] = useState<any[]>([])
  const [text, setText] = useState('')

  const load = async () => setPosts(await api.request('/mood'))

  useEffect(() => { load() }, [])

  return (
    <div className="container mx-auto py-8 space-y-6">
      <h1 className="text-2xl font-bold">Mood & Thoughts</h1>
      <form onSubmit={async (e)=>{ e.preventDefault(); await api.request('/mood',{method:'POST', body: JSON.stringify({text})}); setText(''); load()}} className="flex gap-2">
        <Input placeholder="Share a thought…" value={text} onChange={e=>setText(e.target.value)} />
        <Button type="submit">Post</Button>
      </form>
      <div className="space-y-4">
        {posts.map(p=>(
          <div key={p.id} className="border rounded p-4">
            <div className="text-sm text-gray-500">{new Date(p.created_at).toLocaleString()}</div>
            <div>{p.text}</div>
          </div>
        ))}
      </div>
    </div>
  )
}
EOF

emit apps/web/src/app/playlists/page.tsx <<'EOF'
export default function Playlists() {
  return (
    <div className="container mx-auto py-8">
      <h1 className="text-2xl font-bold mb-4">Playlists</h1>
      <p className="text-gray-600">Coming soon in V1. (API endpoints exist.)</p>
    </div>
  )
}
EOF

emit apps/web/src/app/admin/moderation/page.tsx <<'EOF'
'use client'
import { useEffect, useState } from 'react'

export default function Moderation() {
  const [items, setItems] = useState<any[]>([])
  useEffect(() => {
    (async () => {
      const res = await fetch(${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/mod/queue, {
        headers: { Authorization: Bearer ${localStorage.getItem('token') || ''} }
      })
      if (res.ok) setItems(await res.json())
    })()
  }, [])

  return (
    <div className="container mx-auto py-8">
      <h1 className="text-2xl font-bold mb-4">Moderation Queue</h1>
      {items.length === 0 ? <p>No reports.</p> : (
        <ul className="space-y-3">
          {items.map((r:any)=>(
            <li key={r.id} className="border rounded p-3">
              <div className="text-sm text-gray-500">{r.target_type} · {r.target_id}</div>
              <div>{r.reason}</div>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
EOF

emit apps/web/tests/utils.test.ts <<'EOF'
import { describe, it, expect } from 'vitest';
import { cn } from '@/lib/utils';
describe('cn', () => {
  it('merges classes', () => {
    expect(cn('a', 'b')).toContain('a');
  });
});
EOF

emit apps/web/tests-e2e/smoke.spec.ts <<'EOF'
import { test, expect } from '@playwright/test';
test('home redirects to feed', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveURL(/\/feed$/);
});
EOF

# Documentation
Continue

bash
emit docs/PRIVACY.md <<'EOF'
# Privacy Policy

## Data We Collect

We collect minimal personal data:
- Email address (for authentication)
- Username/handle (for identification)
- Age confirmation (18+ requirement)
- Content you upload (ideas, images, audio)

## How We Use Data

- Provide the service
- Authenticate users
- Enable content sharing
- Safety and moderation

## Data Protection

- Passwords hashed with Argon2id
- HTTPS/TLS encryption
- Regular security updates
- Access controls

## Your Rights

- Access your data
- Export your data
- Delete your account
- Correct information

## Data Retention

- Account data: Until deletion requested
- Content: Preserved under CC licenses even after account deletion
- Logs: 90 days

## Contact

privacy@thevillage.example
EOF

emit docs/TERMS.md <<'EOF'
# Terms of Service

## Acceptance

By using The Village, you agree to these terms.

## Age Requirement

You must be 18 or older to use The Village.

## Content Ownership

- You retain ownership of content you create
- You grant irrevocable licenses under CC0, CC BY 4.0, or CC BY-SA 4.0
- You warrant you have rights to all content you upload

## Prohibited Content

- Illegal material
- Copyright infringement
- Hate speech
- Harassment
- CSAM or exploitation

## License Grant

By uploading content, you grant The Village a non-exclusive, worldwide license to:
- Host and display your content
- Create technical copies for backups
- Modify for technical requirements

## Termination

We may terminate accounts that:
- Violate these terms
- Upload prohibited content
- Repeatedly infringe copyrights

## Disclaimer

The Village is provided "as is" without warranties.

## Changes

We may update these terms with notice.
EOF

emit docs/CONTRIBUTING.md <<'EOF'
# Contributing to The Village

## Development Setup

1. Fork the repository
2. Clone your fork
3. Install dependencies: pnpm install
4. Create a branch: git checkout -b feature/your-feature
5. Make changes
6. Test: pnpm test
7. Commit: git commit -m "feat: your feature"
8. Push: git push origin feature/your-feature
9. Create Pull Request

## Code Style

- Use Prettier for formatting
- Follow ESLint rules
- Use conventional commits
- Write tests for new features

## Testing

- Unit tests: pnpm test
- E2E tests: pnpm test:e2e
- API tests: cd apps/api && pytest

## Documentation

Update docs for:
- API changes
- New features
- Configuration changes
EOF

emit docs/LICENSES.md <<'EOF'
# Content Licences

We support **CC0**, **CC BY 4.0**, and **CC BY-SA 4.0**.

- **CC0** — public-domain dedication; no attribution required.
- **CC BY 4.0** — reuse including commercial, with reasonable attribution.
- **CC BY-SA 4.0** — as CC BY, *plus* **Share-Alike**: derivatives **must** be BY-SA 4.0.

We do **not** support **NC** (Non-Commercial) or **ND** (No-Derivatives).

**Attribution (BY/BY-SA)** 
Use a short, reasonable credit such as: 
> "Title" by @handle — licensed CC BY 4.0. Source: thevillage.example/ideas/… 

The app provides a "copy attribution" button on downloads.

**Share-Alike propagation** 
If a parent is BY-SA 4.0, all forks/remixes must also be BY-SA 4.0. The API enforces this.
EOF

emit docs/NOTICE_TAKEDOWN_POLICY.md <<'EOF'
# Notice & Takedown (UK)

- Email **takedown@thevillage.example** with claimant name, contact, basis, and a link to the content.
- We will **temporarily hide** the content while reviewing.
- We notify the uploader and track actions in the moderation dashboard.
- Outcomes: restore / remove / restrict account. We keep an audit trail.
EOF

emit docs/ARCHITECTURE.md <<'EOF'
# Architecture (MVP)

Monorepo: **apps/api** (FastAPI + Postgres + Redis + RQ), **apps/web** (Next.js 14). 
Media: MinIO (S3 compatible) presigned uploads; worker stubs for audio pipeline. 
Metrics: Prometheus /metrics. Logs: JSON with request IDs.
EOF

emit docs/DATA_MODEL.md <<'EOF'
# Data Model (key tables)
- users, invites, ideas (+stems), playlists (+items), mood_posts, reports, takedowns, audit_events, refresh_tokens.
Indexes: ideas.parent_id, ideas.created_at, FTS planned on ideas.title+text.
EOF

emit docs/SECURITY.md <<'EOF'
# Security

- Argon2id for passwords, JWT (access+refresh).
- CORS restricted to app origins.
- Rate limits configurable, basic quotas on invites.
- Secret scanning in CI, SBOM available, dependencies pinned.
EOF

emit docs/VILLAGE_CHARTER.md <<'EOF'
# The Village Charter

Be generous. Credit upstream. Remix respectfully. Report abuse. We remove illegal content swiftly.
EOF

emit docs/Release-Readiness-Packet.md <<'EOF'
# Release Readiness — The Village (MVP)

## Executive Summary
Invite-only commons for ideas/images/audio under CC0/BY/BY-SA. Upload via presigned S3. BY-SA share-alike enforced.

## What Changed (Branch: refactor/initial-review-upgrade)
- Pinned runtimes; pre-commit; Make targets.
- API metrics (/metrics), JSON logs, request IDs.
- API tests: auth/invite/ideas incl. BY-SA propagation; coverage ≥85% for modules touched.
- Web ESLint; Playwright smoke test.
- CI: Postgres/Redis/MinIO services; coverage gate; secret scan.
- Legal docs: Licences, N&T, Architecture, Data Model, Security, Charter.

## How to Run From Scratch
bash
cp .env.example .env
docker compose up -d
docker compose exec api alembic upgrade head
docker compose exec api python -m scripts.create_admin
docker compose exec api python -m scripts.seed
open http://localhost:3000
Quality Gates
CI enforces lint/typecheck/tests; API coverage ≥85% gate; secret scan.

Test Coverage (API subset)
Auth/register/login
Invites create/validate
Ideas fork with BY-SA propagation
Security Notes
Argon2id, JWT (access+refresh), CORS, quotas on invites, secret scanning in CI.

Operations
Health: GET /health
Metrics: GET /metrics (Prometheus)
Logs: JSON with X-Request-Id
Buckets: API ensures MinIO bucket on startup.
Known Gaps
Audio pipeline (ffmpeg/HLS/waveform) stubbed.
Full E2E flows for uploads and moderation not yet in tests.
SBOM optional; Dependabot/CodeQL optional.
Next Steps
Implement audio worker (ffmpeg → HLS preview, waveform JSON).
Add FTS (title+text) and search endpoints.
Expand Playwright to cover invite → register → post idea flow. EOF
CI/CD
emit .github/workflows/ci.yml <<'EOF'
name: CI
on:
pull_request:
push:
branches: [main]

jobs:
lint-and-typecheck:
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v4
- uses: pnpm/action-setup@v2
with: { version: 8 }
- uses: actions/setup-node@v4
with: { node-version: 18, cache: 'pnpm' }
- run: pnpm install
- run: pnpm lint
- name: Gitleaks
uses: gitleaks/gitleaks-action@v2
with: { args: "--no-git -v ." }

api-tests: runs-on: ubuntu-latest services: postgres: image: postgres:15-alpine env: POSTGRES_USER: village_user POSTGRES_PASSWORD: change_me POSTGRES_DB: thevillage ports: [5432:5432] options: >- --health-cmd "pg_isready -U village_user" --health-interval 10s --health-timeout 5s --health-retries 5 redis: image: redis:7-alpine ports: [6379:6379] minio: image: minio/minio:latest env: MINIO_ROOT_USER: minioadmin MINIO_ROOT_PASSWORD: minioadmin ports: [9000:9000,9001:9001] options: --health-cmd "curl -f http://localhost:9000/minio/health/live || exit 1" --health-interval 10s --health-timeout 5s --health-retries 5 command: server /data --console-address ":9001" steps: - uses: actions/checkout@v4 - uses: actions/setup-python@v5 with: { python-version: '3.11' } - name: Install deps run: | cd apps/api pip install -r requirements.txt - name: Run tests + coverage run: | cd apps/api pytest --cov=./ --cov-report=xml --cov-fail-under=85 - name: Upload coverage uses: actions/upload-artifact@v4 with: name: api-coverage-xml path: apps/api/coverage.xml

web-build-and-e2e: runs-on: ubuntu-latest needs: [api-tests] steps: - uses: actions/checkout@v4 - uses: pnpm/action-setup@v2 with: { version: 8 } - uses: actions/setup-node@v4 with: { node-version: 18, cache: 'pnpm' } - run: pnpm install - run: pnpm --filter web build - name: Install Playwright run: npx playwright install --with-deps - name: Start services via docker compose run: docker compose up -d postgres redis minio api web - name: E2E smoke run: pnpm --filter web test:e2e - name: Teardown if: always() run: docker compose down -v EOF

Set executable permissions
chmod +x scripts/gen-sbom.sh
chmod +x .husky/pre-commit
chmod +x apps/api/scripts/create_admin.py
chmod +x apps/api/scripts/seed.py

echo "Setting up git repository..."

Initialize git if not already
if [ ! -d .git ]; then
x git init -b main
fi

Stage and commit if clean
if [ -z "(git status --porcelain)" ] && [ -z " (git log --oneline 2>/dev/null)" ]; then x git add . x git commit -m "chore: bootstrap repo" fi

printf "\n🎉 The Village repository bootstrapped successfully!\n\n" printf "Next steps:\n" printf "1) cp .env.example .env\n" printf "2) docker compose up -d\n" printf "3) docker compose exec api alembic upgrade head\n" printf "4) docker compose exec api python -m scripts.create_admin\n" printf "5) docker compose exec api python -m scripts.seed\n\n" printf "Open:\n" printf "- Web: http://localhost:3000\n" printf "- API: http://localhost:8000 (docs at /docs)\n" printf "- MinIO: http://localhost:9001 (minioadmin/minioadmin)\n"
ChatGPT said:

Thought for 1m 31s
#!/usr/bin/env bash
set -euo pipefail

# bootstrap_village.sh
# Creates a Cursor-ready monorepo for "The Village" and writes all files exactly.
# Shebang + safety flags present. Uses single-quoted heredocs to avoid interpolation.

ROOT="$(pwd)"

mkd() { mkdir -p "$@"; }
emit() { # emit <path> <<'EOF' ... EOF
  local path="$1"; shift
  mkdir -p "$(dirname "$path")"
  cat > "$path"
}
x() { echo "Running: $*"; "$@"; }

echo "Bootstrapping The Village repository into: $ROOT"

# ────────────────────────────────────────────────────────────────────────────────
# Directories
# ────────────────────────────────────────────────────────────────────────────────
mkd \
  .github/workflows \
  .husky/_ \
  apps/api/{alembic/{versions,},api,core,models,schemas,scripts,tests,workers} \
  apps/web/{public,src/{app/{admin/moderation,auth/{login,register},feed,ideas/{new,[id]},invite/{[token]},mood,playlists},components/ui,lib},tests,tests-e2e} \
  docs packages sbom scripts

# ────────────────────────────────────────────────────────────────────────────────
# Root files
# ────────────────────────────────────────────────────────────────────────────────
emit .editorconfig <<'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.py]
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EOF

emit .gitignore <<'EOF'
# Node
node_modules/
.pnp/
.pnp.js

# Next.js
.next/
*.next/
out/

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
env/
ENV/
*.so
.Python
*.egg-info/

# Coverage & test
coverage/
htmlcov/
.pytest_cache/
.nyc_output
*.cover
.coverage
.coverage.*
playwright-report/
test-results/

# Build caches
dist/
build/
.turbo/

# Environments
.env
.env.local
.env.*.local
*.env
!.env.example

# IDE & OS
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# DB
*.db
*.sqlite
*.sqlite3

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*
EOF

emit LICENSE <<'EOF'
MIT License

Copyright (c) 2025 The Village

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
EOF

emit README.md <<'EOF'
# The Village

An invite-only creative commons for sharing ideas, images, and audio under open licences.

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ and PNPM (for local dev)
- Python 3.11+ (for local dev)

### Run with Docker

```bash
cp .env.example .env
docker compose up -d
docker compose exec api alembic upgrade head
docker compose exec api python -m scripts.create_admin
docker compose exec api python -m scripts.seed
Access:

Web: http://localhost:3000

API: http://localhost:8000 (docs at /docs)

MinIO Console: http://localhost:9001 (minioadmin / minioadmin)

Local Dev (optional)
# Start infra
docker compose up -d postgres redis minio

# API
cd apps/api
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
uvicorn main:app --reload

# Web
cd apps/web
pnpm install
pnpm dev
See docs/ARCHITECTURE.md for system design.
EOF

emit .env.example <<'EOF'

Database
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=thevillage
POSTGRES_USER=village_user
POSTGRES_PASSWORD=change_me_in_production

Redis
REDIS_URL=redis://redis:6379/0

S3/MinIO
S3_ENDPOINT=http://minio:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET_UPLOADS=village-uploads
S3_REGION=us-east-1
S3_PUBLIC_BASE_URL=http://localhost:9000

JWT
JWT_SECRET=change_me_very_secret_key_minimum_32_chars_long
JWT_REFRESH_SECRET=change_me_another_very_secret_key_minimum_32
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=30

App
APP_BASE_URL=http://localhost:3000
API_BASE_URL=http://localhost:8000
CORS_ORIGINS=http://localhost:3000,http://localhost:3001

ACRCloud (Optional - stub mode if not set)
ACRCLOUD_HOST=
ACRCLOUD_ACCESS_KEY=
ACRCLOUD_ACCESS_SECRET=

Rate Limiting
RATE_LIMIT_SIGNUP_PER_DAY=10
RATE_LIMIT_INVITES_PER_USER=5
RATE_LIMIT_UPLOADS_PER_HOUR=20

Admin bootstrap
ADMIN_EMAIL=admin@thevillage.local
ADMIN_PASSWORD=change_me_admin_password
EOF

emit package.json <<'EOF'
{
"name": "the-village",
"version": "1.0.0",
"private": true,
"description": "An invite-only creative commons",
"scripts": {
"dev": "turbo dev",
"build": "turbo build",
"test": "turbo test",
"test:e2e": "turbo test:e2e",
"lint": "turbo lint",
"format": "turbo format",
"prepare": "husky install"
},
"devDependencies": {
"@commitlint/cli": "^18.4.3",
"@commitlint/config-conventional": "^18.4.3",
"husky": "^8.0.3",
"lint-staged": "^15.2.0",
"turbo": "^1.11.2"
},
"engines": {
"node": ">=18.0.0",
"pnpm": ">=8.0.0"
},
"packageManager": "pnpm@8.14.0"
}
EOF

emit pnpm-workspace.yaml <<'EOF'
packages:

'apps/*'

'packages/*'
EOF

emit turbo.json <<'EOF'
{
"$schema": "https://turbo.build/schema.json",
"globalDependencies": ["/.env.*local"],
"pipeline": {
"build": { "dependsOn": ["^build"], "outputs": [".next/", "!.next/cache/", "dist/"] },
"dev": { "cache": false, "persistent": true },
"lint": {},
"format": {},
"test": { "dependsOn": ["build"] },
"test:e2e": { "dependsOn": ["build"] }
}
}
EOF

emit .husky/pre-commit <<'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
EOF

emit .husky/_/husky.sh <<'EOF'
#!/usr/bin/env sh

Minimal shim to make pre-commit runnable without 'husky install'
if [ -z "$husky_skip_init" ]; then
readonly husky_skip_init=1
export husky_skip_init
sh -e "$0" "$@"
exit $?
fi
EOF

emit .lintstagedrc.json <<'EOF'
{
".{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
".{json,md,yml,yaml}": ["prettier --write"],
"*.py": ["black", "ruff --fix"]
}
EOF

emit commitlint.config.js <<'EOF'
module.exports = {
extends: ['@commitlint/config-conventional'],
rules: {
'type-enum': [2, 'always', [
'feat','fix','docs','style','refactor','perf','test','build','ci','chore','revert'
]]
}
}
EOF

emit docker-compose.yml <<'EOF'
version: '3.8'

services:
postgres:
image: postgres:15-alpine
environment:
POSTGRES_DB: ${POSTGRES_DB:-thevillage}
POSTGRES_USER: ${POSTGRES_USER:-village_user}
POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-change_me_in_production}
ports: ["5432:5432"]
volumes:
- postgres_data:/var/lib/postgresql/data
healthcheck:
test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-village_user} -d ${POSTGRES_DB:-thevillage}"]
interval: 10s
timeout: 5s
retries: 5

redis:
image: redis:7-alpine
ports: ["6379:6379"]
volumes:
- redis_data:/data
healthcheck:
test: ["CMD", "redis-cli", "ping"]
interval: 10s
timeout: 5s
retries: 5

minio:
image: minio/minio:latest
command: server /data --console-address ":9001"
environment:
MINIO_ROOT_USER: ${S3_ACCESS_KEY:-minioadmin}
MINIO_ROOT_PASSWORD: ${S3_SECRET_KEY:-minioadmin}
ports: ["9000:9000", "9001:9001"]
volumes:
- minio_data:/data
healthcheck:
test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
interval: 30s
timeout: 20s
retries: 3

api:
build:
context: ./apps/api
dockerfile: Dockerfile
env_file: [.env]
environment:
POSTGRES_HOST: postgres
REDIS_URL: redis://redis:6379/0
S3_ENDPOINT: http://minio:9000
ports: ["8000:8000"]
depends_on:
postgres:
condition: service_healthy
redis:
condition: service_healthy
minio:
condition: service_healthy
volumes:
- ./apps/api:/app
command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

worker:
build:
context: ./apps/api
dockerfile: Dockerfile.worker
env_file: [.env]
environment:
POSTGRES_HOST: postgres
REDIS_URL: redis://redis:6379/0
S3_ENDPOINT: http://minio:9000
depends_on:
- redis
- postgres
- minio
volumes:
- ./apps/api:/app
command: python -m worker

web:
build:
context: ./apps/web
dockerfile: Dockerfile
environment:
NEXT_PUBLIC_API_URL: http://localhost:8000
ports: ["3000:3000"]
depends_on:
- api
volumes:
- ./apps/web:/app
- /app/node_modules
- /app/.next

volumes:
postgres_data:
redis_data:
minio_data:
EOF

emit .nvmrc <<'EOF'
18.19.0
EOF

emit .python-version <<'EOF'
3.11.9
EOF

emit .pre-commit-config.yaml <<'EOF'
repos:

repo: https://github.com/psf/black
rev: 24.8.0
hooks: [{ id: black }]

repo: https://github.com/astral-sh/ruff-pre-commit
rev: v0.6.4
hooks:

id: ruff
args: [--fix]

id: ruff-format

repo: https://github.com/pre-commit/mirrors-mypy
rev: v1.11.2
hooks:

id: mypy
additional_dependencies: [pydantic==2.7.3, types-requests]
files: ^apps/api/

repo: https://github.com/gitleaks/gitleaks
rev: v8.18.4
hooks:

id: gitleaks
EOF

emit Makefile <<'EOF'
.PHONY: setup format lint typecheck test coverage build run docker-up docker-down sbom

setup:
pnpm install
pre-commit install

format:
pnpm format || true
cd apps/api && black .

lint:
pnpm lint || true
cd apps/api && ruff .

typecheck:
cd apps/api && mypy .

test:
pnpm --filter web test || true
cd apps/api && pytest -q

coverage:
cd apps/api && pytest --cov=./ --cov-report=term-missing --cov-fail-under=85

build:
pnpm build

run:
docker compose up -d

docker-up:
docker compose up -d

docker-down:
docker compose down -v

sbom:
./scripts/gen-sbom.sh
EOF

emit scripts/gen-sbom.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p sbom
if ! command -v syft >/dev/null 2>&1; then
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
fi
syft . -o cyclonedx-json > sbom/repo.cdx.json
echo "SBOM at sbom/repo.cdx.json"
EOF

────────────────────────────────────────────────────────────────────────────────
API (FastAPI)
────────────────────────────────────────────────────────────────────────────────
emit apps/api/Dockerfile <<'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends
gcc
libpq-dev
curl
ffmpeg
&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

emit apps/api/Dockerfile.worker <<'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends
gcc
libpq-dev
curl
ffmpeg
&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "-m", "worker"]
EOF

emit apps/api/requirements.txt <<'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
gunicorn==21.2.0
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
pydantic==2.5.2
pydantic-settings==2.1.0
python-jose[cryptography]==3.3.0
passlib[argon2]==1.7.4
python-multipart==0.0.6
httpx==0.25.2
redis==5.0.1
rq==1.15.1
boto3==1.34.7
Pillow==10.1.0
python-magic==0.4.27
email-validator==2.1.0
pytest==7.4.3
pytest-cov==4.1.0
pytest-asyncio==0.21.1
black==23.12.0
ruff==0.1.8
prometheus-fastapi-instrumentator==7.0.0
structlog==24.4.0
EOF

emit apps/api/pyproject.toml <<'EOF'
[tool.black]
line-length = 88
target-version = ['py311']

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "UP", "S", "B", "A", "C4", "T20"]
ignore = ["E501"]
target-version = "py311"

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = "-v --cov=. --cov-report=html --cov-report=term"
EOF

emit apps/api/init.py <<'EOF'

The Village API package
EOF

emit apps/api/main.py <<'EOF'
from contextlib import asynccontextmanager
import logging
import structlog
import uuid

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator
from starlette.middleware.base import BaseHTTPMiddleware

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
processors=[structlog.processors.TimeStamper(fmt="iso"), structlog.processors.JSONRenderer()],
)
log = structlog.get_logger()

@asynccontextmanager
async def lifespan(app: FastAPI):
log.info("startup", service="the-village-api")

# Create database tables for dev
Base.metadata.create_all(bind=engine)

# Ensure S3 bucket exists
ensure_bucket_exists()

yield
log.info("shutdown", service="the-village-api")
app = FastAPI(
title="The Village API",
description="An invite-only creative commons for sharing ideas",
version="1.0.0",
lifespan=lifespan,
)

Middleware
app.add_middleware(RequestIdMiddleware)
app.add_middleware(
CORSMiddleware,
allow_origins=settings.CORS_ORIGINS,
allow_credentials=True,
allow_methods=[""],
allow_headers=[""],
)

Metrics
Instrumentator().instrument(app).expose(app, include_in_schema=False)

Routers
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
EOF

emit apps/api/core/init.py <<'EOF'

Core module
EOF

emit apps/api/core/config.py <<'EOF'
from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
# Database
POSTGRES_HOST: str = "localhost"
POSTGRES_PORT: int = 5432
POSTGRES_DB: str = "thevillage"
POSTGRES_USER: str = "village_user"
POSTGRES_PASSWORD: str = ""

# Redis
REDIS_URL: str = "redis://localhost:6379/0"

# S3/MinIO
S3_ENDPOINT: str = "http://localhost:9000"
S3_ACCESS_KEY: str = "minioadmin"
S3_SECRET_KEY: str = "minioadmin"
S3_BUCKET_UPLOADS: str = "village-uploads"
S3_REGION: str = "us-east-1"
S3_PUBLIC_BASE_URL: str = "http://localhost:9000"

# JWT
JWT_SECRET: str = "change_me_very_secret_key"
JWT_REFRESH_SECRET: str = "change_me_refresh_secret"
JWT_ALGORITHM: str = "HS256"
JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30

# App
APP_BASE_URL: str = "http://localhost:3000"
API_BASE_URL: str = "http://localhost:8000"

# ACRCloud (Optional)
ACRCLOUD_HOST: str = ""
ACRCLOUD_ACCESS_KEY: str = ""
ACRCLOUD_ACCESS_SECRET: str = ""

# Rate Limiting
RATE_LIMIT_SIGNUP_PER_DAY: int = 10
RATE_LIMIT_INVITES_PER_USER: int = 5
RATE_LIMIT_UPLOADS_PER_HOUR: int = 20

# Admin bootstrap
ADMIN_EMAIL: str = "admin@thevillage.local"
ADMIN_PASSWORD: str = "change_me_admin_password"

@property
def DATABASE_URL(self) -> str:
    return (
        f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
        f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
    )

@property
def CORS_ORIGINS(self) -> List[str]:
    origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
    return [origin.strip() for origin in origins]

class Config:
    env_file = ".env"
    case_sensitive = True
settings = Settings()
EOF

emit apps/api/core/database.py <<'EOF'
from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

from .config import settings

engine = create_engine(settings.DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db() -> Generator:
db = SessionLocal()
try:
yield db
finally:
db.close()
EOF

emit apps/api/core/security.py <<'EOF'
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from .config import settings
from .database import get_db
from models import User
from models.session import RefreshToken

pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def verify_password(plain_password: str, hashed_password: str) -> bool:
return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
return pwd_context.hash(password)

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

token = secrets.token_urlsafe(32)
expires_at = datetime.utcnow() + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS)

refresh_token = RefreshToken(token=token, user_id=user_id, expires_at=expires_at)
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

user = db.query(User).filter(User.id == user_id).first()
if user is None:
    raise credentials_exception
if not user.is_active:
    raise HTTPException(status_code=403, detail="User account is suspended")
return user
async def get_current_admin(current_user: User = Depends(get_current_user)) -> User:
if current_user.role not in ["admin", "moderator"]:
raise HTTPException(status_code=403, detail="Not enough permissions")
return current_user
EOF

emit apps/api/core/storage.py <<'EOF'
import boto3
from botocore.client import Config

from .config import settings

def get_s3_client():
return boto3.client(
"s3",
endpoint_url=settings.S3_ENDPOINT,
aws_access_key_id=settings.S3_ACCESS_KEY,
aws_secret_access_key=settings.S3_SECRET_KEY,
config=Config(signature_version="s3v4"),
region_name=settings.S3_REGION,
)

def ensure_bucket_exists():
s3 = get_s3_client()
try:
s3.head_bucket(Bucket=settings.S3_BUCKET_UPLOADS)
except Exception:
s3.create_bucket(Bucket=settings.S3_BUCKET_UPLOADS)

def generate_presigned_upload_url(file_key: str, content_type: str | None = None, expires_in: int = 3600) -> dict:
s3 = get_s3_client()
fields = {}
conditions = [["content-length-range", 0, 10485760]]
if content_type:
fields["Content-Type"] = content_type
conditions.append({"Content-Type": content_type})
post = s3.generate_presigned_post(
Bucket=settings.S3_BUCKET_UPLOADS, Key=file_key, Fields=fields or None, Conditions=conditions, ExpiresIn=expires_in
)
return post

def generate_file_key(user_id: str, filename: str, folder: str = "uploads") -> str:
import hashlib
from datetime import datetime

ext = filename.rsplit(".", 1)[-1] if "." in filename else ""
file_hash = hashlib.sha256(f"{user_id}-{filename}-{datetime.utcnow().isoformat()}".encode()).hexdigest()[:12]
base = f"{folder}/{user_id}/{file_hash}"
return f"{base}.{ext}" if ext else base
def get_public_url(file_key: str) -> str:
return f"{settings.S3_PUBLIC_BASE_URL}/{settings.S3_BUCKET_UPLOADS}/{file_key}"

def delete_file(file_key: str):
s3 = get_s3_client()
s3.delete_object(Bucket=settings.S3_BUCKET_UPLOADS, Key=file_key)
EOF

emit apps/api/core/acrcloud.py <<'EOF'
from typing import Optional, Dict
from .config import settings

class ACRCloudClient:
def init(self):
self.host = settings.ACRCLOUD_HOST
self.access_key = settings.ACRCLOUD_ACCESS_KEY
self.access_secret = settings.ACRCLOUD_ACCESS_SECRET
self.enabled = bool(self.host and self.access_key and self.access_secret)

def scan_audio(self, audio_data: bytes) -> Optional[Dict]:
    """
    Stubbed: returns None unless enabled. MVP uses mock/no-op.
    """
    if not self.enabled:
        return None
    # TODO: real integration
    return {"status": "ok", "confidence": 0.0}
acrcloud = ACRCloudClient()
EOF

emit apps/api/core/queue.py <<'EOF'
from rq import Queue
from redis import Redis
from .config import settings

redis_conn = Redis.from_url(settings.REDIS_URL)
queue = Queue(connection=redis_conn)

def enqueue_job(func, *args, **kwargs):
"""Enqueue a job to be processed by workers"""
return queue.enqueue(func, *args, **kwargs)
EOF

Models
emit apps/api/models/init.py <<'EOF'
from .user import User
from .invite import Invite
from .idea import Idea, Stem
from .playlist import Playlist, PlaylistItem
from .mood import MoodPost
from .report import Report
from .takedown import Takedown
from .audit import AuditEvent
from .session import RefreshToken

all = [
"User",
"Invite",
"Idea",
"Stem",
"Playlist",
"PlaylistItem",
"MoodPost",
"Report",
"Takedown",
"AuditEvent",
"RefreshToken",
]
EOF

emit apps/api/models/user.py <<'EOF'
from sqlalchemy import Column, String, DateTime, Boolean, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
import enum

from core.database import Base

class UserRole(str, enum.Enum):
USER = "user"
MODERATOR = "moderator"
ADMIN = "admin"

class User(Base):
tablename = "users"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
email = Column(String, unique=True, nullable=False, index=True)
password_hash = Column(String, nullable=False)
handle = Column(String, unique=True, nullable=False, index=True)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
role = Column(SQLEnum(UserRole), default=UserRole.USER, nullable=False)
is_active = Column(Boolean, default=True, nullable=False)
age_confirmed_at = Column(DateTime, nullable=True)
EOF

emit apps/api/models/invite.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class Invite(Base):
tablename = "invites"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
token = Column(String, unique=True, nullable=False, index=True)
invited_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
expires_at = Column(DateTime, nullable=False)
used_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
used_at = Column(DateTime, nullable=True)

inviter = relationship("User", foreign_keys=[invited_by], backref="sent_invites")
invitee = relationship("User", foreign_keys=[used_by], backref="received_invite")
EOF

emit apps/api/models/idea.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Integer, Enum as SQLEnum, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from core.database import Base

class IdeaType(str, enum.Enum):
TEXT = "text"
IMAGE = "image"
AUDIO = "audio"
VIDEO = "video"

class License(str, enum.Enum):
CC0 = "CC0"
CC_BY_4_0 = "CC_BY_4_0"
CC_BY_SA_4_0 = "CC_BY_SA_4_0"

class Visibility(str, enum.Enum):
MEMBERS = "members"
PRIVATE = "private"

class IdeaStatus(str, enum.Enum):
PUBLISHED = "published"
HELD = "held"
REMOVED = "removed"

class Idea(Base):
tablename = "ideas"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
author_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
type = Column(SQLEnum(IdeaType), nullable=False)
title = Column(String(255), nullable=False, index=True)
text = Column(Text, nullable=True)
media_url = Column(String, nullable=True)
thumb_url = Column(String, nullable=True)
duration_s = Column(Integer, nullable=True)
waveform_json_url = Column(String, nullable=True)
license = Column(SQLEnum(License), nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
parent_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=True, index=True)
provenance_json = Column(JSON, nullable=True)
visibility = Column(SQLEnum(Visibility), default=Visibility.MEMBERS, nullable=False)
status = Column(SQLEnum(IdeaStatus), default=IdeaStatus.PUBLISHED, nullable=False)

author = relationship("User", backref="ideas")
parent = relationship("Idea", remote_side=[id], backref="forks")
stems = relationship("Stem", back_populates="idea", cascade="all, delete-orphan")
class Stem(Base):
tablename = "stems"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
idea_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=False)
file_url = Column(String, nullable=False)
license = Column(SQLEnum(License), nullable=False)

idea = relationship("Idea", back_populates="stems")
EOF

emit apps/api/models/playlist.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class Playlist(Base):
tablename = "playlists"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
title = Column(String(255), nullable=False)
description = Column(Text, nullable=True)
is_public = Column(Boolean, default=False, nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

owner = relationship("User", backref="playlists")
items = relationship("PlaylistItem", back_populates="playlist", cascade="all, delete-orphan", order_by="PlaylistItem.position")
class PlaylistItem(Base):
tablename = "playlist_items"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
playlist_id = Column(UUID(as_uuid=True), ForeignKey("playlists.id"), nullable=False)
idea_id = Column(UUID(as_uuid=True), ForeignKey("ideas.id"), nullable=False)
position = Column(Integer, nullable=False)

playlist = relationship("Playlist", back_populates="items")
idea = relationship("Idea")
EOF

emit apps/api/models/mood.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class MoodPost(Base):
tablename = "mood_posts"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
author_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
text = Column(Text, nullable=False)
media_url = Column(String, nullable=True)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
reply_to = Column(UUID(as_uuid=True), ForeignKey("mood_posts.id"), nullable=True)

author = relationship("User", backref="mood_posts")
parent = relationship("MoodPost", remote_side=[id], backref="replies")
EOF

emit apps/api/models/report.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from core.database import Base

class ReportStatus(str, enum.Enum):
PENDING = "pending"
REVIEWED = "reviewed"
ACTIONED = "actioned"
DISMISSED = "dismissed"

class Report(Base):
tablename = "reports"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
reporter_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
target_type = Column(String, nullable=False)  # 'idea', 'user', 'mood_post', etc.
target_id = Column(UUID(as_uuid=True), nullable=False)
reason = Column(Text, nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
status = Column(SQLEnum(ReportStatus), default=ReportStatus.PENDING, nullable=False)
action_taken = Column(Text, nullable=True)

reporter = relationship("User", backref="reports")
EOF

emit apps/api/models/takedown.py <<'EOF'
from sqlalchemy import Column, String, DateTime, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
import enum

from core.database import Base

class TakedownStatus(str, enum.Enum):
RECEIVED = "received"
REVIEWING = "reviewing"
ACTIONED = "actioned"
REJECTED = "rejected"

class Takedown(Base):
tablename = "takedowns"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
claimant_name = Column(String, nullable=False)
claimant_email = Column(String, nullable=False)
basis = Column(Text, nullable=False)
target_type = Column(String, nullable=False)
target_id = Column(UUID(as_uuid=True), nullable=False)
received_at = Column(DateTime, default=datetime.utcnow, nullable=False)
action = Column(Text, nullable=True)
status = Column(SQLEnum(TakedownStatus), default=TakedownStatus.RECEIVED, nullable=False)
notes = Column(Text, nullable=True)
EOF

emit apps/api/models/audit.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class AuditEvent(Base):
tablename = "audit_events"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
actor_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
action = Column(String, nullable=False)
payload_json = Column(JSON, nullable=True)
ts = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)

actor = relationship("User")
EOF

emit apps/api/models/session.py <<'EOF'
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from core.database import Base

class RefreshToken(Base):
tablename = "refresh_tokens"

id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
token = Column(String, unique=True, nullable=False, index=True)
user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
expires_at = Column(DateTime, nullable=False)
created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

user = relationship("User", backref="refresh_tokens")
EOF

Schemas
emit apps/api/schemas/init.py <<'EOF'
from .auth import *
from .invite import *
from .idea import *
from .playlist import *
from .mood import *
from .report import *
from .upload import *
EOF

emit apps/api/schemas/auth.py <<'EOF'
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
import uuid

class UserRegister(BaseModel):
email: EmailStr
handle: str = Field(min_length=2, max_length=32)
password: str = Field(min_length=8)
age_confirmed: bool
invite_token: Optional[str] = None

class UserLogin(BaseModel):
email: EmailStr
password: str

class UserResponse(BaseModel):
id: uuid.UUID
email: EmailStr
handle: str
created_at: datetime
role: str
is_active: bool

class Config:
    from_attributes = True
class Token(BaseModel):
access_token: str
refresh_token: str
token_type: str = "bearer"

class RefreshTokenRequest(BaseModel):
refresh_token: str
EOF

emit apps/api/schemas/invite.py <<'EOF'
from pydantic import BaseModel
from datetime import datetime
import uuid
from typing import Optional

class InviteCreate(BaseModel):
pass

class InviteResponse(BaseModel):
id: uuid.UUID
token: str
invited_by: uuid.UUID
expires_at: datetime
used_by: Optional[uuid.UUID] = None
used_at: Optional[datetime] = None

class Config:
    from_attributes = True
class InviteValidateResponse(BaseModel):
ok: bool
token: str
EOF

emit apps/api/schemas/idea.py <<'EOF'
from pydantic import BaseModel
from typing import Optional, List, Any
from datetime import datetime
import uuid

class IdeaCreate(BaseModel):
type: str # "text" | "image" | "audio" | "video"
title: str
text: Optional[str] = None
media_url: Optional[str] = None
license: str # "CC0" | "CC_BY_4_0" | "CC_BY_SA_4_0"
parent_id: Optional[uuid.UUID] = None
visibility: str = "members" # "members" | "private"

class IdeaUpdate(BaseModel):
title: Optional[str] = None
text: Optional[str] = None
visibility: Optional[str] = None

class IdeaFork(BaseModel):
title: Optional[str] = None
text: Optional[str] = None
license: str
visibility: Optional[str] = None

class StemResponse(BaseModel):
id: uuid.UUID
file_url: str
license: str

class Config:
    from_attributes = True
class IdeaResponse(BaseModel):
id: uuid.UUID
author_id: uuid.UUID
type: str
title: str
text: Optional[str] = None
media_url: Optional[str] = None
thumb_url: Optional[str] = None
duration_s: Optional[int] = None
waveform_json_url: Optional[str] = None
license: str
created_at: datetime
parent_id: Optional[uuid.UUID] = None
provenance_json: Optional[Any] = None
visibility: str
status: str
stems: List[StemResponse] = []

class Config:
    from_attributes = True
class ProvenanceExport(BaseModel):
id: str
title: str
author: str
license: str
created_at: str
chain: list
EOF

emit apps/api/schemas/playlist.py <<'EOF'
from pydantic import BaseModel
from typing import Optional, List
import uuid
from datetime import datetime

class PlaylistCreate(BaseModel):
title: str
description: Optional[str] = None
is_public: bool = False

class PlaylistUpdate(BaseModel):
title: Optional[str] = None
description: Optional[str] = None
is_public: Optional[bool] = None

class PlaylistItemAdd(BaseModel):
idea_id: uuid.UUID
position: Optional[int] = None

class PlaylistItemResponse(BaseModel):
id: uuid.UUID
playlist_id: uuid.UUID
idea_id: uuid.UUID
position: int

class Config:
    from_attributes = True
class PlaylistResponse(BaseModel):
id: uuid.UUID
owner_id: uuid.UUID
title: str
description: Optional[str] = None
is_public: bool
created_at: datetime
items: List[PlaylistItemResponse] = []

class Config:
    from_attributes = True
EOF

emit apps/api/schemas/mood.py <<'EOF'
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid

class MoodCreate(BaseModel):
text: str
media_url: Optional[str] = None
reply_to: Optional[uuid.UUID] = None

class MoodResponse(BaseModel):
id: uuid.UUID
author_id: uuid.UUID
text: str
media_url: Optional[str] = None
created_at: datetime
reply_to: Optional[uuid.UUID] = None

class Config:
    from_attributes = True
EOF

emit apps/api/schemas/report.py <<'EOF'
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid

class ReportCreate(BaseModel):
target_type: str
target_id: uuid.UUID
reason: str

class ReportResponse(BaseModel):
id: uuid.UUID
reporter_id: uuid.UUID
target_type: str
target_id: uuid.UUID
reason: str
created_at: datetime
status: str
action_taken: Optional[str] = None

class Config:
    from_attributes = True
EOF

emit apps/api/schemas/upload.py <<'EOF'
from pydantic import BaseModel
from typing import Dict

class PresignRequest(BaseModel):
filename: str

class PresignResponse(BaseModel):
url: str
fields: Dict[str, str]
file_key: str

class CompleteUpload(BaseModel):
file_key: str | None = None
type: str | None = None
object_name: str | None = None
content_type: str | None = None
EOF

API routes
emit apps/api/api/init.py <<'EOF'

API module
EOF

emit apps/api/api/auth.py <<'EOF'
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
EOF

emit apps/api/api/invites.py <<'EOF'
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
EOF

emit apps/api/api/ideas.py <<'EOF'
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
from schemas.idea import IdeaCreate, IdeaUpdate, IdeaResponse, IdeaFork, ProvenanceExport
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
query = db.query(Idea).filter(Idea.status == IdeaStatus.PUBLISHED, Idea.visibility == Visibility.MEMBERS)
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
def get_idea(idea_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
idea = db.query(Idea).filter(Idea.id == idea_id).first()
if not idea:
raise HTTPException(status_code=404, detail="Idea not found")
if idea.visibility == Visibility.PRIVATE and idea.author_id != current_user.id:
raise HTTPException(status_code=403, detail="Access denied")
return idea

@router.post("/", response_model=IdeaResponse)
def create_idea(idea_data: IdeaCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
if idea_data.parent_id:
parent = db.query(Idea).filter(Idea.id == idea_data.parent_id).first()
if parent and parent.license == License.CC_BY_SA_4_0 and idea_data.license != "CC_BY_SA_4_0":
raise HTTPException(status_code=400, detail="Share-alike license must be preserved in derivatives")

idea = Idea(
    author_id=current_user.id,
    type=idea_data.type,
    title=idea_data.title,
    text=idea_data.text,
    media_url=idea_data.media_url,
    license=idea_data.license,
    parent_id=idea_data.parent_id,
    visibility=idea_data.visibility,
    status=IdeaStatus.HELD if idea_data.type == "audio" and idea_data.media_url else IdeaStatus.PUBLISHED,
)

if idea_data.parent_id:
    parent = db.query(Idea).filter(Idea.id == idea_data.parent_id).first()
    if parent:
        idea.provenance_json = (parent.provenance_json or []) + [
            {"id": str(parent.id), "title": parent.title, "author": parent.author.handle, "license": parent.license}
        ]

db.add(idea)
db.commit()
db.refresh(idea)

if idea.type == "audio" and idea.media_url:
    enqueue_job(process_audio_upload, str(idea.id))

audit = AuditEvent(actor_id=current_user.id, action="idea_created", payload_json={"idea_id": str(idea.id)})
db.add(audit)
db.commit()
return idea
@router.post("/{idea_id}/fork", response_model=IdeaResponse)
def fork_idea(idea_id: str, fork_data: IdeaFork, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
parent = db.query(Idea).filter(Idea.id == idea_id).first()
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
    {"id": str(parent.id), "title": parent.title, "author": parent.author.handle, "license": parent.license}
]

db.add(fork)
db.commit()
db.refresh(fork)
return fork
@router.patch("/{idea_id}", response_model=IdeaResponse)
def update_idea(idea_id: str, idea_update: IdeaUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
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
def delete_idea(idea_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
idea = db.query(Idea).filter(Idea.id == idea_id).first()
if not idea:
raise HTTPException(status_code=404, detail="Idea not found")
if idea.author_id != current_user.id and current_user.role != "admin":
raise HTTPException(status_code=403, detail="Not authorized to delete this idea")
idea.status = IdeaStatus.REMOVED
db.commit()
return {"message": "Idea removed"}

@router.get("/{idea_id}/provenance", response_model=ProvenanceExport)
def get_provenance(idea_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
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
EOF

emit apps/api/api/uploads.py <<'EOF'
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import mimetypes

from core.database import get_db
from core.security import get_current_user
from core.storage import generate_presigned_upload_url, generate_file_key
from models import User
from schemas.upload import PresignRequest, PresignResponse, CompleteUpload

router = APIRouter()

ALLOWED = {
"image": ["image/jpeg", "image/png", "image/gif", "image/webp"],
"audio": ["audio/mpeg", "audio/wav", "audio/ogg", "audio/webm"],
"video": ["video/mp4", "video/webm", "video/ogg"],
}

def _classify_mime(filename: str) -> tuple[str, str]:
mime, _ = mimetypes.guess_type(filename)
for kind, mimes in ALLOWED.items():
if mime in mimes:
return kind, mime or "application/octet-stream"
raise HTTPException(status_code=400, detail="File type not allowed")

@router.get("/presign", response_model=PresignResponse)
def presign_get(filename: str = Query(...), current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
kind, mime = _classify_mime(filename)
file_key = generate_file_key(str(current_user.id), filename, folder=f"{kind}s")
presigned = generate_presigned_upload_url(file_key, content_type=mime)
return {"url": presigned["url"], "fields": presigned["fields"], "file_key": file_key}

@router.post("/presign", response_model=PresignResponse)
def presign_post(req: PresignRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
return presign_get(filename=req.filename, current_user=current_user, db=db)

@router.post("/complete")
def complete_upload(data: CompleteUpload, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
# MVP acknowledgement
return {"message": "Upload recorded"}
EOF

emit apps/api/api/playlists.py <<'EOF'
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
EOF

emit apps/api/api/mood.py <<'EOF'
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from core.database import get_db
from core.security import get_current_user
from models import MoodPost, User
from schemas.mood import MoodCreate, MoodResponse

router = APIRouter()

@router.get("/", response_model=List[MoodResponse])
def list_mood(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
posts = db.query(MoodPost).order_by(MoodPost.created_at.desc()).limit(100).all()
return posts

@router.post("/", response_model=MoodResponse)
def create_mood(data: MoodCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
post = MoodPost(author_id=current_user.id, text=data.text, media_url=data.media_url, reply_to=data.reply_to)
db.add(post)
db.commit()
db.refresh(post)
return post
EOF

emit apps/api/api/reports.py <<'EOF'
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
EOF

emit apps/api/api/moderation.py <<'EOF'
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
EOF

emit apps/api/api/legal.py <<'EOF'
from fastapi import APIRouter

router = APIRouter()

docs = {
"terms": "# Terms\nSee docs/TERMS.md in the repo.",
"privacy": "# Privacy\nSee docs/PRIVACY.md.",
"charter": "# Village Charter\nShare generously. Credit upstream.",
"notice-takedown": "# Notice & Takedown\nEmail takedown@thevillage.local with details.",
"illegal-content": "# Illegal Content Policy\nWe remove illegal content swiftly.",
"licenses": "# Licences\nCC0, CC BY 4.0, CC BY-SA 4.0",
}

@router.get("/{slug}")
def get_legal(slug: str):
return {"slug": slug, "markdown": docs.get(slug, "# Not found")}
EOF

Workers & scripts
emit apps/api/workers/media.py <<'EOF'
from sqlalchemy.orm import Session
from core.database import SessionLocal
from models import Idea
from models.idea import IdeaStatus

def process_audio_upload(idea_id: str):
"""MVP: mark audio ideas as published (stub for ffmpeg+ACR). Extend later."""
db: Session = SessionLocal()
try:
idea = db.query(Idea).filter(Idea.id == idea_id).first()
if not idea:
return
idea.status = IdeaStatus.PUBLISHED
db.commit()
finally:
db.close()
EOF

emit apps/api/worker.py <<'EOF'
from rq import Worker
from core.queue import redis_conn, queue

if name == "main":
w = Worker([queue], connection=redis_conn)
w.work()
EOF

emit apps/api/scripts/create_admin.py <<'EOF'
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

if name == "main":
main()
EOF

emit apps/api/scripts/seed.py <<'EOF'
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
        inv = Invite(token=secrets.token_urlsafe(12), invited_by=u.id, expires_at=datetime.utcnow() + timedelta(days=14))
        db.add(inv)
    db.commit()

    # Ideas
    samples = [
        ("Open Drum Loop (90bpm)", "audio", "CC_BY_4_0", None),
        ("Lyric seed: 'It takes a village'", "text", "CC0", "A chorus hook: It takes a village, hold me up tonight..."),
        ("Cover artwork mood", "image", "CC0", None),
    ]
    for title, t, lic, text in samples:
        idea = Idea(
            author_id=users[0].id, type=t, title=title, text=text, license=lic, status="published" if t != "audio" else "held"
        )
        db.add(idea)
    db.commit()
    print("Seed complete.")
finally:
    db.close()
if name == "main":
main()
EOF

Alembic
emit apps/api/alembic.ini <<'EOF'
[alembic]
script_location = alembic
sqlalchemy.url = driver://placeholder

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
EOF

emit apps/api/alembic/env.py <<'EOF'
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context

from core.config import settings
from core.database import Base
import models # noqa: F401

config = context.config
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)

if config.config_file_name is not None:
fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline():
context.configure(
url=settings.DATABASE_URL,
target_metadata=target_metadata,
literal_binds=True,
dialect_opts={"paramstyle": "named"},
)
with context.begin_transaction():
context.run_migrations()

def run_migrations_online():
connectable = engine_from_config(
config.get_section(config.config_ini_section),
prefix="sqlalchemy.",
poolclass=pool.NullPool,
url=settings.DATABASE_URL,
)
with connectable.connect() as connection:
context.configure(connection=connection, target_metadata=target_metadata)
with context.begin_transaction():
context.run_migrations()

if context.is_offline_mode():
run_migrations_offline()
else:
run_migrations_online()
EOF

emit apps/api/alembic/versions/0001_init.py <<'EOF'
"""init

Revision ID: 0001
Revises:
Create Date: 2025-01-01 12:00:00.000000
"""
from alembic import op
import sqlalchemy as sa # noqa: F401

revision identifiers
revision = '0001'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
# Tables are created by Base.metadata.create_all in main.py (dev)
pass

def downgrade() -> None:
pass
EOF

API Tests
emit apps/api/tests/conftest.py <<'EOF'
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from main import app
from core.database import Base, get_db

TEST_DB = "sqlite:///./test.db"
engine = create_engine(TEST_DB, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="session", autouse=True)
def setup_db():
Base.metadata.drop_all(bind=engine)
Base.metadata.create_all(bind=engine)
yield
Base.metadata.drop_all(bind=engine)

def override_get_db():
db = TestingSessionLocal()
try:
yield db
finally:
db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture()
def client():
return TestClient(app)
EOF

emit apps/api/tests/test_auth_invite.py <<'EOF'
def test_register_login_flow(client):
# register
r = client.post(
"/auth/register",
json={"email": "u1@example.com", "handle": "u1", "password": "password123", "age_confirmed": True},
)
assert r.status_code == 200
# login
r = client.post("/auth/login", json={"email": "u1@example.com", "password": "password123"})
assert r.status_code == 200
tok = r.json()["access_token"]
assert tok

def test_invite_create_and_validate(client):
# seed user
client.post(
"/auth/register",
json={"email": "u2@example.com", "handle": "u2", "password": "password123", "age_confirmed": True},
)
tok = client.post("/auth/login", json={"email": "u2@example.com", "password": "password123"}).json()["access_token"]
# create invite
r = client.post("/invites/", headers={"Authorization": f"Bearer {tok}"})
assert r.status_code == 200
token = r.json()["token"]
# validate invite
r = client.post(f"/invites/join/{token}")
assert r.status_code == 200
assert r.json()["ok"] is True
EOF

emit apps/api/tests/test_ideas_licenses.py <<'EOF'
def auth(client, email="u3@example.com", handle="u3"):
client.post("/auth/register", json={"email": email, "handle": handle, "password": "password123", "age_confirmed": True})
tok = client.post("/auth/login", json={"email": email, "password": "password123"}).json()["access_token"]
return {"Authorization": f"Bearer {tok}"}

def test_create_and_fork_with_by_sa_propagation(client):
hdrs = auth(client)
# Parent BY-SA
p = client.post(
"/ideas/",
json={"type": "text", "title": "BYSA parent", "text": "t", "license": "CC_BY_SA_4_0", "visibility": "members"},
headers=hdrs,
).json()

# Try to fork with CC BY (should be forced to BY-SA)
f = client.post(f"/ideas/{p['id']}/fork", json={"license": "CC_BY_4_0", "title": "child"}, headers=hdrs).json()
assert f["license"] == "CC_BY_SA_4_0"
EOF

────────────────────────────────────────────────────────────────────────────────
Web (Next.js 14 App Router)
────────────────────────────────────────────────────────────────────────────────
emit apps/web/package.json <<'EOF'
{
"name": "web",
"version": "1.0.0",
"private": true,
"scripts": {
"dev": "next dev -p 3000",
"build": "next build",
"start": "next start -p 3000",
"lint": "next lint",
"test": "vitest run",
"test:e2e": "playwright test"
},
"dependencies": {
"@radix-ui/react-label": "^2.0.2",
"@radix-ui/react-slot": "^1.0.2",
"class-variance-authority": "^0.7.0",
"clsx": "^2.1.0",
"next": "14.2.4",
"react": "18.2.0",
"react-dom": "18.2.0",
"tailwind-merge": "^2.2.1",
"zod": "^3.23.8"
},
"devDependencies": {
"@playwright/test": "^1.45.3",
"@types/node": "^20.14.2",
"@types/react": "^18.3.3",
"@types/react-dom": "^18.3.0",
"autoprefixer": "^10.4.20",
"eslint": "^8.57.0",
"eslint-config-next": "^14.2.4",
"postcss": "^8.4.41",
"tailwindcss": "^3.4.10",
"typescript": "^5.5.4",
"vitest": "^2.0.4"
}
}
EOF

emit apps/web/next.config.js <<'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
reactStrictMode: true,
experimental: { appDir: true }
}
module.exports = nextConfig
EOF

emit apps/web/tailwind.config.ts <<'EOF'
import type { Config } from "tailwindcss"

const config: Config = {
content: ["./src/app//*.{ts,tsx}", "./src/components//*.{ts,tsx}"],
theme: { extend: {} },
plugins: []
}
export default config
EOF

emit apps/web/postcss.config.js <<'EOF'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } }
EOF

emit apps/web/tsconfig.json <<'EOF'
{
"compilerOptions": {
"target": "ES2022",
"lib": ["DOM", "ES2022"],
"jsx": "preserve",
"module": "ESNext",
"moduleResolution": "Bundler",
"resolveJsonModule": true,
"strict": true,
"allowJs": false,
"noEmit": true,
"esModuleInterop": true,
"baseUrl": ".",
"paths": { "@/": ["src/"] },
"types": ["@types/node"]
},
"include": ["next-env.d.ts", "src//*.ts", "src//*.tsx"],
"exclude": ["node_modules"]
}
EOF

emit apps/web/.eslintrc.json <<'EOF'
{
"extends": ["next/core-web-vitals"],
"rules": { "@next/next/no-img-element": "off" }
}
EOF

emit apps/web/playwright.config.ts <<'EOF'
import { defineConfig, devices } from '@playwright/test';
export default defineConfig({
testDir: './tests-e2e',
retries: 0,
use: { baseURL: 'http://localhost:3000', trace: 'retain-on-failure' },
projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }]
});
EOF

emit apps/web/Dockerfile <<'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN npm i -g pnpm && pnpm install --frozen-lockfile || pnpm install
COPY . .
RUN pnpm build
EXPOSE 3000
CMD ["pnpm","start"]
EOF

emit apps/web/src/app/globals.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root { color-scheme: light; }
body { @apply bg-white text-gray-900; }
EOF

emit apps/web/src/app/layout.tsx <<'EOF'
import './globals.css'
import Link from 'next/link'

export default function RootLayout({ children }: { children: React.ReactNode }) {
return (
<html lang="en">
<body>
<header className="border-b">
<div className="container mx-auto flex items-center justify-between p-4">
<Link href="/feed" className="font-bold">The Village</Link>
<nav className="text-sm space-x-4">
<Link href="/ideas/new">Share</Link>
<Link href="/mood">Mood</Link>
<Link href="/playlists">Playlists</Link>
</nav>
</div>
</header>
<main>{children}</main>
</body>
</html>
)
}
EOF

emit apps/web/src/app/page.tsx <<'EOF'
import { redirect } from 'next/navigation'
export default function Home() { redirect('/feed') }
EOF

emit apps/web/src/lib/utils.ts <<'EOF'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
return twMerge(clsx(inputs))
}
EOF

emit apps/web/src/lib/api.ts <<'EOF'
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export interface LoginData { email: string; password: string }
export interface RegisterData {
email: string; handle: string; password: string; age_confirmed: boolean; invite_token?: string
}
export interface TokenResponse { access_token: string; refresh_token: string; token_type: string }

class ApiClient {
private token: string | null = null

setToken(token: string) {
this.token = token
if (typeof window !== 'undefined') localStorage.setItem('token', token)
}

getToken(): string | null {
if (typeof window !== 'undefined' && !this.token) this.token = localStorage.getItem('token')
return this.token
}

clearToken() {
this.token = null
if (typeof window !== 'undefined') {
localStorage.removeItem('token')
localStorage.removeItem('refresh_token')
}
}

async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
const url = ${API_URL}${endpoint}
const headers: HeadersInit = { 'Content-Type': 'application/json', ...(options.headers || {}) }
const tok = this.getToken()
if (tok) headers['Authorization'] = Bearer ${tok}
const response = await fetch(url, { ...options, headers })
if (!response.ok) {
if (response.status === 401) { this.clearToken(); if (typeof window !== 'undefined') window.location.href = '/auth/login' }
throw new Error(API Error: ${response.statusText})
}
return response.json()
}

async login(data: LoginData): Promise<TokenResponse> {
const res = await this.request<TokenResponse>('/auth/login', { method: 'POST', body: JSON.stringify(data) })
this.setToken(res.access_token)
if (typeof window !== 'undefined') localStorage.setItem('refresh_token', res.refresh_token)
return res
}

async register(data: RegisterData): Promise<any> {
return this.request('/auth/register', { method: 'POST', body: JSON.stringify(data) })
}

async getMe(): Promise<any> { return this.request('/auth/me') }

async getIdeas(params?: any): Promise<any> {
const qs = params ? ?${new URLSearchParams(params)} : ''
return this.request(/ideas${qs})
}

async createIdea(data: any): Promise<any> {
return this.request('/ideas', { method: 'POST', body: JSON.stringify(data) })
}

async forkIdea(ideaId: string): Promise<any> {
return this.request(/ideas/${ideaId}/fork, { method: 'POST', body: JSON.stringify({ license: 'CC_BY_4_0' }) })
}

async createInvite(): Promise<any> { return this.request('/invites', { method: 'POST' }) }
async validateInvite(token: string): Promise<any> { return this.request(/invites/join/${token}, { method: 'POST' }) }
}
export const api = new ApiClient()
EOF

emit apps/web/src/components/ui/button.tsx <<'EOF'
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cn } from "@/lib/utils"

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
({ className, asChild = false, ...props }, ref) => {
const Comp = asChild ? Slot : "button"
return (
<Comp
className={cn(
"inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium",
"ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2",
"focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
"h-10 px-4 py-2 bg-black text-white hover:bg-black/90",
className
)}
ref={ref}
{...props}
/>
)
}
)
Button.displayName = "Button"

export { Button }
EOF

emit apps/web/src/components/ui/input.tsx <<'EOF'
import * as React from "react"
import { cn } from "@/lib/utils"

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {}

const Input = React.forwardRef<HTMLInputElement, InputProps>(({ className, type, ...props }, ref) => {
return (
<input
type={type}
className={cn(
"flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm",
"ring-offset-background placeholder:text-muted-foreground",
"focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
"disabled:cursor-not-allowed disabled:opacity-50",
className
)}
ref={ref}
{...props}
/>
)
})
Input.displayName = "Input"

export { Input }
EOF

emit apps/web/src/components/ui/label.tsx <<'EOF'
"use client"

import * as React from "react"
import * as LabelPrimitive from "@radix-ui/react-label"
import { cn } from "@/lib/utils"

const Label = React.forwardRef<
React.ElementRef<typeof LabelPrimitive.Root>,
React.ComponentPropsWithoutRef<typeof LabelPrimitive.Root>

(({ className, ...props }, ref) => (
<LabelPrimitive.Root ref={ref} className={cn("text-sm font-medium leading-none", className)} {...props} />
))
Label.displayName = LabelPrimitive.Root.displayName

export { Label }
EOF

emit apps/web/src/app/auth/login/page.tsx <<'EOF'
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { api } from '@/lib/api'

export default function LoginPage() {
const router = useRouter()
const [email, setEmail] = useState('')
const [password, setPassword] = useState('')
const [error, setError] = useState('')
const [loading, setLoading] = useState(false)

const handleSubmit = async (e: React.FormEvent) => {
e.preventDefault()
setError('')
setLoading(true)
try {
await api.login({ email, password })
router.push('/feed')
} catch {
setError('Invalid email or password')
} finally {
setLoading(false)
}
}

return (
<div className="flex min-h-screen items-center justify-center">
<div className="w-full max-w-md space-y-8 p-8">
<div className="text-center">
<h1 className="text-2xl font-bold">Welcome back</h1>
<p className="text-muted-foreground mt-2">Sign in to your Village account</p>
</div>

    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
      </div>

      <div>
        <Label htmlFor="password">Password</Label>
        <Input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
      </div>

      {error && <div className="text-sm text-red-600">{error}</div>}

      <Button type="submit" className="w-full" disabled={loading}>
        {loading ? 'Signing in...' : 'Sign in'}
      </Button>
    </form>

    <div className="text-center text-sm">
      <span className="text-muted-foreground">Don't have an account? </span>
      <Link href="/invite" className="text-blue-600 underline">Join with invite</Link>
    </div>
  </div>
</div>
)
}
EOF

emit apps/web/src/app/auth/register/page.tsx <<'EOF'
'use client'

import { useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { api } from '@/lib/api'

export default function RegisterPage() {
const router = useRouter()
const searchParams = useSearchParams()
const inviteToken = searchParams.get('token')

const [email, setEmail] = useState('')
const [handle, setHandle] = useState('')
const [password, setPassword] = useState('')
const [ageConfirmed, setAgeConfirmed] = useState(false)
const [error, setError] = useState('')
const [loading, setLoading] = useState(false)

const handleSubmit = async (e: React.FormEvent) => {
e.preventDefault()
setError('')
setLoading(true)

if (!ageConfirmed) {
  setError('You must be 18 or older to use The Village')
  setLoading(false)
  return
}

try {
  await api.register({ email, handle, password, age_confirmed: ageConfirmed, invite_token: inviteToken || undefined })
  await api.login({ email, password })
  router.push('/feed')
} catch (err: any) {
  setError(err.message || 'Registration failed')
} finally {
  setLoading(false)
}
}

return (
<div className="flex min-h-screen items-center justify-center">
<div className="w-full max-w-md space-y-8 p-8">
<div className="text-center">
<h1 className="text-2xl font-bold">Join The Village</h1>
<p className="text-muted-foreground mt-2">Create your account to start sharing</p>
</div>

    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
      </div>

      <div>
        <Label htmlFor="handle">Handle</Label>
        <Input id="handle" value={handle} onChange={(e) => setHandle(e.target.value)} placeholder="@yourhandle" required />
      </div>

      <div>
        <Label htmlFor="password">Password</Label>
        <Input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
      </div>

      <div className="flex items-center space-x-2">
        <input type="checkbox" id="age" checked={ageConfirmed} onChange={(e) => setAgeConfirmed(e.target.checked)} className="rounded border-gray-300" />
        <Label htmlFor="age" className="text-sm">I confirm that I am 18 years or older</Label>
      </div>

      {error && <div className="text-sm text-red-600">{error}</div>}
      <Button type="submit" className="w-full" disabled={loading}>{loading ? 'Creating account...' : 'Create account'}</Button>
    </form>
  </div>
</div>
)
}
EOF

emit apps/web/src/app/invite/[token]/page.tsx <<'EOF'
'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { api } from '@/lib/api'

export default function InvitePage({ params }: { params: { token: string } }) {
const router = useRouter()
const [validating, setValidating] = useState(true)
const [valid, setValid] = useState(false)
const [error, setError] = useState('')

useEffect(() => { validateInvite() }, [])

const validateInvite = async () => {
try {
await api.validateInvite(params.token)
setValid(true)
} catch {
setError('This invite is invalid or has expired')
} finally {
setValidating(false)
}
}

if (validating) {
return <div className="flex min-h-screen items-center justify-center"><p>Validating invite...</p></div>
}

if (!valid) {
return (
<div className="flex min-h-screen items-center justify-center">
<div className="text-center space-y-4">
<h1 className="text-2xl font-bold">Invalid Invite</h1>
<p className="text-muted-foreground">{error}</p>
<Button onClick={() => router.push('/')}>Return Home</Button>
</div>
</div>
)
}

return (
<div className="flex min-h-screen items-center justify-center">
<div className="text-center space-y-4 max-w-md">
<h1 className="text-2xl font-bold">Welcome to The Village!</h1>
<p className="text-muted-foreground">You've been invited to join our creative community. Click below to create your account.</p>
<Button onClick={() => router.push(/auth/register?token=${params.token})}>Create Account</Button>
</div>
</div>
)
}
EOF

emit apps/web/src/app/invite/page.tsx <<'EOF'
'use client'
import { useState } from 'react'
import { api } from '@/lib/api'
import { Button } from '@/components/ui/button'

export default function InviteIndex() {
const [link, setLink] = useState<string | null>(null)
const [wa, setWa] = useState<string | null>(null)

return (
<div className="container mx-auto py-8 space-y-4">
<h1 className="text-2xl font-bold">Invite a friend</h1>
<Button onClick={async ()=>{
const inv = await api.createInvite()
const url = ${window.location.origin}/invite/${inv.token}
setLink(url)
const msg = encodeURIComponent(Join The Village: ${url})
setWa(https://wa.me/?text=${msg})
}}>Generate Invite</Button>

  {link && (
    <div className="space-y-2">
      <div className="text-sm">Invite link:</div>
      <code className="block p-2 bg-gray-100 rounded">{link}</code>
      <a href={wa!} className="inline-block underline text-blue-600" target="_blank" rel="noreferrer">Share via WhatsApp</a>
    </div>
  )}
</div>
)
}
EOF

emit apps/web/src/app/feed/page.tsx <<'EOF'
'use client'

import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/button'
import { api } from '@/lib/api'
import Link from 'next/link'

export default function FeedPage() {
const [ideas, setIdeas] = useState<any[]>([])
const [loading, setLoading] = useState(true)

useEffect(() => { loadIdeas() }, [])

const loadIdeas = async () => {
try {
const data = await api.getIdeas()
setIdeas(data)
} catch (err) {
console.error('Failed to load ideas:', err)
} finally {
setLoading(false)
}
}

const handleFork = async (ideaId: string) => {
try {
await api.forkIdea(ideaId)
loadIdeas()
} catch (err) {
console.error('Failed to fork idea:', err)
}
}

if (loading) return <div className="container mx-auto py-8"><p>Loading ideas...</p></div>

return (
<div className="container mx-auto py-8">
<div className="flex justify-between items-center mb-8">
<h1 className="text-3xl font-bold">The Village Feed</h1>
<Link href="/ideas/new"><Button>Share Idea</Button></Link>
</div>

  <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
    {ideas.map((idea) => (
      <div key={idea.id} className="border rounded-lg p-6 space-y-4">
        <h2 className="text-xl font-semibold">{idea.title}</h2>
        {idea.text && <p className="text-muted-foreground">{idea.text}</p>}

        <div className="flex items-center justify-between text-sm">
          <span className="inline-flex items-center px-2 py-1 rounded-full text-xs bg-gray-100">
            {idea.license}
          </span>
          <span className="text-muted-foreground">{idea.type}</span>
        </div>

        {idea.parent_id && <div className="text-sm text-muted-foreground">Forked from another idea</div>}

        <div className="flex gap-2">
          <Button size="sm" onClick={() => handleFork(idea.id)}>Fork</Button>
          <Link href={`/ideas/${idea.id}`}><Button size="sm">View</Button></Link>
        </div>
      </div>
    ))}
  </div>

  {ideas.length === 0 && <div className="text-center py-12"><p className="text-muted-foreground">No ideas yet. Be the first to share!</p></div>}
</div>
)
}
EOF

emit apps/web/src/app/ideas/new/page.tsx <<'EOF'
'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { api } from '@/lib/api'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'

export default function NewIdea() {
const router = useRouter()
const [title, setTitle] = useState('')
const [text, setText] = useState('')
const [type, setType] = useState<'text'|'image'|'audio'|'video'>('text')
const [license, setLicense] = useState<'CC0'|'CC_BY_4_0'|'CC_BY_SA_4_0'>('CC0')
const [error, setError] = useState<string>('')

const submit = async (e: React.FormEvent) => {
e.preventDefault()
setError('')
try {
await api.createIdea({ type, title, text: type === 'text' ? text : undefined, license })
router.push('/feed')
} catch (err: any) {
setError(err.message ?? 'Failed to create idea')
}
}

return (
<div className="container mx-auto max-w-2xl py-8">
<h1 className="text-2xl font-bold mb-6">Share an Idea</h1>
<form onSubmit={submit} className="space-y-4">
<div>
<Label>Type</Label>
<select value={type} onChange={e => setType(e.target.value as any)} className="border rounded p-2 w-full">
<option value="text">Text</option>
<option value="image">Image (URL later)</option>
<option value="audio">Audio (URL later)</option>
<option value="video">Video (URL later)</option>
</select>
</div>
<div>
<Label>Title</Label>
<Input value={title} onChange={e=>setTitle(e.target.value)} required />
</div>
{type === 'text' && (
<div>
<Label>Text</Label>
<textarea className="border rounded p-2 w-full min-h-[120px]" value={text} onChange={e=>setText(e.target.value)} />
</div>
)}
<div>
<Label>Licence</Label>
<select value={license} onChange={e => setLicense(e.target.value as any)} className="border rounded p-2 w-full">
<option value="CC0">CC0 (Public Domain)</option>
<option value="CC_BY_4_0">CC BY 4.0 (Credit required)</option>
<option value="CC_BY_SA_4_0">CC BY-SA 4.0 (ShareAlike)</option>
</select>
<p className="text-xs text-gray-500 mt-1">We disallow ND/NC. Share freely; credit where needed.</p>
</div>

    {error && <p className="text-red-600 text-sm">{error}</p>}
    <Button type="submit">Publish</Button>
  </form>
</div>
)
}
EOF

emit apps/web/src/app/ideas/[id]/page.tsx <<'EOF'
'use client'
import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function IdeaDetail() {
const params = useParams<{ id: string }>()
const [idea, setIdea] = useState<any | null>(null)

useEffect(() => {
(async () => {
const res = await fetch(${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/ideas/${params.id}, {
headers: { Authorization: Bearer ${localStorage.getItem('token') || ''} }
})
if (res.ok) setIdea(await res.json())
})()
}, [params.id])

if (!idea) return <div className="container mx-auto py-8">Loading…</div>

return (
<div className="container mx-auto py-8 space-y-4">
<h1 className="text-2xl font-bold">{idea.title}</h1>
{idea.text && <p className="text-gray-700">{idea.text}</p>}
<div className="flex items-center gap-2 text-sm">
<span className="px-2 py-1 rounded bg-gray-100">{idea.license}</span>
<span className="text-gray-500">{idea.type}</span>
</div>
<div className="flex gap-2">
<Button onClick={async () => {
await fetch(${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/ideas/${idea.id}/fork, {
method: 'POST',
headers: {
Authorization: Bearer ${localStorage.getItem('token') || ''},
'Content-Type': 'application/json'
},
body: JSON.stringify({ license: idea.license })
})
window.location.href = '/feed'
}}>Fork</Button>
<Link href="/feed"><Button>Back</Button></Link>
</div>
</div>
)
}
EOF

emit apps/web/src/app/mood/page.tsx <<'EOF'
'use client'
import { useEffect, useState } from 'react'
import { api } from '@/lib/api'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

export default function Mood() {
const [posts, setPosts] = useState<any[]>([])
const [text, setText] = useState('')

const load = async () => setPosts(await api.request('/mood'))

useEffect(() => { load() }, [])

return (
<div className="container mx-auto py-8 space-y-6">
<h1 className="text-2xl font-bold">Mood & Thoughts</h1>
<form onSubmit={async (e)=>{ e.preventDefault(); await api.request('/mood',{method:'POST', body: JSON.stringify({text})}); setText(''); load()}} className="flex gap-2">
<Input placeholder="Share a thought…" value={text} onChange={e=>setText(e.target.value)} />
<Button type="submit">Post</Button>
</form>
<div className="space-y-4">
{posts.map(p=>(
<div key={p.id} className="border rounded p-4">
<div className="text-sm text-gray-500">{new Date(p.created_at).toLocaleString()}</div>
<div>{p.text}</div>
</div>
))}
</div>
</div>
)
}
EOF

emit apps/web/src/app/playlists/page.tsx <<'EOF'
export default function Playlists() {
return (
<div className="container mx-auto py-8">
<h1 className="text-2xl font-bold mb-4">Playlists</h1>
<p className="text-gray-600">Coming soon in V1. (API endpoints exist.)</p>
</div>
)
}
EOF

emit apps/web/src/app/admin/moderation/page.tsx <<'EOF'
'use client'
import { useEffect, useState } from 'react'

export default function Moderation() {
const [items, setItems] = useState<any[]>([])
useEffect(() => {
(async () => {
const res = await fetch(${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/mod/queue, {
headers: { Authorization: Bearer ${localStorage.getItem('token') || ''} }
})
if (res.ok) setItems(await res.json())
})()
}, [])

return (
<div className="container mx-auto py-8">
<h1 className="text-2xl font-bold mb-4">Moderation Queue</h1>
{items.length === 0 ? <p>No reports.</p> : (
<ul className="space-y-3">
{items.map((r:any)=>(
<li key={r.id} className="border rounded p-3">
<div className="text-sm text-gray-500">{r.target_type} · {r.target_id}</div>
<div>{r.reason}</div>
</li>
))}
</ul>
)}
</div>
)
}
EOF

emit apps/web/tests/utils.test.ts <<'EOF'
import { describe, it, expect } from 'vitest';
import { cn } from '@/lib/utils';
describe('cn', () => {
it('merges classes', () => {
expect(cn('a', 'b')).toContain('a');
});
});
EOF

emit apps/web/tests-e2e/smoke.spec.ts <<'EOF'
import { test, expect } from '@playwright/test';
test('home redirects to feed', async ({ page }) => {
await page.goto('/');
await expect(page).toHaveURL(//feed$/);
});
EOF

────────────────────────────────────────────────────────────────────────────────