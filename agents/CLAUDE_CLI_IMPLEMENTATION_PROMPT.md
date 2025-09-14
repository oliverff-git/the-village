# Claude CLI Implementation Mission - Docker Services Fix

## CRITICAL P0 TICKET IMPLEMENTATION

**Repository**: /Users/oliver/projects/the-village  
**Ticket**: TICKET-20250114-docker-services-fix  
**Priority**: P0 - CRITICAL BLOCKER  
**Goal**: Fix Docker services to enable E2E testing and achieve GREEN status

## Current State
- ✅ Web unit tests: FIXED (run `pnpm install` at workspace root)
- ❌ Docker web service: BROKEN (command syntax error)
- ❌ Docker API service: BROKEN (missing DATABASE_URL)
- ❌ E2E tests: BLOCKED (services down)

## Required Fixes

### 1. Fix Web Service Command (docker-compose.yml line 99)
**Current (BROKEN)**:
```yaml
command: sh -c "npm install --no-audit --no-fund && npm run build && npm start -p 3000"
```

**Error**: Results in "npm start -p 3000 3000" (duplicate port)

**Fix to**:
```yaml
command: sh -c "npm install --no-audit --no-fund && npm run build && npm start"
```

### 2. Fix API Service Environment (docker-compose.yml ~line 60)
**Current (BROKEN)**: Missing DATABASE_URL environment variable

**Add to api service**:
```yaml
environment:
  DATABASE_URL: postgresql://village_user:change_me_in_production@postgres:5432/thevillage
```

## Implementation Steps
1. Open docker-compose.yml
2. Fix web service command (remove "-p 3000" from npm start)
3. Add DATABASE_URL to api service environment section
4. Save file
5. Restart services: 
   ```bash
   docker compose down
   docker compose up -d
   ```
6. Verify all services running:
   ```bash
   docker compose ps
   ```

## Acceptance Verification
Run these commands to confirm fixes:

```bash
# 1. All 6 services should be running/healthy
docker compose ps | grep -c "running\|healthy"
# Expected: 6

# 2. Web service accessible
curl -I http://localhost:3000 | grep "200 OK"
# Expected: HTTP/1.1 200 OK

# 3. API service accessible  
curl -s http://localhost:8000/docs | grep -q "FastAPI" && echo "API OK"
# Expected: API OK

# 4. E2E smoke test passes
cd apps/web && pnpm test:e2e
# Expected: 1 passed
```

## Success Criteria
- All Docker services running (6/6)
- Web responds on port 3000
- API responds on port 8000  
- E2E tests execute successfully
- No errors in container logs

## Post-Implementation
After fixing Docker services:
1. Commit changes with message: `[TICKET-20250114] fix: correct docker service configurations`
2. Update PROJECT_STATUS.md to reflect GREEN status
3. Consider implementing P2 documentation ticket

---
IMPORTANT: This is a CRITICAL blocker. Without these fixes, no E2E testing is possible and the development environment is unusable.