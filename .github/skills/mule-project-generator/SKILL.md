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

## Supporting Artifacts
- Use `templates/mule-project/` as the source scaffold.
