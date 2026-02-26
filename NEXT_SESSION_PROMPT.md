# Next session prompt — template cleanup after intake removal

You are working in:
`~/programming/pi-extensions/pi-extensions-template_copier`

## Context
The previous startup questionnaire workflow was intentionally removed from this template.
Keep the scaffold focused on core extension development, validation, and release automation.

## Mandatory review method
Use `~/steve/prompts/prompt-snippets.md` for deep review before release.
Focus on:
- INVERSION (hidden failure modes after removing workflow)
- BLAST RADIUS (CLI wrappers, docs, contract, smoke tests)
- ESCAPE HATCH (rollback plan if template generation breaks)

## High-priority checks
1. `bash ./scripts/template-guardrails.sh`
2. `bash ./scripts/smoke-test-template.sh`
3. `bash ./scripts/generated-contract-test.sh`
4. `bash ./scripts/idempotency-test-template.sh`

## Fast start
```bash
cd ~/programming/pi-extensions/pi-extensions-template_copier
git status --short
npm run check:full
```

## Decision log
- Intake/interview process removed from template scaffold.
- Docs and wrapper CLI now target plain extension scaffolding only.
- Keep template minimal: extension scaffold + quality/release baseline.
