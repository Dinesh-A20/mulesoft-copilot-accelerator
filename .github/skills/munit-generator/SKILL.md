---
name: munit-generator
description: Generates MUnit suites for success, failure, timeout, edge, retry, and contract scenarios.
---

# MUnit Generator

## Trigger Conditions
- A Mule flow or subflow is implemented.
- A review requires test coverage or regression automation.
- A DataWeave mapping changes public behavior.

## Workflow Steps
1. Inventory flow inputs, dependencies, branches, and error types.
2. Build deterministic mocks for external systems.
3. Create success, negative, boundary, timeout, retry, and replay scenarios.
4. Assert payload, status, headers, variables, and error metadata.
5. Add coverage and reports.
6. Integrate tests with Maven.

## Expected Outputs
- MUnit test suite XML
- Sanitized fixtures
- Mock definitions
- Coverage configuration
- Maven test command

## Validation Rules
- Tests do not call production dependencies.
- Assertions include contract and error semantics.
- Replay, idempotency, retry, and null cases are covered.
- Coverage threshold is explicit.

## Supporting Artifacts
- Use `templates/munit/test-suite-template.xml`.
