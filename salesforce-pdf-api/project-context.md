# Project Context Instruction: Salesforce Account PDF API

| Field | Value |
| --- | --- |
| Status | Approved |
| Version | 1.2 |
| Prepared on | 2026-11-25 |
| Approved by | @Dinesh-A20 |
| Approved on | 2026-11-25 |
| Project root | `salesforce-pdf-api/` |

This document is the single source of truth for design, implementation, tests,
configuration, deployment, and documentation. Artifacts must cite requirement IDs.
Approval of discovery answers does not replace approval of this complete context.
The earlier Salesforce Excel Export context does not apply to this application.

## 1. Business Context

- **BO-01**: Let authorized internal enterprise applications and integration
  platforms retrieve a current Salesforce Account summary as a PDF by Account ID.
- **BO-02**: Generate a confidential business document on demand without storing
  it or modifying Salesforce.
- Success: a valid, accessible Account with complete mandatory fields produces
  an immediate PDF containing the specified data. Failures return consistent JSON.
- Performance and availability are design objectives requiring release validation,
  not claims established by generated code.

## 2. Systems and Integration

| ID | Item | Decision |
| --- | --- | --- |
| FR-01 | Source | Salesforce Account, read only, using OAuth 2.0 JWT Bearer |
| FR-02 | Output | PDF generated in application with OpenHTMLToPDF from an HTML template |
| FR-03 | Trigger | Synchronous REST request; no scheduler, batch, or event trigger |
| FR-04 | Retrieval | Retrieve only the requested Account and listed fields; no related records |
| FR-05 | Architecture | One deployable application with thin Experience/APIKit routing, Process orchestration, and isolated Salesforce System flows |
| FR-06 | Persistence | No document, Account, local-session, or business-data persistence; no PDF/Account cache |
| FR-07 | Renderer isolation | App-owned local child JVM per active render; Java support code authorized; HTML/PDF passed only over memory pipes, not business-data files |
| FR-08 | Validation layer | Dedicated reusable validation subflows before business processing and response generation; enforce ID, mandatory data, correlation metadata, PDF size, and enabled-feature preconditions |
| FR-09 | Success contract alternatives | Only HTTP 200 PDF bytes enabled; JSON/Base64 wrappers documented only; download-link responses prohibited without a separately approved persistence change |

### Enterprise extensions

The following requirements extend the existing Salesforce/PDF behavior. Existing
IDs and acceptance criteria remain; the former SAP/MQ scope exclusions in CON-04
are explicitly superseded only to the extent described here.

| ID | Capability | Decision |
| --- | --- | --- |
| FR-20 | Success event | Attempt asynchronous publication of `PDF_GENERATED` after successful PDF generation; return 200 PDF regardless of event publication outcome |
| FR-21 | Failure event | Attempt asynchronous publication of `PDF_FAILED` for business/technical failures; preserve the original HTTP status/body if publication fails or is skipped |
| FR-22 | Delivery guarantee | Best effort only; no persistent outbox, replay store, durable local queue, or exactly-once guarantee; duplicates possible and consumers must be idempotent |
| FR-23 | Destinations | Environment-configured standard queues with logical names `account-pdf-generated` and `account-pdf-failed` |
| FR-24 | Publisher execution | Bounded asynchronous publishing of sanitized event metadata, independent of response; no waiting queue or API-response delay; skip when publisher capacity or remaining deadline budget is unavailable |
| FR-25 | Telemetry events | Emit metadata-only `PDF_GENERATED`, `PDF_FAILED`, and `SALESFORCE_RETRIEVED` telemetry/counters; MQ publishes only the first two |
| FR-26 | SAP extension | Include an isolated Process/System extension boundary and its documented disabled flow; disabled in DEV/QA/PROD with no effect on PDF processing |
| FR-27 | SAP restrictions | No SAP API calls, connectors, configurations, authentication, mappings, retries, or SAP error handling without a separately approved contract and business/technical enablement |
| FR-28 | Reserved SAP event | Document `SAP_ENRICHMENT_COMPLETED` for future approved enrichment only; never emit it while disabled; SAP metrics track disabled-feature state only |

Publication outcomes never rewrite the completed document/error response. Failure
publication errors do not recursively generate failure events. Boundary failures
at API Manager that never enter Mule cannot initiate an application MQ publish;
policy telemetry covers these, with integration behavior requiring validation.

### Business-event contract

- **DR-20**: Events contain `schemaVersion`, `eventId`, `eventType`, UTC `timestamp`,
  `correlationId`, `transactionId`, `apiName`, `status`, and `processingTimeMs`.
  `PDF_GENERATED` additionally contains `pdfBytes`; `PDF_FAILED` additionally
  contains a safe `errorCode`. Telemetry uses the same privacy boundaries.
- **DR-21**: No Account ID, business/contact/revenue values, raw URL, headers,
  generated HTML/PDF, secret, or raw exception text appears in event payloads.
  Event IDs remain stable across retry attempts; consumer deduplication uses
  `eventId`. Different requests may legitimately generate different events.
- **DR-22**: Event retention, MQ residency/endpoint, ownership, and consuming
  applications remain release blockers. No unapproved values are fabricated.

## 3. Interface Contract

