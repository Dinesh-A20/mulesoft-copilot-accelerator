# Error Handling Patterns

## Classification
Separate client validation, authentication/authorization, downstream unavailability, timeout, duplicate, mapping, and unknown errors.

## Retry
Retry only transient, idempotent operations. Use bounded exponential backoff and jitter. Respect Retry-After.

## Circuit Breaking
Open on sustained downstream failures and recover through half-open probes. Keep separate thresholds for availability and latency.

## Dead Letters
Retain original payload, metadata, failure type, attempt count, timestamps, and replay token.

## API Response
Return stable error code, message, correlation ID, and optional details. Never expose stack traces or secrets.
