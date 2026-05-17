# Lessons Learned: AQ-07 Agent Delivery Rework

Date: 2026-05-15
Prepared by: CODEX-LEAD
Scope: Gemini AQ-07 Power Automate build package rework loop
Release decision: NO-SHIP
Tenant execution by this artifact: none

## 1. Summary

The AQ-07 Power Automate build package required repeated rework cycles before approaching a usable portal-build runbook. The review exposed two different problems:

1. Initial task requirements were too permissive for AQ-07.
2. After requirements were tightened, Gemini still missed concrete acceptance criteria that should have been caught by local self-validation.

This is not acceptable for future P0 work. Agent tasks must be dispatched with strict input/output contracts, and agents must validate against the exact contract before handoff.

## 2. What Happened

Gemini first delivered a local Power Automate package that was useful as planning material but not usable for AQ-07 because it remained pseudocode/local documentation.

CODEX then created a stricter AQ-07 corrective prompt requiring either:

- `IMPORTABLE_PACKAGE`, or
- `PORTAL_BUILD_RUNBOOK`

Gemini selected `PORTAL_BUILD_RUNBOOK`, but repeated review found several blockers:

| Review cycle | Main issue | Result |
|---|---|---|
| Initial final package review | Artifact was `local-pseudocode-not-importable` | BLOCKED |
| AQ-07 package review | Wrong route keys: `task.list`, `task.create`, `task.update`, `ops.failure` | BLOCKED |
| Route-key rework review | Route keys fixed, but Planner create/update inputs remained ambiguous | BLOCKED |
| Exact Planner inputs review | Planner inputs improved, but FI-04 omitted required SharePoint fields | BLOCKED |
| SharePoint required fields review | Required fields added, but SharePoint `Status` hard-coded to `Pendente` while bucket can map elsewhere | BLOCKED |

The final unresolved issue at this point is not syntax. It is consistency: FI-04 must map the selected Planner bucket to the same SharePoint `Status`.

## 3. Root Cause Assessment

### 3.1 Requirement Design Issues

The early prompt allowed:

```text
Draft local flow definition JSON or pseudocode artifacts
```

That was acceptable for AQ-05 planning, but not AQ-07 build preparation.

Impact:

- Gemini could satisfy the prompt while still producing an artifact that could not support tenant save/import.
- CODEX had to convert, tighten, and reject output after the fact.
- The team lost time because "ready" did not mean "build-ready".

Corrective action already applied:

- Created `.planning/comms/AGENT_TASK_IO_CONTRACT_PROTOCOL_20260515.md`.
- Updated `.planning/comms/AGENTIC_DISPATCH_PROMPTS_ADAPTIVE_CARDS_PLANNER_20260514.md`.
- Updated `.planning/AGENT_CONTRACT.md`.
- Added mandatory `QUALITY_GATES_REQUIRED` and `EVIDENCE_REQUIRED`.

### 3.2 Agent Execution Issues

After the corrective prompt became explicit, Gemini still missed items that were directly stated or inferable from required evidence:

- Used non-approved route keys even though approved route keys were already known.
- Marked route-key acceptance PASS without checking exact allowed values.
- Declared Planner `ListTasks_V3` in manifest while the flow used SharePoint `GetItems`.
- Used ambiguous placeholders like target bucket behavior rather than exact portal-build fields.
- Created SharePoint item behavior without required fields from the live schema.
- Hard-coded SharePoint status despite variable Planner bucket mapping.

Impact:

- Repeated rework.
- Review had to catch basic contract mismatches.
- The work behaved like junior delivery: superficially complete, but not validated against operational consequences.

Corrective stance:

- Treat these as objective gate failures, not subjective style disagreements.
- Non-conforming output remains `BLOCKED_REWORK_REQUIRED`.
- No owner approval can be requested from blocked output.

## 4. Process Defects Identified

| Defect | Severity | Why it matters | Fix |
|---|---|---|---|
| Task allowed pseudocode where build package was needed | High | Created false readiness | Require `DELIVERY_FORMAT` and block wrong format |
| Acceptance did not validate exact route key values | High | Would break Copilot routing | Require allowed-value validation |
| Agent did not reconcile manifest vs flow file | High | Build instructions contradicted package metadata | Require cross-file consistency checks |
| Agent did not validate SharePoint required fields before create-item flow | High | Runtime write would fail | Require schema evidence mapping for every write |
| Agent did not preserve semantic consistency between Planner bucket and SharePoint status | High | Runtime data would be inconsistent | Require field-to-field consistency mapping |
| Validation used broad PASS statements | Medium | Hid gaps behind generic validation | Require evidence-specific validation rows |