| ID | Method | Path | Request | Success |
| --- | --- | --- | --- | --- |
| FR-10 | GET | `/documents/{recordId}` | Account ID path parameter; JWT bearer token and `client_id`/`client_secret` headers | HTTP 200, `application/pdf`, PDF bytes |
| FR-11 | GET | `/health` | Same authentication and authorization controls | HTTP 200, JSON `{"status":"UP"}` |
| FR-12 | All | All responses | Accept a bounded, safe incoming correlation ID or generate one | Return `X-Correlation-ID`; use the same ID in logs, PDF, and JSON errors |

Account IDs must be alphanumeric, start with `001`, and have exactly 15 or 18
characters. Discovery examples are illustrative; fixtures must use valid
sanitized IDs. A GET request has no business request body.
The RAML contract is versioned without adding an unrequested path prefix.
Health is runtime health only: no Salesforce call, rendering, or dependency probe.

All errors use this shape, with populated strings:

```json
{
  "status": "FAILED",
  "errorCode": "",
  "message": "",
  "correlationId": ""
}
```

## 4. Data and Mapping

| ID | Salesforce field | Document label | Required | Rule |
| --- | --- | --- | --- | --- |
| DR-01 | Id | Account Id; Salesforce Record Id | Yes | Present and nonblank; business identity |
| DR-02 | Name | Account Name | Yes | Present and nonblank |
| DR-03 | Phone | Phone | No | Missing, null, empty, or blank becomes `N/A` |
| DR-04 | Website | Website | No | Missing, null, empty, or blank becomes `N/A`; display text, not a fetched resource |
| DR-05 | Type | Account Type | No | Missing, null, empty, or blank becomes `N/A` |
| DR-06 | Industry | Industry | No | Missing, null, empty, or blank becomes `N/A` |
| DR-07 | BillingCity | Billing City | No | Missing, null, empty, or blank becomes `N/A` |
| DR-08 | BillingCountry | Billing Country | No | Missing, null, empty, or blank becomes `N/A` |
| DR-09 | AnnualRevenue | Annual Revenue | No | Missing/null becomes `0`; otherwise locale-neutral numeric value, no currency symbol |
| DR-10 | LastModifiedDate | Last Modified Date | No | Missing/null/blank becomes `N/A`; valid timestamp displayed in UTC |
| DR-11 | Request context | Generation Timestamp; Correlation ID | Yes | UTC generation timestamp; request correlation ID |

Malformed present numeric/date values return upstream-data validation errors,
not silent defaults. Do not query CurrencyIsoCode or assume a currency.

- **DR-12**: Static HTML template with escaped dynamic values. Never inject raw
  Salesforce HTML. Layout uses label-value pairs, not complex tables.
- **DR-13**: Sections: header, Account information, contact information, address,
  financial information, audit information, footer. Title: `Account Summary Report`.
  Header contains generation timestamp and correlation ID. Audit repeats
  Salesforce Record Id and generation timestamp. Footer:
  `Document generated by MuleSoft Integration Platform`.
- **DR-14**: Target one page per Account; overflow continues onto additional
  pages instead of truncating content, within the PDF size limit.
- **DR-15**: Initial report is unbranded: no logo, company name, support contact,
  or confidentiality disclaimer. Future branding is a separate change request;
  keep presentation in the HTML template, separate from retrieval/render logic.

All Account fields, contact information, revenue, and generated PDFs are
Confidential Business Data/Documents. No related Contact records are retrieved.

## 5. Error Handling and Reliability

| ID | Condition | HTTP / error code | Behavior |
| --- | --- | --- | --- |
| ERR-01 | Missing ID, `/documents`, invalid Account ID format | 400 / `INVALID_ACCOUNT_ID` | Do not query Salesforce or render |
| ERR-02 | Account absent or inaccessible | 404 / `NOT_FOUND` | No PDF; do not disclose record accessibility |
| ERR-03 | Authentication or authorization failure | 401 / `UNAUTHORIZED` | Message: `Authentication or authorization failed.` |
| ERR-04 | Salesforce record has missing/null/blank Id or Name | 502 / `ACCOUNT_DATA_INVALID` | Message: `Mandatory Account data returned from Salesforce is incomplete.`; no PDF |
| ERR-05 | Malformed optional numeric/date source data | 502 / `ACCOUNT_DATA_INVALID` | No silent coercion/default; no PDF |
| ERR-06 | Required dependency unavailable | 503 / `DEPENDENCY_UNAVAILABLE` | Normalize Salesforce connectivity and renderer unavailability |
| ERR-07 | Salesforce, render, or overall deadline exceeded | 504 / `TIMEOUT` | Stop further retries/work; no late PDF response |
| ERR-08 | Unexpected error, transformation failure, unhandled exception | 500 / `INTERNAL_ERROR` | Safe message; no stack trace or confidential data |
| ERR-09 | Capacity exceeded | 503 / `CAPACITY_EXCEEDED` | `Service capacity exceeded. Please retry later.`; fail fast, no queue/delayed throttle |
| ERR-10 | Generated PDF exceeds 2 MB | 500 / `PDF_SIZE_EXCEEDED` | No partial PDF response |
| ERR-11 | Unknown path | 404 / `NOT_FOUND` | Standard JSON error |
| ERR-12 | Unsupported HTTP method | 405 / `METHOD_NOT_ALLOWED` | Standard JSON error |
| ERR-13 | Salesforce transient failure | Applicable final error above | At most 2 retries, 3 seconds apart, constrained by overall deadline |
| ERR-14 | Global handling | Standard JSON contract | Reusable named error handlers; preserve error cause internally with metadata-only logging |

