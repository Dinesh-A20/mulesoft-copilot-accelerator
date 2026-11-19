# SAP to Salesforce

## Pattern
SAP master/transaction data synchronization to Salesforce.

## Architecture
SAP -> System API -> canonical Process API -> Salesforce System API.

## Data Flow
Extract changes from SAP, normalize business keys, map canonical objects, upsert external IDs, and reconcile rejects.

## Controls
OData/RFC/IDoc/SOAP selection, stable external keys, bulk upsert, retries, compensation, and audit reconciliation.
