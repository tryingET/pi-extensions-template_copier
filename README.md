# pi extension copier template

Copier-first template for creating production-ready pi extension repositories.

## Preferred usage (Copier directly)

```bash
copier copy --trust --vcs-ref HEAD ~/programming/pi-extensions/template ~/programming/pi-extensions/<repo-name> \
  -d repo_name=<repo-name> \
  -d command_name=<command-name> \
  -d intake_profile=guided \
  -d interview_tool_version=0.5.1
```

## npm CLI usage (published package)

Run directly without global install:

```bash
npm exec --yes --package @tryinget/pi-extension-template -- \
  new-pi-extension-repo <repo-name> [command-name] [--target-dir <path>] \
  [--intake-profile guided|minimal] [--interview-tool-version 0.5.1]
```

Install once, then run:

```bash
npm install -g @tryinget/pi-extension-template
new-pi-extension-repo <repo-name> [command-name] [--target-dir <path>] \
  [--intake-profile guided|minimal] [--interview-tool-version 0.5.1]
```

If you publish under a different npm scope/name, update [package.json](package.json) first.

## Bootstrap npm publish helper (all packages)

This package also ships `npm-bootstrap-publish` for first-time package publishes.
It creates a temporary `.npmrc`, runs publish, waits for registry propagation (30s default), retries verification, then cleans up credentials.

```bash
# token from 1Password CLI
npm-bootstrap-publish --project ~/programming/pi-extensions/pi-evalset-lab --op op://dev/npm-publish/token

# token from env var
NPM_TOKEN=... npm-bootstrap-publish --project ~/programming/pi-extensions/pi-evalset-lab
```

You can run it without global install too:

```bash
npm exec --yes --package @tryinget/pi-extension-template -- \
  npm-bootstrap-publish --project ~/programming/pi-extensions/pi-evalset-lab --op op://dev/npm-publish/token
```

## Local shell shortcut (maintainer convenience)

A local wrapper function is installed at:

- `~/.bashrc.d/functions/npmbp.bash`

