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

1. Adopt the instructions and skills for the target repository. Select the
   Mule project explicitly when the workspace contains more than one project.
2. Invoke `mule-architect` with the requirement, relevant sanitized schemas
   and examples, project path, and the intended task: create, change, or
   troubleshoot. The agent reads the selected project's context explicitly.
3. Use the `requirements-analyzer` and the templates in
   `templates/project-context/` to capture requirements, decisions,
   traceability, and nontrivial mapping rules in the selected project.
4. For a new project, use `full-project-generator`; for an existing project,
   use `existing-project-analyzer` to establish a baseline and assess impact
   before editing. For errors in either path, use `mule-troubleshooter`.
5. Generate modular flows and DataWeave, and run MUnit and applicable checks.
   Record real test counts and reports, or report a blocked check explicitly.
6. Prepare deployment and obtain the required authorization before promoting.

The Salesforce-specific
[project context](.github/instructions/project-context.instructions.md) is not
a generic default; select it only for that project. Use
[the context template](templates/project-context/project-context-template.md)
for other projects.

Skills are instructions to the agent, not executable programs. Validate
requirements extraction, flow decomposition, and troubleshooting with
representative Copilot sessions and project-specific evidence.

## MUnit template and CI

The [Maven scaffold](templates/mule-project/pom.xml) includes MUnit 3.4.0,
Mule 4.9.4, Mule Maven Plugin 4.10.3, and an 80% application coverage default.
Confirm the runtime, Maven, Java, plugin versions, and coverage threshold
against the target organization's approved policy. The MUnit 3.4.0 release
notes list Java 17, Mule 4.3+, and Maven 3.8.1-3.9.7; the plugin lists Maven
3.9.0-3.9.15, so Maven 3.9.7 is within both published ranges. Coverage requires
the Mule Enterprise runtime and an authorized Maven Enterprise plugin
repository configured in `settings.xml`; do not commit credentials. The
[suite example](templates/munit/test-suite-template.xml) contains placeholder
flow names and an expected value; replace them for the application.

Run `mvn -B -ntp clean test` from the selected project directory. The test
workflow requires the GitHub repository variable `MULE_PROJECT_DIR` to name
that directory relative to the checkout (`.` for a root project). Configure the
`MULE_MAVEN_SETTINGS` Actions secret with a complete Maven `settings.xml`
containing the approved Enterprise plugin repository and corresponding server
credentials. GitHub does not provide repository secrets to fork pull requests,
so those runs need an authorized alternative before they can pass. The MUnit
plugin must write Surefire XML and JSON coverage to the paths used in the
scaffold. The workflow installs checksum-verified Maven 3.9.7; adjust
the version and checksum if the selected project requires a different supported
version. CI checks the reports for executed tests and fails if
reports are absent, coverage is below its configured threshold, or tests fail
or are skipped. A Community runtime does not produce MUnit coverage and cannot
pass this quality gate. CI uploads reports when available. When adopting the workflow in another repository,
include [the report checker](scripts/check_munit_reports.py) as well.

This repository has no root Maven project. Configuring `MULE_PROJECT_DIR`
requires an actual Mule project in the checkout; placeholder examples are not
projects. The other existing build and deployment workflows still require
project-specific configuration and are not an enforced promotion chain.
