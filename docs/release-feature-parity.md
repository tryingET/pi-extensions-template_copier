---
summary: "Release automation parity matrix between secure-package-update and the copier template baseline."
read_when:
  - "Aligning release setup across extension repositories."
  - "Preparing template changes for npm publish readiness."
---

# Release setup parity matrix

Legend: ✅ present, ⚠️ partial, ❌ missing.

| Capability | `secure-package-update` | template (before) | template (after) | Notes |
| --- | --- | --- | --- | --- |
| release-please workflow + config + manifest | ❌ | ✅ | ✅ | Template already had release-please baseline. |
| npm publish workflow (OIDC + provenance) | ❌ | ✅ | ✅ | Template already had trusted publishing baseline. |
| automated release-check workflow on PR/push | ✅ | ❌ | ✅ | Added `.github/workflows/release-check.yml` to template scaffold. |
| local `release:check` script with npm dry-runs | ✅ | ❌ | ✅ | Added `scripts/release-check.sh` + npm scripts. |
| deterministic npm artifact whitelist (`package.json files`) | ✅ | ❌ | ✅ | Added `files` list to template package scaffold. |
| package publish metadata (`publishConfig`) | ✅ | ❌ | ✅ | Added npm registry + public access defaults. |
| tarball hygiene (`*.tgz` ignored + cleanup in checks) | ⚠️ | ❌ | ✅ | Template now ignores `*.tgz`; release-check auto-cleans tarballs by default. |
| SPDX + license file included in package | ✅ | ❌ | ✅ | Added `LICENSE` to generated scaffold. |
| structure validation enforces release baseline | ⚠️ | ⚠️ | ✅ | `validate-structure.sh` now validates release-check files + package publish metadata. |

## Migration outcome in template

The template now combines both baselines:

1. **Versioning & release orchestration** (release-please + publish workflow).
2. **Artifact/publish preflight checks** (`release-check` workflow + script).

This gives generated extension repos a single, repeatable release path:

- PR/push: `release-check` + structural CI.
- Release prep (local): `npm run release:check`.
- Release automation: release-please PR -> GitHub release tag -> npm trusted publish.
