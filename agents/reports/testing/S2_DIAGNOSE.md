# Diagnostic Report - Test Coverage Gaps

## Component
Testing Infrastructure - API Test Coverage

## Purpose
Ensure comprehensive test coverage for all API endpoints, error paths, and edge cases to maintain code quality and prevent regressions.

## Boundaries/Dependencies
- **Testing Framework**: pytest, pytest-cov
- **Current Coverage**: 75.87% total
- **Affected Modules**: Primarily api/* endpoints
- **Dependencies**: Test database, mocked external services

## Issue Summary
- Critical endpoints with low/no coverage
- Missing error path testing
- No integration tests for complex workflows
- Untested external service integrations

## Evidence
### Issue 1: Low Coverage in Critical Endpoints
- **File(s)**: `apps/api/api/ideas.py`
- **Coverage**: 48% (58 statements missed)
- **Missing Coverage**:
  ```
  Lines 35-46, 55-63, 73-81, 104-109, 123, 147, 187-198, 207-216, 225-236
  ```
- **Critical Gaps**: Update, delete, provenance export, stem operations

### Issue 2: Playlist Endpoint Nearly Untested
- **File(s)**: `apps/api/api/playlists.py`
- **Coverage**: 29% (49 statements missed)
- **Missing Coverage**:
  ```
  Lines 14-15, 19-24, 28-32, 36-48, 51-66, 69-81
  ```

### Issue 3: Zero Coverage for External Services
- **File(s)**: `apps/api/core/acrcloud.py`
- **Coverage**: 0% (13 statements missed)
- **Impact**: Audio fingerprinting integration completely untested

### Issue 4: Security Module Gaps
- **File(s)**: `apps/api/core/security.py`
- **Coverage**: 70% (21 statements missed)
- **Missing**: Admin authentication, token refresh edge cases

## Reproduction Steps
```bash
cd /Users/oliver/projects/the-village/apps/api
source ../../.venv/bin/activate
pytest --cov=. --cov-report=term-missing --cov-report=html
open htmlcov/index.html
```

## Hypothesis
1. **Focus on Happy Path**: Tests primarily cover successful scenarios
2. **Complex Features Skipped**: Multi-step workflows (playlists, stems) lack tests
3. **External Services Mocked Out**: No integration testing strategy
4. **Time Constraints**: MVP focused on core functionality testing only

## Severity/Blast Radius
- **Severity**: High
- **Affected Components**: 
  - All untested endpoints could harbor bugs
  - Error handling paths unverified
  - Security vulnerabilities possible in untested code
- **User Impact**: Potential runtime errors, data corruption, security issues

## Readiness for Ticketisation
- [x] Issue clearly defined
- [x] Evidence documented
- [x] Reproduction steps verified
- [x] Root cause hypothesized
- [x] Impact assessed

**Status**: [x] Ready for ticket / [ ] Needs more information
