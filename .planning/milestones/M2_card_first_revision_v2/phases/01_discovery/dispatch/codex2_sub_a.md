# CODEX 5.5 #2 SUB-A — M2 Phase 1 — Track D batch 2 (flows 7-12)

**Agent ID:** CODEX-2-SUB-A
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT. Use ONLY this prompt + referenced files + live PAC.

---

## Governance — MANDATORY

1. Read `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN to ACTIVITY_LOG + CHECKIN_BOARD as `CODEX-2-SUB-A`
3. HEARTBEAT every 5 min
4. CHECK-OUT + HANDOFF when done

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/AGENT_CONTRACT.md
```

---

## Hard Constraints

- Read-only PAC.
- Output to `phases/01_discovery/D_flow_definitions/`.
- FILE LOCK before write.
- No tenant writes.

---

## Tasks — Flow Definitions Extract (batch 2: 6 of 18)

| # | Flow name | Workflow ID | Type |
|---:|---|---|---|
| D.7 | PMO_PA_ExcluirProjeto | 16fbe313-2edc-406e-ad7f-d08cee0edc43 | legacy |
| D.8 | PMO_PA_ExcluirTarefa | 70b39334-5926-4fb1-bd22-f10bd99f0f6d | legacy |
| D.9 | PMO_PA_ListarTarefas | 9544f14b-3748-f111-bec7-6045bdf42cae | legacy |
| D.10 | PMO_PA_PedirDecisaoBot | feb79d54-c64c-f111-bec7-7ced8d955c6c | legacy |
| D.11 | PMO_PA_RegistrarBloqueioBot | 3ec37952-c64c-f111-bec7-000d3abc5cc6 | legacy |
| D.12 | PMO_PA_RegistrarRiscoBot | ee732d46-c64c-f111-bec7-7ced8d955c6c | legacy |

For each flow, extract: trigger schema, action graph, connections, output schema, 30d run history.

---

## Deliverables

- 6 × `definition_<flow_name>.json`
- 6 × `triggerSchema_<flow_name>.json`
- 6 × `outputSchema_<flow_name>.json`
- 6 × `flow_run_history_30d_<flow_name>.json`

When done, signal CODEX-2-LEAD via HANDOFF_LOG so they can compile master matrix.

---

## Time Budget

60 min hard limit.

---

## Begin

CHECK-IN → read references → extract 6 flows → CHECK-OUT + HANDOFF.
