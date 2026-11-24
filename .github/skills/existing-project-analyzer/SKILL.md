---
name: existing-project-analyzer
description: Analyzes Mule projects and change impacts before making focused, behavior-preserving modifications.
---

# Existing Project Analyzer

## Trigger Conditions
- A change affects an existing Mule application, flow, mapping, contract, or test.
- A generated project needs a targeted modification rather than a new scaffold.

## Workflow Steps
1. Identify the intended project and `pom.xml`; clarify the selection if multiple projects could match. Inspect worktree changes and preserve unrelated user work.
2. Inventory runtime and plugin versions, API contracts, Mule XML, referenced flows, DataWeave modules, configuration, connectors, tests, and CI for the affected behavior.
3. Trace entry points, callers, `flow-ref` targets, payloads, variables, side effects, error handlers, transactions, concurrency, and public outputs.
4. Run the smallest relevant existing tests when safe and feasible. Record command, results, existing failures, and blockers without claiming an unrun baseline passed.
5. Map each requested change to affected components, compatibility risks, configuration, tests, and unresolved decisions using the impact template.
6. Make only the approved change; preserve unrelated code, contracts, processing order, error behavior, and user edits. Do not restructure unrelated flows.
7. Add focused regression tests, run affected checks, and compare results with the baseline.

## Expected Outputs
- Project inventory and impact assessment
- Baseline evidence and unresolved risks
- Focused implementation and regression results

## Validation Rules
- Ambiguous project selection or business behavior is clarified before editing.
- Changes do not overwrite user work or silently change public contracts.
- Connector mocks never call production systems; filesystem tests avoid user data.
- Existing failures, new failures, and blocked checks are distinguished.

## Supporting Artifacts
- `templates/project-context/change-impact-template.md`
