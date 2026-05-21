# M2 Phase 1 — Dispatch Index (Setup B: 13 agents)

**Date:** 2026-05-20 18:14 BRT
**Phase:** M2 Phase 1 — Discovery
**Mode:** Parallel execution, 13 agents
**Setup level:** B (sweet spot — 10→13 agents adds ~2h calendar savings)

---

## Agent Roster & Prompt Files (12 AI + 1 Owner)

| # | Agent ID | Model | File | Tracks | Time Budget |
|---:|---|---|---|---|---:|
| 1 | **CODEX-1-LEAD** | Codex 5.5 | `codex1_lead.md` | A.1 + A.2 (topics + workflows) + integrator | 60 min |
| 2 | CODEX-1-SUB-A | Codex 5.5 (sub) | `codex1_sub_a.md` | A.3 + A.4 (bindings + connections) | 45 min |
| 3 | CODEX-1-SUB-B | Codex 5.5 (sub) | `codex1_sub_b.md` | B (SharePoint inventory) | 60 min |
| 4 | CODEX-1-SUB-C | Codex 5.5 (sub) | `codex1_sub_c.md` | A.5 (topic errors RCA) + H (risks) | 45 min |
| 5 | **CODEX-2-LEAD** | Codex 5.5 (instance #2) | `codex2_lead.md` | D.1-D.6 (legacy flows 1-6) + Track D consolidation | 60 + 15 min |
| 6 | CODEX-2-SUB-A | Codex 5.5 (sub) | `codex2_sub_a.md` | D.7-D.12 (legacy flows 7-12) | 60 min |
| 7 | CODEX-2-SUB-B | Codex 5.5 (sub) | `codex2_sub_b.md` | D.13-D.18 (PM0 flows + ops handler) | 60 min |
| 8 | CODEX-2-SUB-C | Codex 5.5 (sub) | `codex2_sub_c.md` | G (cleanup script generation, depends on B) | 45 min |
| 9 | **OPUS-2** | Opus 4.7 (instance #2) | `opus2.md` | E (routing) + F (16 topic YAMLs) | 75 min |
| 10 | **GEMINI-FLASH-LEAD** | Gemini Flash 3.5 | `gemini_flash_lead.md` | C.1 (deploy/cards inventory) + Track C compilation | 30 + 15 min |
| 11 | GEMINI-FLASH-SUB-1 | Gemini Flash 3.5 (sub) | `gemini_flash_sub_1.md` | C.2 (frontend/ inventory) | 30 min |
| 12 | GEMINI-FLASH-SUB-2 | Gemini Flash 3.5 (sub) | `gemini_flash_sub_2.md` | C.3 (gap analysis vs M2 reqs) | 30 min |
| 13 | **OWNER (Manoel)** | Human | (this chat with OPUS-LEAD) | All gates + dispatch | continuous |

**Phase 1 critical path: ~75 min calendar** (OPUS-2 com 16 topic YAMLs é o mais lento).

---

## ⚠️ CRITICAL: All agents MUST obey governance protocol

Before doing ANY work, every agent reads:
```
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md
```

The 5 mandatory operations are:
1. CHECK-IN at start
2. HEARTBEAT every 5 min
3. FILE LOCK before write
4. FILE UNLOCK after write
5. CHECK-OUT at end (+ HANDOFF if other agents depend)

**Compliance required.** Non-compliance = automatic FAIL.

---

## How to Dispatch (recommended sequence)

For each of 12 agents (in your preferred order):
1. **Logout** of any prior session/IDE
2. **Login fresh** (new conversation, zero memory)
3. **Open** the corresponding file in the dispatch folder
4. **Copy entire content** (Ctrl+A, Ctrl+C)
5. **Paste** into the new fresh session
6. **Wait** for the agent's "references read" + CHECK-IN confirmation in `governance/ACTIVITY_LOG.md`
7. Move to next agent

---

## File paths (absolute, copy-paste ready)

```
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex1_lead.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex1_sub_a.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex1_sub_b.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex1_sub_c.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex2_lead.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex2_sub_a.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex2_sub_b.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex2_sub_c.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\opus2.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\gemini_flash_lead.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\gemini_flash_sub_1.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\gemini_flash_sub_2.md
```

---

## Lead Roles

- **CODEX-1-LEAD** is the primary Phase 1 integrator. Validates all 10 tracks' output and produces the consolidated `phases/01_discovery/HANDOFF.md`.
- **CODEX-2-LEAD** coordinates Track D (18 flow definitions across 3 agents).
- **GEMINI-FLASH-LEAD** coordinates Track C (cards catalog across 3 agents).
- **OPUS-LEAD** (in main owner chat) is the project orchestrator and Phase 2 spec author.

---

## Coordination

All 12 AI agents update `governance/CHECKIN_BOARD.md` + `governance/ACTIVITY_LOG.md` continuously.

When all 10 tracks PASS + integrator validations complete, CODEX-1-LEAD writes `phases/01_discovery/HANDOFF.md` and Phase 2 auto-advances.

---

## Phase 1 Hard Limits

- 90 minutes calendar per individual track
- ~75 min total Phase 1 critical path with 12 parallel agents
- Beyond 3h, raise flag to Owner

---

*Last updated: 2026-05-20 18:14 BRT — Setup B (13 agents)*

---

## How to Dispatch

### Recommended sequence (re-login + clean context per agent)

For each agent:
1. **Logout** of the current session/IDE
2. **Login fresh** (new conversation, zero memory)
3. **Open the corresponding file** from `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/dispatch/`
4. **Copy entire content** (Ctrl+A, Ctrl+C)
5. **Paste into the new fresh session**
6. **Wait for the agent's "references read" confirmation**

### File paths (absolute)

```
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex1_lead.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex1_sub_a.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex1_sub_b.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex1_sub_c.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex2_lead.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex2_sub_a.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex2_sub_b.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\codex2_sub_c.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\opus2.md
D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\dispatch\gemini_flash.md
```

---

## Context Reset Statement (included in every prompt)

Each prompt includes at the top:

> **CONTEXT RESET DIRECTIVE:** If you have any prior memory of this project, codebase, or related work — DISCARD IT. This prompt is self-contained. The ONLY context you should use is:
> 1. This prompt (full content)
> 2. The files explicitly listed in `Mandatory Read-Before-Start`
>
> Do NOT pull from training cache, prior sessions, or implicit assumptions about the project. Treat this as if encountering the project for the first time, but with the documents listed below as your sole source of truth.

---

## Lead Roles

- **Codex 5.5 #1 Lead** is the primary Phase 1 integrator. Validates all 10 tracks' output and produces the consolidated `HANDOFF.md`.
- **Codex 5.5 #2 Lead** is the flow definitions specialist coordinator (Tracks D.1-D.18 spread across 3 agents).

---

## Coordination

All 10 agents update `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` every 5 minutes.

When all 10 tracks PASS, Codex 5.5 #1 Lead writes `phases/01_discovery/HANDOFF.md` and Phase 2 auto-advances.

---

## Phase 1 Hard Limits

- 90 minutes calendar per individual track
- 3 hours total Phase 1 (with 10 agents parallel)
- Beyond that, raise flag to Owner

---

*Last updated: 2026-05-20 18:06 BRT*
