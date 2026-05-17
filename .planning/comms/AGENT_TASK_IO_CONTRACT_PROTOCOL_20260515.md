# Agent Task I/O Contract Protocol

Date: 2026-05-15
Owner: CODEX-LEAD
Scope: all P0 Adaptive Cards + Planner agents
Release decision: NO-SHIP
Tenant execution by this artifact: none

## 1. Purpose

Every agent task must specify exactly what the agent receives, what it must produce, where it must write it, how it must validate it, and what status is allowed at handoff.

This protocol exists because ambiguous deliverables create rework. If an agent receives an underspecified task, the correct outcome is `BLOCKED_FOR_INPUT_CONTRACT`, not an invented artifact.

## 2. Mandatory Task Contract

Every new agent task or rework prompt must include these sections.

```text
TASK_ID:
OWNER:
AGENT:
GOAL:
READ_BEFORE_START:
INPUTS:
OUTPUTS:
WRITE_SCOPE:
DO_NOT_EDIT:
FORBIDDEN_ACTIONS:
DELIVERY_FORMAT:
VALIDATION_REQUIRED:
QUALITY_GATES_REQUIRED:
EVIDENCE_REQUIRED:
ACCEPTANCE_CRITERIA:
REJECTION_CRITERIA:
HANDOFF_STATUS_ALLOWED:
FINAL_RESPONSE_REQUIRED:
```

No task is considered dispatch-ready without all sections.

## 2.1 Mandatory Quality Gate Mapping

Every task must include `QUALITY_GATES_REQUIRED` and `EVIDENCE_REQUIRED`.

The gate mapping must state:

| Gate field | Required content |
|---|---|
| Gate ID | AQ/Gate identifier, for example AQ-07, AQ-09, XPIA, Card Static Validation |
| Gate type | Local validation, tenant read-only, tenant write, runtime smoke, release decision |
| Required evidence | Exact artifact, screenshot, run ID, export log, JSON parse result, CSV, or transcript |
| Blocking rule | What makes the gate `BLOCKED` or `NO-SHIP` |
| Owner approval needed | Yes/No and exact approval scope |
| Current status | READY, BLOCKED, PASS, FAIL, DONE, or NO-SHIP |

Minimum gate rules for every P0 task:

```text
QUALITY_GATES_REQUIRED:
- SEV-0: mandatory; CI may be ignored only if owner-excluded; all other gates are blocking.
- Scope gate: agent must stay inside WRITE_SCOPE and DO_NOT_EDIT.
- Access gate: no tenant access unless explicitly approved in the current thread.
- Output gate: outputs must match DELIVERY_FORMAT exactly.
- Validation gate: VALIDATION_REQUIRED must be executed and evidence recorded.
- Evidence gate: evidence must be current and tied to the current artifact.
- Security/output gate: no raw SharePoint/Planner rows, connector traces, stack traces, or unsafe output to Copilot.
- Release gate: default release decision is NO-SHIP until every non-CI gate is green.
```

If a task touches or prepares tenant runtime behavior, it must also include the relevant gate rows:

```text
- AQ-02 SharePoint read-only schema
- AQ-03 SharePoint schema write
- AQ-04 Planner ID discovery/readiness
- AQ-07 Power Automate save/import
- AQ-08 Copilot publish/update
- AQ-09 runtime smoke and XPIA regression
- AQ-10 final SHIP/NO-SHIP decision
```

If any quality gate is missing from a task where it applies, the task status is:

```text
BLOCKED_FOR_GATE_CONTRACT
```

## 3. Required Input Rules

`INPUTS` must list concrete files, IDs, schemas, route keys, cards, approvals, and evidence the agent must use.

Bad:

```text
Use the planning docs and prepare the flow package.
```

Good:

```text
INPUTS:
- AQ-03 SharePoint schema evidence:
  D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md
- AQ-04 Planner IDs:
  groupId = 96c5b0c4-46cc-46cd-8695-50451db74994
  planId = -1kBj1PLv0qQM-R4PwkqbpcABv_P
- Route keys:
  board.status, pmo.ops, pm.status.updates, task.card.route
- Cards:
  D:\VMs\Projetos\STT_Project_Management\deploy\cards\ResumoExecutivoPortfolio.json
```

If an input is unknown, the task must say:

```text
UNKNOWN_BLOCKER: <specific missing input>
```

The agent must not invent missing inputs.

## 4. Required Output Rules

`OUTPUTS` must list exact files or exact tenant evidence expected.

Each output must specify:

| Required field | Meaning |
|---|---|
| Path or evidence target | Exact local path or tenant evidence type |
| Format | Markdown, JSON, CSV, Power Automate package, screenshot, run ID, etc. |
| Required fields | Required headings, JSON keys, CSV columns, or evidence values |
| Validation | Parse command, static check, runtime proof, or manual review rule |
| Status impact | READY, BLOCKED, NO-SHIP, or PASS condition |

