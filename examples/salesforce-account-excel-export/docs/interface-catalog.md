# Interface catalog

| Interface | Owner | Protocol / contract | Auth | Failure and replay |
|---|---|---|---|---|
| Manual trigger | Application/API owner TBD | HTTPS `POST /api/v1/exports/accounts`, RAML 1.0 | API Manager Client ID Enforcement policy required | Synchronous response; gateway limits required; caller may re-run after checking output |
| Salesforce JWT authentication and Account query | Salesforce platform owner TBD | Salesforce Connector OAuth JWT connection and SOQL query operation | Connected App consumer key and keystore password in runtime secure properties; private-key keystore delivered externally; TLS certificate validation | Read-only query: initial load top 50 by `LastModifiedDate DESC`, then incremental keyset query after the stored `(LastModifiedDate, Id)` watermark, limit 50; bounded connection/login/read timeouts; no automatic retry |
| XLSX output | Data/output owner TBD | Mule File connector, configured directory (`C:\mule` locally) | Runtime filesystem identity / destination ACL | Fixed `salesforceAccountRecords.xlsx`, read-merge-rewrite upsert by Account Id per successful run; retain prior copies if audit history is required |
| Export watermark | Application owner TBD | Mule Object Store (persistent) | Runtime-local | Key `export.watermark.key`; JSON `{lastModifiedDate, id}` stored only after a successful workbook write |

Hosts, credentials, output destination, ownership, retention, rate limits, and business
SLOs must be confirmed for each environment. Salesforce URLs and credentials are
never copied into logs.
