Agent: Auth-Invites (claude)
Objective: Pass apps/api/tests/test_auth_invite.py.
Scope: api/{auth.py,invites.py}, core/security.py, models/{user.py,invite.py,session.py}.
Tests: apps/api/tests/test_auth_invite.py
Constraints: edit only inside this worktree
Run: pytest -q -k auth_invite
Acceptance: both tests pass.
