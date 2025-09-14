Agent: Python-Skeleton (claude)
Objective: Make API importable + DB usable in tests.
Scope: apps/api/**/__init__.py files; core/{database.py,config.py}.
Tests: existing pytest session (conftest) imports app; Base metadata creates tables (SQLite).
Constraints: edit only inside this worktree
Run: pytest -q
Acceptance: `pytest -q` sets up DB; no ImportError.
