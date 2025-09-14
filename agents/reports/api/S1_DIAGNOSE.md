# Diagnostic Report - API Module

## Component
apps/api - FastAPI Backend Service

## Purpose
RESTful API service providing authentication, idea management, invites, mood tracking, playlists, and content moderation functionality with PostgreSQL persistence and Redis/RQ for background jobs.

## Boundaries/Dependencies
- **External Services**: PostgreSQL, Redis, MinIO (S3-compatible storage)
- **Python Dependencies**: FastAPI, SQLAlchemy, Pydantic, Alembic, passlib, prometheus-fastapi-instrumentator
- **Internal Dependencies**: Shared models, schemas, core utilities
- **Interfaces**: HTTP REST API on port 8000

## Issue Summary
- Missing test coverage reporting dependency (pytest-cov)
- Pydantic v2 deprecation warnings (9 occurrences)
- Passlib deprecation warnings for Python 3.13 compatibility
- Potential Ruff linting issues mentioned in Sprint 3 report

## Evidence
### Issue 1: Missing pytest-cov
- **File(s)**: `/Users/oliver/projects/the-village/apps/api/pyproject.toml`
- **Error/Log Excerpt**:
```
ERROR: usage: __main__.py [options] [file_or_dir] [file_or_dir] [...]
__main__.py: error: unrecognized arguments: --cov=. --cov-report=html --cov-report=term
```
- **Line Numbers**: Line 14 in pyproject.toml

### Issue 2: Pydantic Deprecation Warnings
- **File(s)**: Multiple schema files using class-based Config
- **Error/Log Excerpt**:
```
PydanticDeprecatedSince20: Support for class-based `config` is deprecated, use ConfigDict instead
```
- **Occurrences**: 9 warnings during test run

### Issue 3: Passlib Deprecation Warnings
- **File(s)**: Uses passlib for password hashing
- **Error/Log Excerpt**:
```
DeprecationWarning: 'crypt' is deprecated and slated for removal in Python 3.13
DeprecationWarning: Accessing argon2.__version__ is deprecated
```

## Reproduction Steps
```bash
# Missing pytest-cov
cd /Users/oliver/projects/the-village/apps/api
python -m pytest -v

# Deprecation warnings
cd /Users/oliver/projects/the-village/apps/api
python -m pytest -v tests/ --tb=short -o addopts="" -W error::DeprecationWarning
```

## Hypothesis
1. **pytest-cov**: Not listed in requirements.txt but configured in pyproject.toml
2. **Pydantic warnings**: Code written for Pydantic v1, needs migration to v2 ConfigDict pattern
3. **Passlib warnings**: Using deprecated Python stdlib features, may need update or alternative library

## Severity/Blast Radius
- **Severity**: 
  - pytest-cov: Low (development only)
  - Pydantic: Medium (technical debt, will break in v3)
  - Passlib: Medium (will break in Python 3.13)
- **Affected Components**: All API tests, all Pydantic schemas, authentication system
- **User Impact**: None immediate, but blocks Python 3.13 upgrade and Pydantic v3

## Readiness for Ticketisation
- [x] Issue clearly defined
- [x] Evidence documented
- [x] Reproduction steps verified
- [x] Root cause hypothesized
- [x] Impact assessed

**Status**: [x] Ready for ticket / [ ] Needs more information
