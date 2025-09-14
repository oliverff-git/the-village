# TEST-FIRST Sprint Plan — the-village

## Sprint 1 — Python package skeleton & DB layer (Claude)
Goal: Make API importable + DB usable in tests.
Scope: apps/api/core/{__init__.py,database.py,config.py}; add __init__.py to apps/, apps/api/, core/, api/, models/, schemas/.
Tests: apps/api/tests/conftest.py should import `from apps.api.main import app`; creating tables in SQLite must succeed.
Risks: UUID types on SQLite; path/package resolution.
Acceptance: `pytest -q` sets up DB without ImportError; no syntax errors.

## Sprint 2 — Auth & Invites endpoints (Claude)
Goal: Implement /auth/register, /auth/login, /auth/refresh, /auth/me and /invites endpoints with quotas.
Scope: apps/api/api/{auth.py,invites.py}, core/security.py, models/{user.py,invite.py,session.py}.
Tests: apps/api/tests/test_auth_invite.py (both tests) pass.
Risks: password hashing (argon2), JWT/config.
Acceptance: Both tests green.

## Sprint 3 — Ideas + BY-SA propagation (Claude)
Goal: CRUD minimal ideas; enforce BY-SA on forks.
Scope: apps/api/api/ideas.py, models/idea.py (+ enums), workers/media.py (stub ok).
Tests: apps/api/tests/test_ideas_licenses.py passes.
Risks: enums/strings, relationships.
Acceptance: Test passes; /ideas list returns created items.

## Sprint 4 — Docker/Compose & CI e2e smoke (Codex)
Goal: Fix API Dockerfile apt-get lines; ensure compose targets assemble; Playwright smoke runs.
Scope: apps/api/Dockerfile, docker-compose.yml; CI job uses docker compose up for api+web.
Tests: web tests-e2e smoke passes in CI.
Risks: services healthcheck timings.
Acceptance: e2e job green in CI.

## Sprint 5 — Pre-commit, lint, typecheck (Codex)
Goal: Pre-commit baseline; ruff/black checks; optional mypy relaxed.
Scope: .pre-commit-config.yaml, Makefile targets, CI jobs (format/lint/typecheck).
Tests: CI format/lint jobs pass.
Risks: strictness too high initially.
Acceptance: All quality jobs green.

## Sprint 6 — Observability & runbook (Codex)
Goal: JSON logs with request IDs; /health; metrics; RUNBOOK.
Scope: apps/api/main.py, docs/OPERATIONS.md.
Tests: curl /health returns {"status":"healthy"}; metrics endpoint wired (can be smoke checked).
Acceptance: Health & logs verified in CI logs.

## Sprint 7 — Supply chain & secrets (Codex)
Goal: Dependabot/CodeQL/gitleaks finalized; SBOM optional.
Scope: .github/*, scripts/gen-sbom.sh, sbom/.
Tests: gitleaks CI job runs; CodeQL workflow present.
Acceptance: CI shows secret scan and CodeQL jobs triggered.


