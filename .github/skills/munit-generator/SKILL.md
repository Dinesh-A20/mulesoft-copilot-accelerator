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
5. For file output, mock writes and assert the configured target filename/path and write mode match the API response.
6. Add coverage and reports.
7. Integrate tests with Maven.

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
- Tests verify output naming and write behavior without touching a real user directory.
- For binary exports, force serialization and read back the generated content before mocking away the write; assert worksheet/column/value contracts, not only the completion response.
- When connectors use target variables, mocks return connector results and tests verify that mappings use the captured source rather than a replaced payload.
- For read-merge-rewrite exports, mock `file:read` with a real serialized fixture (for example `write({Accounts: [...]}, 'application/xlsx')`) and `FILE:ILLEGAL_PATH` for the missing-file path; mock `os:retrieve`/`os:store` and cover initial load, update-in-place, append, no-change, and write-failure-does-not-store-watermark cases.
- Do not combine success assertions with `expectedErrorType` in one test; a failing assertion would satisfy the expected error.
- Coverage threshold is explicit.

## Supporting Artifacts
- Use `templates/munit/test-suite-template.xml`.
