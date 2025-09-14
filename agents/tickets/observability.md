Agent: Observability (codex)
Objective: JSON logs + /health + metrics surfaced; RUNBOOK.
Scope: apps/api/main.py, docs/OPERATIONS.md.
Tests: curl /health returns 200
Constraints: edit only inside this worktree
Run: curl -s localhost:8000/health
Acceptance: /health 200; logs show request id.
