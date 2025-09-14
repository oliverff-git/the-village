# Implementation Ticket Template

## Title
[TICKET-YYYYMMDD-descriptive-slug]

## Background/Problem
- **Linked DIAG**: [/agents/reports/module/S1_DIAGNOSE.md]
- **Problem Statement**: 
- **Business Impact**: 

## Affected Paths
```
apps/module/path/to/file.ext
config/related/file.yml
```

## Scope
### In Scope
- [ ] 
- [ ] 

### Out of Scope
- [ ] 
- [ ] 

## Implementation Plan
1. **Step 1**: [Description - no code]
2. **Step 2**: [Description - no code]
3. **Step 3**: [Description - no code]

## Acceptance Criteria
```bash
# Command 1: Expected result
$ command here
# Expected output/behavior

# Command 2: Expected result
$ another command
# Expected output/behavior
```

## Test Plan
### Existing Tests to Update
- `path/to/test_file.py::test_name`

### New Tests to Add
- [ ] Unit test for X
- [ ] Integration test for Y

### Test Commands
```bash
# Run specific test suite
$ pytest path/to/tests -k "test_pattern"
```

## Observability
- [ ] Logging requirements
- [ ] Metrics to add
- [ ] Alerts needed

## Risks/Rollback
### Risks
1. **Risk**: [Description]
   - **Mitigation**: [Strategy]

### Rollback Plan
```bash
# Commands to rollback if needed
```

## Branching/Commits
- **Branch**: `feature/TICKET-YYYYMMDD-slug`
- **Commit Pattern**: `[TICKET-YYYYMMDD] type: description`

## RACI
- **Responsible**: [Who implements]
- **Accountable**: [Who owns success]
- **Consulted**: [Who provides input]
- **Informed**: [Who needs updates]

## Traceability
- **DIAG**: [Link to diagnostic report]
- **VERIFY**: [Link to verification report]
- **STATUS**: [Link to status update]