Retry-eligible conditions: connectivity, DNS failures, connection reset, network
interruption, and dependency HTTP 502/503/504 where represented by the selected
Salesforce operation. Never retry authentication, authorization, validation,
record-not-found, or malformed-request errors. Do not automatically retry PDF
rendering. Retry scopes must not retry the entire business flow indiscriminately.
Use Until Successful only where its retry semantics satisfy these restrictions.
Requests are read only and safely repeatable; no durable replay system is needed.

Authoritative timing, explicitly confirmed after discovery:

- Salesforce connection timeout: 5 seconds.
- Salesforce response timeout: 10 seconds per attempt.
- PDF rendering timeout: 5 seconds.
- Maximum overall execution: 20 seconds, including retries and rendering.
- The overall deadline overrides per-attempt budgets: skip attempts that cannot
  fit and stop further work at expiry. Two retries are a maximum, not a guarantee.
- These settings supersede earlier 30/60-second and 1-second retry suggestions.

- **ERR-20**: MQ may retry at most twice at 1-second intervals for transient
  connectivity/service errors only. No retry of authentication/authorization,
  malformed event, or destination-configuration failures. Avoid hidden connector
  reconnection loops that exceed the same total retry allowance.
- **ERR-21**: Every MQ attempt/retry uses the original request start plus
  20-second deadline, even if the API response has already completed. Do not start
  attempts after expiry; bound in-flight publication by remaining time. Skip
  publication at deadline/capacity exhaustion; no durable delivery guarantee.
  Async cancellation and resource cleanup require runtime verification.
- **ERR-22**: MQ publication failure/exhaustion/skips produce structured safe logs,
  metrics, and operational alert signals, not a different PDF or original error
  response. Delivery failures do not recursively invoke PDF failure publication.
- **ERR-23**: Preserve the existing Salesforce/render/overall deadline errors.
  MQ does not extend those deadlines or delay the caller. No additional async
  grace period is approved.

## 6. Non-Functional Requirements

- **NFR-01**: Expected throughput 60 requests/minute; spike test 120 requests/minute.
- **NFR-02**: At most 5 concurrent PDF generations per CloudHub replica. Remain
  stateless; fail fast when capacity is exceeded; do not queue excess requests.
- **NFR-03**: PDF maximum 2 MB. Use bounded memory and streaming where applicable;
  HTML-to-PDF rendering is CPU-bound, not inherently streaming/nonblocking.
- **NFR-04**: Under expected load: p50 <=2 seconds, p95 <=5 seconds, p99 <=10 seconds.
  Normal Salesforce retrieval and rendering objectives are each <=2 seconds.
- **NFR-05**: Availability >=99.9%, excluding Salesforce outages; maximum monthly
  downtime approximately 43 minutes. RTO 15 minutes; RPO 0 (no stored business data).
- **NFR-06**: Validate load, spikes, concurrency, degradation, failures, deadlines,
  size limits, and memory/worker stability before production. No corruption,
  duplicate responses, or worker crashes. Generated tests are not performance proof.
- **NFR-07**: Structured JSON logs at flow start/completion, before/after Salesforce,
  transformation start/end, and error handling. Include timestamp, correlation ID,
  transaction ID, API/application name, environment, flow, source, status,
  duration/processing time, and safe error codes. Payload fields, if present, are
  redacted metadata only. Never log raw Account IDs, customer data, HTML, PDF,
  credentials, token/header values, or raw exception details.
- **NFR-08**: Anypoint Monitoring/CloudHub observability: request count, success/error
  rates, response time, Salesforce query latency/timeouts/retries, PDF render
  duration/failures/size, 4xx/5xx, capacity events, concurrency/active rendering/
  saturation, CPU, memory, and replica availability. Separate business events
  from technical logs; both contain metadata only.
- **NFR-09**: Alert design covers unavailability, repeated 5xx, Salesforce/render
  failures, latency, retries, and saturation. Destinations/owners and thresholds
  require operations approval before production; do not fabricate provisioning.
- **NFR-10**: Actual MUnit reports must demonstrate >=90% flow coverage and >=90%
  processor coverage. Missing reports, failing tests, or insufficient measured
  coverage block QA/PROD promotion. Verify the exact metrics, not a substitute.
- **NFR-20**: Use connector-supported bounded connection pools for Salesforce and
  MQ; select and document supported pool sizes as accelerator defaults subject to
  CloudHub sizing verification. Reconnection is transient-only, bounded by approved
  retry counts/deadlines, and never an additional invisible retry policy.
- **NFR-21**: Stream PDF responses where applicable, while renderer input/output
  remains bounded in-memory; never claim HTML-to-PDF generation is fully streaming.
  Do not cache Account data or PDFs because every request must reflect a fresh
  Salesforce retrieval. Secure connector token/connection reuse is not data caching.
- **NFR-22**: Explicit log fields include `transactionId`, `apiName`, `flowName`,
  and `processingTimeMs`. Request metadata is HTTP method and route template only;
  response metadata is status code, media type, and byte count only. No raw record
  ID, identifier-bearing URL, token, secret, or confidential business data.
