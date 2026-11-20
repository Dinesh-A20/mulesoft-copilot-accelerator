# Account-to-XLSX mapping

| Salesforce source | XLSX column | Null/missing behavior |
|---|---|---|
| `Account.Id` | Account Id | Empty string |
| `Account.Name` | Account Name | Empty string |
| `Account.Phone` | Phone | Empty string |
| `Account.BillingCity` | Billing City | Empty string |

`LastModifiedDate` is used for query order and the incremental watermark and is
intentionally not exported. The query result is capped at 50. Merge, query, and
watermark logic is in the reusable module `src/main/resources/dwl/AccountWorkbook.dwl`;
`src/main/resources/dwl/accounts-to-xlsx.dwl` serializes `vars.mergeResult.rows` as one
`Accounts` worksheet.
The Salesforce query captures the raw record array in `vars.salesforceAccounts`.
Record counting and the merge both use that variable, not the current payload.
The mapping rejects missing or non-array source data; a workbook object such as
`{Accounts: [...]}` is output, not a Salesforce query result. Serialization happens
once, after projection.
An empty query result emits the four columns plus a blank row to preserve worksheet
headings; the API result still reports zero exported Accounts.

The output is binary XLSX, written to the configured fixed filename
`salesforceAccountRecords.xlsx` in the configured output directory (local Windows
default: `C:\mule`).

## Upsert rules

| Case | Result |
|---|---|
| Account Id already in sheet | Row replaced in place with Salesforce values (counted as updated only if a value changed) |
| Account Id not in sheet | Row appended at the end, in query order |
| Row in sheet not returned by Salesforce | Kept unchanged |
| Row with empty Account Id | Dropped (placeholder) |
| Workbook missing/empty | Initial load: latest 50 by `LastModifiedDate DESC, Id DESC` |
| Workbook has rows | Incremental: `(LastModifiedDate, Id)` after watermark, `ASC`, limit 50 |

Existing cell values are normalized to strings. `LastModifiedDate` values are accepted
as DateTime or ISO strings (including `+0000` offsets), converted to UTC, and rendered
as SOQL literals; the watermark Account Id must match `^[A-Za-z0-9]{15,18}$` before it
is embedded in SOQL. There is no locale-sensitive number or date conversion in the
exported fields.
