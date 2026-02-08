# Next session prompt — production baseline phase 2 (community + intake + vouch trust gate)

Goal: finalize production baseline for `~/programming/pi-extensions/template` by adapting usable GitHub community templates from the Windows notes folder **and** adding `mitchellh/vouch` trust-gating defaults for generated repos.

## Must-read source of truth first

- `~/programming/pi-extensions/README.md`
- `~/programming/pi-extensions/docs/EXTENSION_RELEASE_SECURITY_GUIDE.md`
- `~/programming/pi-extensions/template/README.md`
- `~/programming/pi-extensions/template/copier.yml`
- `~/programming/pi-extensions/template/copier-template/package.json.jinja`
- `~/programming/pi-extensions/template/copier-template/README.md.jinja`

## External reference material to mine/adapt

Windows notes source:
- `/mnt/c/Users/mjpa/Documents/Obsidian/20-29_Input/23_Schriftliches/23.03_Code/github`

Vouch source (local clone for this workspace):
- `~/programming/upstream/vouch`
- `~/programming/upstream/vouch/action/check-pr/README.md`
- `~/programming/upstream/vouch/action/check-pr/action.yml`
- `~/programming/upstream/vouch/action/manage-by-issue/README.md`
- `~/programming/upstream/vouch/action/manage-by-issue/action.yml`
- `~/programming/upstream/vouch/VOUCHED.example.td`
- pinned upstream commit for this planning cycle:
  - `5713ce1baedf75e2f830afa3dac813a9c48bff12`

## Findings already analyzed

- Windows folder has good issue/PR structure, but many unresolved placeholders (`{username}`, `{repo}`, `{discordInvite}`, `{@twitter}`, etc.).
- `workflows/CICD*.md` there are notes only; not production workflow YAML.
- Existing twitter-based vulnerability contact text is outdated and must not be copied.
- `vouch` supports GitHub-native trust workflows via Actions (`check-pr`, `manage-by-issue`, optional discussion flow).
- Local mirror now exists at `~/programming/upstream/vouch` and should be the primary reference for implementation details.

## Current template state (already done)

- Copier-first scaffold stable.
- Startup intake router + interview flow stable.
- docs-list wrapper + npm scripts integrated.
- Release/security baseline already included:
  - `.github/workflows/ci.yml`
  - `.github/workflows/release-please.yml`
  - `.github/workflows/publish.yml`
  - `.github/dependabot.yml`
  - `.github/CODEOWNERS`
  - `.release-please-config.json`
  - `.release-please-manifest.json`
- Template repo tagged to `v0.2.0`.

## Non-negotiables

1. Keep command shape:
   - `bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh <repo-name> [command-name]`
2. Keep one canonical smoke repo only: `_template-smoke`.
3. Keep default topology/tooling policy:
   - one extension repo/package by default
   - single-package default = `release-please`
   - no default `semantic-release` / `changesets`
4. Keep version/tag policy:
   - package `X.Y.Z`
   - git/release tags `vX.Y.Z`
5. Keep workflow permissions minimal (read by default; elevate per job only).
6. Keep markdown frontmatter + `system4d` keys for generated markdown files.
7. Adapt templates; do not ship unresolved placeholder tokens.

## Tasks for next session

1. **Add GitHub issue + PR intake templates (adapted, not copied raw)**
   - Add under `copier-template/.github/ISSUE_TEMPLATE/`:
     - `bug-report.yml`
     - `feature-request.yml`
     - `docs.yml`
     - `config.yml`
   - Add `copier-template/.github/pull_request_template.md` (single concise template).
   - Remove placeholder tokens from adapted files.
   - Keep wording concise + operational.

2. **Add/align community health files for discoverability**
   - Add top-level generated files (or `.github` equivalents; pick one and stay consistent):
     - `CODE_OF_CONDUCT.md`
     - `SUPPORT.md`
     - `CONTRIBUTING.md` (can point to `docs/dev/CONTRIBUTING.md`)
   - Ensure `SECURITY.md` is production-safe and consistent with release/security guide.

