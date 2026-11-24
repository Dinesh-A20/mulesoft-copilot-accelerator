---
name: full-project-generator
description: Orchestrates requirements analysis through architecture, contracts, implementation, tests, deployment, and reviews.
---

# Full Project Generator

## Trigger Conditions
- A business requirements package asks for an end-to-end Mule application.
- A generated project must include architecture, implementation, tests, CI/CD, and operations.
- The `mule-architect` agent needs a complete delivery workflow.

## Workflow Steps
1. **Read requirements**: invoke requirements-analyzer; explicitly read the selected project context, trace requirements to sources, resolve material conflicts, and record scope, NFRs, data classes, integrations, and constraints.
2. **Design architecture**: invoke integration-designer and api-led-designer; record assumptions and ADRs.
3. **Design APIs**: define ownership, contracts, versioning, and dependencies.
4. **Generate RAML**: invoke raml-generator and validate fragments/examples.
5. **Generate project**: invoke mule-project-generator for Maven and decomposed Mule XML flows; use existing-project-analyzer before modifying an existing application.
6. **Generate mappings**: invoke dataweave-generator using the project mapping specification and expected examples for nontrivial transformations.
7. **Generate error handling**: invoke error-handling-generator for normalization, retries, and replay.
8. **Generate tests**: invoke munit-generator for success, negative, edge, timeout, and downstream failures.
9. **Generate deployment**: invoke deployment-generator and target runtime skill.
10. **Generate CI/CD**: invoke ci-cd-generator for build, test, scan, and promotion workflows.
11. **Generate documentation**: invoke documentation-generator for README, API, runbook, and recovery.
12. **Review security**: invoke security-reviewer and stop on hardcoded secret or disabled TLS findings.
13. **Review performance**: invoke performance-reviewer for volume, streaming, pagination, pools, retries, and cache.
14. **Review code**: invoke code-reviewer and report merge-blocking findings.
15. **Validate**: build the selected project, run MUnit and available static checks, inspect reports, and reconcile requirements to implementation, tests, or explicit gaps. Route failures through mule-troubleshooter.

## Expected Outputs
- Requirements traceability matrix
- Architecture and API-led design
- RAML and reusable fragments
- Maven Mule project
- DataWeave mappings/modules
- Error handling and replay design
- MUnit suites and fixtures
- Deployment descriptors and CI/CD workflows
- README and operational runbook
- Security and performance reports

## Validation Rules
- Every requirement maps to implementation or an explicit gap.
- Complex mappings have approved business rules and examples; unresolved decisions are not invented.
- Preserve existing user changes and contracts; record baseline failures separately.
- Project builds and MUnit suite completes or failure evidence is returned.
- No hardcoded secrets, credentials, or private endpoints.
- API contracts have positive and error examples.
- Deployment is target-specific and promotion-safe.
- Security and performance gates include evidence.
