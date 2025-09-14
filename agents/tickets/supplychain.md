Agent: Codex
Objective: Dependabot/CodeQL/gitleaks finalized; SBOM optional.
Tests:
- CI shows secret scan and CodeQL jobs triggered.
Run:
- npx gitleaks detect --source . || true
Done when:
- CodeQL workflow present; gitleaks job runs in CI; optional SBOM script exists.
Notes:
- Ensure .github workflows for CodeQL; add scripts/gen-sbom.sh and sbom/.


