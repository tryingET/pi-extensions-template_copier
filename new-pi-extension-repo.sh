#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <repo-name> [command-name]" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

REPO_NAME="$1"
COMMAND_NAME="${2:-$1}"
ROOT_DIR="$HOME/programming/pi-extensions"
TARGET_DIR="$ROOT_DIR/$REPO_NAME"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Error: repo-name must match [a-zA-Z0-9._-]+" >&2
  exit 1
fi

if [[ ! "$COMMAND_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Error: command-name must match [a-zA-Z0-9._-]+" >&2
  exit 1
fi

if [[ -e "$TARGET_DIR" ]]; then
  echo "Error: target already exists: $TARGET_DIR" >&2
  exit 1
fi

if ! command -v copier >/dev/null 2>&1; then
  echo "Error: copier is not installed." >&2
  echo "Install one of:" >&2
  echo "  pipx install copier" >&2
  echo "  uv tool install copier" >&2
  echo "  pip install copier" >&2
  exit 1
fi

# Generation-only wrapper around Copier.
# In generated repos: prefer `copier update --trust` when `_commit` is present;
# otherwise use `copier recopy --trust`.
copier copy \
  --trust \
  -d repo_name="$REPO_NAME" \
  -d command_name="$COMMAND_NAME" \
  "$TEMPLATE_DIR" \
  "$TARGET_DIR"

if [[ ! -d "$TARGET_DIR/.git" ]]; then
  (
    cd "$TARGET_DIR"
    git init -q
    if [[ -x "./scripts/install-hooks.sh" ]]; then
      ./scripts/install-hooks.sh >/dev/null || true
    fi
  )
fi

echo "Created: $TARGET_DIR"
