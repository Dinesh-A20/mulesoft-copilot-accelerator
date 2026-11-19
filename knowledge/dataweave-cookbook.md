# DataWeave Cookbook

## Required Patterns

### Null and missing values
Use `default`, `null`, and explicit field projections. Convert source absence to target-defined defaults and never hide required-field violations.

### Pagination
Return a page projection and next-page metadata separately. Avoid loading all pages into memory unless the integration is explicitly batch-safe.

### Batch-friendly transformations
Use streaming and batch scopes for large collections. Enrich only fields needed by downstream APIs and limit lookups per record.

### Dates
Parse from explicit formats, convert to normalized UTC or offset-aware values, and document timezone at API boundaries.

### Conditional mappings
Prefer declarative `map`, `filter`, and `mapObject`; isolate complex functions in reusable `.dwl` modules.

### Safe conversion
Validate numbers, enums, dates, and identifiers. Use `try` for recoverable conversion failures and preserve source record identity for replay.

## Performance
Minimize payload depth and field projections, avoid repeated lookups, stream files, and benchmark representative payload sizes.
