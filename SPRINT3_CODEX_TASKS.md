# Sprint 3 Tasks: Claude (Refactoring & Implementation)

## Agent Role
You are Claude, the implementation expert. Your mission is to fix all identified issues based on Claude's debugging findings and ensure clean, working code.

## Context
- You've already fixed infrastructure on `agent/codex/infra-ci`
- Claude's debugging will identify specific import/path issues
- API and web tests are currently failing
- Integration with existing API logic from Claude is needed

## Your Tasks

### 1. Fix API Import Issues
**Priority**: CRITICAL
**Branch**: Continue on `agent/codex/infra-ci`

Based on Claude's findings, implement fixes:
- Adjust import statements in `apps/api/tests/conftest.py`
- Ensure proper Python path configuration
- Options to implement:
  ```python
  # Option 1: Use absolute imports
  import sys
  import os
  sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
  from main import app
  
  # Option 2: Use package imports
  from apps.api.main import app
  ```
- Update any other test files with import issues

### 2. Fix Web Build Configuration
**Location**: `apps/web/`

- Add/fix Vite alias configuration for `@/` paths
- Update `vite.config.ts`:
  ```typescript
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
  ```
- Ensure TypeScript paths align with Vite aliases

### 3. Merge Claude's API Logic
**IMPORTANT**: Preserve Claude's business logic while fixing structure

- Cherry-pick or merge relevant commits from `agent/claude/api-core`
- Ensure auth/invites and ideas/licenses logic is preserved
- Resolve any merge conflicts maintaining both infra fixes and logic

### 4. Update Test Configuration
- Ensure `pytest.ini` or `pyproject.toml` has correct test paths
- Add `__init__.py` files where needed for test discovery
- Configure test environment variables if needed

### 5. Dockerfile Adjustments (if needed)
Based on test requirements:
- Ensure test dependencies are included
- Add any missing system packages
- Verify PYTHONPATH is set correctly in containers

## Code Quality Requirements
- Maintain clean, readable code
- Add comments explaining any non-obvious fixes
- Ensure all changes are backwards compatible
- Follow existing code style conventions

## Deliverables
- [ ] All import errors fixed with proper path configuration
- [ ] Web build configuration corrected
- [ ] Claude's business logic integrated
- [ ] Tests can be discovered and run
- [ ] Commit each fix separately with clear messages

## Git Workflow
```bash
# Stay on your branch
git checkout agent/codex/infra-ci

# For each fix, commit with prefix:
git add <files>
git commit -m "[agent/codex/infra-ci] fix: resolve API test imports"
```

## Success Criteria
- [ ] `cd apps/api && pytest` runs without import errors
- [ ] `cd apps/web && pnpm test` runs without build errors
- [ ] All existing business logic preserved
- [ ] Clean commit history with atomic changes
