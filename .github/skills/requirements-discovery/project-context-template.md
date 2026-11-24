# Project Context Instruction: {Project Name}

| Field | Value |
| --- | --- |
| Status | Draft \| Approved |
| Version | 1.0 |
| Approved by | {user handle, or pending} |
| Approved on | {YYYY-MM-DD, or pending} |
| Project root | `{artifact-id}/` |

> This document is the single source of truth for design, implementation, tests, configuration,
> deployment, and documentation. Artifacts must cite the requirement IDs below.

## 1. Business Context
- **BO-01** Objective: {business outcome}
- Consumers / stakeholders: {who uses the result}
- Success criteria: {measurable outcome}

## 2. Systems and Integration
| ID | Item | Value |
| --- | --- | --- |
| FR-01 | Source system and object/resource | {e.g., Salesforce Account} |
| FR-02 | Target system and object/resource | {e.g., XLSX file, REST API} |
| FR-03 | Trigger / pattern | {API, schedule, event, file, on demand} |
| FR-04 | Operations | {read, create, update, upsert, delete} |

## 3. Interface Contract (if API)
| ID | Method | Path | Request | Success response | Business outcomes (not found, duplicate, empty) |
| --- | --- | --- | --- | --- | --- |
| FR-10 | {GET} | {/v1/resource} | {body/params} | {status + body} | {status + body per outcome} |

## 4. Data and Mapping
| ID | Source field | Target field | Required | Rule / default |
| --- | --- | --- | --- | --- |
| DR-01 | {Id} | {id} | Yes | {business key} |

- Data classification: {public, internal, PII, financial...}; retention and masking: {rules}

## 5. Error Handling and Reliability
- **ERR-01** {failure} → {expected behavior/status, retry, notification}
- Idempotency / replay: {rule}

## 6. Non-Functional Requirements
- **NFR-01** Volume and frequency: {records per run, requests per second}
- **NFR-02** Latency / throughput: {target}
- **NFR-03** Availability, RTO/RPO, monitoring: {target or not applicable}

## 7. Security
- **SEC-01** Consumer authentication/authorization: {mechanism}
- **SEC-02** Downstream credentials: {mechanism and secure property names only, never values}

## 8. Deployment
- **DEP-01** Target: {CloudHub 2.0, Runtime Fabric, local only}; environments: {dev, qa, prod}

## 9. Constraints, Dependencies, and Out of Scope
- **CON-01** {constraint}
- Out of scope: {explicit exclusions}

## 10. Accelerator Defaults Applied
- Modular layout per `.github/instructions/mulesoft.instructions.md`
- {pinned runtime/connector versions, naming, logging, test structure}

## 11. Assumptions and Open Items
| Item | Owner | Blocking? | Resolution |
| --- | --- | --- | --- |
| {non-critical assumption confirmed by user, or open question} | {name} | {Yes/No} | {decision} |

## 12. Acceptance Criteria
| ID | Requirement | Given / When | Then (expected result) |
| --- | --- | --- | --- |
| AC-01 | FR-10 | {input} | {status, body, side effect} |

## 13. Traceability Matrix
| Requirement | Flow / config | MUnit test | Documentation |
| --- | --- | --- | --- |
| FR-10 | {file.xml: flow-name} | {test name} | {README section} |

## 14. Change Log
| Version | Date | Change | Impacted artifacts | Approved by |
| --- | --- | --- | --- | --- |
| 1.0 | {date} | Initial context | — | {user} |
