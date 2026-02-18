#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "README.md"
  "LICENSE"
  "CHANGELOG.md"
  "SECURITY.md"
  "CODE_OF_CONDUCT.md"
  "SUPPORT.md"
  "CONTRIBUTING.md"
  "AGENTS.md"
  "biome.jsonc"
  ".vscode/settings.json"
  ".copier-answers.yml"
  "prek.toml"
  ".github/CODEOWNERS"
  ".github/dependabot.yml"
  ".github/pull_request_template.md"
  ".github/VOUCHED.td"
  ".github/ISSUE_TEMPLATE/bug-report.yml"
  ".github/ISSUE_TEMPLATE/feature-request.yml"
  ".github/ISSUE_TEMPLATE/docs.yml"
  ".github/ISSUE_TEMPLATE/config.yml"
  ".github/workflows/ci.yml"
  ".github/workflows/release-check.yml"
  ".github/workflows/release-please.yml"
  ".github/workflows/publish.yml"
  ".github/workflows/vouch-check-pr.yml"
  ".github/workflows/vouch-manage.yml"
  ".release-please-config.json"
  ".release-please-manifest.json"
  "docs/org/operating_model.md"
  "docs/org/project-docs-intake.questions.json"
  "docs/project/foundation.md"
  "docs/project/vision.md"
  "docs/project/incentives.md"
  "docs/project/resources.md"
  "docs/project/skills.md"
  "docs/project/strategic_goals.md"
  "docs/project/tactical_goals.md"
  "docs/dev/next_steps.md"
  "docs/dev/status.md"
  "docs/tech-stack.local.md"
  "docs/dev/CONTRIBUTING.md"
  "docs/dev/EXTENSION_SOP.md"
  "policy/stack-lane.json"
  ".pi/extensions/startup-intake-router.ts"
  ".pi/prompts/init-project-docs.md"
  ".pi/prompts/commit.md"
  "scripts/sync-to-live.sh"
  "scripts/install-hooks.sh"
  "scripts/init-project-docs.sh"
  "scripts/build-intake-questions-runtime.mjs"
  "scripts/docs-list.sh"
  "scripts/release-check.sh"
  "scripts/validate-structure.sh"
  "scripts/quality-gate.sh"
  ".githooks/pre-commit"
  ".githooks/pre-push"
  "prompts/implementation-planning.md"
  "prompts/security-review.md"
  "prompts/init-project-docs.md"
)

required_dirs=(
  ".github"
  ".github/workflows"
  ".github/ISSUE_TEMPLATE"
  ".vscode"
  "docs/org"
  "docs/dev/plans"
  "examples"
  "external"
  "ontology"
  "policy"
  "scripts"
  "src"
  "tests"
  ".pi"
  ".pi/extensions"
  ".pi/prompts"
  ".githooks"
  "prompts"
)

required_executables=(
  "scripts/sync-to-live.sh"
  "scripts/install-hooks.sh"
  "scripts/init-project-docs.sh"
  "scripts/build-intake-questions-runtime.mjs"
  "scripts/docs-list.sh"
  "scripts/release-check.sh"
  "scripts/validate-structure.sh"
  "scripts/quality-gate.sh"
  ".githooks/pre-commit"
  ".githooks/pre-push"
)

errors=0

for required_file in "${required_files[@]}"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing required file: $required_file" >&2
    ((errors+=1))
  fi
done

for required_dir in "${required_dirs[@]}"; do
  if [[ ! -d "$required_dir" ]]; then
    echo "Missing required directory: $required_dir" >&2
    ((errors+=1))
  fi
done

for executable in "${required_executables[@]}"; do
  if [[ ! -x "$executable" ]]; then
    echo "Expected executable bit on: $executable" >&2
    ((errors+=1))
  fi
done

