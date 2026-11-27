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
1. **Approve context**: invoke requirements-discovery; run interactive discovery until no critical gap remains and obtain explicit approval of `<project-root>/project-context.md`. Stop here while it is `Draft`. All later steps use only the approved context.
2. **Design architecture**: invoke integration-designer and api-led-designer; record assumptions and ADRs.
3. **Design APIs**: define ownership, contracts, versioning, and dependencies.
4. **Generate RAML**: invoke raml-generator and validate fragments/examples.
5. **Generate project**: invoke mule-project-generator and enforce the [mandatory modular layout](../../instructions/mulesoft.instructions.md#mandatory-modular-project-layout): APIKit entry and resource routing flows together in `main-flow.xml`, dedicated per-business-flow XML files, grouped common subflows, separate configurations, and explicit `flow-ref` delegation.
6. **Generate mappings**: invoke dataweave-generator for source/target and reusable transformations.
7. **Generate error handling**: invoke error-handling-generator for normalization, retries, and replay.
8. **Generate tests**: invoke munit-generator for success, negative, edge, timeout, and downstream failures.
9. **Generate deployment**: invoke deployment-generator and target runtime skill.
10. **Generate CI/CD**: invoke ci-cd-generator for build, test, scan, and promotion workflows.
11. **Generate documentation**: invoke documentation-generator for README, API, runbook, and recovery.
12. **Review security**: invoke security-reviewer and stop on hardcoded secret or disabled TLS findings.
13. **Review performance**: invoke performance-reviewer for volume, streaming, pagination, pools, retries, and cache.
14. **Review code**: invoke code-reviewer and report merge-blocking findings.
15. **Validate**: build the project, run MUnit and available static checks, then follow the agent's autonomous local validation loop for the contract-defined endpoint or trigger. Diagnose and fix failures and rerun affected checks within the loop's retry limit.

## Expected Outputs
- Approved Project Context Instruction
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
- Check the generated or enhanced app against `salesforce-pdf-api`: one authored Mule root with `main/`, `implementation/`, and `config/`. Require action-specific connector and Logger `doc:name` labels and MUnit evidence for the changed orchestration.
- Distinguish physical duplicate source trees from Studio source-folder entries and their physical parents. Never delete `src/main` or exclude required source resources to simplify Package Explorer; use view filters for presentation-only requests and preserve normal Maven/MUnit build mirrors.
- Generation does not start until the Project Context Instruction is `Approved`; no critical requirement is assumed.
- Every requirement ID maps to implementation, tests, and documentation, or to an explicit user-approved gap; no artifact implements untraced behavior.
- Project builds and MUnit suite completes or failure evidence is returned.
- New and modified flows must satisfy the mandatory modular layout, including safe extraction of touched business flows, consolidation of APIKit routes in main, loaded XML modules, and resolved cross-file references. Do not mark generation complete for a monolithic implementation.
- Include a main-to-business reference map and MUnit evidence for the real cross-file orchestration path; do not mock internal `flow-ref` calls in that integration check.
- Use MuleSoft-native implementation and validation artifacts, including MUnit and the Mule HTTP Request connector; do not generate standalone scripts or code in other languages as test clients.
- Contract-derived MUnit assertions check response and observable side effects; when safely available, an actual local listener is exercised over HTTP and its result is reported separately from flow-level mocked tests.
- Validation uses isolated test state and mocked external dependencies; blocked or unexecuted checks are reported, not presented as passing.
- If manual HTTP commands are supplied, verify their request bytes and shell quoting separately from MUnit when execution tools permit; use the same UTF-8 request fixtures and report any unverified manual checks.
- No hardcoded secrets, credentials, or private endpoints.
- API contracts have positive and error examples.
- Deployment is target-specific and promotion-safe.
- Security and performance gates include evidence.
