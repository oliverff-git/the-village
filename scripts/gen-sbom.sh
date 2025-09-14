#!/usr/bin/env bash
set -euo pipefail
mkdir -p sbom
if ! command -v syft >/dev/null 2>&1; then
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
fi
syft . -o cyclonedx-json > sbom/repo.cdx.json
echo "SBOM at sbom/repo.cdx.json"
