---
name: dataweave-generator
description: Generates DataWeave 2.0 mappings, reusable modules, schemas, and mapping tests.
---

# DataWeave Generator

## Trigger Conditions
- Source and target models require field or format transformation.
- Data normalization or enrichment is required.
- A transformation is too complex or reusable for an inline expression.

## Workflow Steps
1. Compare source/target schemas and mappings.
2. Define null, default, enum, date, number, and locale behavior.
3. Generate reusable transformation modules.
4. Minimize payload fields and redact sensitive values.
5. Add streaming or batch-aware mappings when needed.
6. Create MUnit fixtures and assertions.

## Expected Outputs
- Mapping `.dwl` files
- Reusable DataWeave modules
- Mapping specification
- Positive and edge fixtures

## Validation Rules
- Mapping has no implicit timezone or locale.
- Required and nullable fields are explicit.
- Large collections use streaming or batch patterns.
- Output conforms to target schema/examples.

## Supporting Artifacts
- Use `templates/mule-project/src/main/resources/dwl/` patterns.
