#!/usr/bin/env bash
# Regenerate the inputs/outputs reference with terraform-docs.
# Usage: ./scripts/generate-docs.sh [--check]   (--check fails if docs are stale)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$ROOT/.terraform-docs.yml"
cd "$ROOT"

command -v terraform-docs >/dev/null 2>&1 || { echo "terraform-docs is not installed" >&2; exit 1; }

for dir in modules/*/ platform/; do
  terraform-docs --config "$CONFIG" "$dir" >/dev/null
done
terraform-docs --config "$CONFIG" --output-file docs/reference.md . >/dev/null

if [[ "${1:-}" == "--check" ]]; then
  if [[ -n "$(git status --porcelain -- '*.md')" ]]; then
    git status --porcelain -- '*.md' >&2
    echo "Documentation is out of date: run ./scripts/generate-docs.sh and commit the result." >&2
    exit 1
  fi
fi
