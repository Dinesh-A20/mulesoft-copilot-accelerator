---
name: documentation-generator
description: Generates implementation, operational, security, testing, and runbook documentation.
---

# Documentation Generator

## Trigger Conditions
- A solution reaches implementation or review.
- Operations or security needs an operating procedure.
- API or project documentation is incomplete.

## Workflow Steps
1. Use the approved Project Context Instruction as the source; extract architecture, APIs, dependencies, and configuration, and update its traceability matrix and change log.
2. Generate README and setup instructions.
3. Generate API, flow, error, and replay documentation, including the [mandatory modular layout](../../instructions/mulesoft.instructions.md#mandatory-modular-project-layout), each file's registered flow names/responsibilities, and the main-to-business reference map.
4. Generate runbook, monitoring, alert, and recovery procedures.
5. Generate decision log and assumption/limitation list.
6. Validate links and sensitive-data-free examples.

## Expected Outputs
- README
- Architecture and API documentation
- Operational runbook
- Security and recovery notes
- Configuration matrix

## Validation Rules
- No credentials or private endpoints in examples.
- Setup commands are reproducible.
- Operational recovery steps are executable.
- The documented entry, business modules, shared subflows, separate configurations, and references match the generated files and application config-loading metadata.
