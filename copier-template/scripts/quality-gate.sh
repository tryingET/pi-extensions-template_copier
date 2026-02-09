#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

STAGE="${1:-}"

usage() {
  echo "Usage: bash ./scripts/quality-gate.sh <lint|fix|typecheck|pre-commit|pre-push|ci>" >&2
}

has_biome_config() {
  [[ -f "biome.json" ]] || [[ -f "biome.jsonc" ]]
}

run_biome() {
  local -a args=("$@")

  if [[ -x "$ROOT_DIR/node_modules/.bin/biome" ]]; then
    "$ROOT_DIR/node_modules/.bin/biome" "${args[@]}"
    return 0
  fi

  echo "biome: configuration detected but local biome binary is unavailable." >&2
  echo "Run 'npm install' (or add @biomejs/biome to devDependencies)." >&2
  exit 1
}

run_lint() {
  if ! has_biome_config; then
    echo "lint: skipped (no biome config found)"
    return 0
  fi

  run_biome check --no-errors-on-unmatched .
}

run_fix() {
  if ! has_biome_config; then
    echo "fix: skipped (no biome config found)"
    return 0
  fi

  run_biome check --write --no-errors-on-unmatched .
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

  echo "typecheck: tsconfig.json found but local tsc binary is unavailable." >&2
  echo "Run 'npm install' (or add typescript to devDependencies)." >&2
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
  fix)
    run_fix
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
