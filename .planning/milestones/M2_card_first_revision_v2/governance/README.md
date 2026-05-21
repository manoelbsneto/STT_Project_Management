# M2 Governance Kit — Index

**Date:** 2026-05-20
**Purpose:** Single source of truth for project control, agent coordination, and audit trail.

---

## Files

| File | Purpose | Update mode |
|---|---|---|
| `CHECKIN_CHECKOUT_PROTOCOL.md` | The rules every agent obeys | Read-only (locked spec) |
| `CHECKIN_BOARD.md` | Live snapshot — who's active right now | Updated on every check-in/heartbeat/check-out |
| `ACTIVITY_LOG.md` | Append-only timestamp stream of every action | Append-only |
| `FILE_LOCK_TABLE.md` | Coordinates concurrent file writes | Updated on lock acquire/release |
| `HANDOFF_LOG.md` | Records agent-to-agent transitions | Append-only |
| `README.md` (this file) | Index | Static |

---

## Reading Order for New Agent

1. `CHECKIN_CHECKOUT_PROTOCOL.md` — understand the rules (mandatory)
2. `CHECKIN_BOARD.md` — see current state
3. `ACTIVITY_LOG.md` (last 50 entries) — recent context
4. Your dispatch prompt in `phases/<N>_<phase>/dispatch/<your_id>.md`
5. M2 PROJECT.md, REQUIREMENTS.md, ROADMAP.md (per dispatch prompt)

---

## Editing Rules

- `CHECKIN_BOARD.md`: any agent can edit (table updates)
- `ACTIVITY_LOG.md`: APPEND ONLY — never edit existing lines
- `FILE_LOCK_TABLE.md`: any agent can edit (table updates)
- `HANDOFF_LOG.md`: APPEND ONLY — never edit existing lines
- `CHECKIN_CHECKOUT_PROTOCOL.md`: only OPUS-LEAD can edit (changing rules requires owner approval)
- `README.md`: only OPUS-LEAD edits

---

## File Paths (absolute)

```
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\governance\CHECKIN_CHECKOUT_PROTOCOL.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\governance\CHECKIN_BOARD.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\governance\ACTIVITY_LOG.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\governance\FILE_LOCK_TABLE.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\governance\HANDOFF_LOG.md
```

---

## Compliance Audit

At end of each phase, OPUS-LEAD audits:
- Did every agent CHECK-IN at start? (Compliance metric)
- Did every agent emit HEARTBEATs every 5 min? (Liveness metric)
- Did every file write have a LOCK acquired? (Safety metric)
- Did every CHECK-OUT include deliverable list? (Traceability metric)
- Did every cross-agent dependency have a HANDOFF entry? (Coordination metric)

Compliance score per agent recorded in phase HANDOFF.md. <80% compliance triggers protocol review.

---

*Governance kit version: 1.0 — locked 2026-05-20 18:14 BRT.*
