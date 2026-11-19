---
name: deployment-generator
description: Generates environment promotion, Maven deployment, CloudHub 2.0, Runtime Fabric, rollback, and smoke-test plans.
---

# Deployment Generator

## Trigger Conditions
- A Mule project requires environment promotion.
- Runtime target or deployment topology is approved.
- CI/CD deployment automation is required.

## Workflow Steps
1. Identify artifact, runtime target, regions, replicas, resources, and availability.
2. Generate secure environment property and secret mappings.
3. Generate target-specific deployment configuration.
4. Add smoke, health, rollback, and replay steps.
5. Generate approval and promotion gates.
6. Document operational ownership.

## Expected Outputs
- Deployment design
- Environment property matrix
- Target deployment descriptors
- Promotion and rollback runbook

## Validation Rules
- One immutable artifact moves between environments.
- Production secrets cannot exist in source or logs.
- Resource, HA, and health settings are explicit.
