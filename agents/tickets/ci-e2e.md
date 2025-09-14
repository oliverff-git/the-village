Agent: Codex
Objective: CI e2e smoke green.
Tests:
- apps/web/tests-e2e/smoke.spec.ts
Commands:
- pnpm --filter web build
- npx playwright install --with-deps
- docker compose up -d postgres redis minio api web
- pnpm --filter web test:e2e
Done when:
- e2e job passes in CI.


