# Test Charter - E2E Test Validation

## Charter ID
TC_20250114_e2e_validation

## Objective
Validate end-to-end test execution using Playwright to ensure full user journey testing capability.

## Scope
### Components
- [x] Module/Service: apps/web (frontend)
- [x] Features: User flows, authentication, idea creation

### Test Types
- [ ] Unit
- [ ] Integration
- [x] E2E
- [ ] Performance
- [ ] Security

## Pre-requisites/Data
### Environment Setup
```bash
# Ensure Docker services are running
docker compose ps

# Verify API is accessible
curl -s http://localhost:8000/health || echo "API not responding"

# Check web service
curl -s http://localhost:3000 || echo "Web not responding"
```

### Test Data
- [x] Sample files: Built into test specs
- [x] Database state: Clean state via Docker
- [x] External services: All via Docker Compose

## Commands to Run
### Sequential Execution
```bash
# Step 1: Install Playwright browsers if needed
$ cd /Users/oliver/projects/the-village/apps/web && pnpm dlx playwright install

# Step 2: Run E2E tests
$ cd /Users/oliver/projects/the-village/apps/web && pnpm test:e2e

# Step 3: Run with headed browser for debugging (if tests fail)
$ cd /Users/oliver/projects/the-village/apps/web && pnpm test:e2e -- --headed

# Step 4: Check for test artifacts
$ ls -la test-results/ 2>/dev/null || echo "No test results directory"
```

### Parallel Execution (if safe)
Not recommended - E2E tests may conflict with shared state

## Signals to Capture
- [x] Exit codes
- [x] Test pass/fail counts
- [x] Screenshots on failure
- [x] Video recordings (if configured)
- [x] Console errors

## Pass/Fail Criteria
### PASS Conditions
- [x] All E2E tests pass
- [x] No console errors during test execution
- [x] Test duration reasonable (<60s total)
- [ ] Expected artifacts created

### FAIL Conditions
- [x] Any test fails
- [x] Timeout errors
- [x] Network/connection errors
- [x] Missing test dependencies

## Risk Assessment
- **Blast Radius**: E2E tests interact with running services, may leave test data
- **Rollback**: docker compose down && docker compose up -d for clean state

---
Charter Created: 2025-01-14
Target Execution: After web unit tests pass
