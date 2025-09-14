# Implementation Ticket - Fix Python 3.13 Compatibility for Password Hashing

## Title
Replace Deprecated Passlib Dependencies for Python 3.13 Compatibility

## Background/Problem Statement
The authentication system uses passlib for password hashing, which internally depends on Python's `crypt` module. This module is deprecated and will be removed in Python 3.13. Additionally, passlib is accessing deprecated attributes in the argon2-cffi library. These deprecation warnings indicate that the application will break when upgrading to Python 3.13.

Maintaining Python version compatibility is crucial for security updates and long-term maintenance of the application.

**Link to diagnostic report**: [API Module Diagnostic](../reports/api/S1_DIAGNOSE.md)

## Affected Paths
- `apps/api/core/security.py` (password hashing implementation)
- `apps/api/requirements.txt` (passlib dependency)
- Any authentication-related code using passlib
- Test files that verify password hashing

## Scope
### In Scope
- Evaluate passlib's Python 3.13 compatibility status
- Implement alternative if passlib won't be compatible
- Update password hashing to use supported libraries
- Ensure backward compatibility with existing password hashes
- Maintain current security standards (Argon2 hashing)

### Out of Scope  
- Changing hashing algorithm (keep Argon2)
- Forcing password resets for existing users
- Upgrading to Python 3.13 now
- Modifying authentication flow logic

## Implementation Plan
1. Research passlib maintenance status and Python 3.13 roadmap
2. Identify modern alternatives (e.g., argon2-cffi directly)
3. Implement password hashing wrapper that:
   - Uses new library for hashing
   - Maintains compatibility with existing hashes
   - Provides same interface as current implementation
4. Update security module to use new implementation
5. Verify all existing passwords still validate
6. Update requirements.txt with new dependencies
7. Document migration for other developers

## Acceptance Criteria / Definition of Done
- [ ] No deprecation warnings related to crypt or argon2.__version__
- [ ] All existing user passwords continue to work
- [ ] New passwords are hashed with compliant library
- [ ] Security standards maintained (Argon2)
- [ ] Tests pass without deprecation warnings
- [ ] Compatible with Python 3.11 through 3.13

## Test Plan
### Tests to Add
- **Test Name**: test_password_compatibility
  - **Location**: tests/test_security.py
  - **Purpose**: Verify old passlib hashes still validate

### Tests to Run
- All authentication tests must pass
- `pytest -W error::DeprecationWarning` shows no passlib warnings
- Manual test: existing user can still login

## Observability/Telemetry Updates
- Log migration status during startup
- Monitor authentication failures after deployment

## Risks and Rollback Considerations
### Risks
- Existing passwords might not validate
- Performance differences in new library
- Security vulnerabilities in migration

### Rollback Plan
- Keep passlib as fallback for validation
- Feature flag for new vs old hashing
- Gradual rollout with monitoring

## Branching and Commit Guidelines
- **Branch Name**: `feature/TICKET-20241214-python313-passlib`
- **Commit Message Format**: `[TICKET-20241214] fix: Replace deprecated passlib for Python 3.13 compatibility`

## RACI Matrix
- **Responsible**: Human Developer / External Implementation Agent
- **Accountable**: Security Lead / API Tech Lead
- **Consulted**: Claude Strategist (diagnostic), Security Team
- **Informed**: Cursor Ops (verification), DevOps (deployment)

## Traceability Links
- **Diagnostic Report**: [API Module Diagnostic](../reports/api/S1_DIAGNOSE.md)
- **Verification Report**: [To be added after implementation](../verification/...)
- **Status Update**: [PROJECT_STATUS.md](../status/PROJECT_STATUS.md)
