#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: new-pi-extension-repo.sh <repo-name> [command-name]

Optional env:
  PI_TEMPLATE_REF=<tag|commit>
    Override Copier --vcs-ref.
    Defaults to HEAD when template source is a local git checkout.
  PI_GITHUB_MAINTAINER=<handle>
    GitHub handle to seed in generated .github/VOUCHED.td.
    If unset, tries `gh api user -q .login`, then falls back to tryingET.
  ALLOW_DIRTY_TEMPLATE=1
    Allow generation from uncommitted template changes (not recommended for production).
USAGE
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
TEMPLATE_REF="${PI_TEMPLATE_REF:-}"
GITHUB_MAINTAINER="${PI_GITHUB_MAINTAINER:-}"

if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Error: repo-name must match [a-zA-Z0-9._-]+" >&2
  exit 1
fi

if [[ ! "$COMMAND_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Error: command-name must match [a-zA-Z0-9._-]+" >&2
  exit 1
fi

if [[ -z "$GITHUB_MAINTAINER" ]] && command -v gh >/dev/null 2>&1; then
  GITHUB_MAINTAINER="$(gh api user -q .login 2>/dev/null || true)"
fi

if [[ -z "$GITHUB_MAINTAINER" ]]; then
  GITHUB_MAINTAINER="tryingET"
fi

if [[ ! "$GITHUB_MAINTAINER" =~ ^[A-Za-z0-9-]+$ ]]; then
  echo "Error: PI_GITHUB_MAINTAINER must match GitHub handle characters [A-Za-z0-9-]+" >&2
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
if git -C "$TEMPLATE_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ -z "${ALLOW_DIRTY_TEMPLATE:-}" ]] && [[ -n "$(git -C "$TEMPLATE_DIR" status --porcelain)" ]]; then
    echo "Error: template repo has uncommitted changes: $TEMPLATE_DIR" >&2
    echo "Commit/stash changes before generation, or set ALLOW_DIRTY_TEMPLATE=1 to override." >&2
    exit 1
  fi

  if [[ -z "$TEMPLATE_REF" ]]; then
    TEMPLATE_REF="HEAD"
  fi
fi

copier_args=(
  copy
  --trust
  -d "repo_name=$REPO_NAME"
  -d "command_name=$COMMAND_NAME"
  -d "github_maintainer=$GITHUB_MAINTAINER"
)

if [[ -n "$TEMPLATE_REF" ]]; then
  copier_args+=(--vcs-ref "$TEMPLATE_REF")
fi

copier "${copier_args[@]}" "$TEMPLATE_DIR" "$TARGET_DIR"

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
