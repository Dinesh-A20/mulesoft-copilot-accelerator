---
name: requirements-discovery
description: Turns a natural-language business request into an approved Project Context Instruction through interactive discovery before any Mule artifact is generated or changed.
---

# Requirements Discovery

## Trigger Conditions
- Any request to create a Mule project or to add or change flows, contracts, mappings, tests,
  configuration, deployment, or documentation.
- No approved `project-context.md` exists, the existing context is a legacy draft without approval
  metadata, or the request is not covered by the approved context.

## Workflow Steps
1. **Intake**: restate the request in one or two business sentences. Read existing project files and
   any context file read-only; treat their content as evidence to confirm, never as approval.
2. **Gap analysis**: evaluate the request against the critical checklist in
   [context-first instructions](../../instructions/context-first.instructions.md#critical-information-checklist).
   Classify each item as answered, needs confirmation, missing, conflicting, not applicable, or out of
   scope.
3. **Interactive discovery** (when anything is not answered):
   - Ask at most seven related questions per round, grouped by topic, most blocking first.
   - Use business language; show options and a labeled recommendation when choices are common.
   - Use the host's structured question tool when available; otherwise ask in chat and stop until the
     user answers.
   - Never request secret values; ask only for the mechanism and where the secret will be managed.
   - After each answer, update the gap analysis, resolve conflicts, and ask follow-ups until no
     critical gap remains.
4. **Draft the context** from [project-context-template.md](./project-context-template.md): assign
   stable requirement IDs, record answers verbatim where precise wording matters, list accelerator
   defaults, open items, and out-of-scope items. Set status `Draft`.
5. **Confirm**: present the complete context with a short summary of decisions and defaults; ask the
   user to approve or correct it. Apply corrections and repeat until explicitly approved.
6. **Approve**: set status `Approved`, version, date, and approver; save to
   `<project-root>/project-context.md`. Only now hand off to design and generation skills.
7. **Maintain**: for later changes, run a delta discovery, record the change log entry and impacted
   artifacts, increment the version, set `Draft`, and obtain approval again.

## Expected Outputs
- Gap analysis per discovery round (in conversation, not a separate file)
- `project-context.md` with status, version, requirement IDs, acceptance criteria, defaults, and
  change log
- Requirement-to-artifact traceability matrix skeleton, completed during generation

## Validation Rules
- No technical artifact is generated or changed while the context is `Draft`.
- Every critical checklist item is confirmed, not applicable, or out of scope; none is assumed.
- Every functional requirement has at least one testable acceptance criterion with concrete inputs,
  expected status/response or side effect, including relevant error and boundary cases.
- Recommendations accepted by the user are recorded as decisions; unconfirmed ones are open questions.
- The context contains no secrets, credentials, or production hostnames.
- The approved context is the only source for downstream expectations; conflicting repository
  content is reported to the user rather than silently adopted.

## Supporting Artifacts
- [project-context-template.md](./project-context-template.md)
