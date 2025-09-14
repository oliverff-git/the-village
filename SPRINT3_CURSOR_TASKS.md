# Sprint 3 Tasks: Cursor Agent AI (Integration Manager)

## Agent Role
You are Cursor Agent AI, the integration and verification expert. Your mission is to merge all fixes, ensure everything builds and tests pass, and achieve a green CI pipeline.

## Context
- Claude will provide debugging insights
- Claude will implement fixes on `agent/codex/infra-ci`
- Multiple agent branches exist with various fixes
- Goal is to integrate everything into a working system

## Your Tasks

### 1. Pre-Integration Verification
**Branch**: Create `agent/cursor/integration-sprint3`

```bash
git checkout -b agent/cursor/integration-sprint3
```

- Pull latest changes from all agent branches
- Review commits from:
  - `agent/codex/infra-ci` (infra fixes + new fixes)
  - `agent/claude/api-core` (business logic)
  - Any other relevant branches

### 2. Strategic Integration Plan
**Create integration order**:

1. First, merge Codex's infrastructure base:
   ```bash
   git merge agent/codex/infra-ci
   ```

2. Then selectively integrate Claude's business logic:
   ```bash
   # Cherry-pick specific commits if needed
   git cherry-pick <commit-hash>
   ```

3. Resolve any conflicts prioritizing:
   - Codex's infrastructure fixes
   - Claude's business logic
   - Working test configuration

### 3. Full System Verification

#### API Verification:
```bash
cd apps/api
# Install dependencies
pip install -r requirements.txt

# Run linting
ruff .
black --check .

# Run tests with coverage
pytest -v --cov=. --cov-report=term

# Start API locally
uvicorn main:app --reload
```

#### Web Verification:
```bash
cd apps/web
# Install dependencies
pnpm install

# Run tests
pnpm test

# Build check
pnpm build

# Start dev server
pnpm dev
```

### 4. Docker Integration Testing
```bash
# Build all images
docker compose build

# Start services
docker compose up -d

# Verify health
docker compose ps
docker compose logs

# Run integration tests
docker compose exec api pytest
```

### 5. CI Pipeline Verification
- Run all CI jobs locally:
  ```bash
  # Lint/typecheck
  make lint
  make typecheck
  
  # Full test suite
  make test
  
  # Coverage check
  make coverage
  ```

- Ensure CI config uses integrated changes
- Verify all GitHub Actions would pass

### 6. Fix Integration Issues
For any failures found:
- Document the issue clearly
- Implement minimal fix
- Re-test affected components
- Commit with clear message

### 7. E2E Smoke Test
Run full end-to-end flow:
1. Start all services
2. Register a user
3. Create an idea
4. Verify API responses
5. Check web UI rendering

### 8. Final Integration Report
**Create**: `SPRINT3_INTEGRATION_REPORT.md`

Include:
- Branches merged
- Conflicts resolved
- Tests status (before/after)
- CI status
- Any remaining issues
- Deployment readiness

## Git Workflow
```bash
# Create integration branch
git checkout -b agent/cursor/integration-sprint3

# Merge changes
git merge agent/codex/infra-ci
# Resolve conflicts if any

# After each verification step
git add .
git commit -m "[agent/cursor/integration] <what>: <why>"

# Final commit
git commit -m "[agent/cursor/integration] feat: complete Sprint 3 integration - all tests passing"
```

## Success Criteria
- [ ] All changes from Claude and Codex integrated
- [ ] API tests: 100% passing
- [ ] Web tests: 100% passing  
- [ ] Docker compose: All services healthy
- [ ] CI pipeline: Would be green if run
- [ ] E2E smoke test: Passes
- [ ] Integration branch ready to merge to main

## Important Notes
- Prioritize getting tests green over feature completeness
- Document any compromises or temporary fixes
- Ensure no regressions from previously working features
- Keep integration commits atomic and reversible
