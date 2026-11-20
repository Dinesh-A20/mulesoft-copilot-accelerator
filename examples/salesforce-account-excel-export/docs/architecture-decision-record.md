# ADR-001: On-demand Salesforce Account XLSX export

- **Status:** Proposed; requires platform/security and output-storage approval.
- **Decision date:** 2026-11-19.
- **Context:** The approved initial scope is 50 latest Account records, sorted by
  `LastModifiedDate DESC`, exported on demand with `Id`, `Name`, `Phone`, and
  `BillingCity` in XLSX format.
- **Decision:** Implement a versioned APIKit experience endpoint that invokes one
  bounded process flow. The process flow uses the Salesforce Connector's OAuth JWT
  connection to query Salesforce, transforms only the approved four fields, and
  writes the configured XLSX filename using the Mule File connector.
- **API-led ownership:** Experience owns the trigger contract and ingress policy;
  Process owns the export orchestration and response; the Salesforce adapter owns
  OAuth/token and Salesforce REST details. The first release packages these logical
  boundaries in one Mule application because there is one consumer and one 50-row
  operation. Split System/Process/Experience APIs into separately deployed assets
  if independent ownership or reuse is approved. This is an explicit initial-scope
  exception, not a claim that the flows are separate deployed APIs.
- **Trigger:** `POST /api/v1/exports/accounts`; synchronous completion, protected by
  Anypoint API Manager Client ID Enforcement. The API Manager policy is not
  implemented by APIKit and is a mandatory deployment gate.
- **Authentication:** Salesforce OAuth JWT bearer flow using the native Salesforce
  Connector. The Connected App consumer key and keystore password are secure runtime
  properties; the private-key keystore is supplied externally at runtime. The principal,
  certificate alias, token endpoint, and API version are environment-specific. The
  Salesforce Connected App must trust the matching public certificate and authorize
  the least-privilege integration user.
- **Output:** The app maintains `salesforceAccountRecords.xlsx` in the configured output
  directory as an incremental upsert (decision 2026-11-20). Because XLSX cannot be appended
  in place, each run reads the workbook, merges by Account Id (update in place, append new
  Ids at the end), and rewrites the file. A persistent Object Store holds the
  `(LastModifiedDate, Id)` watermark, committed only after a successful write. Local
  Windows configuration uses `C:\mule`; deployed environments must override it with an
  approved runtime-accessible destination. The app does not promise durable storage.
- **Failure/replay:** 30-second Salesforce read/login/connection timeouts; no automatic
  retry. The Salesforce query is read-only; an operator may manually re-run after checking
  whether the file is valid. Re-runs are idempotent: if the write fails the watermark is
  not advanced, and re-applying the same Accounts produces the same rows. Retain a copy
  of the workbook first if prior versions must be auditable. Incomplete-file cleanup and durable replay
  require a storage-specific design.
- **Rejected alternatives:** Scheduler was rejected because the approved first
  release is manually invoked. Salesforce Bulk API was rejected for the bounded
  50-record result. A separate API-per-layer deployment was deferred pending
  ownership/reuse confirmation.
- **Consequences:** The workbook and watermark are per-runtime state, so the app must
  run as a single replica with serialized requests. Deleted Salesforce Accounts are not
  removed. Each invocation performs one Salesforce query; the connector
  acquires or refreshes an OAuth token as needed. Local CloudHub storage is ephemeral.
  A durable external output target,
  availability targets, RTO/RPO, retention, data residency, peak trigger rate, and
  execution SLA remain unresolved and must be approved before production.
