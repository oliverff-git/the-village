Agent: Claude
Objective: Pass test_auth_invite.py.
Constraints: edit only inside this worktree.
Tests:
- apps/api/tests/test_auth_invite.py
Run:
- pytest -q -k auth_invite
Done when:
- Both tests pass.
Notes:
- Argon2 hashing via passlib; JWT via python-jose.
- Refresh tokens persisted; /invites endpoints enforce simple quota.


