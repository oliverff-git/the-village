# Project Status

- Status: GREEN
- Date: 2025-09-14
- Docker: 6/6 services up (3 healthy with checks)
- Web: http://localhost:3000 (responds; 200 on /feed)
- API: http://localhost:8000 (responds; docs at /docs)
- E2E: 1 passed (apps/web: `pnpm test:e2e`)

Notes:
- Web root (/) returns 307 redirect; use `/feed` for 200 check.
- `docker compose ps` shows "Up" for services; healthchecks defined for postgres, redis, minio.