## 5. New Rules For Future Agent Tasks

Every task must include:

```text
TASK_ID
OWNER
AGENT
GOAL
READ_BEFORE_START
INPUTS
OUTPUTS
WRITE_SCOPE
DO_NOT_EDIT
FORBIDDEN_ACTIONS
DELIVERY_FORMAT
VALIDATION_REQUIRED
QUALITY_GATES_REQUIRED
EVIDENCE_REQUIRED
ACCEPTANCE_CRITERIA
REJECTION_CRITERIA
HANDOFF_STATUS_ALLOWED
FINAL_RESPONSE_REQUIRED
```

Every agent must block itself when requirements are missing:

```text
BLOCKED_FOR_INPUT_CONTRACT
BLOCKED_FOR_GATE_CONTRACT
```

Every agent must block its own output when validation fails:

```text
BLOCKED_REWORK_REQUIRED
```

## 6. Minimum Validation Standard

For any flow/build task, validation must include:

| Validation | Required |
|---|---|
| Required files exist | Yes |
| Structured files parse | Yes |
| Approved route keys only | Yes |
| Manifest matches flow files | Yes |
| Card actions match flow dispatch | Yes |
| Required SharePoint fields populated for writes | Yes |
| Planner IDs come from AQ-04 only | Yes |
| Planner bucket/status mapping is consistent | Yes |
| No raw SharePoint/Planner output to Copilot | Yes |
| No tenant actions without approval | Yes |
| Quality gates mapped and current | Yes |

Generic statements like `known gaps: none` are not acceptable unless backed by specific validation rows.

## 7. How To Review Similar Agent Output

CODEX-LEAD should review in this order:

1. Check handoff status and check-in compliance.
2. Verify required files exist.
3. Parse structured artifacts.
4. Search for forbidden placeholders and invalid route keys.
5. Validate route/action/card/flow consistency.
6. Validate SharePoint writes against live schema evidence.
7. Validate Planner operations against AQ-04 IDs.
8. Validate semantic consistency across systems.
9. Confirm quality gates and evidence are current.
10. Only then consider owner approval request.

## 8. Future Prompting Guidance

Prompts must avoid vague verbs:

- "prepare"
- "draft"
- "describe"
- "make actionable"
- "align"

Unless paired with exact output format and acceptance criteria.

Prompts should instead say:

```text
Create exactly these files.
Use exactly these route keys.
Use exactly these columns.
Use exactly this status mapping.
Validation must fail if any of these strings remain.
Final status must be BLOCKED_REWORK_REQUIRED if any required field is missing.
```

## 9. Accountability Model

This project should avoid vague "penalties" and use gate consequences:

| Behavior | Consequence |
|---|---|
| Task contract missing | `BLOCKED_FOR_INPUT_CONTRACT` |
| Gate/evidence mapping missing | `BLOCKED_FOR_GATE_CONTRACT` |
| Wrong delivery format | `BLOCKED_REWORK_REQUIRED` |
| Local validation missing or false | `BLOCKED_REWORK_REQUIRED` and escalation note |
| Repeated non-compliance | `ESCALATION_REQUIRED` in check-in board |
| Tenant action outside approval | Stop work, preserve evidence, escalate immediately |

## 10. Action Items

| ID | Action | Owner | Status |
|---|---|---|---|
| LL-01 | Require I/O contract for every new task | CODEX-LEAD | DONE |
| LL-02 | Require quality gate and evidence mapping for every task | CODEX-LEAD | DONE |
| LL-03 | Use `BLOCKED_FOR_INPUT_CONTRACT` for underspecified prompts | All agents | ACTIVE |
| LL-04 | Use `BLOCKED_REWORK_REQUIRED` for non-conforming output | CODEX-LEAD | ACTIVE |
| LL-05 | For AQ-07, continue blocking until FI-04 status mapping is fixed | CODEX-LEAD | ACTIVE |
| LL-06 | Run a short lessons learned session before next multi-agent dispatch | Owner + CODEX-LEAD | PENDING |

## 11. Current Status

AQ-07 remains:

```text
BLOCKED_REWORK_REQUIRED
```

Release remains:

```text
NO-SHIP
```

No tenant actions were performed while creating this lessons learned artifact.

