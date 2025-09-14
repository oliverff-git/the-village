# The Village

An invite-only creative commons for sharing ideas, images, and audio under open licences.

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ and PNPM (for local development)
- Python 3.11+ (for local development)

### Running with Docker

```bash
cp .env.example .env
docker compose up -d
docker compose exec api alembic upgrade head
docker compose exec api python -m scripts.create_admin
docker compose exec api python -m scripts.seed
```

Access:
- Web: http://localhost:3000
- API: http://localhost:8000 (docs at /docs)
- MinIO Console: http://localhost:9001 (minioadmin / minioadmin)

### Local Development

```bash
# Start infra
docker compose up -d postgres redis minio

# API
cd apps/api
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
uvicorn main:app --reload

# Web
cd ../../apps/web
pnpm install
pnpm dev
```

See `docs/ARCHITECTURE.md` for system design.
