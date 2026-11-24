---
name: mule-project-generator
description: Scaffolds Maven Mule 4 projects with modular flows, global configs, APIKit, properties, and packaging.
---

# Mule Project Generator

## Trigger Conditions
- A new Mule application is approved from architecture and RAML artifacts.
- Existing project structure must align to enterprise accelerator conventions.

## Workflow Steps
1. Confirm `<project-root>/project-context.md` is `Approved`; derive artifact ID, domain, layer, API version, and runtime requirements from it. Stop and return to requirements-discovery if it is missing, draft, or does not cover the request.
2. Generate Maven project and mule-artifact metadata.
3. Inventory filenames, registered flow/subflow names, responsibilities, and references using the [mandatory modular project layout](../../instructions/mulesoft.instructions.md#mandatory-modular-project-layout). Scaffold one thin `main-flow.xml` containing APIKit routing flows, dedicated business-flow XML files, capability-grouped common subflows, and separate configuration/error-handler files.
4. Add secure/environment properties and APIKit routes.
5. Add connector dependencies and policy configuration placeholders.
6. Generate build scripts and project documentation.
7. Ensure all generated XML modules are loaded (including explicit `mule-artifact.json` config lists), validate against the pinned connector schemas, compile with the project's Mule Maven Plugin, and run MUnit across the orchestration path before declaring the project complete.

## Expected Outputs
- Complete Maven project structure
- Mule XML configurations
- `pom.xml` and `mule-artifact.json`
- Properties and secure properties scaffolds
- Build and run instructions
- File/flow responsibility inventory and main-to-business reference map

## Validation Rules
- Project builds on supported Mule and JDK versions.
- No credential or environment hostname is hardcoded.
- Flow references resolve; connector configs exist.
- The mandatory layout applies to all new projects and every new or modified flow. Extract touched business flows from shared legacy XML files, consolidate affected APIKit resource flows in `main-flow.xml`, remove old definitions, and preserve behavior without refactoring unrelated functionality.
- Each business flow has its own XML file; shared subflows may be grouped by capability. Keep APIKit resource flows together with the listener/router in `main-flow.xml`, not in separate route files. Configuration files contain no business logic.
- APIKit routes in `main-flow.xml` delegate to their business modules through `flow-ref`; preserve generated registered names and use filesystem-safe business filenames. Reference names, not filenames, and do not call unrelated operations from main.
- All required files load, registered names are unique, and an integration test exercises main through the actual referenced business modules without mocking internal `flow-ref` calls. Layout violations block completion.
- Public contracts map to APIKit routes.
- APIKit resource flow names use its generated backslash path convention, such as `post:\v1\orders:api-config`, and contain no forward slashes or other invalid flow-name characters.
- Use only attributes supported by the pinned APIKit and connector schemas; each connector config has exactly one connection definition.
- Verify Maven `groupId:artifactId` uniqueness in the active workspace. Resolve duplicate project imports instead of arbitrarily renaming a published artifact.
- Keep configured output directory, file name, File Connector path, and API response filename consistent; never use a remote web URL as a filesystem directory.
- Incremental file sync flows: read the existing file inside a `try` that treats only `FILE:ILLEGAL_PATH` as "no file", materialize it to `application/java` before rewriting the same path, and serialize requests (`maxConcurrency="1"`, single replica) because file and watermark are per-instance state.
- Store watermarks in a persistent Object Store (`org.mule.connectors:mule-objectstore-connector`, `os` namespace) and commit them only after the target write succeeds; a missing or empty target forces an initial load instead of trusting a stale watermark.
- Document that files open in Excel on Windows are locked and make writes fail; the flow must not advance its watermark on that failure.

## Supporting Artifacts
- Use `templates/mule-project/` as the source scaffold.
