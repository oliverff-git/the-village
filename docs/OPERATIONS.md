# OPERATIONS / RUNBOOK (MVP)

## Startup
```bash
cp .env.example .env
docker compose up -d postgres redis minio
docker compose up -d api web
```

## Health
- API: `GET /health` returns JSON `{"status":"healthy"}`
- Prometheus metrics (if enabled): `/metrics`

## Common Tasks
- DB migrations: `docker compose exec api alembic upgrade head`
- Seed admin: `docker compose exec api python -m scripts.create_admin`
- Logs: `docker compose logs -f api`