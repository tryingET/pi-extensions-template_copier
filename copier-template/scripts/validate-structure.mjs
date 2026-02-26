#!/usr/bin/env node

/**
 * Structure validation for pi extension repositories.
 * Extracted from validate-structure.sh for maintainability.
 *
 * Exits 0 on success, 1 on validation failure.
 */

import fs from "node:fs";
import path from "node:path";

const FAIL_FAST = process.env.VALIDATE_FAIL_FAST === "1";

let failed = false;
const errors = [];

function fail(msg) {
  if (FAIL_FAST) {
    console.error(msg);
    process.exit(1);
  }
  errors.push(msg);
  failed = true;
}

function readJsonSafe(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return undefined;
  }
}

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
  ".jsonc",
]);
const biomeIgnoreSkippedDirs = new Set([
  ".git",
  "node_modules",
  "dist",
  "coverage",
  "external",
  "ontology",
]);

// Skip self-validation to avoid circular checks on error message strings
const biomeIgnoreSkippedFiles = new Set(["scripts/validate-structure.mjs"]);

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
      if (biomeIgnoreSkippedFiles.has(relPath)) {
        continue;
      }
      const lines = fs.readFileSync(fullPath, "utf8").split(/\r?\n/);
      for (let i = 0; i < lines.length; i += 1) {
        const line = lines[i];
        if (!line.includes("biome-ignore")) continue;

        if (!biomeIgnoreWithRationalePattern.test(line)) {
          fail(
            `${relPath}:${i + 1} biome-ignore must include a rationale after ':' (example: // biome-ignore lint/<group>/<rule>: <why>)`,
          );
          continue;
        }

        if (!biomeIgnoreTrackingPattern.test(line)) {
          fail(
            `${relPath}:${i + 1} biome-ignore must include tracking reference TODO(#123) or Issue: #123`,
          );
        }
      }
    }
  };

  walk(rootDir);
}

function validateInterviewQuestions() {
  const qPath = "docs/org/project-docs-intake.questions.json";
  const q = readJsonSafe(qPath);

  if (!q) {
    fail(`Failed to parse interview questions file: ${qPath}`);
    return;
  }

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
      continue;
    }

    const id = entry.id;
    const type = entry.type;
    const questionText = entry.question;

    if (typeof id !== "string" || id.trim().length === 0) {
      fail(`Interview question at index ${index} is missing a non-empty id: ${qPath}`);
      continue;
    }

    if (questionIds.has(id)) {
      fail(`Interview questions must use unique ids (duplicate: ${id}): ${qPath}`);
      continue;
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
      fail(
        `Guided interview profile must include at least one decision question (single/multi): ${qPath}`,
      );
    }

    if (recommendedQuestionCount < 1) {
      fail(`Guided interview profile must include at least one prefilled recommendation: ${qPath}`);
    }
  }
}

function validatePackageJson() {
  const p = readJsonSafe("package.json");
  if (!p) {
    fail("Failed to parse package.json");
    return;
  }

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
    "release:check:quick": "SKIP_PI_SMOKE=1 bash ./scripts/release-check.sh",
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

  const interviewToolSource = p.config?.interviewToolSource;
  if (typeof interviewToolSource !== "string" || interviewToolSource.trim().length === 0) {
    fail(
      "package.json config.interviewToolSource must be a non-empty string (e.g. git:github.com/ghoseb/pi-askuserquestion)",
    );
  }

  const intakeContextSeed = p.config?.intakeContextSeed;
  if (typeof intakeContextSeed !== "string") {
    fail("package.json config.intakeContextSeed must be a string");
  }

  // Cross-validate intake profile with questions file
  const qPath = "docs/org/project-docs-intake.questions.json";
  const q = readJsonSafe(qPath);
  if (q) {
    const qProfileRaw = q.profile;
    const qProfile = typeof qProfileRaw === "string" ? qProfileRaw : "guided";
    if (qProfile !== intakeProfile) {
      fail(
        "package.json config.intakeProfile must match docs/org/project-docs-intake.questions.json profile",
      );
    }
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
}

function validateReleasePlease() {
  const rpConfig = readJsonSafe(".release-please-config.json");
  if (!rpConfig) {
    fail("Failed to parse .release-please-config.json");
    return;
  }

  if (rpConfig["include-v-in-tag"] !== true) {
    fail(".release-please-config.json must set include-v-in-tag=true");
  }
  if (rpConfig["include-component-in-tag"] !== false) {
    fail(".release-please-config.json must set include-component-in-tag=false");
  }
  if (!rpConfig.packages || !rpConfig.packages["."]) {
    fail(".release-please-config.json must include packages['.']");
  }

  const rpManifest = readJsonSafe(".release-please-manifest.json");
  if (!rpManifest) {
    fail("Failed to parse .release-please-manifest.json");
    return;
  }

  if (!rpManifest["."]) {
    fail(".release-please-manifest.json must include '.' version entry");
  }

  const versionPattern = /^\d+\.\d+\.\d+([-.][0-9A-Za-z.]+)?$/;
  if (!versionPattern.test(rpManifest["."])) {
    fail(".release-please-manifest.json '.' entry must match X.Y.Z");
  }

  const p = readJsonSafe("package.json");
  if (p && rpManifest["."] !== p.version) {
    fail(".release-please-manifest.json '.' entry must match package.json version");
  }
}

function validateStackLane() {
  const stackLane = readJsonSafe("policy/stack-lane.json");
  if (!stackLane) {
    fail("Failed to parse policy/stack-lane.json");
    return;
  }

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
}

function main() {
  const cwd = process.cwd();

  validateInterviewQuestions();
  validatePackageJson();
  validateReleasePlease();
  validateStackLane();
  validateBiomeIgnoreGovernance(cwd);

  if (failed) {
    for (const error of errors) {
      console.error(error);
    }
    console.error(`Validation failed with ${errors.length} issue(s).`);
    process.exit(1);
  }

  console.log("Node.js validation passed.");
}

main();
