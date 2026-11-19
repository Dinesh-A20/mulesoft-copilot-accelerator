# Logging Patterns

## Minimum Context
Include correlation ID, application, environment, flow, operation, business key, status, duration, and error category.

## Structured Data
Use stable key names and avoid concatenated free-text where metric extraction is needed.

## Redaction
Redact credentials, PII, PAN, authorization headers, and sensitive request/response fields.

## Levels
Use DEBUG in diagnostics only, INFO for lifecycle/business milestones, WARN for recoverable degradation, and ERROR for failed outcomes.

## Metrics
Track success, failure, latency, retries, queue depth, batch records, payload size, and downstream availability.
