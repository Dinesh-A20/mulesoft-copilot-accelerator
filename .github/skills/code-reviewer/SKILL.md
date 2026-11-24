---
name: code-reviewer
description: Reviews Mule XML, DataWeave, RAML, Maven, tests, and CI for enterprise quality.
---

# Code Reviewer

## Trigger Conditions
- Generated or modified Mule artifacts are ready for merge.
- Pull requests require standards validation.
- Static quality findings need triage.

## Workflow Steps
1. Review architecture and instruction adherence, including the [mandatory modular project layout](../../instructions/mulesoft.instructions.md#mandatory-modular-project-layout) and its file/flow reference map.
2. Validate XML structure, connector configuration schemas, APIKit route naming, and flow references.
3. Review DataWeave, error handling, security, and logging.
4. Validate MUnit coverage and test determinism.
5. Validate Maven coordinates/dependencies and run the configured build on the supported Mule/JDK versions.
6. Check that configured output path, written filename, and response contract agree.
7. Produce findings ranked by risk.

## Expected Outputs
- Review findings
- Standards compliance matrix
- Required and advisory fixes
- Verification commands

## Validation Rules
- Block when the Project Context Instruction is missing or not `Approved`, when changed behavior is not covered by it, or when flows, tests, configuration, or documentation lack requirement traceability.
- Findings reference exact files and behavior.
- No unrelated changes are included.
- Block completion for new or modified flows that violate the mandatory layout: business logic in main, multiple business flows per XML file, or mixed business/configuration files. Shared subflows may be grouped by capability in dedicated reusable files.
- Verify APIKit resource flows are in `main-flow.xml`, preserve registered names, and delegate through `flow-ref` to separate business files. Flag separate route XML files; check every required module loads and moved definitions were removed from their original files.
- Require MUnit evidence that entry/routing and real business modules work together without mocking their internal references; check that extraction preserved contracts, errors, variables, transactions, concurrency, and sources.
- High-risk security or data-loss issues block merge.
- A build is not reported as passing unless the Maven validation completes successfully; distinguish IDE diagnostics and warnings from build failures.
- APIkit flow names and connector config elements match the exact DSL supported by the pinned dependency versions.
- File Connector destinations are filesystem paths; they are not HTTP/Google Sheets URLs.
