# Implementation Ticket - Add Test Coverage Tooling

## Title
Install and Configure pytest-cov for Test Coverage Reporting

## Background/Problem Statement
The API project's pyproject.toml is configured to use pytest-cov for test coverage reporting, but the package is not installed. This causes pytest to fail when run without overriding the configuration. Additionally, the CI pipeline expects coverage reports with an 85% threshold, which will fail without the proper tooling installed.

Coverage reporting is essential for maintaining code quality and identifying untested code paths.

**Link to diagnostic report**: [API Module Diagnostic](../reports/api/S1_DIAGNOSE.md)

## Affected Paths
- `apps/api/requirements.txt` (add pytest-cov)
- `apps/api/pyproject.toml` (verify configuration)
- `.gitignore` (ensure coverage artifacts ignored)
- CI workflow (once created) will use coverage

## Scope
### In Scope
- Add pytest-cov to requirements.txt
- Verify coverage configuration in pyproject.toml
- Ensure coverage reports generate correctly
- Add htmlcov/ and coverage.xml to .gitignore
- Document coverage commands for developers
- Verify CI compatibility

### Out of Scope  
- Improving actual code coverage percentages
- Adding coverage to web/frontend tests
- Setting up coverage badges
- Integrating with external coverage services

## Implementation Plan
1. Add pytest-cov to apps/api/requirements.txt
2. Install updated dependencies
3. Run tests with coverage to verify configuration
4. Check generated reports (HTML and XML)
5. Update .gitignore for coverage artifacts
6. Document coverage commands in API README
7. Test with CI coverage requirements (85% threshold)

## Acceptance Criteria / Definition of Done
- [ ] `pytest` runs without configuration override errors
- [ ] Coverage reports generate in both HTML and terminal
- [ ] `coverage.xml` generates for CI consumption
- [ ] Coverage artifacts are gitignored
- [ ] Documentation includes coverage commands
- [ ] Coverage percentage is displayed in test output

## Test Plan
### Tests to Add
- No new tests needed (tooling addition)

### Tests to Run
- `cd apps/api && pytest` - should run with coverage
- `cd apps/api && pytest --cov-fail-under=75` - verify threshold works
- Check htmlcov/index.html opens correctly

## Observability/Telemetry Updates
- Coverage metrics will be visible in:
  - Terminal output during test runs
  - HTML reports for detailed analysis
  - XML reports for CI integration

## Risks and Rollback Considerations
### Risks
- Current coverage might be below CI threshold (85%)
- Performance impact on test execution time
- Large HTML reports in git if not ignored

### Rollback Plan
- Remove pytest-cov from requirements.txt
- Override pytest settings with `-o addopts=""`
- No code changes required

## Branching and Commit Guidelines
- **Branch Name**: `feature/TICKET-20241214-coverage-tooling`
- **Commit Message Format**: `[TICKET-20241214] build: Add pytest-cov for test coverage reporting`

## RACI Matrix
- **Responsible**: Human Developer / External Implementation Agent
- **Accountable**: QA Lead / API Tech Lead
- **Consulted**: Claude Strategist (diagnostic analysis)
- **Informed**: Cursor Ops (will use in verification), All API Developers

## Traceability Links
- **Diagnostic Report**: [API Module Diagnostic](../reports/api/S1_DIAGNOSE.md)
- **Verification Report**: [To be added after implementation](../verification/...)
- **Status Update**: [PROJECT_STATUS.md](../status/PROJECT_STATUS.md)
