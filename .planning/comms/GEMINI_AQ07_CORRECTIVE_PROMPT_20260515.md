# Gemini Corrective Prompt: AQ-07 Power Automate Build Package

Date: 2026-05-15
Prepared by: CODEX-LEAD
Purpose: force an AQ-07-ready delivery format after prior Gemini output remained pseudocode-only.
Release decision: NO-SHIP

## Copy/Paste Prompt

```text
You are GEMINI-PA, continuing the PMO Intelligent Hub Adaptive Cards + Planner P0 delivery.

This is a corrective AQ-07 build-preparation task.

Context:
- Your previous package was reviewed by CODEX-LEAD.
- It is usable as planning input, but it is NOT sufficient for AQ-07 because it is still `local-pseudocode-not-importable`.
- Do not mark anything deploy-ready, import-ready, or AQ-07-ready unless this prompt's required output contract is satisfied.
- A non-conforming delivery remains BLOCKED / NO-SHIP and must be reworked.

Before doing any work, read:
1. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
2. D:\VMs\Projetos\STT_Project_Management\.planning\comms\CODEX_REVIEW_GEMINI_FINAL_P0_FLOW_PACKAGE_20260515.md
3. D:\VMs\Projetos\STT_Project_Management\.planning\comms\P0_OWNER_APPROVAL_QUEUE_ADAPTIVE_CARDS_PLANNER_20260514.md
4. D:\VMs\Projetos\STT_Project_Management\.planning\comms\P0_REMAINING_GATES_EXECUTION_RUNBOOK_20260515.md
5. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md
6. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md
7. D:\VMs\Projetos\STT_Project_Management\.planning\comms\P0_CARD_FLOW_ACTION_CONTRACT_FIX_20260515.md
8. D:\VMs\Projetos\STT_Project_Management\.planning\comms\SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
9. D:\VMs\Projetos\STT_Project_Management\deploy\cards\

Mandatory check-in:
- Update D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md before edits.
- Update it again after edits.
- If blocked, write the blocker immediately.

Hard boundaries:
- Work locally only.
- Do not execute tenant actions.
- Do not save/import Power Automate flows.
- Do not publish Copilot Studio.
- Do not write SharePoint.
- Do not write Planner.
- Do not post Teams production messages.
- Do not use Microsoft 365 CLI / m365.

Allowed write scope:
- Create or update files only under:
  D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\
- You may also append status to:
  D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md

Do not edit card JSON, Copilot topic files, production deploy folders, tests, or tenant resources.

Task:
Produce an AQ-07 build package that CODEX-LEAD can review without guessing.

You must choose exactly one delivery lane:

LANE A - IMPORTABLE_PACKAGE
- Use this only if you can produce a local package/source structure that is actually importable or packable through a documented Power Platform/Solution path.
- Include exact pack/import commands or exact portal import steps.
- Include every expected generated file.
- Include connection reference mapping.

LANE B - PORTAL_BUILD_RUNBOOK
- Use this if you cannot produce an importable package locally.
- This is acceptable only if it is a complete, click-by-click/action-by-action build manual for Power Automate portal execution.
- It must be detailed enough that the owner can build each flow without interpretation.

Required output files:

1. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\AQ07_DELIVERY_DECISION.md

Must contain:
- Selected lane: IMPORTABLE_PACKAGE or PORTAL_BUILD_RUNBOOK.
- Reason for lane selection.
- Explicit statement: "This is local build preparation only. No tenant write was performed."
- Explicit statement: "AQ-07 tenant save/import still requires owner approval."
- Whether the package is executable as-is or requires portal manual build.

2. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\PACKAGE_MANIFEST.json

Must be valid JSON and include:
- packageName
- packageDate
- selectedLane
- releaseDecision = "NO-SHIP"
- tenantWritesPerformed = false
- flows array with one object per flow:
  - flowKey
  - displayName
  - routeKey
  - cardTemplates
  - triggerType
  - connectorDependencies
  - sharePointLists
  - plannerOperations
  - teamsOperations
  - copilotReturnContract
  - buildFile
  - acceptanceStatus

3. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\CONNECTION_REFERENCES.md

Must map:
- SharePoint connection
- Teams connection
- Planner connection `shared_planner`
- Power Automate environment `ColOfertasBrasilPro`
- Tenant ID `7808e005-1489-4374-954b-d3b08f193920`
- Known site/list dependencies
- What must be verified by owner during AQ-07

4. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\FIELD_MAPPING.md

Must include:
- SharePoint list `Tarefas`
- All existing Planner mapping fields from AQ-03:
  - PlannerTaskId
  - PlannerBucketId
  - PlannerSyncStatus
  - PlannerLastSyncAt
  - PlannerSyncError
- Required mapping behavior:
  - never trust client-submitted `plannerTaskId`
  - resolve PlannerTaskId server-side from SharePoint item
  - sanitize PlannerSyncError
  - map card status values to live SharePoint choices
  - map bucket status to canonical bucket IDs from AQ-04

5. One build file per flow under:
   D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\flows\

Required files:
- FI-01_PM0_PA_Card_ResumoExecutivoPortfolio.md
- FI-02_PM0_PA_Card_AtualizarStatus.md
- FI-03_PM0_PA_Card_ListarTarefas.md
- FI-04_PM0_PA_Card_CriarTarefa.md
- FI-05_PM0_PA_Card_AtualizarTarefa.md
- FI-06_PM0_PA_OpsFailureHandling.md

Each flow file must use this exact structure:

## Identity
- Flow key
- Display name
- Purpose
- Route key
- Card templates
- Owner approval required before tenant save/import: yes

## Trigger
- Exact trigger type
- Expected Copilot or manual input schema
- Required fields
- Optional fields
- Validation rules

## Variables
List every initialized variable with:
- name
- type
- default value
- source
- validation

## Actions
Number every Power Automate action in execution order.
For each action include:
- action name as it should appear in Power Automate
- connector
- operationId when known
- input parameters
- expressions
- run-after behavior
- success output shape
- failure behavior

## SharePoint Behavior
- list name
- filter queries
- top limits
- selected columns
- write order
- idempotency behavior
- no raw row output to Copilot

## Planner Behavior
- operationId
- groupId `96c5b0c4-46cc-46cd-8695-50451db74994`
- planId `-1kBj1PLv0qQM-R4PwkqbpcABv_P`
- bucket IDs from AQ-04
- conditional create/update path
- exact fields to write
- error sanitization
- no Planner write unless this specific flow behavior is later approved in AQ-07/AQ-09

## Teams/Card Behavior
- route key
- target route
- card template
- submit payload expected from card
- action dispatch rule: routeKey + action
- operationId is correlation ID only, not action selector

## Copilot Return Contract
- exact static ASCII response string
- max length
- no raw SharePoint output
- no raw Planner output
- no stack trace

## Evidence To Capture During AQ-07/AQ-09
- flow ID
- run ID
- screenshots
- input sample
- output sample
- before/after evidence for writes
- error evidence if failed

## Rollback
- disable/revert path
- what to preserve
- what not to delete without separate approval

6. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\CARD_ACTION_BINDING_MATRIX.csv

CSV columns:
flowKey,routeKey,action,operationIdUsage,cardTemplate,expectedInputs,serverSideLookup,tenantWriteDuringBuild,tenantWriteDuringRuntime,acceptance

Required rules:
- operationIdUsage must be `correlation-only`
- serverSideLookup must be `yes` for any PlannerTaskId usage
- tenantWriteDuringBuild must be `no`

7. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\AQ07_ACCEPTANCE_MATRIX.md

Must contain a pass/fail table for:
- all required files exist
- manifest JSON parses
- each flow has exact action sequence
- each flow has route key
- each flow has static ASCII Copilot return
- no raw SharePoint/Planner output to Copilot
- Planner IDs from AQ-04 used
- SharePoint fields from AQ-03 used
- no hard-coded unknown bucket IDs
- no client-submitted PlannerTaskId trusted
- no tenant writes performed
- AQ-07 remains blocked until owner approval

8. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\VALIDATION.md

Must include:
- local validation steps performed
- JSON parse result for PACKAGE_MANIFEST.json
- ASCII check result for app-facing Copilot responses
- checklist of files created
- known gaps
- final status:
  - READY_FOR_CODEX_REVIEW if all required files exist and pass local validation
  - BLOCKED_REWORK_REQUIRED otherwise

9. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\QUALITY_GATES.md

Must include a gate table with:
- gateId
- gateType
- requiredEvidence
- currentStatus
- blockerIfMissing
- ownerApprovalNeeded
- relatedOutputFile

Required gates:
- SEV-0 mandatory gate
- Scope/write-scope gate
- No tenant action gate
- AQ-03 SharePoint schema evidence gate
- AQ-04 Planner ID evidence gate
- AQ-06 static validation refresh gate
- AQ-07 build/import readiness gate
- AQ-08 Copilot publish dependency gate
- AQ-09 runtime smoke/XPIA dependency gate
- AQ-10 release decision gate

The file must state:

```text
Release decision: NO-SHIP until AQ-07, AQ-08, AQ-09, and AQ-10 have current evidence.
```

Quality bar:
- Do not deliver generic pseudocode.
- Do not say "same as above", "same context", "TBD", "to be configured", or "owner will decide" for any required field.
- If a value is unknown, write `UNKNOWN_BLOCKER: <specific missing value>` and mark final status BLOCKED_REWORK_REQUIRED.
- Do not mark READY_FOR_CODEX_REVIEW if any UNKNOWN_BLOCKER remains.
- Do not invent tenant evidence.
- Do not claim a tenant action happened.

Final answer:
- List exact files changed.
- State selected lane.
- State final status.
- State quality gates reviewed and incomplete gates.
- State explicitly that no tenant writes were performed.
```

## CODEX-LEAD Rationale

The prior Gemini task accepted "JSON or pseudocode artifacts" as a deliverable. That language was too permissive for AQ-07. The corrective prompt above changes the acceptance target from "planning content" to an auditable build package with required file names, schemas, lane selection, validation, and BLOCK/READY criteria.

Non-conformance is handled as a gate consequence, not a subjective penalty:

```text
Non-conforming delivery = BLOCKED_REWORK_REQUIRED + NO-SHIP + no AQ-07 approval request.
```
