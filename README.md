# pi extension copier template

Copier-first template for creating production-ready pi extension repositories.

## Preferred usage (Copier directly)

```bash
copier copy --trust ~/programming/pi-extensions/template ~/programming/pi-extensions/<repo-name> \
  -d repo_name=<repo-name> \
  -d command_name=<command-name>
```

## npm CLI usage (published package)

Run directly without global install:

```bash
npm exec --yes --package @tryinget/pi-extension-template -- \
  new-pi-extension-repo <repo-name> [command-name] [--target-dir <path>]
```

Install once, then run:

```bash
npm install -g @tryinget/pi-extension-template
new-pi-extension-repo <repo-name> [command-name] [--target-dir <path>]
```

If you publish under a different npm scope/name, update [package.json](package.json) first.

## Compatibility wrapper

If you want the old command shape, use:

```bash
bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh <repo-name> [command-name]
```

The wrapper is intentionally thin: argument validation + `copier copy` invocation.

For reproducible generation, optionally pin template ref:

```bash
PI_TEMPLATE_REF=v0.1.0 \
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
  - `scripts/quality-gate.sh` stages: `pre-commit`, `pre-push`, `ci`
  - hooks: `.githooks/pre-commit`, `.githooks/pre-push`
  - npm scripts: `quality:pre-commit`, `quality:pre-push`, `quality:ci`
- interview-first startup flow:
  - `.pi/extensions/startup-intake-router.ts`
  - `.pi/prompts/init-project-docs.md`
  - `docs/org/project-docs-intake.questions.json`
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

Release parity reference: [docs/release-feature-parity.md](docs/release-feature-parity.md)

TypeScript lane reference (for generated repos):
- `uv tool run --from ~/programming/tech-stack-core tech-stack-core show pi-ts --prefer-repo`
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
3. Commit template changes with Conventional Commit messages.
4. Push to `main` and let release-please open/update the release PR.
5. Merge the release PR, then publish from the GitHub Release (`vX.Y.Z`) via workflow.
6. Prefer `PI_TEMPLATE_REF=vX.Y.Z` in automation for deterministic generation.

## Notes

- `copier` must be installed (`pipx install copier`, `uv tool install copier`, or `pip install copier`).
- Post-copy tasks in `copier.yml` set executable bits, run `git init`, and configure git hook path.
