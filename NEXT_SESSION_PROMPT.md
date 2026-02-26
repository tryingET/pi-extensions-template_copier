# Next session prompt — template maintenance & repo migration

You are working in:
`~/programming/pi-extensions/pi-extensions-template_copier`

## Context
Template is stable with intake removal complete. New tooling added:
- `justfile` for maintenance tasks
- `scripts/update-generated-repos.sh` for batch updates

Current focus: **migrate existing repos onto the template** so they can receive future updates.

## Repo migration status

| Repo | Status | Blocker |
|------|--------|---------|
| `pi-extensions-template_copier` | N/A | This is the template source |
| `pi-autonomous-session-control` | NEEDS FIX | Has `.copier-answers.yml`, but 37 pre-existing test failures block update |
| `pi-little-helpers` | NEEDS MIGRATION | No git repo, no `.copier-answers.yml` |
| `pi-user-prompt-compaction` | NEEDS MIGRATION | Git repo, no `.copier-answers.yml` |

## Migration tasks

### 1. Fix `pi-autonomous-session-control` tests

The tests are failing because they mock a `tool` object that doesn't exist in the current extension signature. The extension evolved but tests weren't updated.

```bash
cd ~/programming/pi-extensions/pi-autonomous-session-control
npm run check  # see failures
```

Tasks:
- [ ] Audit test files in `tests/` directory
- [ ] Identify mock expectations vs actual extension API
- [ ] Fix or skip broken tests (document why)
- [ ] Run `npm run check` until green
- [ ] Run update: `just update HEAD` (from template repo)

### 2. Migrate `pi-little-helpers`

Currently has extensions but no git repo or template metadata.

```bash
cd ~/programming/pi-extensions/pi-little-helpers
ls -la extensions/
```

Tasks:
- [ ] List existing extensions and their dependencies
- [ ] Decide: re-generate from template OR retroactively add template metadata
- [ ] If re-generating:
  - [ ] Create temp backup of existing extensions
  - [ ] Run `just new pi-little-helpers little-helpers --target-dir /tmp/pi-little-helpers-new`
  - [ ] Copy extensions back
  - [ ] Move into place
- [ ] If retroactive:
  - [ ] `git init`
  - [ ] Create `.copier-answers.yml` manually with correct `repo_name`, `command_name`, `github_maintainer`
  - [ ] Run `copier recopy --trust --defaults --vcs-ref HEAD ~/programming/pi-extensions/pi-extensions-template_copier`
- [ ] Run `npm run check`
- [ ] Commit

### 3. Migrate `pi-user-prompt-compaction`

Has git repo but no template metadata.

```bash
cd ~/programming/pi-extensions/pi-user-prompt-compaction
ls -la extensions/
```

Tasks:
- [ ] Same options as `pi-little-helpers` (re-generate vs retroactive)
- [ ] Prefer retroactive if repo has meaningful git history
- [ ] Run `npm run check`
- [ ] Commit

## After all migrations

```bash
# Verify all repos are updateable
cd ~/programming/pi-extensions/pi-extensions-template_copier
just update-dry HEAD

# Should show all repos as DRY-RUN ready (no SKIPPED except template source)
```

## Mandatory review method
Use `~/steve/prompts/prompt-snippets.md` for deep review before release.

## Fast start
```bash
cd ~/programming/pi-extensions/pi-extensions-template_copier
git status --short
npm run check:full
just update-dry HEAD  # preview batch update
```

## Decision log
- Intake/interview process removed from template scaffold.
- Docs and wrapper CLI now target plain extension scaffolding only.
- Keep template minimal: extension scaffold + quality/release baseline.
- `update-generated-repos.sh` uses `--overwrite` on recopy for conflict resolution.