- **NFR-23**: Custom metrics cover existing API/Salesforce/PDF/capacity metrics plus
  MQ publication count, latency, retries, failures, deadline/capacity skips, and
  bounded publisher utilization. Business-event counters include only
  `PDF_GENERATED`, `PDF_FAILED`, and `SALESFORCE_RETRIEVED` in this version.
  Event occurrence and publication success are separate metrics; a generated
  document remains generated if MQ fails.
- **NFR-24**: Dashboard requirements: API status/latency, Salesforce latency/retries,
  PDF duration/size/failures, render capacity, MQ delivery attempts/outcomes/skips,
  business-event counts, replica CPU/memory/availability, and SAP-disabled state.
  Recommend alerts for MQ outage/publication failure, repeated skips/saturation,
  and business-event delivery gaps as well as existing service alerts. Monitoring
  destinations, retention, thresholds, owners, and escalation remain blockers.
- **NFR-25**: Extend actual MUnit coverage gates and tests to MQ/events, dedicated
  validation, async original-error preservation, deadline/capacity skipping,
  event redaction and stable retry event IDs, disabled SAP boundary/no-call
  behavior, and connection/retry configuration. Keep >=90% measured flow and
  processor coverage; mocked external dependencies do not substitute for real
  internal route-to-business orchestration.

## 7. Security

- **SEC-01**: JWT OAuth bearer authentication on every endpoint. Validate signature,
  issuer, audience, expiration, not-before when present, and required scope.
  Anypoint Access Management is preferred only if confirmed suitable by IAM;
  otherwise an approved enterprise JWT issuer is required. No issuer is assumed.
- **SEC-02**: API Manager JWT Validation and Client ID Enforcement policies;
  client identity through `client_id` and `client_secret` headers. Provision policies
  before QA/PROD promotion. Verify normalized 401 responses and correlation headers
  for policy-rejected requests, which may not enter application flows.
- **SEC-03**: Salesforce OAuth 2.0 Connected App JWT Bearer only. Least-privilege
  integration identity limited to Account and required fields. No authorization-code,
  username/password, or resource-owner-password fallback.
- **SEC-04**: TLS 1.2 or higher, HTTPS only, certificate validation, no insecure
  protocols/ciphers. Externalize all environment-specific configuration.
- **SEC-05**: Mule Secure Configuration Properties and Anypoint Secrets Manager,
  environment-specific secret provisioning. No real keys, certificates, passwords,
  tokens, credentials, or encrypted production secrets in source control.
  Secure property names follow `<domain>.secure.<purpose>`, for example
  `salesforce.secure.private-key-password`; values are not collected here.
- **SEC-06**: Rendering is self-contained: escaped text, only packaged local or
  embedded assets; no remote HTTP, Internet/internal URLs, CSS/image/font download,
  JavaScript, or arbitrary filesystem access. Enforce resource isolation in code,
  not just by convention. Never log rendered HTML/PDF.
- **SEC-07**: No business-data retention. Mask/omit confidential data in all
  technical logs, audit events, traces, tests, and error responses. Use only
  sanitized test data. Validate/bound correlation IDs and request input.
- **SEC-20**: MQ Connected App credentials externalized through Mule Secure
  Configuration Properties and/or Anypoint Secrets Manager. Least-privilege
  queue publish permissions, HTTPS/certificate validation, environment-separated
  credentials/destinations, no real endpoint/secret/license data in source.
- **SEC-21**: MQ and business telemetry carry sanitized metadata only. Do not
  implement SAP credentials, configuration, or network permissions before a
  separately approved SAP contract.

## 8. Deployment and Deliverables

- **DEP-01**: CloudHub 2.0, DEV/QA/PROD; 1 DEV replica, 1 QA replica, at least
  2 PROD replicas. Region and vCore sizing remain deployment blockers.
- **DEP-02**: GitHub Actions: build, static analysis, unit tests, MUnit tests,
  package, deploy DEV, approved deploy QA, approved deploy PROD. Build one immutable
  artifact and promote the same bytes. Do not rebuild per environment.
- **DEP-03**: DEV deployment automatic only when prerequisites are provisioned.
  QA/PROD require protected-environment approvals, test/scan evidence, measured
  coverage, and resolved applicable blockers. Credentials use CI secrets.
- **DEP-04**: Provide deployment commands, rolling promotion, authenticated health/
  smoke checks, rollback to prior immutable artifact, secret rotation, and
  operational procedures. No business replay/storage migration is needed.
- **DEP-05**: Deliver Maven `pom.xml`, `mule-artifact.json`, configuration-only
  globals, application/environment YAML, secure-properties configuration without
  real secret values, TLS/API Manager integration, and logging configuration.
  Use one shared `application.yaml` plus `dev.yaml`, `qa.yaml`, `prod.yaml` and
  `secure.properties`; avoid duplicate conflicting shared config files.
- **DEP-06**: Deliver RAML 1.0 with request constraints, PDF response, error schema,
  examples; modular Mule XML; reusable DataWeave mappings and mapping specification;
  renderer/template; validation and error handlers; focused unit/MUnit suites;
  CI/CD; and documentation of project structure and design.
- **DEP-07**: Documentation includes Mermaid solution, sequence, error-handling,
  deployment diagrams; security/trust boundaries; configuration and deployment/
  rollback runbook; mapping rules; tests, coverage, performance procedure, limitations,
  and completed requirement-to-artifact traceability.
