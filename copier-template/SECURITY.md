---
summary: "Security reporting and hardening expectations."
read_when:
  - "Reporting vulnerabilities or reviewing risk controls."
system4d:
  container: "Security policy for package maintainers and contributors."
  compass: "Prefer least privilege and explicit review before release."
  engine: "Report -> triage -> patch -> verify -> disclose."
  fog: "Third-party dependency risks change over time."
---

# Security Policy

## Supported versions

Security fixes are applied to the latest main branch.

## Reporting a vulnerability

1. Open a private security report with maintainers.
2. Include reproduction steps and impact.
3. Avoid public disclosure until a fix is available.

## Baseline safeguards

- Run `npm run check` before commits.
- Review changes to scripts, hooks, and extension entrypoints.
- Keep dependencies minimal.
