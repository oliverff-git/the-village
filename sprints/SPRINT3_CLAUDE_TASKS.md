# Sprint 3 Tasks: Claude CLI (Debugging Lead)

## Agent Role
You are Claude CLI, the debugging expert. Your mission is to identify and diagnose all test failures and import issues through systematic debugging.

## Context
- API tests are failing with `ModuleNotFoundError: No module named 'main'`
- Previous work on `agent/claude/api-core` fixed syntax but tests still fail
- Codex has fixed infrastructure on `agent/codex/infra-ci`
- Web tests also failing with Vite alias issues

## Your Tasks

### 1. API Import Debugging
**Priority**: CRITICAL
**Location**: `apps/api/tests/conftest.py`

- Investigate why `from main import app` fails
- Trace the import path issues
- Check if PYTHONPATH needs adjustment
- Verify `__init__.py` files are properly placed
- Test different import approaches:
  ```python
  # Current failing:
  from main import app
  
  # Alternatives to test:
  from apps.api.main import app
  from ..main import app
  import sys; sys.path.append('..'); from main import app
  ```

### 2. Run Comprehensive Test Suite Analysis
- Execute tests with verbose output: `pytest -vvs`
- Document each failure type and root cause
- Create a mapping of:
  - Test file → Failure reason
  - Import error → Missing module/path issue
  - Runtime error → Configuration issue

### 3. Web Build Issue Investigation
**Location**: `apps/web/tests/utils.test.ts`

- Debug Vite alias resolution for `@/lib/utils`
- Check `vite.config.ts` or `tsconfig.json` for alias configuration
- Verify file exists at expected location

### 4. Create Debug Report
**Output**: `SPRINT3_DEBUG_REPORT.md`

Include:
- Complete list of all failing tests
- Root cause analysis for each failure type
- Recommended fixes (for Codex to implement)
- Any discovered configuration issues

## Constraints
- DO NOT modify code directly - only debug and diagnose
- Focus on understanding WHY things fail, not fixing them
- Document all findings clearly for other agents
- Use interactive debugging sessions where helpful

## Success Criteria
- [ ] All import errors diagnosed with clear root causes
- [ ] Test failure patterns identified and documented
- [ ] Clear recommendations for fixes provided
- [ ] Debug report created with actionable insights
