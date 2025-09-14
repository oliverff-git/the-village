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

if [ ! -d .git ]; then
x git init -b main
fi

if [ -z "(git status --porcelain)" ] && [ -z " (git log --oneline 2>/dev/null)" ]; then x git add . x git commit -m "chore: bootstrap repo" fi

printf "\n🎉 The Village repository bootstrapped successfully!\n\n" printf "Next steps:\n" printf "1) cp .env.example .env\n" printf "2) docker compose up -d\n" printf "3) docker compose exec api alembic upgrade head\n" printf "4) docker compose exec api python -m scripts.create_admin\n" printf "5) docker compose exec api python -m scripts.seed\n\n" printf "Open:\n" printf "- Web: http://localhost:3000\n" printf "- API: http://localhost:8000 (docs at /docs)\n" printf "- MinIO: http://localhost:9001 (minioadmin/minioadmin)\n"

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
