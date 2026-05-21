# CODEX 5.5 #2 SUB-B — M2 Phase 1 — Track D batch 3 (flows 13-18, all PM0)

**Agent ID:** CODEX-2-SUB-B
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT.

---

## Governance — MANDATORY

1. Read `governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN as `CODEX-2-SUB-B`
3. HEARTBEAT every 5 min
4. CHECK-OUT + HANDOFF when done

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/comms/aq07_power_automate_build_20260515/execution_evidence/definition_PM0_PA_Card_AtualizarStatus.json
.planning/comms/aq07_power_automate_build_20260515/execution_evidence/definition_PM0_PA_Card_AtualizarTarefa.json
.planning/comms/aq07_power_automate_build_20260515/execution_evidence/definition_PM0_PA_Card_CriarTarefa.json
.planning/comms/aq07_power_automate_build_20260515/execution_evidence/definition_PM0_PA_Card_ListarTarefas.json
.planning/comms/aq07_power_automate_build_20260515/execution_evidence/definition_PM0_PA_Card_ResumoExecutivoPortfolio.json
.planning/comms/aq07_power_automate_build_20260515/execution_evidence/definition_PM0_PA_OpsFailureHandling.json
.planning/AGENT_CONTRACT.md
```

**Note:** PM0 flow definitions were captured during AQ-07 in M1. Cross-reference those files with current tenant state — verify nothing changed since 2026-05-15.

---

## Hard Constraints

- Read-only PAC + read-only file inspection.
- FILE LOCK before any write.

---

## Tasks — Flow Definitions Extract (batch 3: 6 of 18 — all PM0)

| # | Flow name | Workflow ID | Type |
|---:|---|---|---|
| D.13 | PM0_PA_Card_AtualizarStatus | 1721e0a3-a250-f111-bec7-000d3abc5cc6 | new |
| D.14 | PM0_PA_Card_AtualizarTarefa | 7c6300c2-a250-f111-bec7-000d3abc5cc6 | new |
| D.15 | PM0_PA_Card_CriarTarefa | 7f662db7-a250-f111-bec7-000d3abc5cc6 | new |
| D.16 | PM0_PA_Card_ListarTarefas | e0e3c6b0-a250-f111-bec7-000d3abc5cc6 | new |
| D.17 | PM0_PA_Card_ResumoExecutivoPortfolio | 8333bd91-a250-f111-bec7-000d3abc5cc6 | new |
| D.18 | PM0_PA_OpsFailureHandling | 9531fbc7-a250-f111-bec7-000d3abc5cc6 | new |

### Special analysis for PM0 flows

For each PM0 flow, also include:
- **Aderência ao padrão dual-entry hybrid** definido em ADR-M2-003 (will exist in Phase 2). For now, document if the flow currently has:
  - Single trigger entry vs dual (preview/submit)
  - Card post action (Teams)
  - SharePoint/Planner write actions
  - Static return string

- **Refactor effort estimate**: para cada PM0, classifique:
  - SMALL (1-2h): só tweaks
  - MEDIUM (3-4h): mudança estrutural mas factível
  - LARGE (6h+): rebuild quase completo

---

## Deliverables

- 6 × `definition_<flow_name>.json`
- 6 × `triggerSchema_<flow_name>.json`
- 6 × `outputSchema_<flow_name>.json`
- 6 × `flow_run_history_30d_<flow_name>.json`
- 1 × `PM0_REFACTOR_ANALYSIS.md` — per-PM0 effort estimate + dual-entry adherence

When done, signal CODEX-2-LEAD via HANDOFF_LOG.

---

## Time Budget

60 min hard limit.

---

## Begin

CHECK-IN → read references → extract + analyze 6 PM0 flows → CHECK-OUT + HANDOFF.
