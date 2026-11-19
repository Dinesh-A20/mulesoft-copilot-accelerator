# SAP Patterns

## Integration
Choose RFC, IDoc, BAPI, OData, SOAP, or event mechanisms based on landscape, coupling, transaction, and volume.

## Transactions
Keep distributed transactions explicit and short. Use message correlation and compensation for long-running business workflows.

## Idempotency
Use stable external keys and SAP change documents or custom duplicate guards. Retain inbound document IDs for replay.

## Payload and Performance
Paginate OData and REST calls, stream large bulk extracts, and batch only within SAP-safe limits.

## Security
Use approved authentication and least-privilege SAP roles. Externalize RFC destinations and certificates.
