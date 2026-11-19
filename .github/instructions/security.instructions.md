---
applyTo: "**/*.{xml,yaml,yml,properties,raml,md}"
---
# Security Instructions

## Purpose
Enforce enterprise security for Mule applications and APIs.

## Scope
Credentials, transport security, authentication, authorization, policies, secrets, payload protection, and supply-chain controls.

## Mandatory Standards
- Zero hardcoded credentials, tokens, certificates, or keys.
- Store secrets in approved secret managers or encrypted secure properties.
- Use TLS 1.2 or higher and validate certificates.
- Enable client ID enforcement and OAuth2/JWT/OIDC where required.
- Apply least-privilege identities and connector permissions.
- Classify and redact sensitive log fields.
- Validate and constrain request size and content type.
- Use mutual TLS for high-trust integrations when mandated.

## Naming Conventions
- Secure property names: `<domain>.secure.<purpose>`.
- Environments: dev, qa, prod.
- Policy and role names use lowercase kebab-case.
- Vault references use the organization-approved secret path convention.

## Best Practices
- Rotate secrets and certificates without application credential changes.
- Use short-lived OAuth tokens and secure caches.
- Apply API rate limiting, spike control, and IP allowlists appropriately.
- Sign or verify event messages when integrity is required.
- Encrypt sensitive object-store or persistence data.
- Maintain audit logs for privileged operations.

## Anti-Patterns
- Secrets in source control or CI variables exposed in logs.
- Disabled certificate validation.
- Anonymous management endpoints.
- Client IDs in logs or payloads.
- Broad connector permissions or shared admin identities.
- Returning stack traces or internal host details.

## Review Checklist
- [ ] No plaintext secrets or credential-like literals.
- [ ] TLS and certificate validation are configured.
- [ ] Authentication and authorization policies are mapped.
- [ ] Secret rotation is documented.
- [ ] Input validation and payload limits exist.
- [ ] Logging and traces meet privacy controls.
