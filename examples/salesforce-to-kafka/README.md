# Salesforce to Kafka

## Pattern
Salesforce Platform Event/CDC to versioned Kafka domain events.

## Architecture
Salesforce source -> System API -> event Process API -> Kafka topic.

## Data Flow
Transform Salesforce changes to canonical domain events, key by business identifier, publish, and retain replay metadata.

## Controls
Schema compatibility, at-least-once delivery, idempotent consumers, partition ordering, client certificates/OAuth, and DLQ.
