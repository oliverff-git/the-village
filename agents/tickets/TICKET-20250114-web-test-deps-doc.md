# Implementation Ticket - Web Test Dependencies Documentation

## Title
TICKET-20250114-web-test-deps-doc

## Background/Problem
- **Linked DIAG**: [/agents/reports/web/S4_DIAGNOSE.md]
- **Problem Statement**: Web unit tests fail with rollup module errors when dependencies not properly installed at workspace level
- **Business Impact**: Developer confusion and productivity loss when tests fail mysteriously

## Affected Paths
```
README.md
apps/web/README.md (create if not exists)
.github/CONTRIBUTING.md (if exists)
```

## Scope
### In Scope
- [x] Document proper dependency installation process
- [x] Add troubleshooting section for common issues
- [x] Update developer setup instructions
- [x] Add CI cache considerations

### Out of Scope
- [ ] Changing pnpm configuration
- [ ] Modifying test setup
- [ ] Altering dependency versions

## Implementation Plan
1. **Step 1**: Update main README with clear workspace setup instructions
2. **Step 2**: Create/update web-specific README with test running guide
3. **Step 3**: Add troubleshooting section for rollup module errors
4. **Step 4**: Document the workspace-level vs package-level install difference

## Acceptance Criteria
```bash
# Command 1: Documentation exists
$ ls -la README.md apps/web/README.md
# Expected output: Both files exist

# Command 2: Setup instructions work
$ grep -A5 "pnpm install" README.md
# Expected output: Clear instructions visible

# Command 3: Troubleshooting present
$ grep -i "rollup\|module not found" README.md apps/web/README.md
# Expected output: Troubleshooting section found
```

## Test Plan
### Existing Tests to Update
None - documentation only

### New Tests to Add
None - documentation only

### Test Commands
```bash
# Verify instructions by following them
rm -rf node_modules apps/*/node_modules
pnpm install
cd apps/web && pnpm test -- --run
```

## Observability
- [ ] Track README views/searches in repo analytics
- [ ] Monitor issue reports about setup problems

## Risks/Rollback
### Risks
1. **Risk**: Incorrect instructions
   - **Mitigation**: Test on clean environment

### Rollback Plan
```bash
# Simple git revert
git revert HEAD
```

## Branching/Commits
- **Branch**: `feature/TICKET-20250114-web-test-deps-doc`
- **Commit Pattern**: `[TICKET-20250114] docs: add web test dependency setup guide`

## RACI
- **Responsible**: Documentation maintainer
- **Accountable**: Engineering lead
- **Consulted**: Frontend developers
- **Informed**: All developers

## Traceability
- **DIAG**: [/agents/reports/web/S4_DIAGNOSE.md]
- **VERIFY**: [/agents/verification/S4_VERIFY_20250114_web_rollup_fix.md]
- **STATUS**: [/agents/status/PROJECT_STATUS.md]

## Documentation Template
```markdown
## Setup Instructions

### First Time Setup
\`\`\`bash
# Install dependencies at workspace level (REQUIRED)
pnpm install

# This installs all workspace dependencies including platform-specific binaries
\`\`\`

### Running Tests

#### Web Tests
\`\`\`bash
cd apps/web
pnpm test          # Run in watch mode
pnpm test -- --run # Run once and exit
\`\`\`

### Troubleshooting

#### "Cannot find module @rollup/rollup-darwin-*" Error
This occurs when dependencies are not properly installed at the workspace level.

Solution:
\`\`\`bash
# From repository root (not apps/web)
pnpm install
\`\`\`

Note: Running `pnpm install` inside apps/web alone is insufficient due to how pnpm workspaces handle platform-specific optional dependencies.
```

---
Created: 2025-01-14
Priority: P2 (Documentation)
