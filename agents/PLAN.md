# TEST-FIRST Sprint Plan — the-village

## S1 — Python package skeleton & DB layer (Claude)
Goal: Make API importable + DB usable in tests.
Scope: apps/api/**/__init__.py files; core/{database.py,config.py}.
Tests: existing pytest session (conftest) imports app; Base metadata creates tables (SQLite).
Acceptance: `pytest -q` sets up DB; no ImportError.

## S2 — Auth & Invites (Claude)
Goal: Pass apps/api/tests/test_auth_invite.py.
Scope: api/{auth.py,invites.py}, core/security.py, models/{user.py,invite.py,session.py}.
Acceptance: both tests pass.

## S3 — Ideas & BY-SA propagation (Claude)
Goal: Pass apps/api/tests/test_ideas_licenses.py.
Scope: api/ideas.py, models/idea.py (+ enums), workers/media.py stub ok.
Acceptance: test passes.

## S4 — CI e2e smoke (Codex)
Goal: Playwright smoke runs in CI with compose up api+web.
Scope: apps/api/Dockerfile, docker-compose.yml, CI workflow.
Acceptance: e2e job green.

## S5 — Pre-commit & quality gates (Codex)
Goal: ruff/black checks locally and in CI.
Scope: .pre-commit-config.yaml, Makefile, CI jobs.
Acceptance: format/lint jobs green.

## S6 — Observability & runbook (Codex)
Goal: JSON logs + /health + metrics surfaced; RUNBOOK.
Scope: apps/api/main.py, docs/OPERATIONS.md.
Acceptance: /health 200; logs show request id.

## S7 — Supply chain & secrets (Codex)
Goal: Dependabot/CodeQL/gitleaks in CI.
Scope: .github/*, scripts/gen-sbom.sh.
Acceptance: bots/jobs present.