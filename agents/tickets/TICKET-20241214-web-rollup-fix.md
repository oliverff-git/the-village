# Implementation Ticket - Fix Web Application Rollup Dependency

## Title
Resolve Missing @rollup/rollup-darwin-arm64 Dependency Blocking Web Tests

## Background/Problem Statement
The web application's test suite cannot run locally due to a missing platform-specific Rollup dependency. This is caused by a known npm bug with optional dependencies (https://github.com/npm/cli/issues/4828). The error prevents all local web development testing, though the application builds and runs successfully in Docker.

This blocks frontend developers from running tests locally, significantly impacting development velocity and requiring Docker for all testing activities.

**Link to diagnostic report**: [Web Module Diagnostic](../reports/web/S1_DIAGNOSE.md)

## Affected Paths
- `apps/web/node_modules/` (to be regenerated)
- `apps/web/package-lock.json` (to be regenerated)
- `apps/web/package.json` (verify package manager setting)
- Root `pnpm-workspace.yaml` (existing workspace config)
- Root `package.json` (verify packageManager field)

## Scope
### In Scope
- Fix node_modules installation to include platform-specific dependencies
- Standardize on pnpm as the package manager (matching CI)
- Ensure vitest and all test dependencies install correctly
- Verify tests run successfully after fix
- Update developer documentation for correct setup

### Out of Scope  
- Upgrading dependency versions
- Modifying test configurations
- Changing from vitest to another test runner
- Docker-specific configurations

## Implementation Plan
1. Remove corrupted node_modules and lock files in apps/web
2. Verify pnpm is installed and configured at root level
3. Use pnpm to reinstall dependencies (respecting workspace)
4. Run web tests to confirm resolution
5. Document the correct installation process
6. Update any npm references to use pnpm commands
7. Add .nvmrc or similar to standardize Node.js version

## Acceptance Criteria / Definition of Done
- [ ] `apps/web/node_modules/` contains @rollup/rollup-darwin-arm64
- [ ] `pnpm --filter web test` executes without module errors
- [ ] All existing web unit tests pass
- [ ] Installation documented in apps/web/README.md
- [ ] No npm-specific lock files remain (only pnpm-lock.yaml)
- [ ] Developer setup guide updated with pnpm instructions

## Test Plan
### Tests to Add
- No new tests required (fixing existing test infrastructure)

### Tests to Run
- `pnpm --filter web test` - should run without errors
- `pnpm --filter web build` - should complete successfully
- Verify tests run on both macOS ARM64 and x86_64

## Observability/Telemetry Updates
- No telemetry changes required

## Risks and Rollback Considerations
### Risks
- Different behavior between npm and pnpm
- Existing developers may have npm muscle memory
- CI/CD changes may be needed if npm is hardcoded

### Rollback Plan
- Keep backup of working package-lock.json from Docker
- Can revert to npm with explicit platform flags
- Docker development remains available as fallback

## Branching and Commit Guidelines
- **Branch Name**: `feature/TICKET-20241214-web-rollup-fix`
- **Commit Message Format**: `[TICKET-20241214] fix: Resolve web test runner rollup dependency issue`

## RACI Matrix
- **Responsible**: Human Developer / External Implementation Agent
- **Accountable**: Frontend Tech Lead
- **Consulted**: Claude Strategist (diagnostic analysis)
- **Informed**: Cursor Ops (will verify test execution), All Frontend Developers

## Traceability Links
- **Diagnostic Report**: [Web Module Diagnostic](../reports/web/S1_DIAGNOSE.md)
- **Verification Report**: [To be added after implementation](../verification/...)
- **Status Update**: [PROJECT_STATUS.md](../status/PROJECT_STATUS.md)
