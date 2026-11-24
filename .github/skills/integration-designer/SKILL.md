---
name: integration-designer
description: Produces enterprise integration decomposition, interaction patterns, and technical designs for Mule 4 solutions.
---

# Integration Designer

## Trigger Conditions
- Business requirements introduce one or more source and target systems.
- A solution needs interface discovery, sequencing, or integration patterns.
- The architect must assess synchronous, asynchronous, batch, or event integration.

## Workflow Steps
1. Extract actors, systems, business transactions, payloads, volumes, and SLAs from the approved Project Context Instruction; return to requirements-discovery for any gap rather than assuming.
2. Identify authoritative systems and ownership boundaries.
3. Select request-response, event, batch, streaming, or callback interactions.
4. Define message, file, API, database, and connector endpoints.
5. Specify sequencing, idempotency, retries, timeout, replay, and dead-letter behavior.
6. Produce interface and sequence documentation, plus a file/flow responsibility map using the [mandatory modular project layout](../../instructions/mulesoft.instructions.md#mandatory-modular-project-layout).

## Expected Outputs
- Capability and system context model
- Interface catalog
- Sequence or event-flow diagram
- NFR, retry, and failure matrix
- Recommended API-led decomposition

## Validation Rules
- Every interface has owner, contract, security, and SLA.
- Side-effect operations are idempotent or guarded.
- Failure and replay behavior is explicit.
- Volume assumptions are measurable.
- Designs require one `main-flow.xml` containing the orchestration entry and APIKit resource routing flows, dedicated per-business-flow XML files, capability-grouped shared subflows, separate configuration files, and a shallow `flow-ref` call graph. Preserve APIKit dispatch and independent source semantics.

## Supporting Artifacts
- Use `interface-catalog-template.md` for deliverables.
