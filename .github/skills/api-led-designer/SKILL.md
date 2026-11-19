---
name: api-led-designer
description: Designs Experience, Process, and System API layers and reusable API capabilities.
---

# API-Led Designer

## Trigger Conditions
- New or modernized APIs require API-led decomposition.
- Multiple Experience applications share Process or System capabilities.
- Ownership or reuse across domains must be established.

## Workflow Steps
1. Inventory consumers, capabilities, systems of record, and domains.
2. Map capabilities to Experience, Process, or System API ownership.
3. Separate transport/data models from canonical and vendor models.
4. Define dependencies and avoid cross-layer bypass.
5. Define reuse, versioning, rate, cache, and ownership policies.
6. Generate a target API inventory and ADR.

## Expected Outputs
- API-led capability map
- API inventory
- Dependency and ownership model
- Contract versioning plan
- Architecture decision record

## Validation Rules
- Experience APIs are client-focused, Process APIs are reusable, System APIs encapsulate sources.
- No credentials or vendor-specific models leak across layers.
- Circular and cross-layer dependencies are absent.

## Supporting Artifacts
- Use `api-inventory-template.csv` for deliverables.