- **DEP-20**: Deployment configuration extends existing environment files with
  externalized MQ destinations/authentication and bounded async publisher/pool
  settings. Provision standard queues/least-privilege Connected App access before
  deployment. Do not implement SAP connector/security settings while disabled.
- **DEP-21**: Preserve immutable build-once promotion and existing approval/test
  gates; add MQ/event tests and actual coverage evidence. Validate best-effort
  response independence, deadline/capacity cleanup, and MQ outage behavior before
  production. Operations must approve dashboards/alerts and event retention.
- **DEP-22**: Solution, sequence, error-handling, deployment, and CI/CD Mermaid
  diagrams must show MQ best-effort asynchronous publication, metadata-only events,
  dedicated validation, disabled SAP Process/System boundary, monitoring, and
  extended quality gates. Explain PDF-byte primary response, rejected storage/
  download-link patterns, duplicate handling, caching rationale, pools/reconnection,
  and why SAP does not run.

## 9. Constraints, Dependencies, and Out of Scope

- **CON-01**: No technical artifacts until explicit approval of this version.
- **CON-02**: No invented platform credentials, endpoints, issuer/audience/scope,
  policy configuration, region, monitoring destination, or production hostnames.
- **CON-03**: Compiled/runtime deadline enforcement, renderer resource restrictions,
  APIKit dispatch, and coverage require verification. Failures/missing infrastructure
  must be reported explicitly; generated code is not proof of production readiness.
- **CON-04**: Original v1.0 SAP/Anypoint MQ exclusions are superseded in v1.2
  only by FR-20..28. MQ publication is now in scope; actual SAP integration
  remains out of scope beyond its disabled extension boundary. Database access,
  customer-order processing, Excel export, child/related records, external PDF
  SaaS, PDF storage/archive, Account/PDF cache, schedulers/batch, autoscaling, and
  external API consumers remain excluded. Do not add unused connectors, mocks,
  or error branches for still-excluded systems.
- **CON-05**: Comments explain non-obvious behavior and requirement traceability,
  not every processor. Preserve other repository projects unchanged.
- **CON-06**: Hard-cancellation design uses app-owned local child JVMs rather than
  assuming a Java thread interruption stops OpenHTMLToPDF. Maximum five active
  renderer processes per replica; no waiting queue. Terminate the specific owned
  renderer process on deadline and retain its capacity slot until actual exit.
  Bound process memory and pipe output, deny remote resources, avoid customer-data
  diagnostics, and clean up owned processes on application shutdown.
  Startup counts against the render and overall budgets. Java renderer/support
  code and tests are explicitly authorized exceptions to the architect's
  Mule-native-only generation rule; do not add non-Mule test clients.
  CloudHub child-JVM packaging/permissions, exit behavior, memory, startup latency,
  and deadline behavior are not yet verified and are release blockers, not claims.
- **CON-20**: No MQ delivery guarantee is added by retrying. Consumer idempotency
  is an external responsibility. MQ absence/outage must not change PDF availability
  or the original business error. A future durable-delivery requirement needs a
  separately approved persistence/architecture change.
- **CON-21**: Preserve original IDs and acceptance criteria; enterprise extensions
  add criteria rather than replacing PDF functionality. This context update does
  not authorize SAP enablement or waive the Proposed ADR-001 verification gate.

## 10. Accelerator Defaults Applied

- Maven, Mule Maven Plugin, APIKit/RAML 1.0, DataWeave 2.0, lowercase kebab-case names.
- Mandatory modular layout: listener/APIKit routes in `main-flow.xml`; one business
  flow per dedicated XML; shared capability subflows and named error handlers;
  configuration-only XML; shallow acyclic `flow-ref` graph.
- Runtime XML directly under `src/main/mule`; resources under `src/main/resources`;
  MUnit suites/fixtures under test folders. Verify all configuration modules load.
- Use repository-supported pinned runtime/connector/MUnit versions after validating
  compatibility; record actual selections in implementation documentation.
- Structured metadata-only logging, correlation tracking, secret-property naming,
  deterministic sanitized tests, and build-once artifact promotion per instructions.
- Logical API-led layers within the requested single application, not three
  separately deployed applications or redundant pass-through wrappers.
- Dedicated capability-grouped validation subflows and connector-supported bounded
  connection pools/reconnection, with actual supported settings documented during
  implementation. No pool-size values or async publisher capacity are assumed
  until supported implementation defaults are selected and recorded.
- Implementation selections: Mule 4.9.4; Mule Maven Plugin 4.6.1 (the template's
  4.6.2 is unpublished); Salesforce 12.1.1; MQ 4.0.23; HTTP/APIKit 1.11.0;
  Java module 2.0.0; Spring module 2.1.4 for application lifecycle; secure
  properties 1.3.0; custom metrics 2.3.1; MUnit 3.7.0;
  OpenHTMLToPDF 1.1.117/PDFBox 3.0.8. Connector/schema compatibility remains
  unverified until the blocked Mule build can execute.
- Implementation defaults: Salesforce connection pool/cache maximum 10, five
  fail-fast publisher leases, MQ connection timeout 1s/socket timeout 4s,
  Salesforce login timeout 5s; no hidden reconnection loops; 128 MB renderer heap
  cap plus native memory; 2 MB HTML/PDF pipe bounds. These are implementation
  choices, not measured sizing or a waiver of the approved deadlines.

