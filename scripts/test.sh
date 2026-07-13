#!/usr/bin/env bash
set -euo pipefail

terraform_bin="${TERRAFORM:-terraform}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/bedrock-kb-tests.XXXXXX")"
trap 'rm -rf "$temp_dir"' EXIT

"$terraform_bin" -chdir="$repo_root/modules/ingestion-config" test -no-color

cp -R "$repo_root/modules/knowledge-base-core" "$temp_dir/knowledge-base-core"
"$terraform_bin" -chdir="$temp_dir/knowledge-base-core" init \
  -backend=false \
  -input=false \
  -no-color >/dev/null
"$terraform_bin" -chdir="$temp_dir/knowledge-base-core" test -no-color

"$terraform_bin" -chdir="$repo_root/examples/complete-s3-vectors" test -no-color
