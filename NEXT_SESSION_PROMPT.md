# Next session prompt — finalize Biome-first template hardening (HTN slice O1→O4)

You are working in the **template source repo**:
`~/programming/pi-extensions/template`

This is **not** a generated repo. Keep all template changes under:
- `copier-template/**`
- `copier.yml`
- root test/guardrail scripts

Do **not** run `copier copy ... .` in this repo root.

---

## Mission

Complete the first HTN execution slice for Biome hardening (solo builder + AI-heavy workflow), then verify end-to-end.

### HTN slice to execute now

- **O1** editor enforcement
- **O2** tighten high-signal Biome rules
- **O3** suppression governance policy
- **O4** path override strategy (schema-valid, low-noise)

Keep WIP = 1 (finish each operator + validate before next).

---

## Current known state (already in working tree)

Biome baseline migration is mostly done already:
- `quality-gate.sh` switched from ESLint detection to Biome
- `package.json.jinja` has pinned `@biomejs/biome` and `engines.node >=22`
- scaffold docs updated for `npm run fix` + Biome lane
- contract and validation scripts updated
- root `docs/release-feature-parity.md` was intentionally removed

There are local unstaged changes. **Continue from current tree**; do not reset.

---

## Required tasks

### 1) O1 — Editor enforcement (template baseline)

Add a template editor settings file:
- `copier-template/.vscode/settings.json`

Goal:
- Biome as default formatter for JS/TS/JSON(+JSONC)
- format on save enabled
- Biome code actions on save enabled where appropriate

Then update invariants/contract/docs if needed so this new baseline file is expected (only where appropriate).

### 2) O2 — Tighten high-signal rules in `biome.jsonc`

In `copier-template/biome.jsonc`:
- keep `recommended: true`
- explicitly set high-signal rules for AI-generated code quality, at minimum:
  - `suspicious.noExplicitAny`
  - `style.useTemplate`

Pick severities intentionally (prefer `error` unless noisy).

### 3) O3 — Suppression governance policy

Update contributor docs so suppressions are controlled:
- every `biome-ignore` requires a short rationale
- include issue/todo reference pattern when not immediately removable

Touch at least:
- `copier-template/docs/dev/CONTRIBUTING.md`
- `copier-template/CONTRIBUTING.md` (or link to canonical policy)

### 4) O4 — Path overrides strategy

Implement Biome path handling with schema-valid config:
- reduce false positives/noise for generated/artifact paths
- avoid broad blind ignores
- prefer precise overrides or includes, consistent with template intent

Important: verify with current pinned Biome schema (no unknown keys).

---

## Keep these outcomes intact

- `docs/release-feature-parity.md` remains deleted
- no stale references to that doc in root README
- template still passes guardrails + smoke + contract + idempotency

---

## Validation loop (must run and report)

Run in this repo:

```bash
npm run check:full
```

If anything fails, fix and rerun until green.

---

## Deliverable format

Return a concise report with:
1. files changed/added/removed
2. exact Biome rule decisions + rationale
3. suppression policy text added (short quote)
4. validation command output summary (pass/fail)
5. follow-up suggestions (max 3)

If blocked by ambiguity, ask **one** focused question only.
