# Test Charter - Web Rollup Module Resolution

## Charter ID
TC_20250114_web_rollup_fix

## Objective
Investigate and resolve the @rollup/rollup-darwin-arm64 module resolution issue preventing web test execution.

## Scope
### Components
- [x] Module/Service: apps/web
- [x] Features: Test runner initialization, dependency resolution

### Test Types
- [x] Unit (vitest execution)
- [ ] Integration
- [ ] E2E
- [ ] Performance
- [ ] Security

## Pre-requisites/Data
### Environment Setup
```bash
# Ensure we're in the web directory
cd /Users/oliver/projects/the-village/apps/web

# Check current pnpm version
pnpm -v

# List current node_modules structure
ls -la node_modules/@rollup/ | head -20
```

### Test Data
- [ ] Sample files: Not required
- [x] Database state: Not required
- [ ] External services: Not required

## Commands to Run
### Sequential Execution
```bash
# Step 1: Check rollup installation status
$ cd /Users/oliver/projects/the-village/apps/web && ls -la node_modules/@rollup/ | grep darwin

# Step 2: Clean and reinstall with pnpm
$ cd /Users/oliver/projects/the-village/apps/web && rm -rf node_modules
$ cd /Users/oliver/projects/the-village && pnpm --filter web install

# Step 3: Verify rollup module after reinstall
$ cd /Users/oliver/projects/the-village/apps/web && ls -la node_modules/@rollup/ | grep darwin

# Step 4: Attempt test execution
$ cd /Users/oliver/projects/the-village/apps/web && pnpm test -- --run

# Step 5: If still failing, try workspace-wide install
$ cd /Users/oliver/projects/the-village && pnpm install
$ cd /Users/oliver/projects/the-village/apps/web && pnpm test -- --run
```

### Parallel Execution (if safe)
Not applicable - dependency resolution must be sequential

## Signals to Capture
- [x] Exit codes for each command
- [x] Presence/absence of @rollup/rollup-darwin-arm64
- [x] Test execution output
- [x] Any pnpm warnings about peer dependencies
- [ ] File system artifacts

## Pass/Fail Criteria
### PASS Conditions
- [x] pnpm test -- --run exits with code 0
- [x] Test results show actual test execution (not module errors)
- [x] @rollup/rollup-darwin-arm64 present in node_modules
- [ ] Expected artifacts created

### FAIL Conditions
- [x] Module resolution error persists
- [x] Exit code non-zero
- [x] Test runner fails to start
- [ ] Missing expected outputs

## Risk Assessment
- **Blast Radius**: Limited to web module development environment
- **Rollback**: Can restore node_modules from git if needed

---
Charter Created: 2025-01-14
Target Execution: Immediate
