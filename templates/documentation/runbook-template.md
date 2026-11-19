# Runbook: <Application>

## Ownership
- Business owner:
- Technical owner:
- Escalation:

## Health
- Health endpoint:
- Expected latency:
- Key metrics:

## Failure Modes
| Alarm | Impact | Diagnose | Mitigate | Replay |
|---|---|---|---|---|

## Deployment
Verify artifact version, environment, replica health, smoke test, and rollback trigger.

## Recovery
1. Stop side effects if replay would duplicate updates.
2. Isolate downstream dependency.
3. Correct configuration or replay tokens.
4. Replay in bounded batches.
5. Reconcile source and target records.
