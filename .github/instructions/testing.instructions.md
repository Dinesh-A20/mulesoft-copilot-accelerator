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
- Run tests against the selected project's `pom.xml`; record actual test counts, reports, commands, and passed, failed, or blocked status. Skipped tests or missing reports are not a pass.
- Verify end-to-end flow behavior and meaningful processing components, including error paths and ordered side effects.

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
