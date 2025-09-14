# Implementation Ticket - CI/CD Pipeline Configuration

## Title
Setup GitHub Actions CI/CD Pipeline for Main Branch

## Background/Problem Statement
The main branch of The Village repository lacks any CI/CD configuration, meaning no automated quality gates exist for code merges. While CI configurations exist in various worktree branches (claude/*, codex/*), the main branch has no .github directory, preventing automated testing, linting, and deployment processes.

This is a critical gap that allows unvalidated code to be merged to main, increasing the risk of regressions and quality issues.

**Link to diagnostic report**: [Infrastructure Diagnostic](../reports/infrastructure/S1_DIAGNOSE.md)

## Affected Paths
- `.github/` (directory to be created)
- `.github/workflows/` (directory to be created)
- `.github/workflows/ci.yml` (file to be created)
- `.github/dependabot.yml` (optional, for dependency updates)
- `.github/CODEOWNERS` (optional, for review assignments)

## Scope
### In Scope
- Create .github directory structure
- Implement CI workflow for both API and Web applications
- Configure test running for Python (pytest) and Node.js (vitest)
- Setup linting jobs (ruff, black for Python; ESLint for TypeScript)
- Configure build verification for both applications
- Add basic E2E smoke test job
- Setup job concurrency and branch protection rules

### Out of Scope  
- Deployment workflows (separate ticket)
- Security scanning workflows (separate ticket)
- Advanced caching optimizations
- Coverage reporting (blocked by missing pytest-cov)
- Pre-commit hooks (separate ticket)

## Implementation Plan
1. Create .github directory structure in repository root
2. Reference existing CI configurations from worktree branches as templates
3. Implement multi-job workflow with proper dependencies:
   - Linting jobs (Python and TypeScript)
   - Unit test jobs (API and Web)
   - Build verification jobs
   - E2E smoke test (depends on unit tests)
4. Configure workflow triggers for pull requests and main branch pushes
5. Setup concurrency groups to cancel outdated runs
6. Add workflow status badges to README.md
7. Configure branch protection rules requiring CI passage

## Acceptance Criteria / Definition of Done
- [ ] `.github/workflows/ci.yml` exists in main branch
- [ ] Workflow triggers on: pull requests, pushes to main
- [ ] Python linting passes: `ruff . && black --check .`
- [ ] Python tests run: `pytest` executes successfully
- [ ] Web build completes: `pnpm --filter web build`
- [ ] Web tests run: `pnpm --filter web test`
- [ ] E2E smoke test executes after unit tests
- [ ] Workflow shows green checkmark on successful run
- [ ] Branch protection enabled requiring CI passage

## Test Plan
### Tests to Add
- No new tests needed (infrastructure configuration)

### Tests to Run
- Trigger workflow via pull request creation
- Verify all jobs execute in correct order
- Confirm failure in any job blocks merge
- Test concurrent run cancellation

## Observability/Telemetry Updates
- Workflow run times visible in GitHub Actions tab
- Job-level timing and logs available
- Failure notifications to repository maintainers

## Risks and Rollback Considerations
### Risks
- Initial failures due to environment differences
- Missing dependencies not caught locally
- Flaky tests causing intermittent failures

### Rollback Plan
- Disable branch protection rules temporarily
- Remove workflow file to stop execution
- Fix issues and re-enable

## Branching and Commit Guidelines
- **Branch Name**: `feature/TICKET-20241214-cicd-setup`
- **Commit Message Format**: `[TICKET-20241214] ci: Add GitHub Actions workflow for CI/CD`

## RACI Matrix
- **Responsible**: Human Developer / External Implementation Agent
- **Accountable**: Tech Lead / Repository Owner
- **Consulted**: Claude Strategist (diagnostic analysis)
- **Informed**: Cursor Ops (will verify CI execution)

## Traceability Links
- **Diagnostic Report**: [Infrastructure Diagnostic](../reports/infrastructure/S1_DIAGNOSE.md)
- **Verification Report**: [To be added after implementation](../verification/...)
- **Status Update**: [PROJECT_STATUS.md](../status/PROJECT_STATUS.md)
