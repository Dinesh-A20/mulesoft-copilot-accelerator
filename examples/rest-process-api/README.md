# REST Process API

## Pattern
Reusable orchestration API across REST and enterprise System APIs.

## Architecture
Experience API -> Process API -> one or more System APIs.

## Data Flow
Validate contract input, coordinate calls, normalize data, apply compensation, and return one stable contract.

## Controls
OAuth/client ID, timeout budget, bounded fan-out, idempotency, circuit breaking, caching, and correlation.
