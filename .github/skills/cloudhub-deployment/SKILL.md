---
name: cloudhub-deployment
description: Designs and generates CloudHub 2.0 deployments with secure, resilient environment configuration.
---

# CloudHub Deployment

## Trigger Conditions
- CloudHub 2.0 is the approved runtime target.
- Environment replicas, HA, autoscaling, or public endpoints must be designed.

## Workflow Steps
1. Select region, organization, environment, public endpoint, and network mode.
2. Configure replicas, resources, HA, autoscaling, tracing, and persistent state.
3. Map secrets and secure properties to deployment variables.
4. Configure monitoring, alarms, and log retention.
5. Generate Maven or GitHub Actions deployment action.
6. Define smoke and rollback procedures.

## Expected Outputs
- CloudHub deployment manifest
- Environment variable matrix
- Alarm and monitoring configuration
- Promotion and rollback steps

## Validation Rules
- No public management endpoints or plaintext secrets.
- Replicas and autoscaling meet measured load.
- Artifact and runtime patch versions are pinned.
