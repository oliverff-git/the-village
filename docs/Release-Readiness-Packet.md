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
```bash
cp .env.example .env
docker compose up -d
docker compose exec api alembic upgrade head
docker compose exec api python -m scripts.create_admin
docker compose exec api python -m scripts.seed
open http://localhost:3000
```

## Quality Gates
CI enforces lint/typecheck/tests; API coverage ≥85% gate; secret scan.

## Test Coverage (API subset)
- Auth/register/login
- Invites create/validate
- Ideas fork with BY-SA propagation

## Security Notes
Argon2id, JWT (access+refresh), CORS, quotas on invites, secret scanning in CI.

## Operations
- Health: GET /health
- Metrics: GET /metrics (Prometheus)
- Logs: JSON with X-Request-Id
- Buckets: API ensures MinIO bucket on startup.

## Known Gaps
- Audio pipeline (ffmpeg/HLS/waveform) stubbed.
- Full E2E flows for uploads and moderation not yet in tests.
- SBOM optional; Dependabot/CodeQL optional.

## Next Steps
- Implement audio worker (ffmpeg → HLS preview, waveform JSON).
- Add FTS (title+text) and search endpoints.
- Expand Playwright to cover invite → register → post idea flow.
