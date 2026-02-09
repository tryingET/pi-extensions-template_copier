# pi extension copier template

Copier-first template for creating production-ready pi extension repositories.

## Preferred usage (Copier directly)

```bash
copier copy --trust ~/programming/pi-extensions/template ~/programming/pi-extensions/<repo-name> \
  -d repo_name=<repo-name> \
  -d command_name=<command-name>
```

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
- hook setup with `prek.toml`, `.githooks/pre-commit`, and fallback validation
- interview-first startup flow:
  - `.pi/extensions/startup-intake-router.ts`
  - `.pi/prompts/init-project-docs.md`
  - `docs/org/project-docs-intake.questions.json`
- docs discovery wrapper:
  - `scripts/docs-list.sh`
  - npm scripts: `docs:list`, `docs:list:workspace`, `docs:list:json`
- release + security baseline:
  - `.github/workflows/ci.yml`
  - `.github/workflows/release-please.yml`
  - `.github/workflows/publish.yml`
  - `.release-please-config.json`, `.release-please-manifest.json`
  - `.github/dependabot.yml`, `.github/CODEOWNERS`
  - `SECURITY.md`
- community intake baseline:
  - `.github/ISSUE_TEMPLATE/{bug-report,feature-request,docs,config}.yml`
  - `.github/pull_request_template.md`
  - `CODE_OF_CONDUCT.md`, `SUPPORT.md`, `CONTRIBUTING.md`
- vouch trust gate baseline:
  - `.github/VOUCHED.td`
  - `.github/workflows/vouch-check-pr.yml`
  - `.github/workflows/vouch-manage.yml`

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

Manual invariant check:

```bash
bash ./scripts/template-guardrails.sh
```

CI guardrails in this repo run both invariant checks and smoke generation.

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
2. Regenerate canonical smoke repo and run checks.
3. Commit template changes.
4. Create annotated tag (`git tag -a vX.Y.Z -m "Template release vX.Y.Z"`).
5. Push commits + tags to remote (`git push origin main --tags`).
6. Prefer `PI_TEMPLATE_REF=vX.Y.Z` in automation for deterministic generation.

## Notes

- `copier` must be installed (`pipx install copier`, `uv tool install copier`, or `pip install copier`).
- Post-copy tasks in `copier.yml` set executable bits, run `git init`, and configure git hook path.