plan_count=$(find "docs/dev/plans" -maxdepth 1 -type f -name "*.md" | wc -l | tr -d ' ')
if [[ "$plan_count" -lt 1 ]]; then
  echo "docs/dev/plans must contain at least one markdown plan file" >&2
  ((errors+=1))
fi

for copier_key in "_src_path:" "repo_name:" "command_name:"; do
  if ! grep -q "^${copier_key}" ".copier-answers.yml"; then
    echo "Missing copier answer key in .copier-answers.yml: ${copier_key}" >&2
    ((errors+=1))
  fi
done

placeholder_pattern='\{username\}|\{repo\}|\{discordInvite\}|\{@twitter\}'
placeholder_hits="$(grep -R -nE "$placeholder_pattern" .github || true)"
if [[ -n "$placeholder_hits" ]]; then
  echo "Unresolved placeholders found under .github:" >&2
  echo "$placeholder_hits" >&2
  ((errors+=1))
fi

if ! grep -q '^\*\.tgz$' ".gitignore"; then
  echo ".gitignore must ignore npm tarball outputs (*.tgz)" >&2
  ((errors+=1))
fi

if ! grep -q "npm run release:check:quick" ".github/workflows/release-check.yml"; then
  echo "release-check workflow must run npm run release:check:quick" >&2
  ((errors+=1))
fi

if ! grep -q "npm run release:check:quick" ".github/workflows/publish.yml"; then
  echo "publish workflow must run npm run release:check:quick before npm publish" >&2
  ((errors+=1))
fi

if ! grep -q "npm run quality:ci" ".github/workflows/ci.yml"; then
  echo "ci workflow must run npm run quality:ci" >&2
  ((errors+=1))
fi

release_please_ref="16a9c90856f42705d54a6fda1823352bdc62cf38"
if ! grep -q "googleapis/release-please-action@${release_please_ref}" ".github/workflows/release-please.yml"; then
  echo "release-please workflow must pin googleapis/release-please-action to ${release_please_ref} (v4.4.0)" >&2
  ((errors+=1))
fi

if grep -q "command:" ".github/workflows/release-please.yml"; then
  echo "release-please workflow must not use deprecated 'command' input" >&2
  ((errors+=1))
fi

if grep -q "cache: npm" ".github/workflows/publish.yml"; then
  echo "publish workflow must not require setup-node npm cache when lockfile may be absent" >&2
  ((errors+=1))
fi

if ! grep -q "npm install --global npm@\^11.5.1" ".github/workflows/publish.yml"; then
  echo "publish workflow must upgrade npm to >=11.5.1 for trusted publishing compatibility" >&2
  ((errors+=1))
fi

if ! grep -q "scripts/quality-gate.sh\" pre-commit" ".githooks/pre-commit"; then
  echo ".githooks/pre-commit must call scripts/quality-gate.sh pre-commit" >&2
  ((errors+=1))
fi

if ! grep -q "scripts/quality-gate.sh\" pre-push" ".githooks/pre-push"; then
  echo ".githooks/pre-push must call scripts/quality-gate.sh pre-push" >&2
  ((errors+=1))
fi

vouch_check_ref="$(grep -Eo 'mitchellh/vouch/action/check-pr@[0-9a-f]{40}' .github/workflows/vouch-check-pr.yml | head -n1 | sed 's/.*@//')"
vouch_manage_ref="$(grep -Eo 'mitchellh/vouch/action/manage-by-issue@[0-9a-f]{40}' .github/workflows/vouch-manage.yml | head -n1 | sed 's/.*@//')"

if [[ -z "$vouch_check_ref" ]]; then
  echo "vouch-check-pr workflow must pin mitchellh/vouch/action/check-pr to a 40-char SHA" >&2
  ((errors+=1))
fi

if [[ -z "$vouch_manage_ref" ]]; then
  echo "vouch-manage workflow must pin mitchellh/vouch/action/manage-by-issue to a 40-char SHA" >&2
  ((errors+=1))
fi

