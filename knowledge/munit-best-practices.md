# MUnit Best Practices

## Test Strategy
Cover success, validation failure, downstream failure, timeout, retry, batch partial failure, and replay behavior. Test each API status and contract.

## Isolation
Mock all external systems. Use deterministic fixtures and unique test records. Never execute tests against production.

## Assertions
Assert HTTP status, response contract, headers, variables, error type, side-effect count, and idempotency. Verify that unexpected calls fail tests.

## Coverage
Configure MUnit coverage for application XML and mapping logic. Set organization thresholds; a high percentage must not replace meaningful assertions.

## CI
Publish XML and coverage reports. Fail merge and deployment on test or coverage regressions.
