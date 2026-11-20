# Operations runbook

## Before enabling the service

1. Confirm application, Salesforce integration, data, and output-storage owners.
2. Verify the Connected App's JWT bearer flow, registered public certificate, and
   integration user. Grant
   only read access to Account and `Id`, `Name`, `Phone`, `BillingCity`, plus
   access needed to query/order by `LastModifiedDate`.
3. Configure both Salesforce hosts and runtime secure application properties using
   the approved secrets manager. Verify TLS trust remains enabled.
4. Configure an approved writable output directory. Confirm encryption, access
   control, retention, residency, and file cleanup requirements. Local Windows
   execution defaults to `C:\mule\salesforceAccountRecords.xlsx`; each successful run
   upserts changed Accounts into it. Set a runtime-accessible destination for deployments.
5. Deploy with private ingress and the API Manager Client ID Enforcement policy,
   rate controls, and monitoring. Do not rely on the RAML security declaration alone.
6. Confirm the exact artifact hash/source commit, MUnit and scan results, approval,
   smoke-test evidence, and rollback artifact before promotion.

## Trigger / success

An authorized caller sends `POST /api/v1/exports/accounts`. A `200` response
indicates that Salesforce query, workbook upsert, and watermark commit completed.
Confirm `mode`, `recordsInserted`, `recordsUpdated`, `totalRows`,
correlation ID, filename, and resulting file size/permissions. Do not inspect or
copy the workbook into unapproved channels.

## Failure response and recovery

- **500 / `EXPORT_FAILED`:** Find the structured log entry by correlation ID and
  `flowName`. Logs contain only status and connector error type, not payload,
  headers, token, or credentials.
- **Salesforce authentication/authorization:** Verify JWT bearer enablement, certificate
  registration and rotation, keystore availability, token endpoint, integration-user
  policy, and field permissions.
  Correct configuration through secret-management/deployment controls; do not log
  or paste tokens.
- **Salesforce timeout/connectivity:** Check Salesforce status, outbound network
  access, DNS, approved host, and Anypoint Monitoring. This flow has no automatic
  retries. Re-run manually only after checking whether an output file was created.
- **File write failure:** Check configured path, runtime permissions, free space,
  destination availability, and retention controls. An open workbook in Excel locks
  the file; close it (and remove a stale `~$` lock file) before retrying. The watermark
  is not advanced on a failed write, so a re-run picks up the same changes.
- **Full reload:** Delete or rename the workbook and re-run; a missing/empty workbook
  triggers an initial load of the latest 50 Accounts and resets the watermark.
- **Partial/unknown outcome:** The workbook may have been rewritten without the
  watermark being stored; a re-run re-applies the same changes idempotently. If the file
  is corrupt, restore a backup or delete it to force an initial load. Validate it before use; preserve a backup first if previous exports must
  be retained, and quarantine invalid output under approved procedures.

## Monitoring and alerts

Emit/retain structured start, completion, and failure logs with application,
environment, flow, source, status, correlation ID, duration, and record count.
Configure Anypoint Monitoring alerts for failures, latency, HTTP connectivity or
authentication error types, and file write failures after service-owner thresholds
are approved. Never enable HTTP wire logging or payload logging in production.

## Rollback

Stop new triggers through ingress policy or API Manager, preserve the current output
and deployment evidence, then redeploy the last verified immutable artifact through
the approved promotion process. Check artifact compatibility and output-file
replay/duplication before restarting. No deployment action is automated here.
