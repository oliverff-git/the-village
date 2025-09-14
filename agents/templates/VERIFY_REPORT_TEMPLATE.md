# Verification Report Template

## CI/Build Context
- **Branch**: 
- **Commit**: 
- **Timestamp**: 
- **Runner**: 

## Commands Executed
```bash
# Command 1
$ 
# Exit code: 

# Command 2
$ 
# Exit code: 
```

## Results Summary
### Build
- [ ] Compilation: PASS/FAIL
- [ ] Dependencies: PASS/FAIL
- [ ] Lint: PASS/FAIL

### Tests
- **Total**: X tests
- **Passed**: Y
- **Failed**: Z
- **Skipped**: N
- **Duration**: XXs

### Coverage
- **Overall**: XX%
- **Threshold**: XX%
- **Status**: PASS/FAIL

## Notable Logs/Excerpts
```
[Paste relevant output snippets]
```

## Flaky/Slow Tests
| Test | Duration | Flaky Count | Notes |
|------|----------|-------------|-------|
|      |          |             |       |

## Environment Notes
- **OS**: 
- **Runtime Versions**: 
- **Notable Configs**: 

## Status vs Tickets
| Ticket | Expected | Actual | Status |
|--------|----------|--------|--------|
|        |          |        |        |

## Next Actions
- [ ] 
- [ ] 

## Overall Status
**VERDICT**: [ ] GREEN (all pass) / [ ] AMBER (partial) / [ ] RED (blocked)