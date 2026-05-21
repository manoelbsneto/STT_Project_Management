# M2 File Lock Table

**Purpose:** Prevent two agents from writing to the same file at the same time.

**Rule:** Acquire lock BEFORE any write operation. Release immediately after write completes.

**Read-only operations (cat, head, less, grep) do NOT require lock.**

---

## Lock Format

```markdown
| <full_file_path> | <AGENT_ID> | <STATUS> | <acquired_at> | <expected_release_at> | <actual_released_at> | <notes> |
```

**Status values:** `LOCKED` | `RELEASED` | `EXPIRED` | `CONTESTED`

**Lock duration limits:**
- Max single lock: 15 minutes
- Renewal: append new row with same path + same agent if you need more time
- Auto-expire: locks older than 20 min without renewal are EXPIRED automatically

---

## Active Locks (right now)

| File path | Agent | Status | Acquired | Expected release | Actual release | Notes |
|---|---|---|---|---|---|---|
| (none) | | | | | | |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:16:03-03:00 | 2026-05-20T19:21:03-03:00 | 2026-05-20T19:16:03-03:00 | check-in update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:17:30-03:00 | 2026-05-20T19:22:30-03:00 | 2026-05-20T19:17:30-03:00 | references read + PAC plan |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/pac_env_who.txt` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:17:30-03:00 | 2026-05-20T19:32:30-03:00 | 2026-05-20T19:26:37-03:00 | A.1 PAC env evidence |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/all_topics_inventory.txt` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:17:30-03:00 | 2026-05-20T19:32:30-03:00 | 2026-05-20T19:26:37-03:00 | A.1 raw topics fetch |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/all_workflows_inventory.txt` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:17:30-03:00 | 2026-05-20T19:32:30-03:00 | 2026-05-20T19:26:37-03:00 | A.2 raw workflows fetch |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:18:27-03:00 | 2026-05-20T19:23:27-03:00 | 2026-05-20T19:18:27-03:00 | create output folder |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/query_topics.fetchxml` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:20:32-03:00 | 2026-05-20T19:25:32-03:00 | 2026-05-20T19:20:32-03:00 | A.1 FetchXML file workaround |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/query_workflows.fetchxml` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:20:32-03:00 | 2026-05-20T19:25:32-03:00 | 2026-05-20T19:20:32-03:00 | A.2 FetchXML file workaround |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:22:05-03:00 | 2026-05-20T19:27:05-03:00 | 2026-05-20T19:22:05-03:00 | heartbeat update |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/topic_inventory.json` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:22:05-03:00 | 2026-05-20T19:37:05-03:00 | 2026-05-20T19:26:37-03:00 | parsed A.1 output |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/workflow_inventory.json` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:22:05-03:00 | 2026-05-20T19:37:05-03:00 | 2026-05-20T19:26:37-03:00 | parsed A.2 output |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/INVENTORY_TOPICS.md` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:22:05-03:00 | 2026-05-20T19:37:05-03:00 | 2026-05-20T19:26:37-03:00 | A.1 summary |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/INVENTORY_WORKFLOWS.md` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:22:05-03:00 | 2026-05-20T19:37:05-03:00 | 2026-05-20T19:26:37-03:00 | A.2 summary |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-LEAD | RELEASED | 2026-05-20T19:26:37-03:00 | 2026-05-20T19:31:37-03:00 | 2026-05-20T19:26:37-03:00 | checkout update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-LEAD | LOCKED | 2026-05-20T19:55:26-03:00 | 2026-05-20T20:00:26-03:00 | — | check-in update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-LEAD | RELEASED | 2026-05-20T19:55:26-03:00 | 2026-05-20T20:00:26-03:00 | 2026-05-20T19:55:26-03:00 | check-in update |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/` | CODEX-2-LEAD | LOCKED | 2026-05-20T19:56:55-03:00 | 2026-05-20T20:01:55-03:00 | — | create output folder |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/` | CODEX-2-LEAD | RELEASED | 2026-05-20T19:56:55-03:00 | 2026-05-20T20:01:55-03:00 | 2026-05-20T19:57:05-03:00 | create output folder |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-LEAD | LOCKED | 2026-05-20T20:00:00-03:00 | 2026-05-20T20:05:00-03:00 | — | heartbeat update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-LEAD | RELEASED | 2026-05-20T20:00:00-03:00 | 2026-05-20T20:05:00-03:00 | 2026-05-20T20:00:05-03:00 | heartbeat update |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/D.1-D.6_legacy_batch1_files` | CODEX-2-LEAD | LOCKED | 2026-05-20T20:00:00-03:00 | 2026-05-20T20:15:00-03:00 | — | extract batch 1 definitions, schemas, run histories |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/D.1-D.6_legacy_batch1_files` | CODEX-2-LEAD | RELEASED | 2026-05-20T20:00:00-03:00 | 2026-05-20T20:15:00-03:00 | 2026-05-20T20:04:30-03:00 | extracted 6 definitions, 6 trigger schemas, 6 output schemas, 6 run histories |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-LEAD | LOCKED | 2026-05-20T20:04:30-03:00 | 2026-05-20T20:09:30-03:00 | — | heartbeat update after batch 1 extraction |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-LEAD | RELEASED | 2026-05-20T20:04:30-03:00 | 2026-05-20T20:09:30-03:00 | 2026-05-20T20:04:35-03:00 | heartbeat update after batch 1 extraction |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/flow_run_history_30d.json` | CODEX-2-LEAD | LOCKED | 2026-05-20T20:10:30-03:00 | 2026-05-20T20:25:30-03:00 | — | consolidated all 18 flow run histories |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/INVENTORY_FLOW_DEFINITIONS.md` | CODEX-2-LEAD | LOCKED | 2026-05-20T20:10:30-03:00 | 2026-05-20T20:25:30-03:00 | — | master matrix all 18 flows |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/flow_run_history_30d.json` | CODEX-2-LEAD | RELEASED | 2026-05-20T20:10:30-03:00 | 2026-05-20T20:25:30-03:00 | 2026-05-20T20:14:00-03:00 | consolidated all 18 flow run histories |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/INVENTORY_FLOW_DEFINITIONS.md` | CODEX-2-LEAD | RELEASED | 2026-05-20T20:10:30-03:00 | 2026-05-20T20:25:30-03:00 | 2026-05-20T20:14:00-03:00 | master matrix all 18 flows |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-LEAD | LOCKED | 2026-05-20T20:14:00-03:00 | 2026-05-20T20:19:00-03:00 | — | checkout update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-LEAD | RELEASED | 2026-05-20T20:14:00-03:00 | 2026-05-20T20:19:00-03:00 | 2026-05-20T20:14:10-03:00 | checkout update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-B | RELEASED | 2026-05-20T19:55:10-03:00 | 2026-05-20T20:00:10-03:00 | 2026-05-20T19:55:10-03:00 | check-in update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-A | RELEASED | 2026-05-20T19:56:07-03:00 | 2026-05-20T20:01:07-03:00 | 2026-05-20T19:56:07-03:00 | check-in update |

---

| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/D.13-D.18_PM0_batch3_files` | CODEX-2-SUB-B | RELEASED | 2026-05-20T19:57:00-03:00 | 2026-05-20T20:12:00-03:00 | 2026-05-20T20:08:04-03:00 | D.13-D.18 definitions, schemas, run histories, PM0 analysis |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/D.7-D.12_legacy_batch2_files` | CODEX-2-SUB-A | RELEASED | 2026-05-20T19:58:49-03:00 | 2026-05-20T20:13:49-03:00 | 2026-05-20T20:04:27-03:00 | D.7-D.12 definitions, schemas, run histories |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-A | RELEASED | 2026-05-20T20:03:04-03:00 | 2026-05-20T20:08:04-03:00 | 2026-05-20T20:03:30-03:00 | heartbeat update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-A | RELEASED | 2026-05-20T20:04:53-03:00 | 2026-05-20T20:09:53-03:00 | 2026-05-20T20:05:58-03:00 | checkout update |

| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-B | RELEASED | 2026-05-20T20:04:29-03:00 | 2026-05-20T20:09:29-03:00 | 2026-05-20T20:04:31-03:00 | heartbeat update |

| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-B | RELEASED | 2026-05-20T20:08:04-03:00 | 2026-05-20T20:13:04-03:00 | 2026-05-20T20:08:04-03:00 | checkout update |

## Recent Lock History (last 24h)
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | OPUS-2 | LOCKED | 2026-05-20T20:13:30-03:00 | 2026-05-20T20:18:30-03:00 | — | check-in update for OPUS-2 (tracks E + F) |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/E_routing_inventory/` | OPUS-2 | LOCKED | 2026-05-20T20:13:30-03:00 | 2026-05-20T20:28:30-03:00 | — | create + populate Track E output folder |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/F_topic_yamls/` | OPUS-2 | LOCKED | 2026-05-20T20:13:30-03:00 | 2026-05-20T20:28:30-03:00 | — | create + populate Track F output folder |


| File path | Agent | Acquired | Released | Duration | Result |
|---|---|---|---|---|---|
| (none yet) | | | | | |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-C | RELEASED | 2026-05-20T19:58:05-03:00 | 2026-05-20T20:03:05-03:00 | 2026-05-20T19:58:39-03:00 | check-in update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-C | RELEASED | 2026-05-20T20:03:14-03:00 | 2026-05-20T20:08:14-03:00 | 2026-05-20T20:03:24-03:00 | heartbeat update |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-2-SUB-C | RELEASED | 2026-05-20T20:06:40-03:00 | 2026-05-20T20:11:40-03:00 | 2026-05-20T20:06:50-03:00 | blocked checkout update |

---

## Conflict Resolution Rules

1. **Read the table first.** If your target file is LOCKED by another agent — WAIT or work on different file.
2. **First-claim wins.** Whoever acquired LOCKED status first owns it.
3. **Forced unlock requires Owner approval.** No agent may force-unlock another agent's lock.
4. **Stale locks** (>20 min without renewal) can be marked EXPIRED by any agent.
5. **Locks survive agent crashes.** If an agent dies (no heartbeat), the integrator marks lock EXPIRED.

---

## Files NEVER to lock (read-only by design)

- Anything in `.planning/comms/` from M1 (preserved as-is)
- `.planning/PROJECT.md` (only OPUS-LEAD edits)
- `.planning/STATE.md` (only OPUS-LEAD edits)
- `.planning/ROADMAP.md` (only OPUS-LEAD edits)
- `.planning/milestones/M2_card_first_revision_v2/PROJECT.md` (only OPUS-LEAD edits)
- `.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md` (only OPUS-LEAD edits)
- `.planning/milestones/M2_card_first_revision_v2/ROADMAP.md` (only OPUS-LEAD edits)
- `.planning/milestones/M2_card_first_revision_v2/decisions/*.md` (only OPUS-LEAD edits)
- This file (no agent locks the lock table itself — append directly)
- `governance/ACTIVITY_LOG.md` (append-only, no lock)
- `governance/HANDOFF_LOG.md` (append-only, no lock)

---

## Files OFTEN locked (output workspaces)

- `phases/01_discovery/A_dataverse_inventory/` (Codex 1 family)
- `phases/01_discovery/B_sharepoint_inventory/` (Codex 1 sub-B)
- `phases/01_discovery/C_cards_catalog/` (Gemini Flash family)
- `phases/01_discovery/D_flow_definitions/` (Codex 2 family)
- `phases/01_discovery/E_routing_inventory/` (Opus 2)
- `phases/01_discovery/F_topic_yamls/` (Opus 2)
- `phases/01_discovery/G_test_data_cleanup/` (Codex 2 sub-C)
- `phases/01_discovery/H_risks_constraints/` (Codex 1 sub-C)

---

*Update this table on every lock acquire/release.*

| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | OPUS-2 | RELEASED | 2026-05-20T20:13:30-03:00 | 2026-05-20T20:18:30-03:00 | 2026-05-20T20:13:35-03:00 | check-in update for OPUS-2 (tracks E + F) |

| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/E_routing_inventory/` | OPUS-2 | RELEASED | 2026-05-20T20:13:30-03:00 | 2026-05-20T20:28:30-03:00 | 2026-05-20T20:24:00-03:00 | Track E deliverables (3 files) populated |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/F_topic_yamls/` | OPUS-2 | RELEASED | 2026-05-20T20:13:30-03:00 | 2026-05-20T20:28:30-03:00 | 2026-05-20T20:24:00-03:00 | Track F deliverables (16 YAMLs + summary + scripts) populated |
| $boardPath | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:34:31-03:00 | 2026-05-20T20:39:31-03:00 | — | check-in update |
| $boardPath | CODEX-1-SUB-A | RELEASED | 2026-05-20T20:34:31-03:00 | 2026-05-20T20:39:31-03:00 | 2026-05-20T20:34:31-03:00 | check-in update |
| $file | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:35:07-03:00 | 2026-05-20T20:50:07-03:00 | — | Track A.3/A.4 deliverable write |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-SUB-C | RELEASED | 2026-05-20T20:35:43-03:00 | 2026-05-20T20:40:43-03:00 | 2026-05-20T20:35:43-03:00 | check-in update |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/INVENTORY_TOPIC_ERRORS_RCA.md` | CODEX-1-SUB-C | LOCKED | 2026-05-20T20:39:27-03:00 | 2026-05-20T20:54:27-03:00 | — | A.5 deliverable |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/H_risks_constraints/` | CODEX-1-SUB-C | LOCKED | 2026-05-20T20:39:27-03:00 | 2026-05-20T20:54:27-03:00 | — | H deliverables folder |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/H_risks_constraints/connector_quota_analysis.json` | CODEX-1-SUB-C | LOCKED | 2026-05-20T20:39:27-03:00 | 2026-05-20T20:54:27-03:00 | — | H.1 deliverable |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/H_risks_constraints/INVENTORY_QUOTA_RISKS.md` | CODEX-1-SUB-C | LOCKED | 2026-05-20T20:39:27-03:00 | 2026-05-20T20:54:27-03:00 | — | H.1 deliverable |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/H_risks_constraints/INVENTORY_TENANT_CHANGES.md` | CODEX-1-SUB-C | LOCKED | 2026-05-20T20:39:27-03:00 | 2026-05-20T20:54:27-03:00 | — | H.2 deliverable |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-SUB-C | LOCKED | 2026-05-20T20:42:12-03:00 | 2026-05-20T20:47:12-03:00 | — | heartbeat update |

| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-SUB-B | LOCKED | 2026-05-20T20:35:21-03:00 | 2026-05-20T20:40:21-03:00 | — | check-in update for Track B |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-SUB-B | RELEASED | 2026-05-20T20:35:21-03:00 | 2026-05-20T20:40:21-03:00 | 2026-05-20T20:35:21-03:00 | check-in update for Track B |
| `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/B_sharepoint_inventory/` | CODEX-1-SUB-B | LOCKED | 2026-05-20T20:36:03-03:00 | 2026-05-20T20:51:03-03:00 | — | Track B deliverable write |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-SUB-B | LOCKED | 2026-05-20T20:40:30-03:00 | 2026-05-20T20:45:30-03:00 | — | heartbeat update for Track B |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-SUB-B | RELEASED | 2026-05-20T20:40:30-03:00 | 2026-05-20T20:45:30-03:00 | 2026-05-20T20:40:30-03:00 | heartbeat update for Track B |
| `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md` | CODEX-1-SUB-B | LOCKED | 2026-05-20T20:41:58-03:00 | 2026-05-20T20:46:58-03:00 | — | checkout update for Track B |
| $file | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:35:07-03:00 | 2026-05-20T20:50:07-03:00 | — | Track A.3/A.4 deliverable write |
| $file | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:35:07-03:00 | 2026-05-20T20:50:07-03:00 | — | Track A.3/A.4 deliverable write |
| $file | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:35:07-03:00 | 2026-05-20T20:50:07-03:00 | — | Track A.3/A.4 deliverable write |
| $file | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:35:07-03:00 | 2026-05-20T20:50:07-03:00 | — | Track A.3/A.4 deliverable write |
| $file | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:35:07-03:00 | 2026-05-20T20:50:07-03:00 | — | Track A.3/A.4 deliverable write |
| $file | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:35:07-03:00 | 2026-05-20T20:50:07-03:00 | — | Track A.3/A.4 deliverable write |
| $boardPath | CODEX-1-SUB-A | LOCKED | 2026-05-20T20:37:36-03:00 | 2026-05-20T20:42:36-03:00 | — | heartbeat update |
| $boardPath | CODEX-1-SUB-A | RELEASED | 2026-05-20T20:37:36-03:00 | 2026-05-20T20:42:36-03:00 | 2026-05-20T20:37:36-03:00 | heartbeat update |
