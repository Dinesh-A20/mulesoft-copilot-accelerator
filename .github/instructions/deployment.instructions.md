---
applyTo: "**/*.{yaml,yml,xml,properties,md}"
---
# Deployment Instructions

## Purpose
Standardize safe promotion for Mule applications.

## Scope
Maven packaging, CloudHub 2.0, Runtime Fabric, environments, secrets, artifacts, promotion, rollback, and CI/CD.

## Mandatory Standards
- Build once and promote the same immutable artifact.
- Use environment-specific secret resolution.
- Deploy dev, QA, and prod via controlled environments.
- Require artifact scanning and test evidence before production.
- Configure health checks, replicas, and resource limits.
- Define rollback and data replay procedures.
- Use deployment tokens from CI secrets with least privilege.

## Naming Conventions
- Environments: dev, qa, prod.
- Artifact: `${artifactId}-${version}.jar`.
- Application: `<domain>-<layer>-<bounded-context>-api`.
- Tags use immutable release version and commit SHA.

## Best Practices
- Use rolling deployment for state compatibility.
- Configure autoscaling and availability according to RTO/SLO.
- Use blue/green or canary only with contract and data compatibility.
- Verify post-deployment health and smoke tests.
- Retain deployment evidence and approvals.

## Anti-Patterns
- Rebuilding for each environment.
- Manual production configuration edits.
- Reusing production credentials in dev.
- Deploying without version and rollback metadata.
- Stopping applications before replay-safe migration.

## Review Checklist
- [ ] Artifact is immutable and signed where required.
- [ ] Secrets resolve per environment.
- [ ] Health and smoke checks exist.
- [ ] Rollback/replay is documented.
- [ ] Resource and replica settings match NFRs.
