# Verification Report - Baseline

## CI/Build Context
- **Branch**: feature/TICKET-20241214-coverage-tooling
- **Commit**: Not captured (current working tree)
- **Timestamp**: 2025-01-14
- **Runner**: Local development (macOS)

## Commands Executed
```bash
# Command 1: Start Docker services
$ docker compose up -d && sleep 5 && docker compose ps
# Exit code: 0

# Command 2: Run API tests with coverage
$ cd apps/api && python -m pytest -v --tb=short --cov=. --cov-report=term-missing
# Exit code: 0

# Command 3: Run web tests
$ cd /Users/oliver/projects/the-village/apps/web && pnpm test -- --run
# Exit code: 1 (FAILED)
```

## Results Summary
### Build
- [x] Compilation: PASS (Docker images built)
- [x] Dependencies: PASS (Python deps installed)
- [ ] Lint: NOT RUN

### Docker Services
- **postgres**: Healthy
- **redis**: Healthy  
- **minio**: Healthy
- **api**: Running
- **worker**: Running
- **web**: Running

### Tests
#### API Tests
- **Total**: 3 tests
- **Passed**: 3
- **Failed**: 0
- **Skipped**: 0
- **Duration**: 0.56s

#### Web Tests
- **Status**: FAILED - Module resolution error
- **Error**: Cannot find module @rollup/rollup-darwin-arm64

### Coverage
- **Overall**: 76% (API only)
- **Threshold**: 75%
- **Status**: PASS

## Notable Logs/Excerpts
```
Error: Cannot find module @rollup/rollup-darwin-arm64. npm has a bug related to optional dependencies (https://github.com/npm/cli/issues/4828). Please try `npm i` again after removing both package-lock.json and node_modules directory.
```

## Flaky/Slow Tests
| Test | Duration | Flaky Count | Notes |
|------|----------|-------------|-------|
| None identified | - | - | All API tests < 1s |

## Environment Notes
- **OS**: macOS Darwin 24.6.0
- **Runtime Versions**: 
  - Node.js: v20.18.1
  - Python: 3.11.9
  - Docker: 27.4.0
  - pnpm: 9.15.0
- **Notable Configs**: pnpm workspace configuration

## Status vs Tickets
| Ticket | Expected | Actual | Status |
|--------|----------|--------|--------|
| P0: CI/CD Pipeline | CI workflow exists | Confirmed in .github/workflows/ci.yml | ✅ PASS |
| P1: Web Dependencies | Web tests run locally | Module error @rollup/rollup-darwin-arm64 | ❌ FAIL |
| P2: Pydantic + Passlib | No deprecation warnings | 0 warnings in API tests | ✅ PASS |
| P3: Coverage Tooling | Coverage reporting works | 76% coverage reported | ✅ PASS |

## Next Actions
- [x] Investigate web test failure (rollup module issue)
- [ ] Run CI workflow in GitHub Actions
- [ ] Verify E2E tests with Playwright
- [ ] Check git branch states

## Overall Status
**VERDICT**: [x] AMBER (partial) - Web tests failing despite P1 ticket claiming resolution