`npmbp` delegates to `npm-bootstrap-publish` (global binary if installed, otherwise this repo's `bin/npm-bootstrap-publish.mjs`) and defaults `--project` to your current directory.

`npmbp-dry` is the same wrapper but forces `--dry-run` unless you already passed it.

```bash
# from inside a package repo
npmbp --op op://dev/npm-publish/token

# safer preflight (dry-run)
npmbp-dry --op op://dev/npm-publish/token

# explicit project path
npmbp ~/programming/pi-extensions/pi-evalset-lab --op op://dev/npm-publish/token
```

## Compatibility wrapper

If you want the old command shape, use:

```bash
bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh <repo-name> [command-name]
```

The wrapper is intentionally thin: argument validation + `copier copy` invocation.

When run from this template git checkout, it defaults to `--vcs-ref HEAD` so local changes are included.
For reproducible generation, pin a tag/commit explicitly:

```bash
PI_TEMPLATE_REF=v0.1.0 \
  bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh <repo-name> [command-name]
```

Choose intake profile + pinned interview tool version at generation time:

```bash
PI_INTAKE_PROFILE=guided \
PI_INTERVIEW_TOOL_VERSION=0.5.1 \
  bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh <repo-name> [command-name]
```

The wrapper refuses to generate from a dirty template repo by default.
Override only for local experiments:

```bash
ALLOW_DIRTY_TEMPLATE=1 \
  bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh <repo-name> [command-name]
```

## What is templated

Template files live under [copier-template/](copier-template/), configured by [copier.yml](copier.yml).

Generated scaffold includes:

- package extension entrypoint in `extensions/<command-name>.ts`
- governance docs + `system4d` frontmatter
- unified quality gate lane:
  - Biome baseline: `biome.jsonc` + `.vscode/settings.json` + pinned `@biomejs/biome`
  - `scripts/quality-gate.sh` stages: `pre-commit`, `pre-push`, `ci`
  - hooks: `.githooks/pre-commit`, `.githooks/pre-push`
  - npm scripts: `fix`, `quality:pre-commit`, `quality:pre-push`, `quality:ci`
- interview-first startup flow:
  - `.pi/extensions/startup-intake-router.ts`
  - `.pi/prompts/init-project-docs.md`
  - `docs/org/project-docs-intake.questions.json` (profile-driven: `guided` or `minimal`)
  - optional interview package (pinned by template var): `pi install npm:pi-interview@<version>`
  - fallback chat intake still works if interview tooling is unavailable
- repo-local commit prompt:
  - `.pi/prompts/commit.md`
- docs discovery wrapper:
  - `scripts/docs-list.sh`
  - npm scripts: `docs:list`, `docs:list:workspace`, `docs:list:json`
- release + security baseline:
  - `.github/workflows/ci.yml`
  - `.github/workflows/release-check.yml`
  - `.github/workflows/release-please.yml`
  - `.github/workflows/publish.yml`
  - `scripts/release-check.sh`
  - `.release-please-config.json`, `.release-please-manifest.json`
  - `.github/dependabot.yml`, `.github/CODEOWNERS`
  - `SECURITY.md`, `LICENSE`
- community intake baseline:
  - `.github/ISSUE_TEMPLATE/{bug-report,feature-request,docs,config}.yml`
  - `.github/pull_request_template.md`
  - `CODE_OF_CONDUCT.md`, `SUPPORT.md`, `CONTRIBUTING.md`
- vouch trust gate baseline:
  - `.github/VOUCHED.td`
  - `.github/workflows/vouch-check-pr.yml`
  - `.github/workflows/vouch-manage.yml`

TypeScript lane reference (for generated repos):
- `uv tool run --from ~/ai-society/core/tech-stack-core tech-stack-core show pi-ts --prefer-repo`
- pinned lane metadata: `policy/stack-lane.json`

## Template-source guardrails (this repo)

This repository is the **Copier template source**, not a generated extension repo.

- Treat `copier-template/` as the source of truth for scaffolded files.
- Edit template behavior via `copier-template/**`, `copier.yml`, and wrapper scripts.
- Do **not** run `copier copy ... .` into this repo root.
- Do **not** commit a root `.copier-answers.yml` in this repo.

Install local pre-commit guardrails once:

```bash
bash ./scripts/install-hooks.sh
```

Smoke-test template changes by generating to a temp directory:

```bash
bash ./scripts/smoke-test-template.sh
```

Generated repo contract check (required include/exclude paths + placeholder leak scan):

```bash
bash ./scripts/generated-contract-test.sh
```

Contract rules live in `contract/generated-repo.contract.json` (versioned in git).

Run with custom names to test edge inputs:

```bash
CONTRACT_REPO_NAME=template.contract \
CONTRACT_COMMAND_NAME=feature-alpha \
  bash ./scripts/generated-contract-test.sh
```

Generated repo idempotency check (`copier update` fallback `recopy`):

```bash
bash ./scripts/idempotency-test-template.sh
```

Code metadata discovery (top-level comments in programming files):

```bash
node ./scripts/code-list.mjs
node ./scripts/code-list.mjs --json
node ./scripts/code-list.mjs --strict
```

Expected top-level comment keys:
- `summary:` one-line purpose
- `read_when:` list of hints for when to read that file

Manual invariant check:

```bash
bash ./scripts/template-guardrails.sh
```

CI guardrails in this repo run invariant checks, smoke generation,
generated-contract assertions across name-variant matrix cases, and
idempotency verification. On failures, CI uploads forensics artifacts
(logs + generated temp repo) for debugging.

## Template package release automation (this repo)

Template-source npm publishing uses:

- `.github/workflows/release-check.yml`
- `.github/workflows/release-please.yml`
- `.github/workflows/publish.yml`
- `.release-please-config.json`, `.release-please-manifest.json`
- `scripts/release-check-template.sh`

Local preflight:

```bash
npm run check:full
npm run release:check
# quick artifact-only mode:
npm run release:check:quick
```

Trusted-publishing learnings captured in this template:

- release-please uses `vX.Y.Z` tags (`include-component-in-tag: false`) so publish trigger logic stays consistent.
- release-please workflow uses `googleapis/release-please-action` v4.4.0 (SHA pinned) and no deprecated `command` input.
- publish workflow avoids `setup-node` npm cache dependency on lockfiles and upgrades npm (`>=11.5.1`) for trusted publishing compatibility.
- for GitHub repos using this template, ensure Actions policy allows external actions and workflow permissions are `Read and write` with PR creation enabled.
- first-time npm package bootstrap may still require one token-based publish before configuring npm trusted publisher on package settings.

## Copier update policy

Generated repos include `.copier-answers.yml` and should commit it.

- Run from a clean destination repo (commit or stash pending changes first).
- Use `copier update --trust` when `.copier-answers.yml` includes `_commit` and update is supported.
- In non-interactive shells/CI, append `--defaults` to update/recopy.
- Use `copier recopy --trust` when update is unavailable (for example local non-VCS source) or cannot reconcile cleanly.
- After recopy, re-apply local deltas intentionally.
- After update/recopy, run `npm run check`.

## Template release checklist (maintainers)

1. Ensure template repo is clean (`git status`).
2. Run local preflight:
   - `npm run check:full`
   - `npm run release:check`
3. Confirm GitHub Actions repo settings:
   - workflow permissions: `Read and write`
   - allow GitHub Actions to create/approve PRs
   - allowed actions policy permits marketplace actions used by workflows
4. Commit template changes with Conventional Commit messages.
5. Push to `main` and let release-please open/update the release PR.
6. Merge the release PR, then publish from the GitHub Release (`vX.Y.Z`) via workflow.
7. If this is a brand-new npm package, do one bootstrap token publish, then configure npm trusted publisher.
8. Prefer `PI_TEMPLATE_REF=vX.Y.Z` in automation for deterministic generation.

## Notes

- `copier` must be installed (`pipx install copier`, `uv tool install copier`, or `pip install copier`).
- Post-copy tasks in `copier.yml` set executable bits, run `git init`, and configure git hook path.
