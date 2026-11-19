---
applyTo: "**/*.{xml,raml,yaml,yml,md}"
---
# Architecture Instructions

## Purpose
Define enterprise API-led architecture and solution design standards for Mule 4.

## Scope
Architecture decisions, API decomposition, application boundaries, integrations, resilience, and reference implementations.

## Mandatory Standards
- Decompose solutions into Experience, Process, and System APIs with explicit ownership.
- Use RAML 1.0 first and version published contracts.
- Isolate system-of-record credentials and endpoints behind System APIs.
- Document synchronous, asynchronous, batch, and event-driven interactions.
- Define availability, RTO, RPO, data residency, throughput, and peak-volume targets.
- Specify trust boundaries and data classification.
- Include idempotency, retry, timeout, circuit breaker, and back-pressure behavior.
- Use ADRs for significant decisions.

## Naming Conventions
- API names: `{domain}-{layer}-{resource}` (for example, `customer-process-api`).
- Repository/artifact IDs use lowercase kebab-case.
- Flow names: `method-resource-main`, `method-resource-process`, and `method-resource-error`.
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
- [ ] API-led layer and ownership are clear.
- [ ] Contract and data models are governed.
- [ ] NFRs and failure scenarios are quantified.
- [ ] Security and compliance boundaries are documented.
- [ ] Dependencies and SPOFs are identified.
- [ ] Idempotency and replay behavior are defined.
