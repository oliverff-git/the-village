Agent: Codex
Objective: Pre-commit baseline; ruff/black checks; optional mypy relaxed.
Tests:
- CI format/lint/typecheck jobs pass.
Run:
- make format lint || true
- make typecheck || true
Done when:
- All quality jobs are green in CI.
Notes:
- Configure .pre-commit-config.yaml with ruff and black.
- Add Makefile targets for format, lint, typecheck.
- Keep mypy relaxed initially to avoid blocking.


