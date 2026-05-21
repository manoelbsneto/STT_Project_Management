# GEMINI FLASH 3.5 LEAD — M2 Phase 1 — Track C.1 (deploy/cards/ inventory)

**Agent ID:** GEMINI-FLASH-LEAD
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT. Use ONLY this prompt + referenced files.

---

## Governance — MANDATORY

1. Read `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN as `GEMINI-FLASH-LEAD`
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

- Read-only file inspection. No JSON file modifications.
- Output to `phases/01_discovery/C_cards_catalog/`.
- FILE LOCK before any write to that folder.

---

## Your Role: Lead + Track C.1

You are the lead for Track C (Cards Catalog) which is split into 3 sub-tasks:
- **C.1 (you)** — Inventory `deploy/cards/`
- C.2 (GEMINI-FLASH-SUB-1) — Inventory `frontend/dss-showcase/UI_UX/` + `frontend/pmo-executive-viewer/`
- C.3 (GEMINI-FLASH-SUB-2) — Gap analysis vs M2 REQ-M2-02/-03/-04

When sub-agents complete C.2 and C.3, you compile the master `INVENTORY_CARDS_CURRENT.md` and `INVENTORY_CARDS_GAP.md` from all 3 outputs.

---

## Tasks

### Task C.1 — Adaptive Cards Inventory in deploy/cards/

Walk `deploy/cards/` and catalog every JSON file that's an Adaptive Card.

For each card found, capture:

| Field | Description |
|---|---|
| `file_path` | Relative path from project root |
| `file_size_bytes` | File size (must be <27000 to be Teams-compliant) |
| `card_version` | Adaptive Cards schema version (1.x) |
| `schema_valid` | Boolean (validate against https://adaptivecards.io/schemas/adaptive-card.json) |
| `inferred_operation` | Which M2 operation this card supports (CriarProjeto / ConsultarProjeto / etc.) — based on naming + content |
| `usage_status` | `in_use` / `orphan` / `draft` (heuristic: referenced from any flow JSON definition?) |
| `visual_quality` | `complete` / `incomplete` / `placeholder` (heuristic: number of body elements + actions) |
| `actions_present` | List of action names (e.g., ["Action.Submit:confirm", "Action.Submit:cancel"]) |
| `data_fields` | List of input fields (Input.Text, Input.Date, etc.) |
| `notes` | Any anomaly, deprecation marker, or follow-up needed |

Output `cards_catalog_C1.json`:

```json
{
  "track": "C.1",
  "scope": "deploy/cards/",
  "scanned_at": "2026-05-20T18:30:00Z",
  "cards": [
    {
      "file_path": "deploy/cards/CriarTarefaCard.json",
      "file_size_bytes": 3342,
      "card_version": "1.4",
      "schema_valid": true,
      "inferred_operation": "CriarTarefa",
      "usage_status": "in_use",
      "visual_quality": "complete",
      "actions_present": ["Action.Submit:submitCreateTask", "Action.Submit:cancelCreateTask"],
      "data_fields": ["Input.Text:taskTitle", "Input.Date:dueDate", "..."],
      "notes": ""
    },
    ...
  ]
}
```

Plus a per-card markdown summary in `INVENTORY_CARDS_C1_DEPLOY.md`.

---

## Coordination

- Sub-agents (C.2 and C.3) will signal HANDOFF when they finish.
- After all 3 sub-tasks DONE, you compile master INVENTORY_CARDS_CURRENT.md and INVENTORY_CARDS_GAP.md.
- Final HANDOFF_LOG entry: "Track C complete — cards catalog ready for Phase 2 + Phase 3."

---

## Time Budget

- C.1 (yours): 30 min
- Compilation after sub-agents: 15 min

---

## Deliverables

Per Track C.1:
- `cards_catalog_C1.json`
- `INVENTORY_CARDS_C1_DEPLOY.md`

Master (after sub-agents finish):
- `cards_catalog.json` (merged C1+C2+C3)
- `INVENTORY_CARDS_CURRENT.md` (master human-readable)
- `INVENTORY_CARDS_GAP.md` (master gap list for Phase 3)

---

## Begin

1. CHECK-IN per protocol
2. Read 6 references
3. Walk `deploy/cards/` and catalog
4. Wait for C.2 + C.3 HANDOFFs
5. Compile master deliverables
6. CHECK-OUT + HANDOFF to OPUS-LEAD (Phase 2 ready for cards spec)
