# Diagnostic Report - Security Configuration

## Component
Security Infrastructure - Authentication, Secrets, and Headers

## Purpose
Protect user data, prevent unauthorized access, and ensure secure communication between services.

## Boundaries/Dependencies
- **Authentication**: JWT-based with OAuth2
- **Password Hashing**: Argon2id
- **Configuration**: Environment variables via .env
- **CORS**: Configured for allowed origins

## Issue Summary
- Hardcoded default secrets in source code
- Missing security headers
- Rate limiting not implemented despite configuration
- No secret rotation mechanism
- Potential information disclosure

## Evidence
### Issue 1: Hardcoded Secrets in Configuration
- **File(s)**: `apps/api/core/config.py`
- **Evidence**:
  ```python
  JWT_SECRET: str = "change_me_very_secret_key"
  JWT_REFRESH_SECRET: str = "change_me_refresh_secret"
  S3_ACCESS_KEY: str = "minioadmin"
  S3_SECRET_KEY: str = "minioadmin"
  ADMIN_PASSWORD: str = "change_me_admin_password"
  ```
- **Lines**: 25-26, 18-19, 47

### Issue 2: Missing Security Headers
- **File(s)**: `apps/api/main.py`
- **Missing Headers**:
  - X-Content-Type-Options: nosniff
  - X-Frame-Options: DENY
  - Strict-Transport-Security
  - Content-Security-Policy
- **Current**: Only X-Request-Id header added

### Issue 3: Rate Limiting Configuration Unused
- **File(s)**: `apps/api/core/config.py`
- **Configuration Present**:
  ```python
  RATE_LIMIT_SIGNUP_PER_DAY: int = 10
  RATE_LIMIT_INVITES_PER_USER: int = 5
  RATE_LIMIT_UPLOADS_PER_HOUR: int = 20
  ```
- **Implementation**: Not found in codebase

### Issue 4: JWT Algorithm Hardcoded
- **File(s)**: `apps/api/core/security.py`
- **Line 86**: Algorithm retrieved from settings but no validation
- **Risk**: Could be changed to 'none' algorithm attack

## Reproduction Steps
```bash
# Check for secrets in code
cd /Users/oliver/projects/the-village
grep -r "change_me" apps/api/
grep -r "minioadmin" apps/api/

# Test missing headers
curl -I http://localhost:8000/health

# Check rate limiting
# Make multiple requests rapidly - no throttling occurs
```

## Hypothesis
1. **Development Defaults**: Secrets left from initial development
2. **Security as Afterthought**: Basic auth implemented, advanced security postponed
3. **Framework Defaults**: Relying on FastAPI defaults without hardening
4. **MVP Scope**: Security hardening deferred to post-launch

## Severity/Blast Radius
- **Severity**: Critical
- **Affected Components**: 
  - All authenticated endpoints
  - Admin access
  - S3 storage access
  - User sessions
- **User Impact**: 
  - Account takeover risk
  - Data exposure
  - Denial of service vulnerability

## Readiness for Ticketisation
- [x] Issue clearly defined
- [x] Evidence documented
- [x] Reproduction steps verified
- [x] Root cause hypothesized
- [x] Impact assessed

**Status**: [x] Ready for ticket / [ ] Needs more information
