#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

errors=0

fail() {
  echo "$1" >&2
  ((errors+=1))
}

if [[ -f .copier-answers.yml ]]; then
  fail "Root .copier-answers.yml found. This repo is a Copier template source, not a generated repo."
fi

if [[ ! -f copier.yml ]]; then
  fail "Missing copier.yml template config."
fi

if [[ ! -d copier-template ]]; then
  fail "Missing copier-template directory."
fi

if [[ "$errors" -gt 0 ]]; then
  echo "Template guardrails failed with $errors issue(s)." >&2
  exit 1
fi

echo "Template guardrails passed."