if [[ -n "$vouch_check_ref" && -n "$vouch_manage_ref" && "$vouch_check_ref" != "$vouch_manage_ref" ]]; then
  echo "vouch workflow SHAs must match between check-pr and manage-by-issue" >&2
  ((errors+=1))
fi

if grep -n "@main" .github/workflows/vouch-*.yml >/dev/null 2>&1; then
  echo "vouch workflows must not use @main refs" >&2
  ((errors+=1))
fi

if ! grep -q "pull_request_target" ".github/workflows/vouch-check-pr.yml"; then
  echo "vouch-check-pr workflow must trigger on pull_request_target" >&2
  ((errors+=1))
fi

if ! grep -q "require-vouch" ".github/workflows/vouch-check-pr.yml"; then
  echo "vouch-check-pr workflow must set require-vouch" >&2
  ((errors+=1))
fi

if ! grep -q "auto-close" ".github/workflows/vouch-check-pr.yml"; then
  echo "vouch-check-pr workflow must set auto-close" >&2
  ((errors+=1))
fi

if ! grep -q "issue_comment" ".github/workflows/vouch-manage.yml"; then
  echo "vouch-manage workflow must trigger on issue_comment" >&2
  ((errors+=1))
fi

if ! grep -q "concurrency:" ".github/workflows/vouch-manage.yml" || ! grep -q "group: vouch-manage" ".github/workflows/vouch-manage.yml"; then
  echo "vouch-manage workflow must define serialized concurrency" >&2
  ((errors+=1))
fi

if ! grep -q "vouched-file: .github/VOUCHED.td" ".github/workflows/vouch-manage.yml"; then
  echo "vouch-manage workflow must target .github/VOUCHED.td" >&2
  ((errors+=1))
fi

if grep -q "@your-github-handle" ".github/CODEOWNERS"; then
  echo ".github/CODEOWNERS must not keep @your-github-handle placeholder" >&2
  ((errors+=1))
fi

if ! grep -Eq "^github:[A-Za-z0-9][A-Za-z0-9-]*" ".github/VOUCHED.td"; then
  echo ".github/VOUCHED.td must include at least one github maintainer entry" >&2
  ((errors+=1))
fi

if command -v node >/dev/null 2>&1; then
  if ! node - <<'NODE'
const fs = require("node:fs");
const path = require("node:path");

let failed = false;
const fail = (msg) => {
  console.error(msg);
  failed = true;
};

