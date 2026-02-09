# AGENTS.md — template repo guardrails

Purpose: maintain Copier template source. Not generated target repo.

## Invariants
- Keep template content under `copier-template/**`.
- Keep template config in `copier.yml` (+ wrapper scripts at repo root).
- Never run `copier copy ... .` into this repo root.
- Root `.copier-answers.yml` is forbidden.
- `copier update` not applicable for this repo.

## Validation loop
- Run `bash ./scripts/template-guardrails.sh`.
- Run `bash ./scripts/smoke-test-template.sh`.
- Run `bash ./scripts/generated-contract-test.sh`.
- Run `bash ./scripts/idempotency-test-template.sh`.
- Keep contract rules in `contract/generated-repo.contract.json`.
- Install local hook once: `bash ./scripts/install-hooks.sh`.
- Keep this repo clean of generated-root artifacts.
