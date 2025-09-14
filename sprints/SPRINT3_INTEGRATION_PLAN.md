# Sprint 3: Integration & Verification Plan

## Current Repository State

### Completed Work
- **Codex**: Infrastructure fixes on `agent/codex/infra-ci`
  - Docker configurations with proper dependencies
  - CI workflow setup
  - Makefile targets
  - Pre-commit hooks
  
- **Claude**: API core fixes on `agent/claude/api-core` 
  - Fixed syntax/indentation issues
  - Created missing `__init__.py` files
  - Implemented business logic for auth and ideas

### Active Issues
1. **API**: Tests fail with `ModuleNotFoundError: No module named 'main'`
2. **Web**: Vite alias resolution errors (`@/lib/utils` not found)
3. **Integration**: Need to merge infra and API changes
4. **CI**: Pipeline not yet green due to test failures

## Agent Task Assignments

### 🔍 Claude CLI (Debugging Lead)
**Branch**: `agent/claude/debug-sprint3`
**Focus**: Deep debugging of import issues and test failures

### 🔧 Codex (Refactoring & Implementation)
**Branch**: Continue on `agent/codex/infra-ci`
**Focus**: Fix import paths and web build configuration

### ✅ Cursor Agent AI (Integration Manager)
**Branch**: `agent/cursor/integration-sprint3`
**Focus**: Merge all changes, verify builds, and achieve green CI

## Success Criteria
- [ ] All API tests passing
- [ ] Web app builds and tests pass
- [ ] Docker images build successfully
- [ ] CI pipeline is green on main branch
- [ ] Full E2E smoke test passes

## Coordination & Communication Protocol

### Phase 1: Debugging (Claude CLI)
- **Duration**: 2-3 hours
- **Output**: `SPRINT3_DEBUG_REPORT.md`
- **Handoff to Codex**: Complete list of issues with root causes

### Phase 2: Implementation (Codex)
- **Duration**: 3-4 hours  
- **Dependency**: Claude's debug report
- **Output**: Fixed code on `agent/codex/infra-ci`
- **Handoff to Cursor**: Branch ready with all fixes

### Phase 3: Integration (Cursor)
- **Duration**: 2-3 hours
- **Dependency**: Codex's completed fixes
- **Output**: Integrated branch with green tests
- **Final**: Ready to merge to main

### Parallel Work Guidelines
- Claude can debug both API and Web issues simultaneously
- Codex can start planning fixes based on obvious issues while waiting for full report
- Cursor can prepare integration environment and review existing branches
- NO direct code conflicts - each agent works in their designated areas

### Critical Synchronization Points
1. **After Claude's debugging**: Codex must wait for debug report before implementing fixes
2. **After Codex's fixes**: Cursor must wait for implementation before integration
3. **If blockers found**: Report immediately to strategist for re-planning

### Communication Artifacts
- `SPRINT3_DEBUG_REPORT.md` - Claude's findings
- Commit messages with `[agent/name/branch]` prefix
- `SPRINT3_INTEGRATION_REPORT.md` - Final status
