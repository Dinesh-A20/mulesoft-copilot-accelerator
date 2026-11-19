---
name: performance-reviewer
description: Reviews Mule applications for throughput, memory, latency, batching, and scalability.
---

# Performance Reviewer

## Trigger Conditions
- Volume or latency targets are available.
- Payload size or throughput is a risk.
- Production performance issues require diagnosis.

## Workflow Steps
1. Quantify peak volume, payload size, concurrency, latency, and retention.
2. Trace slow dependencies and serial bottlenecks.
3. Verify streaming, pagination, batching, pooling, caching, and back-pressure.
4. Validate retries, timeout budgets, and autoscaling.
5. Create load-test hypotheses and scenarios.
6. Produce capacity and tuning recommendations.

## Expected Outputs
- Performance review report
- Capacity model
- Load and soak test plan
- Bottleneck and tuning backlog

## Validation Rules
- No unbounded payload or collection processing.
- Timeout budgets are below end-to-end SLA.
- Retry volume cannot amplify downstream load.
- Resource settings match measured concurrency.

## Supporting Artifacts
- Use `knowledge/performance-patterns.md`.
