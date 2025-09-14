Agent: Codex
Objective: JSON logs with request IDs; /health; metrics; RUNBOOK.
Tests:
- curl /health returns {"status":"healthy"}
- Metrics endpoint is wired (basic smoke ok)
Run:
- pytest -q || true
- curl -s localhost:8000/health || true
Done when:
- Health endpoint returns healthy JSON in CI logs; logs show request IDs.
Notes:
- Update apps/api/main.py for health route and JSON logging.
- Add docs/OPERATIONS.md runbook with basic troubleshooting.


