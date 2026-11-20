# Salesforce Account Excel Export

Mule 4 application that incrementally upserts Salesforce Accounts into an XLSX
workbook on demand. The first run (or a missing/empty workbook) loads the latest 50
Accounts by `LastModifiedDate DESC`; each later run fetches up to 50 Accounts modified
since the last successful run, updates matching rows by Account Id in place, and appends
new Accounts at the end. The XLSX workbook contains only
`Id`, `Name`, `Phone`, and `BillingCity` (shown as Account Id, Account Name,
Phone, and Billing City).

## Architecture

`POST /api/v1/exports/accounts` (Experience contract/APIKit) invokes the Process
export flow, which reads the existing workbook and the stored watermark, queries
Salesforce through the Salesforce Connector configured for OAuth JWT bearer
authentication, merges the changes, rewrites `salesforceAccountRecords.xlsx`, commits
the new watermark to a persistent Object Store, then returns a small JSON result. See
[`docs/architecture-decision-record.md`](docs/architecture-decision-record.md).
The API-led boundaries are logical flows inside this single initial deployment;
separate API deployments require ownership/reuse approval.

## Prerequisites

- Mule Runtime 4.13.0 / Java 17 and a compatible Anypoint Studio or Maven setup.
- Access to MuleSoft/Anypoint Maven repositories and the Mule Maven Plugin.
- A Salesforce Connected App configured for OAuth JWT bearer flow, with the
  application's public certificate registered, a least-privilege integration user,
  and read-only access to the required Account fields.
- An approved output directory writable by the runtime.

## Configuration and secrets

Non-secret defaults are in `src/main/resources/config.yaml`. Set the environment's
JWT token endpoint, authorized Salesforce principal, keystore path, certificate alias,
Salesforce API version, output directory, and output filename. For local runs, the
configured directory is `C:\mule` and the filename is
`salesforceAccountRecords.xlsx`.

Provide `salesforce.secure.jwt.consumer-key` and
`salesforce.secure.jwt.keystore-password` using CloudHub 2.0 secure application
properties or an approved local secret provider. The keystore containing the private
signing key must be delivered separately through an approved runtime secret/file
mechanism; do not commit or package it. The Connected App's public certificate must
match this private key and use `SHA256withRSA`. No live credentials are stored in this
project. Do not put credentials in Maven arguments, shell history, or logs. See
[`src/main/resources/properties/README.md`](src/main/resources/properties/README.md).

For local Windows execution, `export.output.directory` defaults to `C:\mule` and
`export.output.file-name` defaults to `salesforceAccountRecords.xlsx`. Override the
directory for each deployed environment with a runtime-accessible, approved destination.

The CloudHub template is
[`deployment/cloudhub-2.0.yaml`](deployment/cloudhub-2.0.yaml). It is a reviewable
input template, not a directly executable Mule deployment manifest. Bind it through
the organization's supported deployment tooling only after the open decisions in
[`docs/deployment.md`](docs/deployment.md) are resolved.

## Build and tests

```text
mvn -B clean verify
```

MUnit uses deterministic mocks for Salesforce and file operations; tests do not call
Salesforce or write an export. Anypoint repository access may be required to resolve
Mule runtime/plugin artifacts. Coverage is configured as a CI gate in `pom.xml`.

## Manual invocation

The API is protected at ingress by the Anypoint API Manager Client ID Enforcement
policy. APIKit/RAML describe the policy contract but do not enforce it in-process.
Do not expose or deploy the listener until a private ingress, the policy, approved
client authorization, and rate controls are verified.

After local runtime configuration or an approved deployment, invoke:

```text
POST https://<approved-private-host>/api/v1/exports/accounts
client_id: <injected-by-approved-client>
client_secret: <injected-by-approved-client>
x-correlation-id: <optional-safe-id>
```

The request is synchronous and returns `200` with status, `mode` (`initial` or
`incremental`), `recordsExported` (fetched), `recordsInserted`, `recordsUpdated`,
`totalRows`, file name, and correlation ID. Salesforce or file errors return a sanitized `500`
response; details are logged as structured error type only. The API does not return
Account data or credentials.

## Output and edge behavior

The local output file is
`C:\mule\salesforceAccountRecords.xlsx`. XLSX files cannot be appended in place, so each
run reads the `Accounts` sheet, merges by `Account Id`, and rewrites the whole workbook:

- Existing rows keep their position; changed Accounts are updated in place.
- New Account Ids are appended at the end in Salesforce modification order.
- Rows not returned by Salesforce (including manually added rows) are kept unchanged.
- Rows with an empty Account Id (the empty-workbook placeholder) are dropped.
- Only the `Accounts` sheet and its four columns are kept; other sheets, formulas, and
  cell formatting are not preserved.

**Watermark.** The newest `(LastModifiedDate, Id)` pair of the processed Accounts is
stored in the persistent Object Store key `export.watermark.key` only after the
workbook write succeeds (at-least-once). Incremental queries use keyset paging
(`LastModifiedDate > t OR (LastModifiedDate = t AND Id > id)`), so a backlog larger than
50 is drained over successive runs without skipping Accounts that share a timestamp.
Deleting or emptying the workbook triggers a fresh initial load. Deleted Salesforce
Accounts are not removed from the workbook.

The runtime must have read/write access to the directory, and the workbook **must be
closed in Excel** while a run is in progress (Excel locks the file; the write fails with
`EXPORT_FAILED` and the watermark is not advanced). Requests are serialized
(`maxConcurrency=1`); run a single replica because the file and watermark are
per-instance. If Salesforce returns no Accounts and the workbook is empty, the workbook
has the four column headings and one empty row.

CloudHub container-local files are ephemeral and not a durable delivery mechanism.
The deployment template retains an environment-specific output directory; do not use
the local `C:\mule` path in CloudHub. Use a destination approved for the
required retention and durability. The application currently implements filesystem
output only; SFTP, object storage, and shared storage connectors are outside approved
scope.

## Operations and governance

- Runbook: [`docs/runbook.md`](docs/runbook.md)
- Security review: [`docs/security-review.md`](docs/security-review.md)
- Performance review: [`docs/performance-review.md`](docs/performance-review.md)
- Field mapping: [`docs/mapping-specification.md`](docs/mapping-specification.md)
- Data classification: [`docs/data-classification.md`](docs/data-classification.md)
- Provisional SLOs: [`docs/operational-slo.md`](docs/operational-slo.md)
- API lifecycle: [`docs/api-lifecycle.md`](docs/api-lifecycle.md)

No live Salesforce call or deployment is performed by the project-generation
workflow. Before release, run `mvn -B clean verify` on the supported Java 17
toolchain and validate the connected-app permissions, API Manager policy, and
configured output destination in the target environment.
