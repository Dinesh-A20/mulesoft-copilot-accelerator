# Workday to Kafka

## Pattern
Workday worker or organizational event distribution.

## Architecture
Workday System API -> employee/domain Process API -> Kafka topics.

## Data Flow
Poll or receive changes, normalize Worker IDs and effective-dated values, and publish immutable domain events.

## Controls
Webhook or scheduled poll, OAuth, resume state, effective date handling, PII minimization, schema versioning, and replay.
