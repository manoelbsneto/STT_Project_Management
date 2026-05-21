# GEMINI FLASH 3.5 SUB-2 — M2 Phase 1 — Track C.3 (gap analysis)

**Agent ID:** GEMINI-FLASH-SUB-2
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT.

---

## Governance — MANDATORY

1. Read `governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN as `GEMINI-FLASH-SUB-2`
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
.planning/AGENT_CONTRACT.md
```

---

## Hard Constraints

- Read-only operations.
- Output to `phases/01_discovery/C_cards_catalog/`.
- FILE LOCK before write.
- Wait for HANDOFF from GEMINI-FLASH-LEAD (C.1) and GEMINI-FLASH-SUB-1 (C.2) before starting analysis.

---

## Dependencies

Wait for HANDOFF_LOG entries from:
- GEMINI-FLASH-LEAD (C.1 cards_catalog_C1.json available)
- GEMINI-FLASH-SUB-1 (C.2 cards_catalog_C2.json available)

Then start.

---

## Tasks — Track C.3: Gap Analysis vs M2 Requirements

Cross-reference cards_catalog_C1.json + cards_catalog_C2.json with M2 requirements:

### M2 target cards (from REQ-M2-02, -03, -04 + ADR-M2-001 variants)

**REQ-M2-02 (9 confirmation cards):**
1. CriarProjetoConfirmCard
2. ExcluirProjetoConfirmCard
3. CriarTarefaConfirmCard
4. AtualizarTarefaConfirmCard
5. ExcluirTarefaConfirmCard
6. AtualizarStatusConfirmCard
7. RegistrarRiscoConfirmCard
8. RegistrarBloqueioConfirmCard
9. PedirDecisaoConfirmCard

**REQ-M2-03 (4 result cards):**
10. ConsultarPortfolioCard
11. ConsultarProjetoCard
12. ListarTarefasCard
13. ResumoExecutivoPortfolio (refactor existing)

**REQ-M2-04 (1 ops failure card):**
14. OpsFailureCard

**ADR-M2-001 broadcast variants** (some operations need a separate "broadcast" card variant for channels):
- CriarProjeto → CriarProjetoBroadcastCard (for board.status)
- ExcluirProjeto → ExcluirProjetoBroadcastCard (for pmo.ops)
- CriarTarefa → CriarTarefaBroadcastCard (for pm.status.updates)
- AtualizarTarefa → AtualizarTarefaBroadcastCard (for pm.status.updates)
- ExcluirTarefa → ExcluirTarefaBroadcastCard (for pmo.ops)
- AtualizarStatus → AtualizarStatusBroadcastCard (for pm.status.updates AND board.status if RAG=Vermelho)
- RegistrarRisco → RegistrarRiscoBroadcastCard (for pmo.ops)
- RegistrarBloqueio → RegistrarBloqueioBroadcastCard (for pmo.ops)
- PedirDecisao → PedirDecisaoApproverCard (decision card to approver via board.status)

That's **9 broadcast variants**.

**Total M2 cards: 14 base + 9 broadcast = 23 cards**

(Note: Confirm and Result variants of write operations can share template with state difference — Phase 3 will decide. For inventory purposes, count them separately for now.)

### Gap Analysis Output

For each of the 23 target cards, classify:

| Card name | Existing | Path | Action |
|---|---|---|---|
| CriarProjetoConfirmCard | NO | — | NEW (Phase 3 build from scratch) |
| ExcluirProjetoConfirmCard | NO | — | NEW |
| CriarTarefaConfirmCard | YES (partial) | deploy/cards/CriarTarefaCard.json | REFACTOR (current is form-only, needs hybrid confirm pattern) |
| ResumoExecutivoPortfolio | YES | deploy/cards/ResumoExecutivoPortfolio.json | REFACTOR (align design system) |
| ... | ... | ... | ... |

**Action values:** `NEW` / `REFACTOR` / `KEEP_AS_IS` / `DEPRECATE`

### Effort estimate per card (for Phase 3 planning)

For each card, estimate Phase 3 effort:
- NEW from scratch: 30-45 min
- REFACTOR existing: 15-20 min
- KEEP_AS_IS: 0
- DEPRECATE: 0

Output total Phase 3 effort estimate.

---

## Deliverables

```
phases/01_discovery/C_cards_catalog/
├── cards_catalog_C3_gap.json
├── INVENTORY_CARDS_GAP.md (your output — will be merged with master by GEMINI-FLASH-LEAD)
└── PHASE_3_EFFORT_ESTIMATE.md
```

---

## Time Budget

30 min hard limit. Starts AFTER C.1 + C.2 HANDOFFs received.

---

## Coordination

When DONE, post HANDOFF_LOG entry to GEMINI-FLASH-LEAD: "Track C.3 complete — gap analysis ready for compilation."

---

## Begin

1. CHECK-IN per protocol
2. Read 6 references
3. Wait for C.1 + C.2 HANDOFFs
4. Cross-reference + classify 23 target cards
5. Estimate effort
6. CHECK-OUT + HANDOFF to GEMINI-FLASH-LEAD
