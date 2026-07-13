#!/usr/bin/env bash
set -euo pipefail

terraform_bin="${TERRAFORM:-terraform}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

roots=(
  "bootstrap/backend-bootstrap"
  "live/dev/01-foundation"
  "live/dev/02-vector-store"
  "live/dev/03-knowledge-base"
  "live/dev/04-data-sources/s3-docs"
  "live/dev/04-data-sources/custom-api"
  "examples/complete-s3-vectors"
)

for root in "${roots[@]}"; do
  printf 'Initializing %s\n' "$root"
  "$terraform_bin" -chdir="$repo_root/$root" init \
    -backend=false \
    -input=false \
    -lockfile=readonly \
    -no-color >/dev/null
  "$terraform_bin" -chdir="$repo_root/$root" validate -no-color
done