## 11. Assumptions and Open Items

No unresolved business assumption may silently become implementation behavior.
The user accepted deferred infrastructure items as nonblocking for context/design/
generation, but blocking their applicable validation/deployment/release stages.

### ADR-001: Renderer isolation

- Decision: use OpenHTMLToPDF through an isolated child JVM.
- Status: Proposed; CloudHub 2.0 verification required.
- Alternatives evaluated during discovery: embedded Java invocation, child JVM,
  sidecar service, and dedicated rendering service.
- Child JVM is the selected prototype direction, not a verified production design.
  Same-JVM interruption cannot establish the requested stop-work guarantee.
  Sidecar/dedicated-service alternatives are not authorized for implementation.
- Approval of v1.1 would authorize implementation and feasibility testing of this
  proposed direction, not waive CloudHub validation or release blockers.
  Approval of v1.2 retains this same Proposed status and verification obligation.

| Item | Owner | Blocking stage | Resolution |
| --- | --- | --- | --- |
| IAM issuer suitability, JWKS, audience, final scope, registrations | IAM team, assignment pending | Auth integration validation and deployment | Confirm provider and externally provision values; `document.generate`/`account.pdf.generate` are suggestions only |
| API Manager policies and normalized error behavior | Platform team, assignment pending | Secured deployment/promotion | Provision and exercise rejection paths |
| Salesforce Connected App/key/permissions | Salesforce/platform owner, pending | Live integration/deployment | Supply securely outside repository |
| Maven enterprise repository access and authorized settings | Platform/build owner, pending | Mule dependency resolution/build, MUnit and actual coverage | Obtain authorized access; no credentials in context |
| CloudHub region/residency/regulatory constraints | Security/platform owner, pending | Production deployment | Confirm requirements and region |
| vCore sizing and resource/replica confirmation | Platform owner, pending | Deployment and load validation | Confirm sizing and minimum replica plan |
| Application/support/incident owners and escalation channels | Operations, pending | Production release | Assign owners; provision approved destinations |
| Monitoring destination, alert thresholds and log retention | Operations, pending | Production release | Suggestions only: DEV 14/QA 30/PROD 90 days; p95 >5s, 5xx >5%, PDF failures >2%, memory >80% |
| Production performance/resilience evidence | Application/platform owners, pending | Production release | Execute defined load/spike/failure tests |
| App-owned child-JVM isolation on CloudHub 2.0 | MuleSoft platform owner, pending | Production release and verified cancellation claim | Validate packaged renderer, process permissions, bounded memory, startup, termination, capacity release, and deadline behavior; no deployment assumed |
| Branding assets | Business owner, pending | Future enhancement only | Initial report explicitly unbranded |
| MQ region/endpoints, queues and Connected App access | Platform owner, pending | Deployment/MQ integration verification | Provision external standard destinations and secure least-privilege credentials |
| Event consumers, retention, residency and deduplication ownership | Business/platform owners, pending | Production release | Confirm policy and idempotent consumer handling; no guaranteed delivery assumed |
| Bounded async publisher and in-flight cancellation | Application/platform owners, pending | Production release and verified deadline claim | Verify no response delay, no waiting queue, original 20s deadline, capacity skips, and lifecycle cleanup |
| SAP contract and business/technical enablement | SAP/business owners, pending | Future SAP functionality only | Disabled boundary only; no connector/calls/configuration before separately approved contract |

## 12. Acceptance Criteria

