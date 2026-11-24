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
1. Extract architecture, APIs, dependencies, and configuration.
2. Generate README and setup instructions.
3. Generate API, flow, error, and replay documentation.
4. Generate runbook, monitoring, alert, and recovery procedures.
5. Generate decision log and assumption/limitation list.
6. Validate links and sensitive-data-free examples.
7. Use project-scoped context, requirement traceability, mapping specifications, impact assessments, and troubleshooting records as applicable; report verification and unresolved decisions.

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
