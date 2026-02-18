#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { copyFileSync, existsSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const TEMPLATE_DIR = path.resolve(__dirname, "..");

const NAME_PATTERN = /^[a-zA-Z0-9._-]+$/;
const INTAKE_PROFILES = new Set(["guided", "minimal"]);
const VERSION_PATTERN = /^\d+\.\d+\.\d+([-.][0-9A-Za-z.]+)?$/;

function usage() {
  console.error(`Usage: new-pi-extension-repo <repo-name> [command-name] [options]

Options:
  --target-dir <path>              Destination directory (default: ./<repo-name>)
  --template-ref <ref>             Override copier --vcs-ref
  --intake-profile <guided|minimal>  Intake questionnaire profile (default: guided)
  --interview-tool-version <ver>   Pinned pi-interview npm version (default: 0.5.1)
  -h, --help                       Show this help

Env:
  PI_TEMPLATE_REF=<ref>            Template ref fallback (defaults to HEAD for local git template checkouts)
  PI_INTAKE_PROFILE=<profile>      Optional intake profile fallback
  PI_INTERVIEW_TOOL_VERSION=<ver>  Optional interview tool version fallback

Notes:
  - Requires copier to be installed (pipx/uv/pip).
  - Uses this package as the template source.`);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

function applyNpmIgnoreWorkaround(templateDir) {
  const gitignorePath = path.join(templateDir, "copier-template", ".gitignore");
  const npmignorePath = path.join(templateDir, "copier-template", ".npmignore");

  if (existsSync(gitignorePath) || !existsSync(npmignorePath)) {
    return () => {};
  }

  const npmignoreContent = readFileSync(npmignorePath);
  copyFileSync(npmignorePath, gitignorePath);
  rmSync(npmignorePath);

  return () => {
    if (existsSync(gitignorePath)) {
      rmSync(gitignorePath);
    }
    if (!existsSync(npmignorePath)) {
      writeFileSync(npmignorePath, npmignoreContent);
    }
  };
}

function templateSourceIsGitRepo(templateDir) {
  const check = spawnSync("git", ["-C", templateDir, "rev-parse", "--is-inside-work-tree"], {
    stdio: "ignore",
  });
  return check.status === 0;
}

const args = process.argv.slice(2);
let targetDirArg;
let templateRefArg;
let intakeProfileArg;
let interviewToolVersionArg;
const positional = [];

for (let i = 0; i < args.length; i += 1) {
  const arg = args[i];

  if (arg === "-h" || arg === "--help") {
    usage();
    process.exit(0);
  }

  if (arg === "--target-dir") {
    i += 1;
    if (i >= args.length) fail("Missing value for --target-dir");
    targetDirArg = args[i];
    continue;
  }

  if (arg === "--template-ref") {
    i += 1;
    if (i >= args.length) fail("Missing value for --template-ref");
    templateRefArg = args[i];
    continue;
  }

  if (arg === "--intake-profile") {
    i += 1;
    if (i >= args.length) fail("Missing value for --intake-profile");
    intakeProfileArg = args[i];
    continue;
  }

  if (arg === "--interview-tool-version") {
    i += 1;
    if (i >= args.length) fail("Missing value for --interview-tool-version");
    interviewToolVersionArg = args[i];
    continue;
  }

  if (arg.startsWith("-")) {
    fail(`Unknown option: ${arg}`);
  }

  positional.push(arg);
}

if (positional.length < 1 || positional.length > 2) {
  usage();
  process.exit(1);
}

const repoName = positional[0];
const commandName = positional[1] ?? repoName;
const explicitTemplateRef = templateRefArg ?? process.env.PI_TEMPLATE_REF ?? "";
const templateRef = explicitTemplateRef || (templateSourceIsGitRepo(TEMPLATE_DIR) ? "HEAD" : "");
const intakeProfile = intakeProfileArg ?? process.env.PI_INTAKE_PROFILE ?? "guided";
const interviewToolVersion =
  interviewToolVersionArg ?? process.env.PI_INTERVIEW_TOOL_VERSION ?? "0.5.1";

if (!NAME_PATTERN.test(repoName)) {
  fail("Error: repo-name must match [a-zA-Z0-9._-]+");
}

if (!NAME_PATTERN.test(commandName)) {
  fail("Error: command-name must match [a-zA-Z0-9._-]+");
}

if (!INTAKE_PROFILES.has(intakeProfile)) {
  fail("Error: --intake-profile must be one of: guided, minimal");
}

if (!VERSION_PATTERN.test(interviewToolVersion)) {
  fail("Error: --interview-tool-version must be a pinned semver (e.g. 0.5.1)");
}

const targetDir = path.resolve(targetDirArg ?? path.join(process.cwd(), repoName));

if (existsSync(targetDir)) {
  fail(`Error: target already exists: ${targetDir}`);
}

const copierCheck = spawnSync("copier", ["--version"], { stdio: "ignore" });
if (copierCheck.status !== 0) {
  fail(`Error: copier is not installed.
Install one of:
  pipx install copier
  uv tool install copier
  pip install copier`);
}

const copierArgs = [
  "copy",
  "--trust",
  "--defaults",
  "-d",
  `repo_name=${repoName}`,
  "-d",
  `command_name=${commandName}`,
  "-d",
  `intake_profile=${intakeProfile}`,
  "-d",
  `interview_tool_version=${interviewToolVersion}`,
];

if (templateRef) {
  copierArgs.push("--vcs-ref", templateRef);
}

copierArgs.push(TEMPLATE_DIR, targetDir);

const cleanupWorkaround = applyNpmIgnoreWorkaround(TEMPLATE_DIR);
let child;
try {
  child = spawnSync("copier", copierArgs, {
    stdio: "inherit",
    env: process.env,
    cwd: process.cwd(),
  });
} finally {
  cleanupWorkaround();
}

if (child.error) {
  fail(`Failed to run copier: ${child.error.message}`);
}

if (child.status !== 0) {
  process.exit(child.status ?? 1);
}

console.log(`Created: ${targetDir}`);
