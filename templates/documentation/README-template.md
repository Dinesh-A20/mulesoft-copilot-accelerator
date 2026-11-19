# <Application Name>

## Purpose
<Business purpose and integration scope>

## Architecture
API-led layer: `<experience|process|system>`

## Requirements
- Owner:
- Runtime:
- Environment:
- Dependencies:
- SLO:

## Configuration
Document secure property keys and secret-manager paths only; never include values.

## Build
```bash
mvn -B -ntp clean verify
```

## Run
```bash
mvn mule:run
```

## Test
Run MUnit from Maven and publish reports from `target/munit-reports`.

## Operations
Include health, logs, metrics, alarms, replay, rollback, and support contacts.
