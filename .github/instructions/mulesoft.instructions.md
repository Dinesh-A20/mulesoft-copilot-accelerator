---
applyTo: "**/*.{xml,raml,yaml,yml,properties}"
---
# MuleSoft Development Instructions

## Purpose
Set implementation standards for production-grade Mule 4 applications.

## Scope
Maven projects, Mule configurations, flows, connectors, configuration properties, transformations, and packaging.

## Mandatory Standards
- Use Maven and the Mule Maven Plugin.
- Use DataWeave 2.0; keep transformations maintainable and testable.
- Use APIKit for RAML contract implementation.
- Externalize all environment-specific values.
- Configure connection and HTTP timeouts.
- Use standard named global configurations.
- Include correlation ID propagation and structured logging.
- Catch and normalize all known and unknown errors.

## Naming Conventions
- Applications: lowercase kebab-case.
- Flows: `source-operation-purpose-main`.
- Subflows: `operation-purpose-process`.
- Global configuration names: `<technology>-<purpose>-config`.
- Properties keys: lowercase dot notation, such as `salesforce.auth.host`.
- DataWeave files: purpose-oriented `.dwl` names.

## Best Practices
- Use modular XML and reusable subflows.
- Disable auto-generated sample data and debug-only routes.
- Enrich only required fields.
- Reuse object stores, cache scopes, and connection pools.
- Configure size limits and streaming for batch and bulk operations.
- Preserve original IDs and business keys for idempotency.

## Anti-Patterns
- DataWeave logic embedded across many flows without reuse.
- Deeply chained flow-ref graphs.
- Infinite retries or duplicate side-effect sends.
- Hardcoded hostnames, credentials, queue names, or secrets.
- Catch-all handlers that hide cause and status.
- Shared mutable variables across async scopes.

## Review Checklist
- [ ] Project builds reproducibly.
- [ ] Flows use clear names and no dead routes.
- [ ] Global settings are environment independent.
- [ ] Connector operations define size/time limits.
- [ ] Error paths return stable contracts.
- [ ] Logs exclude secrets and regulated payloads.
