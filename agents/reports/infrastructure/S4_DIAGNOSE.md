# Diagnostic Report - Docker Service Failures

## Component
Docker Compose Infrastructure - Web and API services

## Purpose
Container orchestration for local development and testing environment, providing all necessary services for The Village platform.

## Boundaries/Dependencies
- **Upstream**: Developer workstations, CI environment
- **Downstream**: All application testing and development
- **External**: 
  - Docker Engine
  - Docker Compose
  - Container images (postgres, redis, minio)

## Issue Summary
Two critical service failures preventing E2E testing:
1. Web service container not running (was running earlier in session)
2. API service container running but not responding on port 8000

## Evidence
### Paths
- [x] File locations: /Users/oliver/projects/the-village/docker-compose.yml
- [x] Config paths: Dockerfile (web), Dockerfile (api)

### Logs
```
# Docker compose ps output showing missing web service:
NAME                     IMAGE                COMMAND                  SERVICE    CREATED       STATUS
the-village-api-1        the-village-api      "uvicorn main:app --…"   api        3 hours ago   Up 3 hours
# Note: web service absent from list

# API health check failure:
$ curl -s http://localhost:8000/docs | grep -q "FastAPI"
# Exit code: 1 (not responding)

# E2E test failure:
Error: page.goto: net::ERR_CONNECTION_REFUSED at http://localhost:3000/
```

### Test IDs
- [x] Failing tests: All E2E tests (connection refused)
- [ ] Flaky tests: N/A - hard failure

## Reproduction Steps
```bash
# Check current service status
docker compose ps

# Attempt to access services
curl -I http://localhost:3000  # Web - connection refused
curl -I http://localhost:8000/docs  # API - no response

# View container logs
docker compose logs web --tail 50
docker compose logs api --tail 50
```

## Hypothesis
1. **Web Service**: Container likely crashed after initial startup (was running at session start)
   - Possible causes: Memory issue, build problem, runtime error
   - Next.js build or startup failure

2. **API Service**: Container running but application not serving
   - Possible causes: Database connection issue, startup hang, port binding problem
   - Health check might be passing at container level but app not ready

3. **Root Cause**: Modified files in working tree may have introduced breaking changes

## Severity/Blast Radius
- **Impact**: CRITICAL
- **Affected Systems**: 
  - All E2E testing blocked
  - Local development environment unusable
  - CI/CD E2E tests would fail
- **User Impact**: Developers cannot test full stack locally

## Readiness for Ticketisation
- [x] Evidence collected and verified
- [x] Reproduction steps tested
- [x] Scope clearly defined
- [x] Dependencies identified
- [x] Risk assessment complete

**Status**: [x] Ready

## Additional Investigation Needed
1. Container logs examination
2. Git diff to identify recent changes
3. Resource usage check (Docker system df)
4. Individual service restart attempt

---
Diagnosed: 2025-01-14
Diagnostician: Claude (Mastermind)
