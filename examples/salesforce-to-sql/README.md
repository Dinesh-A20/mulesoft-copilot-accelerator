# Salesforce to SQL

## Pattern
System-to-system integration for Salesforce change events or scheduled extracts to SQL Server/Azure SQL.

## Architecture
Salesforce -> System API -> Process API -> SQL System API.

## Data Flow
1. Query or receive changed Salesforce records.
2. Normalize external ID and audit fields.
3. Upsert in a transaction-safe batch.
4. Record success/reject information and replay status.

## Controls
Pagination or Bulk API, OAuth2, TLS, idempotency key, bounded retry, batch commit size, and MUnit mocks.
