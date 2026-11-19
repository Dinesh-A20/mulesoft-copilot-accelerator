# Performance Patterns

## Streaming
Stream files and large payloads. Avoid `repeatableInMemoryStream` for uncontrolled payload sizes.

## Pagination
Page API and database reads. Bound page size and use stable continuation or offsets.

## Batching
Use batch commit sizes, max failures, and replay-safe state. Do not increase upstream or downstream load beyond capacity.

## Pooling
Configure HTTP and database pool limits, timeouts, and release behavior. Size to downstream capacity.

## Retry
Use bounded attempts and jitter. Circuit-break repeated downstream failures and monitor retry amplification.

## Cache and Object Store
Cache stable, authorized responses with TTL and invalidation. Persist only required state and define retention.
