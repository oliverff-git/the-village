# Cursor Agent Verification Prompt

## Context
Claude CLI has completed implementation of all 5 priority tickets for The Village repository. Your role is to independently verify that each implementation meets the acceptance criteria and document the results.

## Implementations to Verify

### 1. P0 - CI/CD Pipeline (feature/TICKET-20241214-cicd-setup)
**Claimed Status**: ✅ COMPLETED
**What to Verify**:
- [ ] `.github/workflows/ci.yml` exists and is valid YAML
- [ ] Workflow triggers on pull requests and pushes to main
- [ ] API tests run WITHOUT pytest-cov initially (was fixed in P3)
- [ ] Web build and tests execute successfully
- [ ] E2E tests run after unit tests
- [ ] Workflow uses pnpm for web, pip for API

### 2. P1 - Web Dependencies (feature/TICKET-20241214-web-rollup-fix)
**Claimed Status**: ✅ COMPLETED
**What to Verify**:
- [ ] `cd apps/web && pnpm test` runs without rollup errors
- [ ] No npm artifacts remain (no package-lock.json)
- [ ] pnpm-lock.yaml exists at root
- [ ] Web tests actually execute and pass
- [ ] `pnpm --filter web build` completes successfully

### 3. P2a - Pydantic V2 Migration (feature/TICKET-20241214-pydantic-v2-migration)
**Claimed Status**: ✅ COMPLETED
**What to Verify**:
- [ ] Run `cd apps/api && python -m pytest -W error::DeprecationWarning`
- [ ] Zero Pydantic deprecation warnings
- [ ] All schema files use `model_config = ConfigDict()` pattern
- [ ] No `class Config:` blocks remain in schemas
- [ ] All API tests still pass

### 4. P2b - Python 3.13 Compatibility (feature/TICKET-20241214-python313-passlib)
**Claimed Status**: ✅ COMPLETED
**What to Verify**:
- [ ] No passlib/crypt deprecation warnings in test output
- [ ] Authentication still works (can create/verify passwords)
- [ ] Check what solution was implemented (direct argon2-cffi?)
- [ ] Existing password hashes still validate

### 5. P3 - Coverage Tooling (feature/TICKET-20241214-coverage-tooling)
**Claimed Status**: ✅ COMPLETED
**What to Verify**:
- [ ] CI workflow includes `--cov=. --cov-report=xml --cov-fail-under=75`
- [ ] `cd apps/api && pytest` shows coverage report
- [ ] coverage.xml generates successfully
- [ ] Coverage meets 75% threshold
- [ ] coverage.xml added to .gitignore

## Verification Process

1. **Check Current Branch Status**:
   ```bash
   git branch -a | grep feature/TICKET
   ```

2. **For Each Implementation**:
   - Checkout the feature branch
   - Run the specific verification tests
   - Document actual vs expected results
   - Note any deviations or issues

3. **System Integration Check**:
   ```bash
   # Full system test
   docker compose down -v
   docker compose up -d
   cd apps/api && python -m pytest -v
   cd ../web && pnpm test
   ```

4. **CI Simulation**:
   ```bash
   # Simulate what CI would do
   act -j api_tests  # if act is installed
   # Or manually run CI commands
   ```

## Required Output

Create `/agents/verification/VERIFICATION_REPORT_20241214_FINAL.md` with:

1. **Executive Summary**
   - Overall verification result (PASS/FAIL)
   - Count of implementations verified
   - Critical issues found (if any)

2. **Detailed Results per Ticket**
   - Acceptance criteria checklist
   - Actual test results with output
   - Deviations from expected behavior
   - Risk assessment

3. **Integration Test Results**
   - Full system test outcome
   - Performance metrics
   - Any regressions detected

4. **Recommendations**
   - Safe to merge to main? (YES/NO per branch)
   - Any follow-up work needed
   - Production deployment readiness

## Important Notes

- Claude CLI reports all 5 tickets as COMPLETED with GREEN status
- PROJECT_STATUS.md shows 75.87% test coverage achieved
- All deprecation warnings reportedly fixed
- Docker services remain healthy throughout

## Verification Commands Reference

```bash
# P0 - CI verification
cat .github/workflows/ci.yml
gh workflow list  # if GitHub CLI available

# P1 - Web tests
cd apps/web
pnpm test
pnpm build

# P2a - Pydantic check
cd apps/api
python -m pytest -W error::DeprecationWarning
grep -r "class Config:" schemas/

# P2b - Passlib check
cd apps/api
python -m pytest -v -k auth
grep -r "passlib\|crypt" .

# P3 - Coverage
cd apps/api
pytest --cov=. --cov-report=term
ls -la coverage.xml htmlcov/
```

Begin verification and report your findings!
