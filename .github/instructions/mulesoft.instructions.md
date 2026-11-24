---
applyTo: "**/*.{xml,raml,yaml,yml,properties}"
---
# MuleSoft Development Instructions

## Purpose
Set implementation standards for production-grade Mule 4 applications.

## Scope
Maven projects, Mule configurations, flows, connectors, configuration properties, transformations, and packaging.

## Mandatory Standards
- Create or modify Mule artifacts only from an approved Project Context Instruction under the [context-first workflow](./context-first.instructions.md); annotate flows with the requirement IDs they implement (for example, `doc:description="FR-10"`).
- Use Maven and the Mule Maven Plugin.
- Use DataWeave 2.0; keep transformations maintainable and testable.
- Use APIKit for RAML contract implementation.
- Externalize all environment-specific values.
- Configure connection and HTTP timeouts.
- Use standard named global configurations.
- Include correlation ID propagation and structured logging.
- Catch and normalize all known and unknown errors.
- Apply the mandatory modular project layout below to every new application and every new or modified flow; monolithic placement is not an acceptable existing convention to preserve.

## Naming Conventions
- Applications: lowercase kebab-case.
- Flows: `source-operation-purpose-main`.
- Business flows: `resource-operation-process`.
- Subflows: `operation-purpose-process`.
- XML files: `main-flow.xml`, `<resource>-<operation>-flow.xml`, `common-<capability>-subflows.xml`, and `<technology>-config.xml`.
- Global configuration names: `<technology>-<purpose>-config`.
- Properties keys: lowercase dot notation, such as `salesforce.auth.host`.
- DataWeave files: purpose-oriented `.dwl` names.

## Mandatory modular project layout

- Use one `main-flow.xml` per application for the primary entry/orchestration flow and APIKit resource routing flows. Keep these flows thin: accept and route the event, then invoke business functionality through `flow-ref` rather than implementing it inline.
- Place each business flow in its own dedicated XML file, with one top-level `<flow>` or non-shared business `<sub-flow>` per file. Do not combine independent operations into a single business XML file.
- For APIKit, keep the listener, router, and generated resource flows together in `main-flow.xml`; do not create separate route XML files. Preserve APIKit's required registered resource flow names. Each resource flow delegates through `flow-ref` to the corresponding business flow in its own XML file.
- Route only the requested operation. The main entry reaches business flows directly or through APIKit resource flows; it must not invoke every CRUD operation in sequence merely to demonstrate orchestration.
- Keep any additional required scheduler or event source in its own entry-flow XML file, delegating to business functionality with `flow-ref`. Do not remove, duplicate, or change trigger behavior to force unrelated sources into the main flow.
- Group only genuinely shared `<sub-flow>` definitions by capability in dedicated reusable files, such as `common-validation-subflows.xml`. Keep named reusable error handlers in `common-error-handlers.xml`; reference them as error handlers, not as flows.
- Put global elements, configuration-properties declarations, connector configurations, and Object Store definitions in configuration-only XML files such as `global-config.xml`, `http-config.xml`, and `object-store-config.xml`. These files must not contain business flows or subflows.
- Keep RAML, DataWeave, and environment/secure properties under their resource folders, and MUnit suites and fixtures under test folders. Use meaningful lowercase kebab-case filenames and create only the modules the application needs.
- A `flow-ref` references the registered flow/subflow name, not an XML filename. Keep the call graph shallow, explicit, and acyclic; avoid unnecessary pass-through wrappers other than required routing boundaries.

Example layout (business files repeat per operation):

```text
src/
  main/
    mule/
      main-flow.xml
      accounts-get-by-id-flow.xml
      common-validation-subflows.xml
      common-error-handlers.xml
      global-config.xml
      http-config.xml
      object-store-config.xml
    resources/
      api/
      dwl/
      properties/
  test/
    munit/
      main-flow-test-suite.xml
      accounts-get-by-id-flow-test-suite.xml
    resources/
```

Keep runtime XML files directly under `src/main/mule` by default; do not assume nested XML directories are automatically loaded. Ensure every required XML file is loaded by the application, updating `mule-artifact.json` when it explicitly lists `configs`. Validate this through the Mule Maven build and MUnit, not just a directory listing.

Before modifying a business flow co-located with other flows, extract the touched business flow into its dedicated file and update directly required orchestration/configuration boundaries and references. Move affected APIKit resource routing flows into `main-flow.xml`. Remove old definitions and update explicit config lists rather than duplicating them. Preserve public contracts, registered names, event variables, error scopes, transactions, concurrency, and source behavior. Do not bulk-refactor unrelated legacy functionality; report any remaining legacy layout outside the changed scope.

This layout is a blocking generation and review requirement, not a recommendation. Reject new or modified monolithic business flow files, separate APIKit route XML files, mixed configuration/business files, duplicate definitions, unresolved references, or unloaded modules. Multiple thin APIKit routing flows in `main-flow.xml` are required, not a monolithic-business-flow violation. Verify the main-to-business call path with an MUnit integration test that does not mock internal `flow-ref` calls.

## Best Practices
- Follow the mandatory layout above and reuse capability-focused subflows.
- Disable auto-generated sample data and debug-only routes.
- Enrich only required fields.
- Reuse object stores, cache scopes, and connection pools.
- Configure size limits and streaming for batch and bulk operations.
- Preserve original IDs and business keys for idempotency.

## Anti-Patterns
- DataWeave logic embedded across many flows without reuse.
- Deeply chained flow-ref graphs.
- Infinite retries or duplicate side-effect sends.
- Hardcoded hostnames, credentials, queue names, or secrets.
- Catch-all handlers that hide cause and status.
- Shared mutable variables across async scopes.
- Multiple business flows in one XML file or business logic mixed with global configurations.

## Review Checklist
- [ ] Project builds reproducibly.
- [ ] Flows use clear names and no dead routes.
- [ ] Global settings are environment independent.
- [ ] Connector operations define size/time limits.
- [ ] Error paths return stable contracts.
- [ ] Logs exclude secrets and regulated payloads.
- [ ] New and modified flows follow the mandatory modular layout and have a working orchestration path.
- [ ] All required XML modules load, names are unique, and cross-file references resolve.
