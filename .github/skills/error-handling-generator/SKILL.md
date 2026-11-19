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
