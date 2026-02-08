# Next session prompt — copier-first template hardening

Goal: finalize and harden the Copier-based template in `~/programming/pi-extensions/template`.

## Current state (already done)

- Generator is Copier-first (`copier.yml` + `copier-template/`).
- `new-pi-extension-repo.sh` is now a thin compatibility wrapper around `copier copy`.
- Generated repos include:
  - production scaffold docs/scripts/hooks/prompts
  - `prek` pre-commit integration with fallback validation
  - startup intent router:
    - `.pi/extensions/startup-intake-router.ts`
    - `.pi/prompts/init-project-docs.md`
  - interview questions: `docs/org/project-docs-intake.questions.json`
  - Copier answers file: `.copier-answers.yml`
- Wording is fully English.
- Organization purpose and project purpose are explicitly separated.
- Canonical smoke repo is now only:
  - `~/programming/pi-extensions/_template-smoke`

## Non-negotiables

1. Keep command shape:
   - `bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh <repo-name> [command-name]`
2. Keep one canonical smoke repo (`_template-smoke`) — no numbered variants.
3. Keep markdown frontmatter with `system4d` keys for all generated markdown files.
4. Keep links as standard markdown links.
5. Keep startup intent -> interview flow via project-local `.pi` router + prompt.

## Work in this path

- `~/programming/pi-extensions/template/copier.yml`
- `~/programming/pi-extensions/template/copier-template/`
- `~/programming/pi-extensions/template/new-pi-extension-repo.sh`
- `~/programming/pi-extensions/template/README.md`

## Tasks for this session

1. **Copier lifecycle QA**
   - Verify current guidance for:
     - `copier update --trust` (when available)
     - `copier recopy --trust` fallback
   - Ensure docs and script comments are consistent.

2. **Startup interview UX polish**
   - Review `.pi/extensions/startup-intake-router.ts` behavior for first-message capture.
   - Confirm utility commands work:
     - `/startup-intake-router-status`
     - `/startup-intake-router-reset`
   - Confirm no accidental command interception after first message.

3. **Template consistency sweep**
   - Ensure no stale placeholders remain.
   - Ensure `package.json` generated values remain correct (`pi-package`, `pi.extensions`, `pi.prompts`, scripts).
   - Ensure scripts are executable via Copier tasks.

4. **Docs quality pass**
   - README + CONTRIBUTING + AGENTS copier policy wording aligned.
   - Keep concise.

## Validation checklist

Run exactly:

```bash
# regenerate canonical smoke repo
rm -rf ~/programming/pi-extensions/_template-smoke
bash ~/programming/pi-extensions/template/new-pi-extension-repo.sh _template-smoke

cd ~/programming/pi-extensions/_template-smoke
./scripts/validate-structure.sh
npm run check
./.githooks/pre-commit
```

Additional checks:

```bash
# ensure only one smoke repo
cd ~/programming/pi-extensions
ls -1 | rg '^_template-smoke' || true

# ensure copier answers exists
test -f ~/programming/pi-extensions/_template-smoke/.copier-answers.yml && echo OK
```

## Deliverable

Summarize:
- files changed
- validation commands + output
- any lifecycle tradeoffs (`update` vs `recopy`)
- confirmation that only `_template-smoke` exists
