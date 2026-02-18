#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_SRC="${1:-$ROOT_DIR}"
REPO_NAME="${SMOKE_REPO_NAME:-template-smoke}"
COMMAND_NAME="${SMOKE_COMMAND_NAME:-template-smoke}"
INTAKE_PROFILE="${SMOKE_INTAKE_PROFILE:-guided}"
INTERVIEW_TOOL_VERSION="${SMOKE_INTERVIEW_TOOL_VERSION:-0.5.1}"
PROJECT_CONTEXT="${SMOKE_PROJECT_CONTEXT:-template smoke context}"
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
  -d "intake_profile=$INTAKE_PROFILE"
  -d "interview_tool_version=$INTERVIEW_TOOL_VERSION"
  -d "project_context=$PROJECT_CONTEXT"
)

if [[ -n "$TEMPLATE_REF" ]]; then
  copier_args+=(--vcs-ref "$TEMPLATE_REF")
fi

copier "${copier_args[@]}" "$TEMPLATE_SRC" "$DEST_DIR"

(
  cd "$DEST_DIR"

  node - "$INTAKE_PROFILE" "$INTERVIEW_TOOL_VERSION" "$PROJECT_CONTEXT" <<'NODE'
const fs = require("node:fs");

const expectedIntakeProfile = process.argv[2];
const expectedInterviewToolVersion = process.argv[3];
const expectedProjectContext = process.argv[4];
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const questions = JSON.parse(fs.readFileSync("docs/org/project-docs-intake.questions.json", "utf8"));
const answers = fs.readFileSync(".copier-answers.yml", "utf8");

const fail = (msg) => {
  console.error(msg);
  process.exit(1);
};

if (pkg?.config?.intakeProfile !== expectedIntakeProfile) {
  fail(
    `package.json config.intakeProfile mismatch: expected ${expectedIntakeProfile}, got ${pkg?.config?.intakeProfile ?? "undefined"}`,
  );
}

if (pkg?.config?.interviewToolVersion !== expectedInterviewToolVersion) {
  fail(
    `package.json config.interviewToolVersion mismatch: expected ${expectedInterviewToolVersion}, got ${pkg?.config?.interviewToolVersion ?? "undefined"}`,
  );
}

if (questions?.profile !== expectedIntakeProfile) {
  fail(
    `docs/org/project-docs-intake.questions.json profile mismatch: expected ${expectedIntakeProfile}, got ${questions?.profile ?? "undefined"}`,
  );
}

if (!answers.includes(`intake_profile: ${expectedIntakeProfile}`)) {
  fail(`.copier-answers.yml missing intake_profile: ${expectedIntakeProfile}`);
}

if (!answers.includes(`interview_tool_version: ${expectedInterviewToolVersion}`)) {
  fail(`.copier-answers.yml missing interview_tool_version: ${expectedInterviewToolVersion}`);
}

if (pkg?.config?.intakeContextSeed !== expectedProjectContext) {
  fail(
    `package.json config.intakeContextSeed mismatch: expected ${expectedProjectContext}, got ${pkg?.config?.intakeContextSeed ?? "undefined"}`,
  );
}

if (!answers.includes("project_context:")) {
  fail(".copier-answers.yml missing project_context entry");
}
NODE

  if [[ -f package-lock.json ]]; then
    npm ci
  else
    npm install --package-lock-only --ignore-scripts
    npm ci
  fi

  npm run check
)

echo "Smoke test passed: $DEST_DIR"
