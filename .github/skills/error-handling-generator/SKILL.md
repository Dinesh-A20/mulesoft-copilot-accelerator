---
name: error-handling-generator
description: Generates normalized Mule error handling, retries, circuit breakers, dead letters, and replay behavior.
---

# Error Handling Generator

## Trigger Conditions
- A flow lacks complete error handling.
- Downstream failures require normalization or retry.
- Operational replay or dead-letter handling is required.

## Workflow Steps
1. Inventory connector, HTTP, validation, mapping, and application errors.
2. Classify retryable and non-retryable failures.
3. Map technical errors to stable API error contracts.
4. Configure timeouts, retries, circuit breakers, and DLQ/replay.
5. Add correlation, logging, metrics, and alert tags.
6. Generate MUnit negative and timeout scenarios.
7. Model expected missing-record outcomes separately from connector failures. For Object Store lookups, use an explicit absence default or narrowly handle `OS:KEY_NOT_FOUND` without exception-stack logging; emit a structured INFO business event and return the approved contract. Never treat store unavailability, timeouts, or permission failures as absent data.
8. Follow the [mandatory modular layout](../../instructions/mulesoft.instructions.md#mandatory-modular-project-layout): keep named reusable handlers in `common-error-handlers.xml` and group shared error/logging subflows in dedicated capability files, separate from connector configurations and business implementations.

## Expected Outputs
- Error subflows
- Error type mapping table
- Retry/DLQ configuration
- Stable response contract
- Recovery and replay runbook

## Validation Rules
- No stack trace or internal endpoint leaks.
- Every retryable operation has bounded retry policy.
- Dead-lettered records retain replay metadata.
- Each error response uses correlation ID.
- Missing data is not automatically an implementation defect. HTTP status and message follow the approved contract; do not silently replace an existing 404 contract with 200 or mask genuine infrastructure failures.
- Tests distinguish missing records from unavailable storage and verify that present records retain their original response.
- Modular extraction preserves local error scope, `on-error-continue`/`on-error-propagate` behavior, and transaction boundaries. Named handlers use error-handler references; `flow-ref` is reserved for flows/subflows.
