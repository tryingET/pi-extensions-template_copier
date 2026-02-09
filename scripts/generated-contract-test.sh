#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_SRC="${1:-$ROOT_DIR}"
REPO_NAME="${CONTRACT_REPO_NAME:-template-contract}"
COMMAND_NAME="${CONTRACT_COMMAND_NAME:-template-contract}"
TEMPLATE_REF="${PI_TEMPLATE_REF:-HEAD}"

if ! command -v copier >/dev/null 2>&1; then
  echo "copier is required for generated-contract testing" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
DEST_DIR="$TMP_DIR/$REPO_NAME"

cleanup() {
  if [[ "${KEEP_CONTRACT_DIR:-0}" == "1" ]]; then
    echo "Keeping contract test directory: $TMP_DIR"
  else
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

copier_args=(
  copy
  --trust
  --defaults
  -d "repo_name=$REPO_NAME"
  -d "command_name=$COMMAND_NAME"
)

if [[ -n "$TEMPLATE_REF" ]]; then
  copier_args+=(--vcs-ref "$TEMPLATE_REF")
fi

copier "${copier_args[@]}" "$TEMPLATE_SRC" "$DEST_DIR"

errors=0

fail() {
  echo "$1" >&2
  ((errors+=1))
}

required_files=(
  ".copier-answers.yml"
  "README.md"
  "AGENTS.md"
  "package.json"
  "extensions/${COMMAND_NAME}.ts"
  ".github/workflows/ci.yml"
  ".github/workflows/release-please.yml"
  ".github/workflows/publish.yml"
  ".github/workflows/vouch-check-pr.yml"
  ".github/workflows/vouch-manage.yml"
  "docs/org/operating_model.md"
  "scripts/validate-structure.sh"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$DEST_DIR/$file" ]]; then
    fail "Missing generated contract file: $file"
  fi
done

forbidden_paths=(
  "copier-template"
  "copier.yml"
  "new-pi-extension-repo.sh"
  "scripts/template-guardrails.sh"
  "scripts/smoke-test-template.sh"
  "scripts/generated-contract-test.sh"
  ".github/workflows/template-guardrails.yml"
)

for path in "${forbidden_paths[@]}"; do
  if [[ -e "$DEST_DIR/$path" ]]; then
    fail "Template-source path leaked into generated repo: $path"
  fi
done

jinja_hits="$(find "$DEST_DIR" -type f -name "*.jinja" -print)"
if [[ -n "$jinja_hits" ]]; then
  fail "Template source files leaked (*.jinja):"
  echo "$jinja_hits" >&2
fi

if [[ "$errors" -gt 0 ]]; then
  echo "Generated contract test failed with $errors issue(s)." >&2
  exit 1
fi

echo "Generated contract test passed: $DEST_DIR"
