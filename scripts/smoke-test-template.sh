#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_SRC="${1:-$ROOT_DIR}"
REPO_NAME="${SMOKE_REPO_NAME:-template-smoke}"
COMMAND_NAME="${SMOKE_COMMAND_NAME:-template-smoke}"
TEMPLATE_REF="${PI_TEMPLATE_REF:-HEAD}"

if ! command -v copier >/dev/null 2>&1; then
  echo "copier is required for smoke testing" >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required for smoke testing" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
DEST_DIR="$TMP_DIR/$REPO_NAME"

cleanup() {
  if [[ "${KEEP_SMOKE_DIR:-0}" == "1" ]]; then
    echo "Keeping smoke directory: $TMP_DIR"
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

(
  cd "$DEST_DIR"
  npm run check
)

echo "Smoke test passed: $DEST_DIR"
