# Next session prompt — Path 2 template hardening + release flow stabilization

You are working in:
`~/programming/pi-extensions/pi-extensions-template_copier`

## What is already done (do not redo)

### Repo/package rename + remote setup
- Local repo path renamed from `template` to:
  - `~/programming/pi-extensions/pi-extensions-template_copier`
- Compatibility symlink exists:
  - `~/programming/pi-extensions/template -> pi-extensions-template_copier`
- GitHub repo created and pushed:
  - `https://github.com/tryingET/pi-extensions-template_copier`
- npm package renamed and published at:
  - `@tryinget/pi-extensions-template_copier@0.1.0`

### Path 2 template behavior implemented
- Intake profile + pinned interview version controls are in place (`guided|minimal`, pinned semver).
- Generation defaults to local `HEAD` when using local git template checkout.
- Generated quality gate now runs tests in `pre-push` and `ci` when `tests/*.test.*` exists.
- CLI + shell wrapper accept profile/version controls.

### Vouch + issue templates status
- Added to **template source repo root** (`.github`):
  - `ISSUE_TEMPLATE/{bug-report,feature-request,docs,config}.yml`
  - `VOUCHED.td`
  - `workflows/vouch-check-pr.yml`
  - `workflows/vouch-manage.yml`
- Updated vouch workflow action refs (root + copier-template) to:
  - `e87054b83fcd2b10d2155b733a10a8aec344176a`
- In generated repos, `VOUCHED.td` is now templated (`.jinja`) and seeded via `github_maintainer`.
  - CLI supports `--github-maintainer`
  - env supports `PI_GITHUB_MAINTAINER`
  - fallback detection uses `gh api user -q .login`, then `tryingET`

### Cleanup already completed
- Removed accidental local files `Security` and `Settings`.
- Deleted orphan release-please branch from remote.
- Restored workflow permissions to safe defaults (`read`, no approve PR reviews).

## Important current state

- Template now includes startup intake context seeding and runtime question adaptation.
- Smoke installs currently report ~20 high-severity npm vulnerabilities (mostly transitive).
- Next session must run dependency triage with both **dep-viz** and **dep-diet** before release work.
- Release-please permission follow-up may still be needed depending on GitHub Actions repo settings.

## High-priority next actions

1. **Run dependency triage (mandatory) with dep-viz + dep-diet**
   - Build a dependency graph/hotspot view with `dep-viz`.
   - Build removable/reduction candidates with `dep-diet`.
   - Cross-check both outputs against `npm audit --json` and identify top transitive roots.

2. **Apply dependency reduction/remediation in smallest safe slices**
   - Prefer upgrades/removals that reduce transitive attack surface without breaking generated-repo contract.
   - Re-run full template validation after each slice.

3. **Re-validate release pipeline after dependency cleanup**
   - `npm run check:full`
   - `npm run release:check:quick`
   - Re-check `release-please` permissions/workflow status only after dependency baseline is stable.

4. **Cut next release once vulnerability baseline is improved and checks are green**
   - Merge release PR,
   - confirm publish workflow for new tag succeeds.

## Fast start commands

```bash
cd ~/programming/pi-extensions/pi-extensions-template_copier

git status --short
git log --oneline -n 8

# baseline security snapshot
npm audit --json > /tmp/pi-template-audit.json || true

# dependency triage tools (use installed CLI syntax; check --help first)
dep-viz --help
dep-diet --help

# run both tools against this repo and persist outputs (adjust flags to your installed versions)
mkdir -p /tmp/pi-template-deps
dep-viz . > /tmp/pi-template-deps/dep-viz.txt
dep-diet . > /tmp/pi-template-deps/dep-diet.txt

# then run the template validation loop
npm run check:full
npm run release:check:quick

# inspect workflow state
gh run list --repo tryingET/pi-extensions-template_copier --limit 10
```

## Release-please permission fix helpers

```bash
# inspect current workflow permissions
gh api repos/tryingET/pi-extensions-template_copier/actions/permissions/workflow

# if needed for release-please PR creation:
# (use intentionally; can be reverted after release flow is stable)
gh api -X PUT repos/tryingET/pi-extensions-template_copier/actions/permissions/workflow \
  -f default_workflow_permissions=write \
  -F can_approve_pull_request_reviews=true

# trigger release-please manually
gh workflow run release-please.yml --repo tryingET/pi-extensions-template_copier
```

## Decision log (locked)

- Keep `pi-interview` optional (not package dependency).
- Keep interview install pinned by version.
- Keep template intake modes: `guided` and `minimal`.
- Keep Path 3 implementation in its dedicated repo (`system4d-intake-workflow`), not in default template scaffold.
- Keep root + generated vouch/issue baselines aligned.
