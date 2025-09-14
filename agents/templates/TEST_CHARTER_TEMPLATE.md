# Test Charter Template

## Charter ID
TC_YYYYMMDD_slug

## Objective
[What specific behavior/risk are we investigating?]

## Scope
### Components
- [ ] Module/Service: 
- [ ] Features: 

### Test Types
- [ ] Unit
- [ ] Integration
- [ ] E2E
- [ ] Performance
- [ ] Security

## Pre-requisites/Data
### Environment Setup
```bash
# Commands to prepare environment
```

### Test Data
- [ ] Sample files: 
- [ ] Database state: 
- [ ] External services: 

## Commands to Run
### Sequential Execution
```bash
# Step 1: Setup
$ 

# Step 2: Execute test scenario
$ 

# Step 3: Verify results
$ 

# Step 4: Cleanup
$ 
```

### Parallel Execution (if safe)
```bash
# Can run simultaneously
$ command1 &
$ command2 &
$ wait
```

## Signals to Capture
- [ ] Exit codes
- [ ] Performance metrics (time, memory, CPU)
- [ ] Log patterns
- [ ] Database state changes
- [ ] File system artifacts

## Pass/Fail Criteria
### PASS Conditions
- [ ] All commands exit 0
- [ ] Response time < Xs
- [ ] No error logs matching pattern X
- [ ] Expected artifacts created

### FAIL Conditions
- [ ] Any command exits non-zero
- [ ] Timeout exceeded
- [ ] Error patterns detected
- [ ] Missing expected outputs

## Risk Assessment
- **Blast Radius**: [What could go wrong?]
- **Rollback**: [How to recover?]
