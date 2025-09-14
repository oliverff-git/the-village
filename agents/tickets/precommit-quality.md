Agent: Precommit-Quality (codex)
Objective: ruff/black checks locally and in CI.
Scope: .pre-commit-config.yaml, Makefile, CI jobs.
Tests: CI format/lint jobs
Constraints: edit only inside this worktree
Run: make format lint
Acceptance: format/lint jobs green.
