# MuleSoft Enterprise Accelerator

An enterprise GitHub Copilot customization repository for producing Mule 4 applications and API-led solutions across delivery teams and clients.

## Repository layout

- `.github/agents/` - orchestration agents.
- `.github/instructions/` - repository-wide standards applied by Copilot.
- `.github/skills/` - reusable implementation, review, and deployment capabilities.
- `.github/workflows/` - build, test, security, and environment deployment pipelines.
- `knowledge/` - platform and integration pattern guidance.
- `examples/` - reference application scenarios.
- `templates/` - reusable API and application scaffolds.
- `reference-architectures/` - target-state platform designs.
- `docs/` - governance and operating guidance.

## Primary agent

Use `@mule-architect` for requirements-to-delivery work. The agent orchestrates architecture, RAML, Mule projects, DataWeave, MUnit, security, performance, deployment, CI/CD, and documentation skills.

## Supported platforms

- Mule 4.x, API-led connectivity, and RAML 1.0
- CloudHub 2.0 and Runtime Fabric
- Salesforce, SAP, Oracle, SQL Server, Azure SQL
- Kafka, FTP/SFTP, Workday, ServiceNow
- REST and SOAP services, Snowflake

## Enterprise defaults

- No hardcoded credentials or endpoints
- Secure properties and encrypted secret stores
- TLS 1.2+, mutual TLS where required
- Client ID enforcement and OAuth2/OIDC
- Correlation IDs and business/technical log separation
- Streaming, pagination, batching, pooling, retries, caching, and MUnit coverage
- Environment promotion through GitHub Actions and Maven

## Quick start

1. Adopt the instruction files for the target repository.
2. Invoke the `mule-architect` agent with a business requirements document.
3. Select or generate an Experience, Process, or System API.
4. Generate RAML and the Mule project from approved requirements.
5. Run MUnit and static/security scans locally and in CI.
6. Promote through dev, QA, and production deployment workflows.
