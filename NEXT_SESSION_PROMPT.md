# Next session prompt — Path 2/3 consolidation + publish prep

You are working in:
`~/programming/pi-extensions/pi-extensions-template_copier`

## What is already done (do not redo)

### Path 3 (separate extension repo)
- Dedicated extension repo created:
  - `~/programming/pi-extensions/system4d-intake-workflow`
- `NEXT_SESSION_PROMPT.md` there has a concrete MVP plan for System4D intake workflow commands/contracts/tests.
- Repo currently passes baseline check:
  - `cd ~/programming/pi-extensions/system4d-intake-workflow && npm run check`

### Path 2 (template simplification controls)
Implemented in template source:
- `copier.yml` now has vars:
  - `intake_profile`: `guided|minimal` (default `guided`)
  - `interview_tool_version`: pinned semver (default `0.5.1`)
- CLI wrapper + npm bin support these knobs:
  - `--intake-profile`
  - `--interview-tool-version`
  - env fallbacks: `PI_INTAKE_PROFILE`, `PI_INTERVIEW_TOOL_VERSION`
- generated `package.json` now stores:
  - `config.intakeProfile`
  - `config.interviewToolVersion`
- intake questions are now profile-driven via:
  - `copier-template/docs/org/project-docs-intake.questions.json.jinja`
- interview install helper uses pinned version from repo config.
- structure validation updated for profile-aware checks.

### System planning repo (non-template)
- Created:
  - `~/ai-society/softwareco/owned/nexus-workflow-platform`
- Contains Path 5 system vision + migration roadmap docs.

### Cleanup
- Wrong repo was deleted:
  - `~/ai-society/softwareco/owned/pi-system4d-intake-workflow`

## Important current state

Template repo working tree is intentionally dirty with multiple edits including:
- release tooling + publish helper (`bin/npm-bootstrap-publish.mjs`)
- interview/tooling changes
- copier var/profile changes

Publish is still blocked by auth (`op signin` / `NPM_TOKEN` missing).

## High-priority next actions

1. **Scope + stage commits cleanly in template repo**
   - Group A: release/publish helper work
   - Group B: interview/profile/pinning changes
   - Avoid accidental unrelated files unless intentional.

2. **Sync Path 3 repo with latest template knobs**
   - `system4d-intake-workflow` was generated before newest profile/version wiring.
   - Apply one of:
     - regenerate/recopy from updated template, or
     - manual patch to include `config.intakeProfile` + `config.interviewToolVersion` + pinned install helper behavior.

3. **Then execute Path 3 MVP in its repo**
   - Follow:
     - `~/programming/pi-extensions/system4d-intake-workflow/NEXT_SESSION_PROMPT.md`

4. **Release readiness**
   - In template repo run:
     - `npm run check:full`
     - `npm run release:check:quick`
   - If green and commit(s) pushed, publish once auth is available.

## Fast start commands

```bash
cd ~/programming/pi-extensions/pi-extensions-template_copier
git status --short
npm run check:full
npm run release:check:quick

cd ~/programming/pi-extensions/system4d-intake-workflow
npm run check
```

## Decision log (locked)

- Keep `pi-interview` optional, not package dependency.
- Installation must be pinned by version.
- Template supports two intake modes:
  - `guided` (decision cards + recommendations)
  - `minimal` (text-first)
- Platform/monorepo vision lives in softwareco planning repo, not in the extension template.