const biomeIgnoreWithRationalePattern = /\bbiome-ignore\b[^:\n]*:\s*\S+/;
const biomeIgnoreTrackingPattern = /(TODO\(#\d+\)|Issue:\s*#\d+)/;
const biomeIgnoreFileExtensions = new Set([
  ".ts",
  ".tsx",
  ".js",
  ".jsx",
  ".mjs",
  ".cjs",
  ".mts",
  ".cts",
  ".jsonc"
]);
const biomeIgnoreSkippedDirs = new Set([
  ".git",
  "node_modules",
  "dist",
  "coverage",
  "external",
  "ontology"
]);

function validateBiomeIgnoreGovernance(rootDir) {
  const walk = (dirPath) => {
    const entries = fs.readdirSync(dirPath, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(dirPath, entry.name);
      if (entry.isDirectory()) {
        if (biomeIgnoreSkippedDirs.has(entry.name)) {
          continue;
        }
        walk(fullPath);
        continue;
      }
      if (!entry.isFile()) continue;
      if (!biomeIgnoreFileExtensions.has(path.extname(entry.name))) {
        continue;
      }

      const relPath = path.relative(rootDir, fullPath).replaceAll("\\", "/");
      const lines = fs.readFileSync(fullPath, "utf8").split(/\r?\n/);
      for (let i = 0; i < lines.length; i += 1) {
        const line = lines[i];
        if (!line.includes("biome-ignore")) continue;

        if (!biomeIgnoreWithRationalePattern.test(line)) {
          fail(
            `${relPath}:${i + 1} biome-ignore must include a rationale after ':' (example: // biome-ignore lint/<group>/<rule>: <why>)`
          );
          continue;
        }

        if (!biomeIgnoreTrackingPattern.test(line)) {
          fail(
            `${relPath}:${i + 1} biome-ignore must include tracking reference TODO(#123) or Issue: #123`
          );
        }
      }
    }
  };

  walk(rootDir);
}

try {
  const qPath = "docs/org/project-docs-intake.questions.json";
  const q = JSON.parse(fs.readFileSync(qPath, "utf8"));

  if (typeof q.title !== "string" || q.title.trim().length === 0) {
    fail(`Interview questions file must include a non-empty title: ${qPath}`);
  }

  if (typeof q.description !== "string" || q.description.trim().length === 0) {
    fail(`Interview questions file must include a non-empty description: ${qPath}`);
  }

  if (!Array.isArray(q.questions) || q.questions.length === 0) {
    fail(`Interview questions file must include a non-empty questions array: ${qPath}`);
  }

  const intakeProfile = typeof q.profile === "string" ? q.profile : "guided";
  if (!["guided", "minimal"].includes(intakeProfile)) {
    fail(`Interview questions profile must be 'guided' or 'minimal': ${qPath}`);
  }

  const questionIds = new Set();
  let decisionQuestionCount = 0;
  let recommendedQuestionCount = 0;

  for (const [index, entry] of q.questions.entries()) {
    if (!entry || typeof entry !== "object") {
      fail(`Interview question at index ${index} must be an object: ${qPath}`);
    }

    const id = entry.id;
    const type = entry.type;
    const questionText = entry.question;

    if (typeof id !== "string" || id.trim().length === 0) {
      fail(`Interview question at index ${index} is missing a non-empty id: ${qPath}`);
    }

    if (questionIds.has(id)) {
      fail(`Interview questions must use unique ids (duplicate: ${id}): ${qPath}`);
    }
    questionIds.add(id);

    if (typeof type !== "string" || type.trim().length === 0) {
      fail(`Interview question '${id}' is missing a non-empty type: ${qPath}`);
    }

    if (typeof questionText !== "string" || questionText.trim().length === 0) {
      fail(`Interview question '${id}' is missing a non-empty question field: ${qPath}`);
    }

    if (type === "single" || type === "multi") {
      decisionQuestionCount += 1;
      if (!Array.isArray(entry.options) || entry.options.length === 0) {
        fail(`Interview question '${id}' (${type}) must include non-empty options: ${qPath}`);
      }
    }

    if (entry.recommended !== undefined) {
      recommendedQuestionCount += 1;
    }
  }

  if (intakeProfile === "guided") {
    if (decisionQuestionCount < 1) {
      fail(`Guided interview profile must include at least one decision question (single/multi): ${qPath}`);
    }

    if (recommendedQuestionCount < 1) {
      fail(`Guided interview profile must include at least one prefilled recommendation: ${qPath}`);
    }
  }
} catch (error) {
  fail(`Failed to parse interview questions file: ${error.message}`);
}

try {
  const p = JSON.parse(fs.readFileSync("package.json", "utf8"));
  if (!Array.isArray(p.keywords) || !p.keywords.includes("pi-package")) {
    fail("package.json missing keywords entry: pi-package");
  }
  if (!Array.isArray(p.keywords) || !p.keywords.includes("pi-extension")) {
    fail("package.json missing keywords entry: pi-extension");
  }

  const ext = p.pi?.extensions;
  if (!Array.isArray(ext) || ext.length < 1) {
    fail("package.json missing pi.extensions array");
  } else {
    for (const entry of ext) {
      const normalized = entry.replace(/^\.\//, "");
      if (!fs.existsSync(normalized)) {
        fail(`pi.extensions entry does not exist: ${entry}`);
      }
    }
  }

  const prompts = p.pi?.prompts;
  if (!Array.isArray(prompts) || prompts.length < 1) {
    fail("package.json missing pi.prompts array");
  } else {
    for (const entry of prompts) {
      const normalized = entry.replace(/\/$/, "").replace(/^\.\//, "");
      if (!fs.existsSync(normalized)) {
        fail(`pi.prompts entry does not exist: ${entry}`);
      }
    }
  }

  const requiredPeers = ["@mariozechner/pi-coding-agent", "@mariozechner/pi-ai"];
  for (const peer of requiredPeers) {
    if (typeof p.peerDependencies?.[peer] !== "string") {
      fail(`package.json peerDependencies must include ${peer}`);
    }
  }

  const scriptExpectations = {
    fix: "bash ./scripts/quality-gate.sh fix",
    lint: "bash ./scripts/quality-gate.sh lint",
    typecheck: "bash ./scripts/quality-gate.sh typecheck",
    "quality:pre-commit": "bash ./scripts/quality-gate.sh pre-commit",
    "quality:pre-push": "bash ./scripts/quality-gate.sh pre-push",
    "quality:ci": "bash ./scripts/quality-gate.sh ci",
    check: "npm run quality:ci",
    test: "npm run quality:ci",
    "docs:list": "bash ./scripts/docs-list.sh",
    "docs:list:workspace": "bash ./scripts/docs-list.sh --workspace --discover",
    "docs:list:json": "bash ./scripts/docs-list.sh --json",
    "release:check": "bash ./scripts/release-check.sh",
    "release:check:quick": "SKIP_PI_SMOKE=1 bash ./scripts/release-check.sh"
  };

  for (const [scriptName, expected] of Object.entries(scriptExpectations)) {
    if (p.scripts?.[scriptName] !== expected) {
      fail(`package.json scripts.${scriptName} must be '${expected}'`);
    }
  }

  if (p.publishConfig?.registry !== "https://registry.npmjs.org/") {
    fail("package.json publishConfig.registry must be 'https://registry.npmjs.org/'");
  }

  if (p.publishConfig?.access !== "public") {
    fail("package.json publishConfig.access must be 'public'");
  }

  if (p.engines?.node !== ">=22") {
    fail("package.json engines.node must be '>=22'");
  }

  const intakeProfile = p.config?.intakeProfile;
  if (intakeProfile !== "guided" && intakeProfile !== "minimal") {
    fail("package.json config.intakeProfile must be 'guided' or 'minimal'");
  }

  const interviewToolVersion = p.config?.interviewToolVersion;
  if (typeof interviewToolVersion !== "string" || !/^\d+\.\d+\.\d+([-.][0-9A-Za-z.]+)?$/.test(interviewToolVersion)) {
    fail("package.json config.interviewToolVersion must be a pinned semver string (e.g. 0.5.1)");
  }

  const intakeContextSeed = p.config?.intakeContextSeed;
  if (typeof intakeContextSeed !== "string") {
    fail("package.json config.intakeContextSeed must be a string");
  }

  const qProfileRaw = JSON.parse(fs.readFileSync("docs/org/project-docs-intake.questions.json", "utf8")).profile;
  const qProfile = typeof qProfileRaw === "string" ? qProfileRaw : "guided";
  if (qProfile !== intakeProfile) {
    fail("package.json config.intakeProfile must match docs/org/project-docs-intake.questions.json profile");
  }

  const biomeVersion = p.devDependencies?.["@biomejs/biome"];
  if (typeof biomeVersion !== "string") {
    fail("package.json devDependencies must include @biomejs/biome");
  } else if (!/^\d+\.\d+\.\d+$/.test(biomeVersion)) {
    fail("package.json devDependencies.@biomejs/biome must be pinned to an exact semver (X.Y.Z)");
  }

  if (!Array.isArray(p.files) || p.files.length < 1) {
    fail("package.json must define a non-empty files array");
  } else {
    if (!p.files.includes("prompts")) {
      fail("package.json files must include 'prompts'");
    }
    if (!p.files.includes("examples")) {
      fail("package.json files must include 'examples'");
    }
    if (!p.files.includes("policy/security-policy.json")) {
      fail("package.json files must include 'policy/security-policy.json'");
    }
    if (!p.files.includes("policy/stack-lane.json")) {
      fail("package.json files must include 'policy/stack-lane.json'");
    }

    for (const entry of ext) {
      const normalized = entry.replace(/^\.\//, "");
      if (!p.files.includes(normalized)) {
        fail(`package.json files must include extension artifact: ${normalized}`);
      }
    }
  }

  const rpConfig = JSON.parse(fs.readFileSync(".release-please-config.json", "utf8"));
  if (rpConfig["include-v-in-tag"] !== true) {
    fail(".release-please-config.json must set include-v-in-tag=true");
  }
  if (rpConfig["include-component-in-tag"] !== false) {
    fail(".release-please-config.json must set include-component-in-tag=false");
  }
  if (!rpConfig.packages || !rpConfig.packages["."]) {
    fail(".release-please-config.json must include packages['.']");
  }

  const rpManifest = JSON.parse(fs.readFileSync(".release-please-manifest.json", "utf8"));
  if (!rpManifest["."]) {
    fail(".release-please-manifest.json must include '.' version entry");
  }
  const versionPattern = /^\d+\.\d+\.\d+([-.][0-9A-Za-z.]+)?$/;
  if (!versionPattern.test(rpManifest["."])) {
    fail(".release-please-manifest.json '.' entry must match X.Y.Z");
  }
  if (rpManifest["."] !== p.version) {
    fail(".release-please-manifest.json '.' entry must match package.json version");
  }

  const stackLane = JSON.parse(fs.readFileSync("policy/stack-lane.json", "utf8"));
  if (stackLane.lane !== "ts") {
    fail("policy/stack-lane.json lane must be 'ts'");
  }

  const laneName = stackLane.tech_stack_core?.lane;
  if (laneName !== "pi-ts") {
    fail("policy/stack-lane.json tech_stack_core.lane must be 'pi-ts'");
  }

  const stackRef = stackLane.tech_stack_core?.ref;
  if (typeof stackRef !== "string" || !/^[0-9a-f]{40}$/i.test(stackRef)) {
    fail("policy/stack-lane.json tech_stack_core.ref must be a pinned 40-char git SHA");
  }

  validateBiomeIgnoreGovernance(".");
} catch (error) {
  fail(`Failed to validate package/release metadata: ${error.message}`);
}

process.exit(failed ? 1 : 0);
NODE
  then
    ((errors+=1))
  fi
fi

while IFS= read -r -d '' markdown_file; do
  if [[ "$(head -n 1 "$markdown_file")" != "---" ]]; then
    echo "Missing YAML frontmatter start in: $markdown_file" >&2
    ((errors+=1))
    continue
  fi

  if ! grep -q "^system4d:" "$markdown_file"; then
    echo "Missing system4d section in: $markdown_file" >&2
    ((errors+=1))
    continue
  fi

  for key in container compass engine fog; do
    if ! grep -q "^  $key:" "$markdown_file"; then
      echo "Missing system4d.$key in: $markdown_file" >&2
      ((errors+=1))
    fi
  done

  if [[ "$markdown_file" == "./prompts/"* || "$markdown_file" == "./.pi/prompts/"* ]]; then
    if ! grep -q "^description:" "$markdown_file"; then
      echo "Prompt template missing frontmatter description: $markdown_file" >&2
      ((errors+=1))
    fi
  fi
done < <(find . -type f -name "*.md" ! -path "./.git/*" ! -path "./node_modules/*" -print0)

if [[ "$errors" -gt 0 ]]; then
  echo "Structure validation failed with $errors issue(s)." >&2
  exit 1
fi

echo "Structure validation passed."