Bad:

```text
Create useful QA docs.
```

Good:

```text
OUTPUTS:
1. .planning/comms/AQ09_RUNTIME_EVIDENCE_MATRIX_20260515.md
   Format: Markdown table
   Required columns: Evidence ID, Scenario, Input, Expected Output, Actual Output, Run ID, Screenshot, PASS/BLOCK
   Validation: every row must have PASS or BLOCK; blank cells are rejection criteria.
```

## 5. Delivery Format Rule

The prompt must say whether the agent is producing:

| Format | Meaning |
|---|---|
| `LOCAL_DOC` | Planning or review document only |
| `LOCAL_JSON` | JSON artifact that must parse locally |
| `LOCAL_CSV` | CSV matrix with required columns |
| `IMPORTABLE_PACKAGE` | Artifact that can be imported/packed through a documented path |
| `PORTAL_BUILD_RUNBOOK` | Click-by-click portal build instructions with no omitted fields |
| `TENANT_EVIDENCE` | Screenshot, run ID, export log, or read-only/write evidence from approved tenant action |

If the task needs `IMPORTABLE_PACKAGE`, the agent must not deliver pseudocode and mark it ready.

If the agent cannot produce the required format, it must return:

```text
BLOCKED_REWORK_REQUIRED
Reason: cannot produce required DELIVERY_FORMAT because <specific reason>.
```

## 6. Validation Rules

Every task must define validation before handoff.

Examples:

| Artifact | Required validation |
|---|---|
| JSON | `ConvertFrom-Json` succeeds |
| Card JSON | parse succeeds, target size under 27 KB, required submit metadata present |
| CSV | required columns present and row count expected |
| Markdown runbook | required headings present; no `TBD`, `same as above`, or blank required fields |
| Power Automate build package | lane selected, manifest present, connection references mapped, action sequence complete |
| Tenant evidence | timestamp, actor, environment, ID, screenshot/run ID/export proof tied to current artifact |

If validation is missing, stale, or not tied to the current artifact, the status is:

```text
BLOCKED_VALIDATION_MISSING
```

## 7. Acceptance And Rejection

Every task must include objective acceptance criteria.

Required rejection criteria:

- missing required output file;
- output file in wrong path;
- invalid JSON/CSV where structured format is required;
- ambiguous terms such as `TBD`, `same as above`, `same context`, or `owner will decide` in required fields;
- tenant action claimed without evidence;
- tenant action performed outside approval;
- missing check-in update;
- output not tied to current AQ evidence;
- pseudocode delivered when `IMPORTABLE_PACKAGE` or `PORTAL_BUILD_RUNBOOK` was required.

Rejected work status:

```text
BLOCKED_REWORK_REQUIRED
```

Rejected work cannot be used to request owner approval for a tenant gate.

## 8. Handoff Status Values

Agents may use only these status values:

| Status | Meaning |
|---|---|
| `STARTED` | Agent has read the contract and begun |
| `IN_PROGRESS` | Agent is actively working |
| `BLOCKED_FOR_INPUT_CONTRACT` | Task lacks required input/output specificity |
| `BLOCKED_REWORK_REQUIRED` | Agent produced or found non-conforming work |
| `READY_FOR_CODEX_REVIEW` | All local outputs and validations are complete |
| `READY_FOR_OWNER_APPROVAL_REQUEST` | CODEX-LEAD review passed and a tenant approval request can be drafted |
| `DONE_LOCAL` | Local-only task complete |
| `DONE_TENANT_READONLY` | Approved read-only tenant task complete |
| `DONE_TENANT_WRITE` | Approved tenant write complete |

Agents must not use `deploy-ready`, `ship-ready`, or `production-ready` for P0 unless AQ-10 is complete.

## 9. Default Penalty / Gate Consequence

This project uses gate consequences, not subjective penalties.

Non-conforming delivery means:

```text
BLOCKED_REWORK_REQUIRED
NO-SHIP remains
No owner tenant approval request
Agent must rework against this I/O contract
```

Repeated non-conforming delivery from the same agent must be escalated in the check-in board with:

```text
ESCALATION_REQUIRED: repeated contract non-compliance by <agent>
```

## 10. Required Final Response

Every agent final answer must include:

```text
TASK_ID:
STATUS:
DELIVERY_FORMAT:
FILES_CHANGED:
VALIDATION_PERFORMED:
QUALITY_GATES:
EVIDENCE:
TENANT_ACTIONS_PERFORMED:
BLOCKERS:
NEXT_OWNER_DECISION_NEEDED:
```

If no tenant action happened, it must explicitly say:

```text
Tenant actions performed: none.
```

If any gate remains incomplete, it must explicitly say:

```text
Release decision: NO-SHIP.
Incomplete gates: <list>.
```
