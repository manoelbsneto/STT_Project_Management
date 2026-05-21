# CODEX 5.5 #1 SUB-C — M2 Phase 1 — Tracks A.5 + H

**Agent ID:** CODEX-1-SUB-C
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT. Use ONLY:
1. This prompt
2. Files in `Mandatory Read-Before-Start`
3. Topic YAML data captured by CODEX-1-LEAD (Track A.1)

---

## Governance — MANDATORY (governance kit added 2026-05-20 18:14)

1. Read `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN to `governance/ACTIVITY_LOG.md` + `governance/CHECKIN_BOARD.md` as `CODEX-1-SUB-C`
3. HEARTBEAT every 5 min
4. FILE LOCK before writes (in `governance/FILE_LOCK_TABLE.md`)
5. CHECK-OUT + HANDOFF when done

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/comms/topic_remediation_20260520/as_is/atualizarstatus.yml
.planning/comms/topic_remediation_20260520/as_is/atualizartarefa.yml
.planning/comms/topic_remediation_20260520/as_is/criartarefa.yml
.planning/comms/topic_remediation_20260520/as_is/listartarefas.yml
.planning/AGENT_CONTRACT.md
```

Confirm references read.

---

## Hard Constraints

- Read-only file inspection + read-only PAC.
- No tenant writes.
- Output to `phases/01_discovery/A_dataverse_inventory/` (for A.5) and `phases/01_discovery/H_risks_constraints/` (for H).
- Update check-in board every 5 minutes.

---

## Tasks

### Task A.5 — Copilot Studio Topic Errors RCA

The current Copilot Studio UI shows "1 error" on each of 12 topics, plus "5 errors" on CriarProjeto. This is suspected to be either:
- Power Fx parser issues with regex patterns
- Connection reference orphans after 3.15 import
- Schema validation issues

For each of the 12 user-facing topics:

1. Read its YAML body (from CODEX-1-LEAD output `topic_inventory.json` field `data`, OR from already-extracted files in `.planning/comms/topic_remediation_20260520/as_is/` for 4 of them).
2. Static-analyze:
   - Check Power Fx expressions for syntax issues (especially regex character classes)
   - Check for stale `flowId` references that don't match active workflow IDs (cross-reference with Track A.2 output `workflow_inventory.json`)
   - Check for `BeginDialog dialog: pmo_AssistentePMO_V2.action.PMO_PA_*` references where the action component might be deactivated
3. Identify the most likely root cause per topic.

Output `INVENTORY_TOPIC_ERRORS_RCA.md`:

```markdown
| Topic | Error count (UI) | Root cause hypothesis | Evidence | Proposed fix in M2 |
|---|---:|---|---|---|
| AtualizarStatus | 1 | flowId c11a165b-c64c-f111-bec7-7ced8d9559c1 (PMO_PA_AtualizarStatus) might have orphan connection ref post-3.15 import | YAML line 87 | Replace with PM0_PA_Card_AtualizarStatus binding (M2 Phase 5) |
| ...
| CriarProjeto | 5 | Multi-issue: regex character class + Power Fx variable scope + complex condition group | YAML lines 23, 45, 67, 89, 112 | Refactor regex + simplify condition tree (M2 Phase 5) |
```

Per topic, include:
- The exact line number in YAML where the issue is
- Whether it's a Phase 5 (topic update) issue or Phase 4 (flow build) issue or Phase 6 (schema) issue
- Severity: P0 (blocks publish) / P1 (blocks runtime) / P2 (cosmetic)

### Task H — Risk & Constraint Inventory

#### H.1 — Connector Quotas Analysis

Document current Microsoft Standard tier limits for:
- **SharePoint Standard**: API call limits, item count thresholds, list size limits
- **Teams Standard**: PostCardInChat rate limits, channel post limits
- **Planner Standard**: CreateTask/UpdateTask/ListTasks rate limits
- **Power Virtual Agents Standard**: Skills invocation limits
- **Power Automate Standard**: Flow run limits per environment

For each connector, estimate per-flow call frequency in production:

```markdown
| Connector | Standard limit | Per-flow calls/day | Risk | Mitigation |
|---|---|---|---|---|
| SharePoint | 600 calls/min | CriarTarefa: ~20/day | Low | None needed |
| Teams PostCard | 4 messages/sec | All ops: ~50/day total | Low | None needed |
| Planner | varies | CriarTarefa+AtualizarTarefa: ~30/day | Low | None needed |
| ... |
```

Save as `connector_quota_analysis.json` + `INVENTORY_QUOTA_RISKS.md`.

#### H.2 — Tenant Policy Review

Search for any tenant-level changes in last 60 days that could affect M2:
- Conditional access policy changes
- DLP (data loss prevention) policy updates
- Retention policy changes
- Connector tenant-level enable/disable
- Power Platform environment-level governance changes

Sources:
- `.planning/comms/` for any owner notes about tenant changes
- `.planning/STATE.md` for documented tenant config
- Any references in `docs/` to tenant policy

If you cannot determine specific changes (no admin access, read-only constraint), document what WOULD need to be checked and recommend Owner verification.

Save as `INVENTORY_TENANT_CHANGES.md`.

---

## Deliverables

```
phases/01_discovery/A_dataverse_inventory/
└── INVENTORY_TOPIC_ERRORS_RCA.md

phases/01_discovery/H_risks_constraints/
├── connector_quota_analysis.json
├── INVENTORY_QUOTA_RISKS.md
└── INVENTORY_TENANT_CHANGES.md
```

---

## Time Budget

45 minutes total.
- Task A.5: 25 min (depends on Track A.1 output being available — coordinate with CODEX-1-LEAD)
- Task H: 20 min

---

## Coordination

A.5 needs CODEX-1-LEAD's `topic_inventory.json` (Track A.1). Wait for that output. Meanwhile, start H.1 + H.2 (independent).

When done, post "Tracks A.5 + H DONE" in check-in board.

---

## Begin

1. Confirm 8 references read.
2. Claim Tracks A.5 + H in check-in board.
3. Execute H.1 + H.2 first (no dependency), then A.5 when Track A.1 lands.
4. Submit + notify CODEX-1-LEAD.
