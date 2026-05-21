# M2 Check-in / Check-out Protocol — MANDATORY

**Date created:** 2026-05-20 18:14 BRT
**Owner:** Manoel Benicio
**Architect:** Opus 4.7 (lead)
**Applies to:** All 13 M2 agents (Codex × 8, Opus × 2, Gemini Flash × 3, Owner × 1)
**Compliance:** Mandatory. Non-compliance = automatic task FAIL + escalation to Owner.

---

## Why This Exists

M2 runs 13 agents in parallel across 3 different AI models. Without strict governance:
- Two agents write to the same file simultaneously → corruption
- An agent dies silently and we don't notice for hours
- Nobody knows who is doing what right now
- Handoffs get lost between phases
- No audit trail for compliance / post-mortem

This protocol is **non-negotiable**. Every agent obeys, including Owner.

---

## The 4 Mandatory Logs

Every M2 agent interacts with these 4 files in `.planning/milestones/M2_card_first_revision_v2/governance/`:

1. `CHECKIN_BOARD.md` — current active agents + status (snapshot view)
2. `ACTIVITY_LOG.md` — append-only timestamp log of every action
3. `FILE_LOCK_TABLE.md` — which files are locked for write right now
4. `HANDOFF_LOG.md` — agent-to-agent handoffs (one log entry per handoff)

These files are read+write for all agents. Conflict resolution: timestamp wins.

---

## The 5 Mandatory Operations

Every agent MUST perform these 5 operations during a task:

### 1. CHECK-IN (start of task)

**When:** Before any other action in your prompt.
**Where:** `CHECKIN_BOARD.md` + `ACTIVITY_LOG.md`

**CHECKIN_BOARD.md update:** Add row in "Active Agents" table.
**ACTIVITY_LOG.md append:**

```markdown
[2026-05-20T18:14:22-03:00] CHECKIN | <AGENT_ID> | claiming task <TASK_ID> | references read: <count>/<expected> | next action: <description>
```

### 2. HEARTBEAT (every 5 minutes while active)

**When:** Every 5 minutes from CHECK-IN until CHECK-OUT.
**Where:** `ACTIVITY_LOG.md` (append) + `CHECKIN_BOARD.md` (update "Last seen" timestamp)

**ACTIVITY_LOG.md append:**

```markdown
[2026-05-20T18:19:22-03:00] HEARTBEAT | <AGENT_ID> | task <TASK_ID> | progress: <%> | current step: <description>
```

If 10 minutes pass without heartbeat → agent considered DEAD. Other agents must NOT depend on its output. Owner notified.

### 3. FILE LOCK (before any file write)

**When:** Before writing/editing any file.
**Where:** `FILE_LOCK_TABLE.md`

**Acquire lock:**

```markdown
| <full_file_path> | <AGENT_ID> | LOCKED | 2026-05-20T18:20:00-03:00 | expected release: 2026-05-20T18:25:00-03:00 |
```

**Rules:**
- Check the table first. If file already locked by another agent — WAIT or work on something else.
- Lock max duration: 15 min. If you need longer, append a "renewal" entry.
- Read-only operations (cat/read) DO NOT require lock. Only writes.

### 4. FILE UNLOCK (after file write)

**When:** Immediately after write completes.
**Where:** `FILE_LOCK_TABLE.md`

Update the row to status `RELEASED` with timestamp.

```markdown
| <full_file_path> | <AGENT_ID> | RELEASED | 2026-05-20T18:24:30-03:00 | actually released at 2026-05-20T18:24:30-03:00 |
```

### 5. CHECK-OUT (end of task)

**When:** Task complete OR blocked OR you're about to log off.
**Where:** `CHECKIN_BOARD.md` (remove from active) + `ACTIVITY_LOG.md` + (if handoff) `HANDOFF_LOG.md`

**ACTIVITY_LOG.md append (success):**

```markdown
[2026-05-20T19:00:15-03:00] CHECKOUT | <AGENT_ID> | task <TASK_ID> | status: DONE | deliverables: <list of paths> | next agent: <none|AGENT_ID>
```

**ACTIVITY_LOG.md append (blocked):**

```markdown
[2026-05-20T19:00:15-03:00] CHECKOUT | <AGENT_ID> | task <TASK_ID> | status: BLOCKED | reason: <description> | requires: <Owner action|other agent output|env fix>
```

**HANDOFF_LOG.md append (if next agent depends on your output):**

```markdown
[2026-05-20T19:00:30-03:00] HANDOFF | from: <AGENT_ID> | to: <NEXT_AGENT_ID> | deliverables: <paths> | next agent must: <specific action> | depends on: <list of completed prerequisites>
```

---

## Status Vocabulary (lockado)

| Status | Meaning |
|---|---|
| `READY` | Task assigned, agent not yet started |
| `CLAIMED` | Agent has acknowledged but not started edits |
| `IN_PROGRESS` | Agent actively working, heartbeats expected |
| `BLOCKED` | Agent cannot proceed (waiting on dependency or Owner) |
| `READY_FOR_REVIEW` | Task complete enough for integrator review |
| `DONE` | Reviewed and accepted by integrator |
| `REWORK` | Integrator returned for correction |
| `DEAD` | Agent missed >10min heartbeat |
| `CANCELLED` | Task cancelled before completion (Owner decision) |

---

## Owner-Specific Operations

Owner is part of the agent fleet for governance purposes. Owner-only operations:

- **APPROVE_GATE**: Owner approves a phase gate. Logged in ACTIVITY_LOG with prefix `OWNER_GATE_APPROVED`.
- **TENANT_WRITE**: Owner executes a tenant write (import, publish, save, schema change). Logged with prefix `OWNER_TENANT_WRITE` + the exact command + result.
- **CHAT_TEST**: Owner runs a Copilot Studio chat test. Logged with prefix `OWNER_CHAT_TEST` + command + bot response snippet.

---

## Cross-Agent Communication Rules

1. **Synchronous handoffs** — agent A finishes, posts HANDOFF in HANDOFF_LOG.md, agent B reads HANDOFF_LOG.md and starts. Nobody waits without logging.
2. **No private channels** — every agent-to-agent communication MUST be in one of the 4 governance files. No assumed knowledge.
3. **Conflicts** — if two agents want the same file, the one who acquired lock first wins. The other waits.
4. **Failures** — if your task fails, mark status BLOCKED + describe in ACTIVITY_LOG. Owner triages.

---

## Violation Consequences

| Violation | Consequence |
|---|---|
| Skipped CHECK-IN | Task auto-FAILED. Output discarded. |
| Skipped HEARTBEAT >10min | Agent marked DEAD. Output reviewed but not relied on. |
| Skipped FILE LOCK | If conflict occurred → output discarded + redo. Else: warning. |
| Skipped CHECK-OUT | Other agents wait blocked. Owner manually closes. |
| Tenant write without owner approval | Project-level FAIL. Rollback initiated. |
| Used `m365` CLI or unauthorized tools | Project-level FAIL. |

---

## Quick Reference (every agent prompt links here)

```
Governance docs path: .planning/milestones/M2_card_first_revision_v2/governance/
Files:
  CHECKIN_BOARD.md     — current active agents
  ACTIVITY_LOG.md      — append-only timestamp log
  FILE_LOCK_TABLE.md   — file write locks
  HANDOFF_LOG.md       — handoffs between agents
  CHECKIN_CHECKOUT_PROTOCOL.md — this file
```

---

*Protocol version: 1.0 — locked 2026-05-20 18:14 BRT.*
