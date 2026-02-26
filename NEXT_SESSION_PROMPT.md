# Next session prompt — Template maintenance

You are working in:
`~/programming/pi-extensions/pi-extensions-template_copier`

## What is already done (do not redo)

### Interview tool migration (DONE)
- Migrated from `pi-interview@0.5.1` to `pi-askuserquestion`
- Pinned to verified commit: `e6e8e20b4fa195b11d6f8007d74530374271c254`
- Security review done ✅ — safe to use
- Cloned to: `~/programming/upstream/pi-extensions/pi-askuserquestion/`
- Updated files:
  - `copier.yml` → `interview_tool_source`
  - `copier-template/package.json.jinja` → `interviewToolSource`
  - `copier-template/scripts/init-project-docs.sh` → updated install
  - `copier-template/scripts/validate-structure.mjs` → updated validation
  - `copier-template/README.md.jinja` → updated docs
  - `scripts/smoke-test-template.sh` → updated test

### Template validation fixes (11 bugs fixed)
- Extracted `validate-structure.mjs` (409 lines) from `validate-structure.sh` (now 365 lines)
- Fixed 500-line self-violation in validate-structure.sh
- Fixed forbidden `<repo-name>` placeholder in sync-to-live.sh help text
- Converted `.github/CODEOWNERS` to `.jinja` template with `{{ github_maintainer }}`
- Made release-check.sh test settings configurable via env vars
- All tests pass

### Repo/package setup
- Local repo: `~/programming/pi-extensions/pi-extensions-template_copier`
- GitHub: `https://github.com/tryingET/pi-extensions-template_copier`
- npm: `@tryinget/pi-extensions-template_copier@0.3.0`

## High-priority next actions

1. **Check for pinned dependency updates (MANDATORY before releases)**
   ```bash
   npm run check:pinned
   ```
   - Compares pinned `pi-askuserquestion` commit to upstream HEAD
   - Returns exit 1 if updates available (useful for CI gates)
   - Provides GitHub compare URL for security review
   - Only update pinned SHA after reviewing changes

2. **Update intake questions format for pi-askuserquestion (optional)**
   - pi-askuserquestion uses a different schema:
     ```typescript
     {
       questions: Array<{
         question: string;       // Full question text
         header: string;         // Short tab label (max 12 chars)
         options: Array<{label: string; description?: string}>;
         multiSelect: boolean;
       }>
     }
     ```
   - Current: `docs/org/project-docs-intake.questions.json.jinja` uses pi-interview format
   - Options: (a) adapt format, (b) create converter, or (c) use plain chat fallback

3. **Dependency triage**
   - Run `npm audit` and address transitive vulnerabilities
   - Run dep-viz + dep-diet if available

4. **Cut next release**
   - `npm run check:full`
   - `npm run check:pinned` (ensure no pending updates)
   - `npm run release:check:quick`
   - Merge release PR, confirm publish

## Pinned dependency management

### Current pinned versions
| Package | Pinned SHA | Source |
|---------|-----------|--------|
| pi-askuserquestion | `e6e8e20b4fa195b11d6f8007d74530374271c254` | git:github.com/ghoseb/pi-askuserquestion |

### Update process
1. Run `npm run check:pinned`
2. If updates available, review the compare URL
3. Security review the changes
4. Update `scripts/check-pinned-deps.sh` → `PINNED_SHA`
5. Update `copier.yml` → `interview_tool_source` default
6. Update `scripts/smoke-test-template.sh` → `SMOKE_INTERVIEW_TOOL_SOURCE`
7. Re-run all tests: `npm run check:full`

## Fast start commands

```bash
cd ~/programming/pi-extensions/pi-extensions-template_copier

# Check current state
git status --short
bash ./scripts/template-guardrails.sh

# Check for pinned dependency updates
npm run check:pinned

# Run all validation
npm run check:full

# After template changes
bash ./scripts/smoke-test-template.sh
bash ./scripts/generated-contract-test.sh
bash ./scripts/idempotency-test-template.sh

# Inspect pi-askuserquestion upstream
cd ~/programming/upstream/pi-extensions/pi-askuserquestion
git log --oneline -n 10
git show --stat HEAD
```

## Decision log

- Use `pi-askuserquestion` (native pi-tui integration) — DONE
- Pin to specific commit SHA for security — DONE
- Add `npm run check:pinned` for update detection — DONE
- Keep intake profile modes: `guided` and `minimal`
- Keep template intake context seeding
- May need to adapt question format for pi-askuserquestion schema
- Keep root + generated vouch/issue baselines aligned
