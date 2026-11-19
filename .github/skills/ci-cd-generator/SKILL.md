---
name: ci-cd-generator
description: Generates Maven and GitHub Actions pipelines for build, MUnit, security, and deployment.
---

# CI/CD Generator

## Trigger Conditions
- A Mule project needs repeatable delivery automation.
- Security, quality, approval, or environment promotion gates are required.

## Workflow Steps
1. Generate build and test stages.
2. Execute MUnit and Maven package.
3. Execute SonarQube, Snyk, dependency, and secret scans.
4. Publish versioned immutable artifacts.
5. Deploy dev, QA, and prod with environment protections.
6. Capture evidence and support rollback.

## Expected Outputs
- GitHub Actions workflows
- Maven CI settings
- Scan configuration
- Environment approval and artifact promotion plan

## Validation Rules
- Tests and scans block merge or deployment on failure.
- Secrets are read from GitHub or enterprise secret storage.
- Prod deployment requires approval.
