# Kafka Patterns

## Topics
Use domain-owned, versioned event names. Keep key, partition, schema, retention, and compatibility policies explicit.

## Delivery
Distinguish at-least-once and exactly-once by system capability. Consumers require idempotency and duplicate handling.

## Serialization
Use governed JSON, Avro, or Protobuf schemas. Validate compatibility and prohibit breaking uncoordinated changes.

## Resilience
Configure bounded retries and dead-letter topics. Do not block partition consumers indefinitely. Preserve original offset and headers for replay.

## Ordering
Partition by stable business key. Document per-key ordering and the impact of repartitioning.