3. **Add vouch trust-gate baseline (`mitchellh/vouch`)**
   - Use local upstream mirror as primary implementation source:
     - `~/programming/upstream/vouch`
   - Add `copier-template/.github/VOUCHED.td` starter file with comments and maintainer placeholder entries.
   - Add `copier-template/.github/workflows/vouch-check-pr.yml`:
     - trigger: `pull_request_target` on `opened`, `reopened`
     - action: `mitchellh/vouch/action/check-pr@5713ce1baedf75e2f830afa3dac813a9c48bff12` (or newer pinned ref if intentionally updated)
     - minimal permissions (`contents: read`, `pull-requests: write`)
     - document `require-vouch` and `auto-close` behavior clearly.
   - Add `copier-template/.github/workflows/vouch-manage.yml` (issue-comment based):
     - trigger: `issue_comment` created
     - action: `mitchellh/vouch/action/manage-by-issue@5713ce1baedf75e2f830afa3dac813a9c48bff12` (or newer pinned ref if intentionally updated)
     - include concurrency group for serialized `VOUCHED.td` updates
     - minimal required permissions (`contents: write`, `issues: write`, `pull-requests: read`)
   - Do **not** add discussion-based vouch workflow by default (optional follow-up).

4. **Security/reporting hardening pass**
   - Ensure vulnerability reporting path is explicit and safe.
   - Keep OIDC trusted publishing assumptions aligned with `publish.yml`.
   - Keep third-party action usage explicit; if pinning strategy changes, document rationale.

5. **Template validation upgrades**
   - Extend `scripts/validate-structure.sh` required files list for added `.github` workflows/templates/community docs.
   - Add placeholder leak guard for generated GitHub templates:
     - detect obvious unresolved tokens like `{username}`, `{repo}`, `{discordInvite}`, `{@twitter}`.
   - Add checks for vouch files/workflows presence + key markers.

6. **Docs quality pass**
   - Update `copier-template/README.md.jinja` with concise sections for:
     - release/security baseline
     - issue/PR intake
     - vouch trust gate (how maintainers vouch/denounce/unvouch)
   - Keep concise.

## Validation checklist

Run exactly:

```bash
# regenerate canonical smoke repo
rm -rf ~/programming/pi-extensions/_template-smoke
bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh _template-smoke

cd ~/programming/pi-extensions/_template-smoke
npm run check
./.githooks/pre-commit
```

Additional checks:

```bash
# inspect generated github config
cd ~/programming/pi-extensions/_template-smoke
find .github -maxdepth 4 -type f | sort

# required release/security files
test -f .github/workflows/ci.yml && echo OK
test -f .github/workflows/release-please.yml && echo OK
test -f .github/workflows/publish.yml && echo OK
test -f .github/dependabot.yml && echo OK
test -f .github/CODEOWNERS && echo OK
test -f .release-please-config.json && echo OK
test -f .release-please-manifest.json && echo OK

# required issue/pr intake files
test -f .github/ISSUE_TEMPLATE/bug-report.yml && echo OK
test -f .github/ISSUE_TEMPLATE/feature-request.yml && echo OK
test -f .github/ISSUE_TEMPLATE/docs.yml && echo OK
test -f .github/ISSUE_TEMPLATE/config.yml && echo OK
test -f .github/pull_request_template.md && echo OK

# required vouch files
test -f .github/VOUCHED.td && echo OK
test -f .github/workflows/vouch-check-pr.yml && echo OK
test -f .github/workflows/vouch-manage.yml && echo OK
rg -n "mitchellh/vouch/action/check-pr@" .github/workflows/vouch-check-pr.yml
rg -n "mitchellh/vouch/action/manage-by-issue@" .github/workflows/vouch-manage.yml
rg -n "@main" .github/workflows/vouch-*.yml && echo "unexpected @main" || true

# placeholder leak check in github templates
rg -n "\{username\}|\{repo\}|\{discordInvite\}|\{@twitter\}" .github || true

# ensure only one smoke repo
cd ~/programming/pi-extensions
ls -1 | rg '^_template-smoke' || true

# ensure copier answers exists
test -f ~/programming/pi-extensions/_template-smoke/.copier-answers.yml && echo OK
```

## Deliverable

Summarize:
- files changed
- what was adapted from `/mnt/c/.../github` vs written fresh
- validation commands + output
- confirmation placeholder tokens are cleaned
- confirmation vouch files/workflows are present and coherent
- confirmation of chosen vouch action pin ref (and why)
- confirmation only `_template-smoke` exists
- post-merge operator steps:
  - branch protection
  - CODEOWNERS owner replacement
  - npm trusted publishing wiring
  - vouch maintainer bootstrap (`.github/VOUCHED.td` owners + operating policy)
