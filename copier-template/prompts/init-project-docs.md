---
description: Run interview-first initialization for organization and project docs
system4d:
  container: "Prompt template for document initialization workflow."
  compass: "Create compact, aligned org/project docs from structured intake."
  engine: "Intent -> interview -> synthesize -> update docs -> verify."
  fog: "Incomplete intake answers can cause ambiguous documentation."
---

Initialize organization and project docs from interactive intake.

Startup intent (if provided): $@

Steps:
1. Read `docs/org/project-docs-intake.questions.json`.
2. If startup intent is non-empty, create `docs/org/project-docs-intake.runtime.questions.json` by cloning the base questions file and prepending one text question:
   - `id`: `startup_intent_confirmation`
   - `type`: `text`
   - `question`: `Startup intent captured: <startup intent>. Confirm or refine this intent before continuing.`
3. Try running the `interview` tool:
   - `questions`: runtime file from step 2 if created, otherwise `docs/org/project-docs-intake.questions.json`
   - `timeout`: `900`
4. If `interview` is unavailable or fails (for example missing tool or non-interactive/headless mode), fall back to plain chat intake:
   - Ask the same questions from `docs/org/project-docs-intake.questions.json` directly in chat.
   - Keep question ids so mapping stays deterministic.
5. Use collected responses (tool or fallback chat) to update these files:
   - `docs/org/operating_model.md`
   - `docs/project/foundation.md`
   - `docs/project/vision.md`
   - `docs/project/strategic_goals.md`
   - `docs/project/tactical_goals.md`
6. Keep wording fully in English.
7. Keep **organization purpose** separate from **project purpose**.
8. Keep output compact and testable.
9. Delete `docs/org/project-docs-intake.runtime.questions.json` if it was created.
10. Run `bash ./scripts/validate-structure.sh`.
