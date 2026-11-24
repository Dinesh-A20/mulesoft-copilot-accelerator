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

For implementation requests, the agent derives automated checks from the requirements, builds and tests the project, and, when a safely isolated local runtime is available, checks its contract-defined HTTP endpoint. It diagnoses failures and retries fixes up to three times without requiring manual interpretation. Non-HTTP triggers use their supported test mechanism instead.

Validation uses MuleSoft-native artifacts: MUnit enables the listener and uses the Mule HTTP Request connector to call the endpoint, with DataWeave assertions and isolated downstream dependencies. The agent does not generate or display code in other languages; Maven commands or available MuleSoft tools run the build and tests.

Local checks use mocks and isolated test data, not production systems. If a runtime, deterministic expectation, or safe isolation is unavailable, the agent reports the blocked check rather than claiming success. This is agent guidance, not a guarantee that the host provides a Mule runtime or all required tools; deployment and remote calls still require authorization.

## Context-first workflow (mandatory)

Every project creation and modification starts from a plain business request. Under the
[context-first instructions](.github/instructions/context-first.instructions.md), the agent:

1. Accepts the requirement in natural language and analyzes it for missing information.
2. Asks grouped follow-up questions until no critical gap remains; it never assumes critical answers.
3. Generates `<project-root>/project-context.md` from the
   [template](.github/skills/requirements-discovery/project-context-template.md) and asks you to approve it.
4. Generates design, flows, MUnit tests, configuration, and documentation only from the approved
   context, with every artifact traced to its requirement IDs.

Changes not covered by the approved context trigger delta discovery and re-approval before any code changes.

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

## Mandatory Mule project structure

Every new project and every new or modified flow must follow the
[modular project standard](.github/instructions/mulesoft.instructions.md#mandatory-modular-project-layout):

- One thin `main-flow.xml` for entry, APIKit resource routing, and orchestration.
- One dedicated XML file per business flow; APIKit routing flows stay in `main-flow.xml` rather than separate route files.
- Shared subflows grouped by reusable capability; named common error handlers kept separately.
- Configuration-only XML files, with RAML, DataWeave, properties, and test assets in their own resource folders.
- Explicit `flow-ref` delegation, preserved APIKit names, and all required modules loaded.

The agent, generation skills, review skills, and instruction files treat violations as blocking
for new or modified flows. Existing touched business flows must be extracted safely rather than
extending a monolithic file. Mule builds and MUnit integration checks verify the resulting cross-file
orchestration without changing the public contract or runtime behavior.

## Quick start

1. Adopt the instruction files for the target repository.
2. Describe the business requirement to the `mule-architect` agent in plain language.
3. Answer its discovery questions and approve the generated Project Context Instruction.
4. Generate RAML and the Mule project from the approved context.
5. Run MUnit and static/security scans locally and in CI.
6. Promote through dev, QA, and production deployment workflows.
