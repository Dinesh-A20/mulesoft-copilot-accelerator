# Salesforce Patterns

## Integration
Use SOAP or REST APIs, Composite, Bulk API 2.0, Platform Events, or Change Data Capture according to volume and latency.

## Authentication
Prefer OAuth2 connected app credentials in secure properties. Restrict profiles and connected app policies to least privilege.

## Bulk and Batch
Use Bulk API for large imports/exports. Poll with bounded waits and persist job and batch IDs for replay. Preserve Salesforce IDs.

## Resilience
Honor rate limits and retries. Retry throttling and transient HTTP failures; do not retry validation or duplicate-detection failures.

## Idempotency
Use external IDs and deterministic keys for upserts. Store mapping of source keys to Salesforce IDs.

## Security
Encrypt secrets and logs; redact access and refresh tokens; restrict fields and objects per integration user.
