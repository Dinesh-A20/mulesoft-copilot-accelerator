# API-Led Best Practices

## Principles
- Use Experience APIs for consumer experiences, Process APIs for reusable orchestration, and System APIs for system-of-record isolation.
- Create APIs around business capabilities and stable ownership, not individual HTTP endpoints.
- Publish versioned contracts and preserve backward compatibility.
- Keep source-specific models behind System APIs and canonical models in governed Process APIs.

## Ownership
Assign platform, domain, API, security, data, and operations owners. API producers own contract compatibility and SLOs; API consumers own migration timing.

## Reuse
Reuse RAML fragments, traits, data types, authentication behavior, and error contracts. Reuse connector and data access abstractions through System APIs, not shared mutable state.

## Failure Model
Use bounded retries, idempotency keys, timeouts, dead letters, and replay procedures. Define degradation behavior when optional enrichment systems are unavailable.

## Governance
Review contract changes, lifecycle, discoverability, policy inheritance, deprecation, and retirement. Test contract conformance in CI.
