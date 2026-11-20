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
7. Trace each transform's actual input and media type through the flow; preserve source data in a connector target variable when later steps replace the payload.

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
- Validate collection types before mapping; an Object cannot be made an Array with `as Array`. Do not hide unexpected input with `default []` or accept output-shaped objects as source records.
- XLSX input records and output workbook objects are different contracts: map raw records once into `{SheetName: [rowObjects]}` and serialize once. Reference the explicit source variable consistently in counting and mapping.
- Qualify non-core functions such as `dw::Runtime::fail`, or import them from their defining module.
- XLSX tests force serialization and read the binary back to assert worksheet names, columns, values, nulls, and empty-result behavior; a successful mocked file write alone is insufficient.
- File "append/update" for XLSX is read-merge-rewrite: read the existing sheet, normalize cell values to strings, upsert by a stable business key (update in place, append new keys, keep untouched rows), drop placeholder rows with an empty key, then serialize the whole workbook once. Document that other sheets, formulas, and formatting are not preserved.
- Keep merge, query-building, and watermark logic in an importable module (for example `dwl::AccountWorkbook`) so MUnit and the DataWeave CLI can test functions directly.
- Build dynamic SOQL only from typed or validated values: format DateTimes as UTC literals (`yyyy-MM-dd'T'HH:mm:ss'Z'`, normalize `+0000` offsets before coercion) and pattern-validate Ids before quoting; fail instead of escaping untrusted text.
- Incremental watermarks use keyset ordering on `(timestamp, Id)` with `>`/`=`+`Id >` predicates so a capped page never skips or loops on records sharing a timestamp.
- Time-zone shifts use TimeZone literals (`>> |+00:00|`), not strings; nullable branches must still type-check as DateTime.

## Supporting Artifacts
- Use `templates/mule-project/src/main/resources/dwl/` patterns.