| ID | Requirements | Given / When | Expected result |
| --- | --- | --- | --- |
| AC-01 | BO-01, FR-01..04, FR-10, DR-01..15 | Authenticated valid Account ID and complete accessible Account | 200 PDF, specified labels/values, title/footer, UTC audit data; no unrelated query or write |
| AC-02 | DR-03..10 | Optional strings missing/null/blank and revenue null | PDF generated; strings/dates `N/A`, revenue `0`; no currency symbol |
| AC-03 | ERR-01 | Invalid length/prefix/characters or missing ID | 400 INVALID_ACCOUNT_ID, standard JSON; no Salesforce/render invocation |
| AC-04 | ERR-02 | Salesforce returns no accessible record | 404 NOT_FOUND; no PDF |
| AC-05 | ERR-04..05 | Missing/null/blank mandatory data or malformed number/date | 502 ACCOUNT_DATA_INVALID; no render invocation |
| AC-06 | SEC-01..02, ERR-03 | Missing/invalid/expired JWT, invalid audience/issuer/scope, future nbf, or bad client identity | 401 UNAUTHORIZED with approved message/JSON/correlation header, including gateway-policy paths |
| AC-07 | ERR-06, ERR-13 | Eligible transient Salesforce failure | At most two retries 3s apart within deadline; exhausted availability failure maps to 503 |
| AC-08 | ERR-13 | Authentication/authorization, invalid request/data, or missing record | No retry; preserve specified final error |
| AC-09 | ERR-07, NFR-06 | Salesforce response timeout or render budget exceeded | 504; no render retry or late success |
| AC-10 | ERR-07, ERR-13 | Retry sequence/rendering would exceed 20s overall | Deadline enforced, no work/retry beyond deadline; 504 response |
| AC-11 | NFR-02, ERR-09 | Five renders active on one replica and another needs capacity | Immediate 503 CAPACITY_EXCEEDED; active renders never exceed five; capacity released on all exits |
| AC-12 | NFR-03, ERR-10 | PDF exceeds 2 MB | 500 PDF_SIZE_EXCEEDED; no truncated/partial PDF |
| AC-13 | DR-12, SEC-06 | Salesforce text contains HTML/metacharacters/remote resource strings | Escaped display text; no remote or unapproved filesystem fetch |
| AC-14 | DR-14 | Account display content exceeds a page | Additional pages, no truncation, within size bound |
| AC-15 | FR-11 | Authorized health request | 200 JSON UP; no Salesforce/render call |
| AC-16 | FR-12, NFR-07, SEC-07 | Success/error and safe/unsafe incoming correlation IDs | Safe propagated/generated X-Correlation-ID; metadata-only JSON logs; no confidential values or raw error details |
| AC-17 | ERR-08, ERR-11..12 | Unexpected transform/render error, unknown route, wrong method | 500/404/405 respectively, populated standard JSON |
| AC-18 | FR-05, DEP-06, NFR-10 | Execute unit/MUnit with mocked external systems | Real APIKit-to-business orchestration (no mocked internal flow-ref); assertions, spies, mock-when, verify-call, assert-that; actual >=90% flow and processor reports |
| AC-19 | NFR-01..06 | Expected/spike/concurrency/degradation tests | Measured targets and deadlines, no corruption/duplicate responses/worker crash; evidence required before production |
| AC-20 | FR-06, BO-02 | Repeated document requests | Fresh read/render each time, no stored document or Account and no source mutation |
| AC-21 | DEP-01..07, CON-02..03 | Build/promotion and deployment verification | Same immutable artifact, external secrets, scans/test gates/approvals, documented blockers; no fabricated passing coverage/deployment evidence |
| AC-22 | FR-07, CON-06 | Successful, failed, timed-out, and shutdown renders | Only app-owned renderer JVMs; memory-only business data; bounded output/memory; never more than five live renders; timeout terminates the specific process and releases capacity only after exit; CloudHub behavior must be measured |
| AC-23 | FR-20, FR-23..24, DR-20..21 | PDF generated with publisher capacity/time remaining | Immediate 200 application/pdf; asynchronous PDF_GENERATED attempt to configured standard success queue; sanitized event with PDF byte count |
| AC-24 | FR-20, ERR-20..23 | Success-event publication fails, times out, exhausts retries, or is skipped | Caller still receives original successful PDF; safe delivery logs/metrics/alert signal; no recursive failure event |
| AC-25 | FR-21, ERR-22 | Application returns original business/technical error and publication is eligible | Attempt sanitized PDF_FAILED on failure queue; MQ failure never overrides original status/error JSON |
| AC-26 | ERR-20..21, FR-22..24 | MQ transient vs auth/config failure, exhausted time, or publisher capacity | At most two transient retries 1s apart; no auth/config retry, post-deadline attempt or waiting queue; skips recorded; no response delay |
| AC-27 | DR-20..22, SEC-20..21 | Event publication and retries | Metadata-only exact schema, UTC time, stable eventId across retries; no raw Account ID/data/PDF/secrets; no exactly-once claim |
| AC-28 | FR-25, FR-28, NFR-23 | Salesforce retrieved / PDF generated / PDF failed with SAP disabled | Correct telemetry counters independent of delivery outcomes; no SAP_ENRICHMENT_COMPLETED emission; SAP disabled-state tracking only |
| AC-29 | FR-26..27, CON-21 | Execute requested PDF path in all environments | Disabled SAP boundary has no external call, connector/config/auth/mapping/retry, PDF mutation, or changed response outcome; future enablement requires approval |
| AC-30 | FR-08..09 | Request and response validation / proposed wrapper pattern | Reusable validation exercised; existing 400/502/size/correlation behavior preserved; only PDF success enabled, no wrappers or download links |
| AC-31 | NFR-20..22 | Inspect supported pool/reconnection/streaming configuration and logs | Bounded supported pools/reconnection with no hidden retries; fresh Account data, no PDF/Account caching; allowed metadata only |
| AC-32 | NFR-23..25, DEP-20..22 | Enterprise tests, diagrams, deployment/release review | Extended actual >=90% flow/processor evidence; diagrams/config/docs cover MQ/validation/SAP-disabled/events/monitoring; unresolved deployment/observability blockers remain explicit |

## 13. Traceability Matrix

Generated artifacts are mapped below. Source presence is not execution evidence.
Renderer tests and a focused HTTPS suite passed locally; full MUnit on the pinned
runtime, the 90% coverage gate, gateway policies, CloudHub and performance
validation remain open. Existing requirements and acceptance criteria are unchanged.

