# Security review

**Status:** Design review only; runtime, dependency, gateway-policy, and platform
verification remain outstanding.

## Controls present

- Salesforce Connected App consumer key and keystore password use secure runtime
  properties; the private-key keystore is externally provisioned and is not committed.
- The Salesforce Connector performs OAuth JWT bearer authentication over HTTPS with
  default JVM certificate validation; no trust-all or disabled TLS configuration exists.
- REST projection requests only `Id`, `Name`, `Phone`, and `BillingCity`.
- Access token, authorization header, Salesforce response, and XLSX contents are
  not logged or returned in the API response.
- Error responses are generic; structured logs contain error type and correlation
  context only.
- API contract requires Client ID Enforcement, and deployment design requires
  private ingress.

## Blocking items before deployment

1. Apply and verify API Manager Client ID Enforcement and approved rate limits;
   APIKit does not enforce RAML security schemes.
2. Approve Salesforce Connected App JWT bearer flow, public certificate registration,
   SHA256withRSA signing, service-user authorization, keystore delivery/rotation, and
   environment separation. Disable Salesforce's “Issue JSON Web Token (JWT)-based
   access tokens for named users” option so the connector receives an opaque OAuth
   access token.
3. Confirm approved output location, access control, encryption at rest, residency,
   retention/deletion, and audit requirements. The default local directory is not
   durable.
4. Verify private ingress/network egress, TLS policy, secret resolution, and
   dependency/artifact scans in target environments.
5. Confirm data classification of Account Phone and business contact fields.

No production endpoint or live credentials were used in this review.
