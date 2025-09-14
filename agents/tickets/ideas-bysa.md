Agent: Claude
Objective: Pass test_ideas_licenses.py.
Constraints: worktree-only.
Tests:
- apps/api/tests/test_ideas_licenses.py
Run:
- pytest -q -k ideas_licenses
Done when:
- BY-SA license propagation test passes.
Notes:
- Minimal Idea model + enums; /ideas and /ideas/{id}/fork routes.