| Requirements | Generated artifacts / registered responsibility | Tests / remaining verification | Documentation |
| --- | --- | --- | --- |
| FR-10..12, ERR-01..03, ERR-11..12 | `src/main/resources/api/account-pdf-api.raml`, `src/main/mule/main-flow.xml`, `http-config.xml` | `main-flow-test-suite.xml`: health, PDF and invalid-ID HTTPS tests passed on cached runtime; gateway policies unprovisioned, additional boundary tests required | `README.md`: API, security, main-to-business map |
| FR-01..06, ERR-06..07, ERR-13 | `account-generate-document-flow.xml`, `salesforce-account-get-flow.xml`, `salesforce-config.xml` | `account-generate-document-flow-test-suite.xml`; in-flight composite Salesforce deadline not established | `README.md`: reliability/deadline release blocker |
| DR-01..15, SEC-06 | `dwl/AccountDocument.dwl`, `account-to-document.dwl`, `document-to-html.dwl`, `templates/account-summary.html`, `RendererMain.java` | Mapping MUnit unexecuted; `RendererTest` passed for PDF text, escaping, pagination and resource restrictions | `README.md`: data rules and rendering |
| ERR-04..10, ERR-14 | `common-validation-subflows.xml`, `common-error-handlers.xml`, `dwl/ErrorContract.dwl` | `common-validation-subflows-test-suite.xml`; renderer size/deadline/capacity Java tests passed; full status-path MUnit required | `README.md`: error matrix/diagram |
| NFR-01..06 | `RuntimeSupport.java`, `IsolatedRenderer.java`, connector budget guards | `ChildRendererIT` passed locally; defined load/spike/degradation plan unexecuted | `README.md`: performance/release checklist |
| NFR-07..09, SEC-07 | `common-observability-subflows.xml`, `dwl/structured-log.dwl`, `log4j2.xml` | Safe field projection inspected; actual metric/trace/redaction integration unverified | `README.md`: monitoring/security review |
| SEC-01..05, DEP-01..05 | `global-config.xml`, `http-config.xml`, `salesforce-config.xml`, environment/secure properties, `deployment/pom.xml`, root workflows | External IAM/policy/certificate/secrets and deployment prerequisites remain blockers | `README.md`: configuration/deployment |
| NFR-10, DEP-06..07, CON-01..05 | `pom.xml`, `renderer/pom.xml`, four MUnit suites, root build/promotion workflows | Java test evidence in README; focused HTTPS MUnit 3/3, 84.03% application coverage on cached Mule EE 4.13.0 / MUnit 3.7.5; pinned suite/gates not verified | `README.md`: exact evidence and blockers |
| FR-07, CON-06 | `pdf-render-document-flow.xml`, `lifecycle-config.xml`, `RendererLifecycle.java`, `IsolatedRenderer.java`, `RendererMain.java`, standalone JAR packaging | `ChildRendererIT`: packaged PDF, expired deadline, unresponsive-child termination, sixth live render rejection; managed disposal/CloudHub still require runtime verification | `README.md`: Proposed ADR-001 |
| FR-08..09 | `common-validation-subflows.xml`, `main-flow.xml` PDF-only route | Real-listener invalid-ID and PDF cases passed on cached runtime; validation suite unverified; no wrapper/link implementation | `README.md`: API and rejected alternatives |
| FR-20..24, DR-20..22, ERR-20..23 | `common-event-subflows.xml`, `mq-publish-business-event-flow.xml`, `mq-config.xml`, `dwl/business-event.dwl` | MQ MUnit suite unexecuted; admission/idempotent release Java test passed; actual async/in-flight deadline unresolved | `README.md`: best effort and response independence |
| FR-25..28, SEC-21 | `common-observability-subflows.xml`, `sap-enrichment-extension-flow.xml` unreferenced disabled boundary | `sap-extension-fails-closed` and no-SAP-call assertions generated; telemetry integration unverified | `README.md`: SAP and business events |
| NFR-20..25, SEC-20, DEP-20..22, CON-20..21 | Connector configs, metadata/custom metrics, environment files, `.github/workflows/salesforce-pdf-build.yml`, `salesforce-pdf-promote.yml` | Pool behavior, monitoring destinations, extended coverage and release gates require execution/provisioning | `README.md`: five diagrams and release plan |

## 14. Change Log

| Version | Date | Change | Impacted artifacts | Approved by |
| --- | --- | --- | --- | --- |
| 1.0 | 2026-11-25 | Initial Salesforce Account PDF discovery; resolved scope, revenue, renderer, validation and timing conflicts; complete context explicitly approved | All generated application artifacts | @Dinesh-A20 |
| 1.1 | 2026-11-25 | Java support authorized; local child-JVM rendering direction selected, subject to explicit CloudHub verification | Renderer/bridge packaging, execution/capacity/deadlines, Java tests, Maven, CI, deployment documentation | Pending complete delta approval |
| 1.2 | 2026-11-25 | Complete extended context explicitly approved: response-independent best-effort MQ, metadata events, disabled SAP boundary, dedicated validation, pools/reconnection, logging/metrics/dashboards and traceability; explicitly supersede only SAP/MQ exclusions | Context only at this stage; future flows, RAML, DW, MUnit, config, pipeline, diagrams/runbook | @Dinesh-A20 |
| 1.2 | 2026-11-25 | Implementation artifact/defaults traceability populated; no requirement or acceptance-criterion changes. Renderer local tests passed; Mule/MUnit, in-flight connector deadlines and CloudHub remain explicit blockers | Application sources, tests, CI/deployment, README; approval status unchanged | Existing v1.2 approval |
| 1.2 | 2026-11-25 | Recorded focused offline MUnit evidence and fixes for the approved PDF, health and error response contracts. Full pinned-runtime verification and coverage gate remain open | Main flow, error classification, MUnit suites, Maven/packaging configuration, README; approval status unchanged | Existing v1.2 approval |
