# Security Guidelines

## Secrets
Use secure properties, enterprise secret managers, CI secret stores, and short-lived credentials. Never commit or log secrets.

## Transport
Require TLS 1.2+; validate certificates and hostnames. Use mutual TLS where trust and compliance demand it.

## Identity
Use OAuth2, OIDC, JWT, client ID enforcement, and least-privilege service identities. Separate human and workload access.

## Policy
Apply rate limiting, spike control, IP rules, payload limits, content-type validation, and CORS only as approved.

## Data
Classify payload and logs. Redact PII, PAN, authentication secrets, and regulated fields. Encrypt regulated state at rest.

## Supply Chain
Scan dependencies and artifacts; pin versions; verify sources and keep an SBOM.
