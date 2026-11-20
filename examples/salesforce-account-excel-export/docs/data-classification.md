# Data classification and handling

## Fields in scope

| Source field | XLSX column | Classification assumption | Handling |
|---|---|---|---|
| Account.Id | Account Id | Internal business identifier | Export only for approved integration user |
| Account.Name | Account Name | Internal business information | Export only to configured output location |
| Account.Phone | Phone | Business contact information; may be personal data | Minimize access, restrict sharing and retention |
| Account.BillingCity | Billing City | Business location information | Minimize access, restrict sharing and retention |

This classification is provisional and must be confirmed by the data owner/privacy
office. No full Salesforce response, access token, client ID/secret, or authorization
header is logged. The output file itself contains sensitive business/contact data:
protect it with destination ACLs/encryption, approved retention, and audit controls.

## Unresolved governance decisions

- Data owner and applicable jurisdiction / residency restrictions.
- Retention and deletion period for generated files.
- Whether Phone is personal data under the applicable policy.
- Encryption-at-rest and access-audit requirements for the chosen output location.
- Whether a local CloudHub filesystem is permitted (it is ephemeral and not a
  durable system of record).
