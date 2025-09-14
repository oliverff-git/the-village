# Diagnostic Report - Web Test Execution Failure

## Component
apps/web - Next.js Frontend Application

## Purpose
Web UI for The Village platform, providing user interface for idea sharing, forking, and playlist management.

## Boundaries/Dependencies
- **Upstream**: Browser clients
- **Downstream**: API service (apps/api)
- **External**: 
  - Next.js 14 (App Router)
  - Vitest (test runner)
  - Rollup (bundler dependency)
  - pnpm (package manager)

## Issue Summary
Web unit tests fail to execute due to missing platform-specific Rollup module (@rollup/rollup-darwin-arm64), despite previous P1 ticket claiming to have fixed web dependency issues.

## Evidence
### Paths
- [x] File locations: /Users/oliver/projects/the-village/apps/web/
- [x] Config paths: vitest.config.ts, package.json

### Logs
```
Error: Cannot find module @rollup/rollup-darwin-arm64. npm has a bug related to optional dependencies (https://github.com/npm/cli/issues/4828). Please try `npm i` again after removing both package-lock.json and node_modules directory.
    at requireWithFriendlyError (/Users/oliver/projects/the-village/apps/web/node_modules/rollup/dist/native.js:67:9)
```

### Test IDs
- [x] Failing tests: All web unit tests (cannot start test runner)
- [ ] Flaky tests: N/A - runner doesn't start

## Reproduction Steps
```bash
# From project root
cd /Users/oliver/projects/the-village/apps/web
pnpm test -- --run
# Result: Exit code 1 with module resolution error
```

## Hypothesis
1. **Primary**: Platform-specific Rollup binary not installed correctly via pnpm
2. **Secondary**: Previous P1 fix may have addressed npm but not pnpm workspace setup
3. **Root Cause**: Optional dependency handling differs between npm and pnpm, requiring explicit installation or workspace configuration

## Severity/Blast Radius
- **Impact**: CRITICAL
- **Affected Systems**: 
  - Local development (cannot run tests)
  - CI/CD pipeline (web tests would fail)
  - Developer productivity blocked
- **User Impact**: None (development tooling only)

## Readiness for Ticketisation
- [x] Evidence collected and verified
- [x] Reproduction steps tested
- [x] Scope clearly defined
- [x] Dependencies identified
- [x] Risk assessment complete

**Status**: [x] Ready

## Additional Investigation Notes
- Current branch has modified web files (per git status)
- Docker web service is running successfully (production build works)
- Issue specific to development/test environment
- pnpm workspace configuration may need adjustment

---
Diagnosed: 2025-01-14
Diagnostician: Claude (Mastermind)
