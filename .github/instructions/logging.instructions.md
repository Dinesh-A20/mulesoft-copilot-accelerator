---
applyTo: "**/*.{xml,properties,dwl,md}"
---
# Logging Instructions

## Purpose
Provide consistent operational observability across Mule applications.

## Scope
Logging categories, correlation, metrics, alarms, tracing, audit events, and sensitive-data handling.

## Mandatory Standards
- Propagate and log a correlation ID in every request and async continuation.
- Separate technical logs from business/audit events.
- Use structured fields: correlationId, applicationName, environment, flowName, source, status, durationMs.
- Redact passwords, tokens, keys, PII, PAN, and regulated values.
- Log error type, key business identifiers, and remediation-safe context.
- Use Anypoint monitoring/custom metrics for operational SLIs.

## Naming Conventions
- Every Logger needs a Studio display name (`doc:name`) that identifies the action or outcome being recorded, for example `Log Salesforce query timeout`. The label is static, not the log message; keep payloads, credentials and record identifiers out of both.
- Logger prefixes use stable kebab-case identifiers.
- Metric names use dot notation.
- Audit event names use past-tense business verbs.

## Best Practices
- Log start/end for long-running operations.
- Emit metrics for success, latency, retries, queue depth, and downstream failures.
- Set log levels by environment and category.
- Include dead-letter and replay identifiers.
- Retain audit data according to compliance policy.

## Anti-Patterns
- Full payload logging for every request.
- Secrets in logger expressions or transformed payloads.
- Random or missing correlation IDs.
- Catching failures before logging/metric emission.
- Debug logging enabled in production.

## Review Checklist
- [ ] Correlation ID is propagated end to end.
- [ ] Sensitive fields are redacted.
- [ ] Error logs support diagnosis without secret exposure.
- [ ] Business and technical events are separated.
- [ ] Key latency and failure metrics exist.
