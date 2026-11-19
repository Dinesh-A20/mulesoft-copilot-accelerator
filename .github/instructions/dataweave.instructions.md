---
applyTo: "**/*.dwl"
---
# DataWeave Instructions

## Purpose
Standardize maintainable, performant, and testable DataWeave 2.0 mappings.

## Scope
Transforms, reusable modules, schemas, null handling, date/time, payload conversion, and memory behavior.

## Mandatory Standards
- Use DataWeave 2.0.
- Preserve UTC for timestamps and document timezone assumptions.
- Normalize null, missing, and empty values explicitly.
- Do not expose PII unnecessarily.
- Validate required fields and enums.
- Keep mapping modules reusable and single-purpose.
- Stream payloads for large collections and file operations.

## Naming Conventions
- Function names use lower camelCase.
- Variables use lower camelCase.
- Module names use lower kebab-case.
- Mapping files use `.dwl` and map `<source>-to-<target>.dwl`.

## Best Practices
- Separate lookup, normalization, and projection concerns.
- Use `try` only for known conversion/error cases.
- Prefer declarative maps over imperative branching.
- Test boundary values and locale/number formatting.
- Keep payload projections minimal.

## Anti-Patterns
- Repeating large nested transformations.
- Unbounded `flatMap` memory growth.
- Implicit timezone conversion.
- Business logic hidden inside one monolithic transformation.
- String concatenation for XML/JSON/date values.

## Review Checklist
- [ ] Required and nullable fields are explicit.
- [ ] Date and numeric formats are deterministic.
- [ ] Mapping is streamed when appropriate.
- [ ] Sensitive fields are minimized.
- [ ] MUnit fixtures cover mapping edge cases.
