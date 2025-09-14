# Diagnostic Report - CI/Infrastructure

## Component
CI/CD Pipeline and Development Infrastructure

## Purpose
Continuous Integration pipeline for automated testing, linting, building, and deployment of The Village monorepo applications.

## Boundaries/Dependencies
- **CI Platform**: GitHub Actions (not configured in main)
- **Container Runtime**: Docker & Docker Compose
- **Package Managers**: npm/pnpm for Node.js, pip for Python
- **Testing**: pytest, vitest, playwright
- **Code Quality**: ruff, black, mypy, ESLint

## Issue Summary
- Critical: No CI configuration in main repository (.github directory missing)
- CI exists only in worktree branches (claude/*, codex/*)
- Missing coverage dependency (pytest-cov) will break CI
- Potential pnpm vs npm conflict (CI uses pnpm, local uses npm)
- Coverage requirement set to 85% in some CI configs

## Evidence
### Issue 1: Missing GitHub Actions Configuration
- **Finding**: No .github directory in main repository
- **Evidence**: `grep .github` returns only references in other files
- **Impact**: No automated CI/CD on main branch

### Issue 2: CI Configuration Exists in Worktrees
- **Files Found**:
  - `worktrees/codex/ci-e2e/.github/workflows/ci.yml`
  - `worktrees/claude/auth-invites/.github/workflows/ci.yml`
  - Multiple other worktree locations
- **Note**: CI configurations exist but not in main branch

### Issue 3: CI Will Fail Due to Missing Dependencies
- **CI Command**: `pytest -q --cov=. --cov-report=xml`
- **Local Error**: pytest-cov not installed
- **Coverage Gate**: `--cov-fail-under=85` in some configs

### Issue 4: Package Manager Inconsistency
- **CI Config**: Uses `pnpm` (version 8)
- **Local Testing**: Used `npm` commands
- **Web Error**: npm-specific optional dependency bug

## Reproduction Steps
```bash
# Check for CI config
ls -la /Users/oliver/projects/the-village/.github/

# Verify package manager
cd /Users/oliver/projects/the-village
cat package.json | grep packageManager

# Test CI commands locally
cd /Users/oliver/projects/the-village/apps/api
pytest -q --cov=. --cov-report=xml  # Will fail
```

## Hypothesis
1. CI configuration not yet merged to main branch
2. Development happening in feature branches with CI
3. Package manager standardization needed (pnpm vs npm)
4. Missing test dependencies in requirements.txt

## Severity/Blast Radius
- **Severity**: Critical
- **Affected Components**: 
  - All automated testing
  - Code quality checks
  - Deployment pipeline
  - Pull request validation
- **User Impact**: No quality gates on main branch merges

## Readiness for Ticketisation
- [x] Issue clearly defined
- [x] Evidence documented
- [x] Reproduction steps verified
- [x] Root cause hypothesized
- [x] Impact assessed

**Status**: [x] Ready for ticket / [ ] Needs more information
