---
name: mule-project-generator
description: Scaffolds Maven Mule 4 projects with modular flows, global configs, APIKit, properties, and packaging.
---

# Mule Project Generator

## Trigger Conditions
- A new Mule application is approved from architecture and RAML artifacts.
- Existing project structure must align to enterprise accelerator conventions.

## Workflow Steps
1. Derive artifact ID, domain, layer, API version, and runtime requirements.
2. Generate Maven project and mule-artifact metadata.
3. Scaffold global configs, main flow, process subflows, and error subflows.
4. Add secure/environment properties and APIKit routes.
5. Add connector dependencies and policy configuration placeholders.
6. Generate build scripts and project documentation.
7. Validate generated Mule XML against the pinned connector schemas and compile with the project's Mule Maven Plugin before declaring the project complete.

## Expected Outputs
- Complete Maven project structure
- Mule XML configurations
- `pom.xml` and `mule-artifact.json`
- Properties and secure properties scaffolds
- Build and run instructions

## Validation Rules
- Project builds on supported Mule and JDK versions.
- No credential or environment hostname is hardcoded.
- Flow references resolve; connector configs exist.
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
