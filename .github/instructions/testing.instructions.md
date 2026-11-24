---
applyTo: "**/*.{xml,dwl,java,groovy,md}"
---
# Testing Instructions

## Purpose
Ensure repeatable Mule test coverage and quality gates.

## Scope
MUnit suites, mocks, assertions, fixtures, test data, coverage, and CI test behavior.

## Mandatory Standards
- Generate MUnit success, negative, edge, timeout, and downstream-failure cases.
- Mock external systems deterministically.
- Assert status, headers, payload contract, variables, and error type.
- Use test resources separate from runtime resources.
- Enforce coverage thresholds in CI.
- Never access production systems from tests.
- For new or modified flows, test the [mandatory modular layout's](./mulesoft.instructions.md#mandatory-modular-project-layout) orchestration path through the real business modules, without mocking internal `flow-ref` calls in that integration test. Verify the requested APIKit route delegates to its business flow without invoking unrelated operations; external systems remain mocked.
- After splitting XML files, run the Mule build and affected MUnit regressions to verify configuration loading, cross-file references, APIKit dispatch, response contracts, side effects, and error propagation are preserved.

## Naming Conventions
- Suites: `<flow-or-config>-test-suite.xml`.
- Tests: `<flow-name>-<scenario>` in lower-case-hyphen format.
- Fixtures use `.json`, `.xml`, or `.dwl` and describe the scenario.

## Best Practices
- Use examples and RAML fragments as contract fixtures.
- Verify retries and idempotency keys.
- Test serialization, nulls, empty collections, and maximum payload values.
- Fail fast for unexpected external calls.
- Generate reports for XML, coverage, and failed assertions.

## Anti-Patterns
- Tests that call live third-party services.
- Assertions only on HTTP 200.
- Shared mutable test state.
- Random test data.
- Mock verification omitted.
- Disabling test failures to improve pipelines.

## Review Checklist
- [ ] Primary and alternate flows are covered.
- [ ] External dependencies are mocked.
- [ ] Contract and error semantics are asserted.
- [ ] Retry and timeout behavior are tested.
- [ ] Test data is sanitized.
- [ ] Coverage gate is enabled.
- [ ] Modular orchestration and referenced business files are exercised together, not only as isolated flow tests.
