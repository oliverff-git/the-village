Agent: CI-E2E (codex)
Objective: Playwright smoke runs in CI with compose up api+web.
Scope: apps/api/Dockerfile, docker-compose.yml, CI workflow.
Tests: apps/web/tests-e2e/smoke.spec.ts
Constraints: edit only inside this worktree
Run: pnpm --filter web test:e2e
Acceptance: e2e job green.
