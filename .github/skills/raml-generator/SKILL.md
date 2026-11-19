---
name: raml-generator
description: Generates RAML 1.0 contracts, resources, types, traits, examples, and reusable fragments.
---

# RAML Generator

## Trigger Conditions
- API contract design starts from business requirements.
- Existing RAML is incomplete or needs enterprise traits/fragments.
- OpenAPI compatibility is required for a governed RAML-first workflow.

## Workflow Steps
1. Derive resources, methods, status codes, headers, and media types.
2. Model reusable types and payload examples.
3. Add pagination, correlation, idempotency, and client credentials traits.
4. Add security schemes for OAuth2 and client ID enforcement.
5. Define consistent success and error responses.
6. Validate and package reusable fragments.

## Expected Outputs
- Main RAML
- Resource and data-type fragments
- Reusable traits and security schemes
- Request/response examples
- Contract validation report

## Validation Rules
- Every method has descriptions and success/error bodies.
- IDs, required fields, formats, and enums are explicit.
- `401`, `403`, `429`, and `500` responses are modeled.
- Contract examples serialize successfully.

## Supporting Artifacts
- Use `templates/raml-fragments/` for reusable patterns.
