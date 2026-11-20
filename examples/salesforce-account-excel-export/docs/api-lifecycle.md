# API lifecycle and ownership

- **Contract:** RAML 1.0 at `src/main/resources/api/account-export.raml`.
- **Version:** `v1` in the resource path. Breaking changes require a new version;
  additive changes require compatibility review and governed release approval.
- **Lifecycle state:** Draft / implementation example; not registered or published
  to Anypoint Exchange.
- **Owner:** Unassigned (client product and Salesforce integration ownership must be
  confirmed before promotion).
- **Consumer:** Authorized operator or approved internal automation only.
- **Security:** Apply API Manager Client ID Enforcement at the CloudHub ingress.
  RAML describes the scheme, but APIKit does not enforce it. Do not expose the
  listener until the policy, private ingress, and authorization are verified.
- **Rate/abuse control:** Configure an approved rate limit / spike control in API
  Manager. No limit is guessed in this application; one invocation issues two
  Salesforce HTTP requests and creates one file.
- **Compatibility:** Validate RAML and examples in CI before publishing. Retire a
  version through the organization's API governance process; no retirement date is
  assumed.
