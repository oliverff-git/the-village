# Implementation Ticket - Migrate Pydantic Schemas to V2 Pattern

## Title
Update All Pydantic Models from Class Config to ConfigDict Pattern

## Background/Problem Statement
The API codebase generates 9 deprecation warnings during test runs due to using Pydantic v1-style class-based configuration. Pydantic v2 deprecates the `class Config` pattern in favor of `model_config = ConfigDict()`. While currently only warnings, this will become a breaking change in Pydantic v3, blocking future upgrades.

The warnings indicate systematic use of the old pattern across multiple schema files, requiring a comprehensive update to maintain compatibility with modern Pydantic versions.

**Link to diagnostic report**: [API Module Diagnostic](../reports/api/S1_DIAGNOSE.md)

## Affected Paths
- `apps/api/schemas/` (all schema files)
  - `apps/api/schemas/auth.py`
  - `apps/api/schemas/idea.py`
  - `apps/api/schemas/invite.py`
  - `apps/api/schemas/mood.py`
  - `apps/api/schemas/playlist.py`
  - `apps/api/schemas/report.py`
  - `apps/api/schemas/upload.py`
- Any other files using Pydantic BaseModel with class Config

## Scope
### In Scope
- Replace all `class Config:` blocks with `model_config = ConfigDict(...)`
- Update configuration attributes to ConfigDict format
- Ensure all Pydantic model behaviors remain identical
- Update any custom validators to v2 syntax if needed
- Verify no functional regressions

### Out of Scope  
- Upgrading Pydantic version (stay on current)
- Refactoring model structure or relationships
- Adding new fields or validation logic
- Performance optimizations

## Implementation Plan
1. Audit all Pydantic models to identify Config usage patterns
2. Create mapping of old Config attributes to new ConfigDict keys
3. Update each schema file systematically:
   - Replace class Config with model_config
   - Translate configuration options to new format
   - Test each model individually
4. Run full test suite to verify no behavior changes
5. Check for any remaining deprecation warnings
6. Update any documentation referencing the old pattern

## Acceptance Criteria / Definition of Done
- [ ] Zero Pydantic deprecation warnings in test output
- [ ] All schema files use `model_config = ConfigDict()` pattern
- [ ] All existing tests continue to pass
- [ ] No functional changes to API behavior
- [ ] Code follows consistent pattern across all schemas
- [ ] No new linting errors introduced

## Test Plan
### Tests to Add
- No new tests required (refactoring only)

### Tests to Run
- `pytest -v tests/ -W error::DeprecationWarning` - should run without Pydantic warnings
- Full API test suite must pass
- Manual verification of API endpoints return same responses

## Observability/Telemetry Updates
- No changes required

## Risks and Rollback Considerations
### Risks
- Subtle behavior differences between v1 and v2 patterns
- Missing some schema files in migration
- Custom validators may need syntax updates

### Rollback Plan
- Git revert of the migration commit
- All changes should be in single commit for easy rollback
- No database or external system changes

## Branching and Commit Guidelines
- **Branch Name**: `feature/TICKET-20241214-pydantic-v2-migration`
- **Commit Message Format**: `[TICKET-20241214] refactor: Migrate Pydantic schemas from Config to ConfigDict`

## RACI Matrix
- **Responsible**: Human Developer / External Implementation Agent
- **Accountable**: API Tech Lead
- **Consulted**: Claude Strategist (diagnostic analysis)
- **Informed**: Cursor Ops (will verify warning elimination)

## Traceability Links
- **Diagnostic Report**: [API Module Diagnostic](../reports/api/S1_DIAGNOSE.md)
- **Verification Report**: [To be added after implementation](../verification/...)
- **Status Update**: [PROJECT_STATUS.md](../status/PROJECT_STATUS.md)
