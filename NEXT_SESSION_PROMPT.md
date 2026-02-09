# Next session prompt — apply template baseline to secure-package-update

Goal: migrate `~/programming/pi-extensions/secure-package-update` onto the
current Copier-generated baseline from this template repo, while preserving
extension-specific behavior and release checks.

## Scope and intent

- Target repo to migrate: `~/programming/pi-extensions/secure-package-update`
- Template source: `~/programming/pi-extensions/template`
- Command name to preserve: `secure-package-update`
- Package name to preserve: `@tryinget/secure-package-update`

This is **not** self-applying the template source repo.
This is applying template output to a generated extension repo.

## Release-first gate (before migration)

To avoid context switching and moving targets, freeze template state first.

1. In `template/`, run full validation loop:
   - `bash ./scripts/template-guardrails.sh`
   - `bash ./scripts/smoke-test-template.sh`
   - `bash ./scripts/generated-contract-test.sh`
   - `bash ./scripts/idempotency-test-template.sh`
2. Commit any remaining template-side changes.
3. Cut a new template tag (`vX.Y.Z`, likely patch bump from current state).
4. Use that tag as pinned source for migration:
   - `PI_TEMPLATE_REF=vX.Y.Z`
5. If remote exists, push commits + tags before applying to target repo.

## Current gap snapshot (already observed)

`secure-package-update` is missing most baseline scaffold files now included by
`template` (AGENTS, docs tree, issue templates, vouch workflows, release-please
files, startup intake flow, validate-structure, docs-list wrapper, etc.).

It currently has extension-specific assets we must keep:

- `extensions/secure-package-update.ts`
- `scripts/release-check.sh`
- `.github/workflows/release-check.yml`
- `config/security-policy.json`
- package metadata tuned for npm publish

## Non-negotiables

1. Preserve extension logic and command behavior.
2. Keep release-check workflow/script unless intentionally replaced.
3. Remove packed tarballs from repo root (`*.tgz`) and keep them out of git.
4. End state should be Copier-managed (`.copier-answers.yml` present).
5. Do not change template source invariants in `template/`.

## Migration strategy (one pass)

### 1) Create safety backup of custom files

From `secure-package-update` save copies of:

- `extensions/secure-package-update.ts`
- `scripts/release-check.sh`
- `.github/workflows/release-check.yml`
- `config/security-policy.json`
- `package.json`
- `README.md`

### 2) Generate canonical scaffold in temp

Use Copier from template source with matching names and pinned ref:

- `PI_TEMPLATE_REF=vX.Y.Z`
- `repo_name=secure-package-update`
- `command_name=secure-package-update`

### 3) Overlay scaffold into secure repo

- Sync generated scaffold into `secure-package-update` (exclude `.git`).
- Keep `.copier-answers.yml` from generated scaffold.

### 4) Re-apply secure-package-update customizations

Re-introduce extension-specific artifacts, then merge with scaffold defaults:

- restore `extensions/secure-package-update.ts`
- keep `scripts/release-check.sh`
- keep `.github/workflows/release-check.yml`
- preserve npm publish metadata in `package.json`
- preserve strict `files` whitelist for published artifacts

### 5) Policy path alignment decision

Decide explicitly one of:

A) keep `config/security-policy.json` as extension-specific path, or
B) migrate to scaffold path `policy/security-policy.json` and update
   extension/scripts/docs accordingly.

Document whichever choice is made.

### 6) Clean up artifacts

- remove `*.tgz` package artifacts from repo root
- ensure `.gitignore` covers local pack outputs

## Validation (must run and report)

From `secure-package-update`:

```bash
npm run check
npm run docs:list || true
npm run release:check:quick
echo "/secure-update --help" | pi -e ./extensions/secure-package-update.ts -p
```

If available and intended, also run full:

```bash
npm run release:check
```

## Deliverable format

Report:

1. files added/changed/removed
2. which custom files were preserved
3. policy-path choice (config vs policy) and rationale
4. validation command outputs + exit codes
5. remaining follow-ups (if any)
