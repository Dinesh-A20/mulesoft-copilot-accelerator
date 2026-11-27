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
1. Inventory flow inputs, dependencies, branches, error types, and the file/flow reference map required by the [mandatory modular layout](../../instructions/mulesoft.instructions.md#mandatory-modular-project-layout).
2. Build deterministic mocks for external systems.
3. Create success, negative, boundary, timeout, retry, and replay scenarios.
4. Assert payload, status, headers, variables, and error metadata.
5. For file output, mock writes and assert the configured target filename/path and write mode match the API response.
6. Add coverage and reports.
7. Integrate tests with Maven.
8. For HTTP contracts, add a local integration test using an enabled listener flow source and the Mule HTTP Request connector; assert the actual response and side effects without mocking the endpoint request. Isolate downstream dependencies and test state.

## Expected Outputs
- MUnit test suite XML
- Sanitized fixtures
- Mock definitions
- Coverage configuration
- Maven test command

## Validation Rules
- Load the actual `main/`, `implementation/`, and `config/` modules from the application's single source root. Keep suites in `src/test/munit` and fixtures in `src/test/resources`; never scaffold another `src/main/mule` for tests.
- Derive expected results from the approved Project Context Instruction's acceptance criteria, never from the implementation; name or describe each test with the requirement/acceptance IDs it verifies, and cover every acceptance criterion.
- Tests do not call production dependencies.
- Use MUnit, Mule connectors, and DataWeave for test clients and assertions; do not generate standalone scripts in other languages. Report an unavailable runtime or tool as a blocker.
- Distinguish an actual HTTP listener test from a flow-ref test; handle expected non-2xx responses so their status and body can be asserted.
- Assertions include contract and error semantics.
- For every new or modified flow, cover the main-to-business orchestration path across its real XML modules. Verify APIKit routes in `main-flow.xml` invoke their matching business flow, not unrelated operations. Do not mock internal `flow-ref` calls in that integration test; mock external systems instead. Keep focused unit tests for business modules as needed.
- After extracting flows, verify all XML configurations load, references resolve, and entry behavior, errors, variables, transactions, concurrency, and side effects remain unchanged. Preserve APIKit operation names and enable the required listener/resource sources.
- Replay, idempotency, retry, and null cases are covered.
- Tests verify output naming and write behavior without touching a real user directory.
- For binary exports, force serialization and read back the generated content before mocking away the write; assert worksheet/column/value contracts, not only the completion response.
- When connectors use target variables, mocks return connector results and tests verify that mappings use the captured source rather than a replaced payload.
- For read-merge-rewrite exports, mock `file:read` with a real serialized fixture (for example `write({Accounts: [...]}, 'application/xlsx')`) and `FILE:ILLEGAL_PATH` for the missing-file path; mock `os:retrieve`/`os:store` and cover initial load, update-in-place, append, no-change, and write-failure-does-not-store-watermark cases.
- Do not combine success assertions with `expectedErrorType` in one test; a failing assertion would satisfy the expected error.
- Coverage threshold is explicit.

## Supporting Artifacts
- Use `templates/munit/test-suite-template.xml`.
