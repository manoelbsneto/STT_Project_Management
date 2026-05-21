# OPUS 4.7 #2 — M2 Phase 1 — Tracks E + F (Routing + Topic YAMLs)

**Agent ID:** OPUS-2
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery
**Coordination:** You are the second Opus 4.7 instance. The lead Opus 4.7 (OPUS-LEAD) is in the main owner chat orchestrating the project.

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT. Use ONLY this prompt + referenced files + live tenant state via PAC + Teams Standard read-only test calls.

---

## Governance — MANDATORY

1. Read `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN as `OPUS-2`
3. HEARTBEAT every 5 min
4. CHECK-OUT + HANDOFF when done

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/decisions/ADR-M2-001-routing-matrix.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/comms/aq08_topic_routing_verification_20260520/AQ08_TOPIC_ROUTING_VERIFICATION.md
.planning/comms/topic_remediation_20260520/as_is/atualizarstatus.yml
.planning/comms/topic_remediation_20260520/as_is/atualizartarefa.yml
.planning/comms/topic_remediation_20260520/as_is/consultarportfolio.yml
.planning/comms/topic_remediation_20260520/as_is/criartarefa.yml
.planning/comms/topic_remediation_20260520/as_is/listartarefas.yml
.planning/STATE.md
.planning/AGENT_CONTRACT.md
```

Confirm in CHECK-IN: "references read: 13/13"

---

## Hard Constraints

- Read-only operations.
- PAC for Dataverse, Teams Standard connector test calls only for channel validation.
- No tenant writes anywhere.
- FILE LOCK before any write to output folders.
- Output to `phases/01_discovery/E_routing_inventory/` and `phases/01_discovery/F_topic_yamls/`.

---

## Tasks

### Track E — Routing & Channels Inventory

#### E.1 — Validate channel/group IDs are live

Verify these IDs resolve and are accessible from Power Automate Standard tenant connections:

| Type | ID | Expected name |
|---|---|---|
| Group | `96c5b0c4-46cc-46cd-8695-50451db74994` | Projetos_Tranformação_Digital |
| Channel | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | Projetos_Tranformação_Digital |
| Channel | `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` | QA_Projetos |
| User | `mbenicios@minsait.com` | Owner |

Approach:
- Use PAC to query connection references for Teams connectors and verify they're configured for the right tenant.
- For each channel, attempt a read-only test (e.g., list messages or get channel info) — but only if your tooling supports it without `m365`/Graph.
- If you cannot validate live (read-only constraints), document what WAS checked vs what would need owner verification.

Output:
- `channel_validation.json` — structured result per ID
- `INVENTORY_CHANNELS.md` — human-readable confirmation matrix

#### E.2 — Per-flow routing inspection

For each of the 6 PM0 flows (definitions extracted by CODEX-2-SUB-B in Track D batch 3), look at the flow's Teams "Post adaptive card" action and extract the hard-coded:
- groupId
- channelId

Compare against ADR-M2-001 expected values.

Output:
- `INVENTORY_ROUTING_PER_FLOW.md` — matrix showing per-flow vs ADR expected

If discrepancies found, flag them in the doc + ACTIVITY_LOG with severity (P0/P1/P2).

### Track F — Topic YAML Extraction

For 16 topics (12 user-facing + 4 system), extract clean YAML from `botcomponent.data` field.

5 are already extracted in `.planning/comms/topic_remediation_20260520/as_is/`. Verify those are byte-identical to current tenant state. If yes, copy to your output folder. If different, re-extract.

The 11 missing topics:
1. ConsultarProjeto
2. CriarProjeto
3. ExcluirProjeto
4. ExcluirTarefa
5. PedirDecisao
6. RegistrarBloqueio
7. RegistrarRisco
8. Greeting (system)
9. LowConfidence (system)
10. SeHouverErro (system)
11. Gerar_Multiplos_Projetos (system)

Output: `phases/01_discovery/F_topic_yamls/<TopicName>.yaml` (one per topic, 16 total).

Plus `INVENTORY_TOPIC_YAMLS.md` with summary:
- Per-topic byte size
- Per-topic line count
- Per-topic kind (user-facing / system)
- Per-topic last modified date
- Per-topic flow IDs invoked (if applicable)

---

## Deliverables

```
phases/01_discovery/E_routing_inventory/
├── channel_validation.json
├── INVENTORY_CHANNELS.md
└── INVENTORY_ROUTING_PER_FLOW.md

phases/01_discovery/F_topic_yamls/
├── AtualizarStatus.yaml
├── AtualizarTarefa.yaml
├── ConsultarPortfolio.yaml
├── ConsultarProjeto.yaml
├── CriarProjeto.yaml
├── CriarTarefa.yaml
├── ExcluirProjeto.yaml
├── ExcluirTarefa.yaml
├── ListarTarefas.yaml
├── PedirDecisao.yaml
├── RegistrarBloqueio.yaml
├── RegistrarRisco.yaml
├── Greeting.yaml
├── LowConfidence.yaml
├── SeHouverErro.yaml
├── Gerar_Multiplos_Projetos.yaml
└── INVENTORY_TOPIC_YAMLS.md
```

---

## Time Budget

75 min total:
- Track E: 30 min
- Track F: 45 min

Track F is your bottleneck. Start it first if possible (parallel with E.1).

---

## CHECK-OUT

```
[TIMESTAMP] CHECKOUT | OPUS-2 | tracks E + F | status: DONE | deliverables: <paths>
```

HANDOFF_LOG entry to OPUS-LEAD: "Phase 2 architecture spec can use routing matrix + complete topic YAMLs."

---

## Begin

1. CHECK-IN per protocol (OPUS-2)
2. Read 13 references
3. Track F first (45 min) — extract 11 missing YAMLs in parallel-safe batches
4. Track E (30 min) — validate channels + inspect PM0 routing
5. CHECK-OUT + HANDOFF
