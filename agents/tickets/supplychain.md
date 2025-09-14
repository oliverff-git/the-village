Agent: SupplyChain (codex)
Objective: Dependabot/CodeQL/gitleaks in CI.
Scope: .github/*, scripts/gen-sbom.sh.
Tests: CI security workflows
Constraints: edit only inside this worktree
Run: npx gitleaks detect --source .
Acceptance: bots/jobs present.
