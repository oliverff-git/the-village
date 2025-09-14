# Test Charter - Production Build Validation

## Charter ID
TC_20250115_production_build

## Objective
Validate that the application builds correctly for production deployment and verify optimization settings.

## Scope
### Components
- [x] Module/Service: Full stack (API + Web)
- [x] Features: Production builds, optimizations, environment handling

### Test Types
- [ ] Unit
- [x] Integration (build process)
- [ ] E2E
- [x] Performance (bundle size)
- [ ] Security

## Pre-requisites/Data
### Environment Setup
```bash
# Ensure clean working directory
git status --porcelain

# Check Docker daemon has enough resources
docker system df
```

### Test Data
- [ ] Sample files: Not required
- [x] Database state: Not required for build
- [ ] External services: Docker only

## Commands to Run
### Sequential Execution
```bash
# Step 1: Build API production image
$ cd /Users/oliver/projects/the-village
$ docker build -f apps/api/Dockerfile -t the-village-api:prod apps/api

# Step 2: Check API image size
$ docker images the-village-api:prod --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Step 3: Build Web production image  
$ docker build -f apps/web/Dockerfile -t the-village-web:prod apps/web

# Step 4: Check Web image size
$ docker images the-village-web:prod --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Step 5: Test production web build locally
$ cd apps/web && npm run build

# Step 6: Check build output size
$ du -sh apps/web/.next

# Step 7: Verify production environment handling
$ docker run --rm the-village-api:prod python -c "from core.config import settings; print(f'DEBUG={settings.debug}')"
```

### Parallel Execution (if safe)
```bash
# Can build both images simultaneously
$ docker build -f apps/api/Dockerfile -t the-village-api:prod apps/api &
$ docker build -f apps/web/Dockerfile -t the-village-web:prod apps/web &
$ wait
```

## Signals to Capture
- [x] Build success/failure
- [x] Image sizes
- [x] Build times
- [x] Bundle sizes
- [x] Warning messages

## Pass/Fail Criteria
### PASS Conditions
- [x] Both Docker images build successfully
- [x] Image sizes reasonable (<1GB each)
- [x] Web build completes without errors
- [x] Production settings correctly applied
- [x] No critical security warnings

### FAIL Conditions
- [x] Build failures
- [x] Excessive image size (>2GB)
- [x] Security vulnerabilities in build
- [x] Development settings in production

## Risk Assessment
- **Blast Radius**: Build only, no runtime impact
- **Rollback**: Remove images with `docker rmi`

## Expected Outcomes
1. API image ~500-800MB (Python + dependencies)
2. Web image ~200-400MB (Node + Next.js)
3. Web bundle <10MB
4. DEBUG=False in production
5. No build warnings

---
Charter Created: 2025-01-14
Target Execution: After CI validation
