# Governance

## Repository Governance
- Accelerator changes require architecture, security, and delivery review.
- Breaking knowledge or template changes require an ADR and migration notice.
- Enterprise templates remain client-neutral and secret-free.

## API Governance
- RAML contracts require API owner, lifecycle, deprecation, and compatibility metadata.
- Breaking changes require major-version migration and consumer coordination.
- Policies are tested as part of CI and promoted consistently.

## Delivery Governance
- Production requires review, immutable artifact, test evidence, security gate, and approval.
- Exceptions require owner, expiry, remediation, and risk acceptance.
- Operational ownership, replay, and incident response must be assigned before production.
