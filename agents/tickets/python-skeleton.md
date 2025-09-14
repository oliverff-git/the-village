Agent: Claude
Objective: Make API importable + DB usable in tests.
Constraints: edit only inside this worktree; add tests first if needed; run TEST_CMD.
Exact tests to add/adjust:
- None extra; make existing apps/api/tests/conftest.py work (import path + Base metadata).
Run:
- pytest -q
Done when:
- conftest creates tables without ImportError.
Notes:
- Add __init__.py: apps/, apps/api/, apps/api/{core,api,models,schemas}/
- Ensure apps/api/core/database.py has an indented `get_db()` generator.
- SQLite-friendly IDs: use String for UUIDs or a GUID TypeDecorator.


