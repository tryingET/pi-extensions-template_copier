#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

STAGE="${1:-}"

usage() {
  echo "Usage: bash ./scripts/quality-gate.sh <lint|typecheck|pre-commit|pre-push|ci>" >&2
}

has_eslint_config() {
  [[ -f "eslint.config.js" ]] || [[ -f "eslint.config.cjs" ]] || [[ -f "eslint.config.mjs" ]] || \
  [[ -f ".eslintrc" ]] || [[ -f ".eslintrc.js" ]] || [[ -f ".eslintrc.cjs" ]] || \
  [[ -f ".eslintrc.json" ]] || [[ -f ".eslintrc.yaml" ]] || [[ -f ".eslintrc.yml" ]]
}

run_lint() {
  if ! has_eslint_config; then
    echo "lint: skipped (no eslint config found)"
    return 0
  fi

  if [[ -x "$ROOT_DIR/node_modules/.bin/eslint" ]]; then
    "$ROOT_DIR/node_modules/.bin/eslint" .
    return 0
  fi

  if command -v eslint >/dev/null 2>&1; then
    eslint .
    return 0
  fi

  echo "lint: eslint config detected but eslint binary is unavailable." >&2
  echo "Install eslint (npm install --save-dev eslint)." >&2
  exit 1
}

run_typecheck() {
  if [[ ! -f "$ROOT_DIR/tsconfig.json" ]]; then
    echo "typecheck: skipped (no tsconfig.json found)"
    return 0
  fi

  if [[ -x "$ROOT_DIR/node_modules/.bin/tsc" ]]; then
    "$ROOT_DIR/node_modules/.bin/tsc" --noEmit
    return 0
  fi

  if command -v tsc >/dev/null 2>&1; then
    tsc --noEmit
    return 0
  fi

  echo "typecheck: tsconfig.json found but tsc binary is unavailable." >&2
  echo "Install TypeScript (npm install --save-dev typescript)." >&2
  exit 1
}

run_structure_validation() {
  bash "$ROOT_DIR/scripts/validate-structure.sh"
}

run_pre_commit() {
  echo "== quality gate: pre-commit"
  run_structure_validation
  npm run lint
}

run_pre_push() {
  echo "== quality gate: pre-push"
  run_structure_validation
  npm run lint
  npm run typecheck
}

run_ci() {
  echo "== quality gate: ci"
  run_structure_validation
  npm run lint
  npm run typecheck
  npm pack --dry-run
}

case "$STAGE" in
  lint)
    run_lint
    ;;
  typecheck)
    run_typecheck
    ;;
  pre-commit)
    run_pre_commit
    ;;
  pre-push)
    run_pre_push
    ;;
  ci)
    run_ci
    ;;
  *)
    usage
    exit 1
    ;;
esac
