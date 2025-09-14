# Implementation Ticket - Docker Services Fix

## Title
TICKET-20250114-docker-services-fix

## Background/Problem
- **Linked DIAG**: [/agents/reports/infrastructure/S4_DIAGNOSE.md]
- **Problem Statement**: Web and API Docker services failing to start properly, blocking all E2E testing and local development
- **Business Impact**: Complete development environment blockage, CI/CD E2E tests would fail

## Affected Paths
```
docker-compose.yml
```

## Scope
### In Scope
- [x] Fix web service command syntax error
- [x] Fix API service database connection configuration
- [x] Verify all services start successfully
- [x] Ensure E2E tests can connect

### Out of Scope
- [ ] Upgrading Docker compose version
- [ ] Changing service architecture
- [ ] Modifying application code

## Implementation Plan
1. **Step 1**: Fix web service command in docker-compose.yml - remove duplicate port argument
2. **Step 2**: Add DATABASE_URL environment variable to API service configuration
3. **Step 3**: Restart all services and verify health
4. **Step 4**: Run smoke test to confirm connectivity

## Acceptance Criteria
```bash
# Command 1: All services running
$ docker compose ps | grep -c "running\|healthy"
# Expected output: 6 (all services)

# Command 2: Web service accessible
$ curl -I http://localhost:3000 | grep "200 OK"
# Expected output: HTTP/1.1 200 OK

# Command 3: API service accessible
$ curl -s http://localhost:8000/docs | grep -q "FastAPI" && echo "API OK"
# Expected output: API OK

# Command 4: E2E smoke test passes
$ cd apps/web && pnpm test:e2e
# Expected output: 1 passed
```

## Test Plan
### Existing Tests to Update
None - infrastructure configuration only

### New Tests to Add
- [ ] Docker health check for web service
- [ ] Docker health check for API service

### Test Commands
```bash
# Verify services after fix
docker compose down
docker compose up -d
sleep 10
docker compose ps
```

## Observability
- [ ] Container startup logs should be clean
- [ ] No connection errors in logs
- [ ] Services respond to health checks

## Risks/Rollback
### Risks
1. **Risk**: Breaking existing deployments
   - **Mitigation**: Test in feature branch first

### Rollback Plan
```bash
# Revert to previous docker-compose.yml
git checkout HEAD -- docker-compose.yml
docker compose down
docker compose up -d
```

## Branching/Commits
- **Branch**: `feature/TICKET-20250114-docker-services-fix`
- **Commit Pattern**: `[TICKET-20250114] fix: correct docker service configurations`

## RACI
- **Responsible**: Developer implementing fix
- **Accountable**: DevOps lead
- **Consulted**: Original configuration author
- **Informed**: Development team

## Traceability
- **DIAG**: [/agents/reports/infrastructure/S4_DIAGNOSE.md]
- **VERIFY**: [/agents/verification/S4_VERIFY_20250114_e2e_validation.md]
- **STATUS**: [/agents/status/PROJECT_STATUS.md]

---
Created: 2025-01-14
Priority: P0 (Critical blocker)
