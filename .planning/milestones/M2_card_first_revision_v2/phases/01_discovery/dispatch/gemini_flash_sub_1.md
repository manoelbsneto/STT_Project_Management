# GEMINI FLASH 3.5 SUB-1 — M2 Phase 1 — Track C.2 (frontend/ inventory)

**Agent ID:** GEMINI-FLASH-SUB-1
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT.

---

## Governance — MANDATORY

1. Read `governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN as `GEMINI-FLASH-SUB-1`
3. HEARTBEAT every 5 min
4. CHECK-OUT + HANDOFF when done

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/AGENT_CONTRACT.md
```

---

## Hard Constraints

- Read-only file inspection.
- Output to `phases/01_discovery/C_cards_catalog/`.
- FILE LOCK before write.

---

## Tasks — Track C.2: Adaptive Cards Inventory in frontend/

Walk these directories:
- `frontend/dss-showcase/UI_UX/`
- `frontend/pmo-executive-viewer/`
- `frontend/` (root files)

Catalog every JSON file that looks like an Adaptive Card (must have `"type": "AdaptiveCard"` at top level).

Use the same schema as Track C.1:

```json
{
  "track": "C.2",
  "scope": "frontend/",
  "scanned_at": "2026-05-20T18:30:00Z",
  "cards": [
    {
      "file_path": "frontend/dss-showcase/UI_UX/...",
      "file_size_bytes": ...,
      "card_version": "1.x",
      "schema_valid": true,
      "inferred_operation": "...",
      "usage_status": "...",
      "visual_quality": "...",
      "actions_present": [...],
      "data_fields": [...],
      "notes": ""
    },
    ...
  ]
}
```

If any file is NOT an Adaptive Card (HTML mockups, design system docs, etc.), **list them separately** in a `non_card_assets.json` for Phase 3 design system reference.

---

## Deliverables

```
phases/01_discovery/C_cards_catalog/
├── cards_catalog_C2.json
├── non_card_assets_C2.json (if any)
└── INVENTORY_CARDS_C2_FRONTEND.md
```

---

## Time Budget

30 min hard limit.

---

## Coordination

When DONE, post HANDOFF_LOG entry to GEMINI-FLASH-LEAD: "Track C.2 complete — ready for compilation."

---

## Begin

1. CHECK-IN per protocol
2. Read 5 references
3. Walk frontend/ and catalog
4. CHECK-OUT + HANDOFF
