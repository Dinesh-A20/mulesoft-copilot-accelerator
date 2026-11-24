---
applyTo: "**/*.{xml,raml,yaml,yml,md}"
---
# Architecture Instructions

## Purpose
Define enterprise API-led architecture and solution design standards for Mule 4.

## Scope
Architecture decisions, API decomposition, application boundaries, integrations, resilience, and reference implementations.

## Mandatory Standards
- Start every design from an approved Project Context Instruction produced under the [context-first workflow](./context-first.instructions.md). Do not design from unconfirmed assumptions; return to discovery for any critical gap.
- Decompose solutions into Experience, Process, and System APIs with explicit ownership.
- Use RAML 1.0 first and version published contracts.
- Isolate system-of-record credentials and endpoints behind System APIs.
- Document synchronous, asynchronous, batch, and event-driven interactions.
- Define availability, RTO, RPO, data residency, throughput, and peak-volume targets.
- Specify trust boundaries and data classification.
- Include idempotency, retry, timeout, circuit breaker, and back-pressure behavior.
- Use ADRs for significant decisions.
- Require the [mandatory modular Mule project layout](./mulesoft.instructions.md#mandatory-modular-project-layout): one `main-flow.xml` containing the listener and APIKit routing flows, one business flow per dedicated XML file, grouped reusable common subflows, configuration-only XML files, and `flow-ref` delegation. Apply this to new projects and every new or modified flow.

## Naming Conventions
- API names: `{domain}-{layer}-{resource}` (for example, `customer-process-api`).
- Repository/artifact IDs use lowercase kebab-case.
- Entry/orchestration flow names: `source-operation-purpose-main`; business flow names: `resource-operation-process`. Use the XML and shared-subflow naming conventions in the mandatory modular layout.
- Preserve APIKit-generated resource flow names as required by its router; use filesystem-safe XML filenames independently of those registered names.
- Global configurations use descriptive names; never include environment names.

## Best Practices
- Prefer choreography over fragile central orchestration only when ownership remains clear.
- Reuse API specifications and RAML fragments.
- Keep Process APIs free of source-system-specific credentials and models.
- Keep Experience APIs view-oriented and client-specific.
- Use Anypoint MQ/Kafka for durable decoupling and event contracts where appropriate.
- Apply API caching only to stable, authorized responses.

## Anti-Patterns
- Direct database or ERP access from Experience APIs.
- Shared mutable domains between APIs.
- A “God API” coordinating unrelated capabilities.
- Large, non-streamed payload fan-out.
- Timeouts omitted or retrying non-idempotent operations.
- Environment-specific flows or connector configurations.

## Review Checklist
- [ ] Design traces to an approved, current Project Context Instruction.
- [ ] API-led layer and ownership are clear.
- [ ] Contract and data models are governed.
- [ ] NFRs and failure scenarios are quantified.
- [ ] Security and compliance boundaries are documented.
- [ ] Dependencies and SPOFs are identified.
- [ ] Idempotency and replay behavior are defined.
- [ ] The modular file/flow inventory and main-to-business reference graph follow the mandatory layout; main orchestrates rather than containing business implementations.
