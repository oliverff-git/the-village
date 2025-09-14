# Diagnostic Report - Web Module

## Component
apps/web - Next.js Frontend Application

## Purpose
Modern web frontend for The Village platform providing user interface for authentication, idea sharing, mood tracking, and playlist management with Next.js 14 App Router and Tailwind CSS.

## Boundaries/Dependencies
- **Framework**: Next.js 14 with App Router
- **Styling**: Tailwind CSS, PostCSS
- **Testing**: Vitest for unit tests, Playwright for E2E
- **Build Tools**: TypeScript, Rollup (via Vitest)
- **API Integration**: Communicates with apps/api backend

## Issue Summary
- Critical: Missing platform-specific Rollup dependency prevents tests from running
- Node modules installation incomplete or corrupted
- Potential npm bug with optional dependencies
- Unknown web build status in Docker

## Evidence
### Issue 1: Missing Rollup Darwin ARM64 Module
- **File(s)**: `node_modules` dependency tree
- **Error/Log Excerpt**:
```
Error: Cannot find module @rollup/rollup-darwin-arm64. npm has a bug related to optional dependencies (https://github.com/npm/cli/issues/4828). Please try `npm i` again after removing both package-lock.json and node_modules directory.
```
- **Root Cause**: npm optional dependency handling bug

### Issue 2: Test Suite Cannot Execute
- **Impact**: Unable to run unit tests via `npm test`
- **Command**: `cd apps/web && npm test`
- **Result**: Startup error before any tests run

## Reproduction Steps
```bash
# Reproduce test failure
cd /Users/oliver/projects/the-village/apps/web
npm test

# Suggested fix (not executed)
rm -rf node_modules package-lock.json
npm install
npm test
```

## Hypothesis
1. **Primary**: npm installation bug with optional dependencies on macOS ARM64
2. **Secondary**: Possible version mismatch between local Node.js and Docker environment
3. **Note**: Sprint 3 report indicates web builds successfully in Docker, suggesting environment-specific issue

## Severity/Blast Radius
- **Severity**: High (blocks local development and testing)
- **Affected Components**: 
  - All web unit tests
  - Local development workflow
  - Developer onboarding
- **User Impact**: None (production uses Docker builds which work)

## Readiness for Ticketisation
- [x] Issue clearly defined
- [x] Evidence documented
- [x] Reproduction steps verified
- [x] Root cause hypothesized
- [x] Impact assessed

**Status**: [x] Ready for ticket / [ ] Needs more information
