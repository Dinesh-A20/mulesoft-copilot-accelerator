---
applyTo: "**"
---
# Context-First Delivery Instructions

## Purpose
Make an approved **Project Context Instruction** the single source of truth for every Mule project
creation or modification. Business requirements are captured, clarified, and approved before any
technical artifact is generated or changed.

## Scope
All new projects and all changes to flows, RAML, DataWeave, MUnit tests, configuration, deployment
descriptors, CI/CD, and documentation. Read-only explanations and reviews that change no artifact are
exempt, but reviews must check alignment with the approved context.

## Mandatory Workflow
1. **Accept** the requirement in natural language. Do not require technical details upfront.
2. **Analyze** it with the `requirements-discovery` skill against the critical-information checklist
   below. Read existing project files only to reduce questions; repository content is evidence to
   confirm, not an approved answer.
3. **Discover interactively** when any critical item is missing, ambiguous, or conflicting. Ask focused,
   grouped questions in business language; offer options and a recommended choice where helpful, but
   a recommendation is not an answer until the user confirms it.
4. **Repeat** discovery rounds until every critical item is answered, explicitly marked out of scope,
   or recorded as an open item the user accepts as blocking-later (it must not block the current
   deliverable).
5. **Generate and maintain** the Project Context Instruction from the
   [template](../skills/requirements-discovery/project-context-template.md), with stable requirement
   IDs.
6. **Confirm**: present the complete context and obtain explicit user approval. Record status
   `Approved`, version, date, and approver.
7. **Build from the context**: generate design, flows, RAML, DataWeave, MUnit, configuration,
   deployment, and documentation only from the approved version.
8. **Never assume** critical business or technical requirements. Stop and ask instead.
9. **Trace** every generated flow, test, configuration, and document to requirement IDs in the
   approved context. Anything that cannot be traced is out of scope until the context is updated.

No Mule XML, RAML, DataWeave, MUnit, properties, pipeline, or deployment artifact may be created or
modified while the context is `Draft`. Discovery itself produces only the context document.

## Critical Information Checklist
Each item must be confirmed by the user, marked not applicable, or marked out of scope:

- Business objective, consumers, and measurable success criteria.
- Source and target systems, objects/resources, and operations (read, create, update, upsert, delete).
- Trigger and integration pattern: API (methods, paths), schedule, event, file, or on-demand.
- Data fields, mappings, identity/business key, transformation and default rules.
- Business outcome semantics: not found, duplicates, empty results, partial failure, and the
  expected response or status for each.
- Volume, frequency, payload size, and latency or throughput expectations.
- Data classification (PII, financial, health), retention, residency, and masking needs.
- Authentication and authorization for consumers and downstream systems (secret values are never
  collected in the context; only the mechanism and secure property names).
- Error handling, retry, idempotency, replay, and notification expectations.
- Deployment target, environments, and promotion constraints.
- Availability, RTO/RPO, and monitoring expectations where they apply.
- Constraints, dependencies, ownership, and explicit out-of-scope items.

## Accelerator Defaults
Non-critical implementation choices may use repository standards without asking: modular file
layout, naming conventions, pinned Mule/connector/MUnit versions, logging structure, correlation IDs,
and test structure. List each applied default in the context's **Accelerator Defaults** section so
the user can see and override it during approval.

## Change Control
- Before any modification, load the approved context and identify affected requirement IDs.
- A change already covered by the approved context (for example, fixing a defect that violates an
  approved requirement) may proceed, citing the requirement IDs.
- A new or changed behavior requires delta discovery: update the context, increment its version, set
  status `Draft`, list impacted artifacts, and obtain approval before changing code.
- If the context and an artifact conflict, the approved context wins; report the conflict and ask
  before changing the context.
- A legacy context file without approval metadata is treated as a draft: confirm it with the user
  before building from it.

## Location and Naming
- Store the approved context at `<project-root>/project-context.md`; create the project folder with
  only this file during discovery if needed.
- Requirement IDs: `BO-nn` business objectives, `FR-nn` functional, `DR-nn` data/mapping,
  `NFR-nn` non-functional, `SEC-nn` security, `ERR-nn` error behavior, `DEP-nn` deployment,
  `CON-nn` constraints.

## Anti-Patterns
- Generating code, RAML, or tests before the context is approved.
- Silently filling a critical gap with a "reasonable" assumption or with values from another project.
- Asking technical questions the user cannot answer when a business question or a disclosed
  accelerator default would do.
- Collecting secrets, credentials, or production hostnames in the context.
- Generated artifacts without requirement IDs, or tests whose expectations are not in the context.

## Review Checklist
- [ ] Context status is `Approved`, with version, date, and approver.
- [ ] No critical checklist item is unanswered or assumed.
- [ ] Every flow, test, configuration, and document maps to requirement IDs.
- [ ] Traceability matrix is current; no artifact implements behavior outside the context.
- [ ] Changes since approval went through delta discovery and re-approval.
