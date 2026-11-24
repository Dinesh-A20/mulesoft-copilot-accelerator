---
name: mule-troubleshooter
description: Troubleshoots Mule build, runtime, connector, DataWeave, and MUnit failures in new or existing projects.
---

# Mule Troubleshooter

## Trigger Conditions
- A generated or existing Mule project fails a build, test, deployment configuration check, or runtime operation.
- A user reports unexpected flow behavior or an error.

## Workflow Steps
1. Identify the selected project, expected and actual behavior, failure stage, relevant versions, and sanitized error evidence. Request missing evidence when needed.
2. Inspect the affected path and reproduce with the smallest safe command or isolated test when feasible. Do not call production systems or mutate shared environments without authorization.
3. Classify the failure and trace the root cause through contracts, flows, connector schemas, DataWeave inputs, configuration, and tests. Separate application defects from environment or dependency blockers.
4. Make a focused fix while preserving user changes, error behavior, transactions, concurrency, and side-effect order.
5. Add a focused regression test when applicable and rerun the failing check and dependent checks. If execution is blocked, report the blocker and evidence instead of claiming success.
6. Summarize sanitized symptoms, root cause, files changed, commands, results, and remaining risks. Generalize a reusable skill rule only when the evidence supports it.

## Expected Outputs
- Reproduction evidence or explicit blocker
- Root cause and scoped fix
- Regression test and validation results

## Validation Rules
- No secrets, tokens, private payloads, or unredacted logs appear in reports.
- Failed or unrun tests are not reported as passed.
- User data and unrelated work are not overwritten.

## Supporting Artifacts
- `templates/documentation/troubleshooting-template.md`
