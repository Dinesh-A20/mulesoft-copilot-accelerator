# CloudHub 2.0 deployment and promotion

The selected target is CloudHub 2.0. `deployment/cloudhub-2.0.yaml` is a review
template, not a Mule Maven Plugin manifest. It contains placeholders and is not
deployable until translated to the organization's pinned deployment tooling.

## Required environment inputs

| Property | Secret? | Source |
|---|---:|---|
| `app.environment` | No | Environment-specific deployment configuration |
| `http.listener.host` / `http.listener.port` | No | Approved listener configuration |
| `salesforce.jwt.principal` | No | Approved Salesforce integration user |
| `salesforce.jwt.keystore.path` | No | Runtime-mounted or retrieved keystore path |
| `salesforce.jwt.certificate-alias` | No | Approved signing certificate alias |
| `salesforce.jwt.token-endpoint` | No | Salesforce production, sandbox, or org endpoint |
| `salesforce.api.version` | No | Version reviewed against the org |
| `salesforce.http.response-timeout-ms` | No | Approved NFR tuning |
| `salesforce.secure.jwt.consumer-key` | Yes | Salesforce Connected App consumer key |
| `salesforce.secure.jwt.keystore-password` | Yes | Runtime secure property / secret manager |
| `export.output.directory` | No | Approved writable and retained output destination; use a runtime-accessible path, not a workstation path |
| `export.output.file-name` | No | `salesforceAccountRecords.xlsx`; each successful run upserts changed Accounts into it |
| `export.watermark.key` | No | `account-export-watermark`; persistent Object Store key for the incremental watermark. Run one replica so workbook and watermark stay consistent |

The private-key keystore is not an application property: deliver it through the
organization's approved runtime secret/file mechanism and restrict access to the
application identity. Confirm that the chosen CloudHub 2.0 deployment supports the
required file delivery and rotation method before deployment.

Use separate Salesforce identities/secrets for dev, QA, and prod. Never reuse
production credentials in lower environments.

## Release controls

- Build once, test and scan the exact artifact, record its SHA-256 and source commit,
  and promote that immutable artifact without rebuilding.
- Require approval gates, dependency/artifact/secret scanning, API Manager policy
  attachment, private ingress, runtime health verification, and a protected smoke
  test in each environment.
- Configure replicas and resource size only after throughput/concurrency and
  availability targets are approved. Initial single-replica sizing is a sample, not
  an HA recommendation.
- CloudHub local container storage is ephemeral. Do not treat it as durable output.
  Verify the target supports the approved mounted/shared destination before setting
  `export.output.directory`; otherwise obtain approval for a supported durable
  connector and update this implementation.
- Production promotion must use the exact verified artifact and source commit.
  Rollback to the prior verified artifact; inspect outputs before manual replay.

No CloudHub deployment or shared infrastructure change was performed.
