# Inventory — Channels & Routing IDs (Track E.1)

**Agent:** OPUS-2
**Date:** 2026-05-20
**Method:** Read-only triangulation via PAC + flow definition inspection. No m365 / Graph / direct Teams API calls.
**Source artifacts:**
- `phases/01_discovery/E_routing_inventory/channel_validation.json` (structured per-ID result)
- `phases/01_discovery/D_flow_definitions/definition_PM0_PA_Card_*.json` (Track D batch 3 — CODEX-2-SUB-B)
- PAC live: `pac env who`, `pac connection list`
- `.planning/STATE.md` (Decision #11 — Teams Channel Deep Link)

---

## Confirmation Matrix

| # | Type | ID | Expected name | Validation status | Strongest evidence | Owner action required? |
|---:|---|---|---|---|---|---|
| 1 | Group | `96c5b0c4-46cc-46cd-8695-50451db74994` | Projetos_Tranformação_Digital | ✅ **VALIDATED_INDIRECTLY** | (1) `pac connection list` shows `shared_teams` + `shared_planner` Connected as `mbenicios@minsait.com` in `ColOfertasBrasilPro`; (2) Active flows `PM0_PA_Card_CriarTarefa`, `PM0_PA_Card_ListarTarefas`, `PM0_PA_Card_AtualizarStatus` hard-code this groupId and are state=`Activado` (design-time validated); (3) STATE.md Decision #11 records owner-attested Teams browser deep link to this group | No |
| 2 | Channel | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | Projetos_Tranformação_Digital | ✅ **VALIDATED_INDIRECTLY** | Hard-coded in active `PM0_PA_Card_AtualizarStatus` Teams `PostCardToConversation` action with matching groupId; flow is `Activado`/enabled; STATE.md Decision #11 owner-attested deep link includes this channel ID | No (runtime smoke deferred to M2 Phase 7) |
| 3 | Channel | `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` | QA_Projetos | ⚠️ **REQUIRES_OWNER_ACTION** | Listed in PROJECT.md (allowed channel) and ADR-M2-001 (target for `pm.status.updates`). NOT referenced in any of the 6 active PM0 flow definitions. NOT referenced in any of the 12 legacy `PMO_PA_*` flows either. No design-time activation has validated this ID against the Teams connector | **Yes — 30s action: open Teams in browser, navigate to QA_Projetos, copy deep link, confirm channel ID literal matches.** Alternative: defer until M2 Phase 4 first PM0 flow binds this channel — design-time activation will then validate it |
| 4 | User | `mbenicios@minsait.com` | Owner | ✅ **VALIDATED_DIRECTLY** | `pac env who` returned `Connected as mbenicios@minsait.com` to `ColOfertasBrasilPro`. `pac connection list` shows 30+ connection refs all owned by this UPN | No |

---

## Connector Inventory (relevant to routing)

| Connector | Connections found | Status | Owner UPN | Relevance |
|---|---:|---|---|---|
| `shared_teams` | 2 (`shared-teams-1440d346-...`, `shared-teams-9bb5e0a3-...`) | All Connected | mbenicios@minsait.com | Required for ADR-M2-001 `board.status`, `pmo.ops`, `pm.status.updates`, and any DM via Teams |
| `shared_office365users` | 1 | Connected | mbenicios@minsait.com | Optional helper for resolving DM target by UPN before Teams DM call |
| `shared_planner` | 1 (`6b763b98729c4d99a7a8df4033d381af`) | Connected | mbenicios@minsait.com | Confirms group `96c5b0c4-...` is reachable via Planner; Plan `-1kBj1PLv0qQM-R4PwkqbpcABv_P` (AQ-04) lives there |
| `shared_sharepointonline` | 8 (multiple — most ours, some shared) | All Connected | mbenicios@minsait.com | Required for SharePoint reads/writes; not directly a routing target |

---

## What Was Checked vs What Would Need Owner Verification

### Checked (read-only, this session)
1. PAC environment identity: `pac env who` confirmed connected as `mbenicios@minsait.com` to `ColOfertasBrasilPro` (env `e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
2. PAC connections: `pac connection list` enumerated 30+ refs; both Teams + Planner connectors are Connected
3. Live PM0 flow definitions (6 flows from Track D batch 3) inspected for hard-coded `groupId` / `channelId`. Found 3 distinct hard-codings, all matching the expected group + channel-A IDs
4. Cross-reference with M2 governance docs (ADR-M2-001, REQ-M2-08, STATE.md Decision #11) — IDs match

### NOT possible to check from this CLI session (would need owner)
1. **Direct Teams API resolution of channel IDs** — would require Microsoft Graph or `m365` CLI, both prohibited by project policy
2. **Channel `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` (QA_Projetos)** — no active flow uses it yet, so no design-time activation evidence; owner needs to attest the ID literal
3. **Runtime success of Teams card post** — would need to trigger a flow run with valid input. `PM0_PA_Card_AtualizarStatus` has 0 runs in last 30 days. Defer to M2 Phase 7 Smoke E2E

### Indirect-validation chain (why this is sufficient for Phase 1)
Power Automate Standard does NOT activate (`Activado` state) a flow whose Teams `PostCardToConversation` action references a non-existent channelId or unreachable groupId. Design-time validation runs against the connection at save time. Therefore:
- `PM0_PA_Card_AtualizarStatus` is `Activado` → its hard-coded channelId `19:4c8fe80b...` and groupId `96c5b0c4-...` were both accepted by the Teams connector when the flow was saved on 15/05/2026 19:10
- Same applies to `PM0_PA_Card_CriarTarefa` (Planner CreateTask_V3) and `PM0_PA_Card_ListarTarefas` (Planner ListTasks_V3) using the same groupId

This gives a high-confidence **VALIDATED_INDIRECTLY** for the group ID and channel-A. The **only** unvalidated ID is channel-B (QA_Projetos), which can be cleared by a 30-second owner action OR will be validated at M2 Phase 4 first binding.

---

## Phase 2 Readiness Signal

**GREEN** with one yellow flag:
- ✅ All routing keys to ADR-M2-001 (DM, board.status, pmo.ops) have validated targets
- ✅ Owner UPN validated directly via PAC
- ⚠️ `pm.status.updates` target (channel-B) needs owner attestation OR M2 Phase 4 will catch it at activation

**This does not block Phase 2 architecture spec authoring.** OPUS-LEAD can proceed to draft the architecture spec citing the routing matrix in ADR-M2-001 verbatim, with a note that the QA_Projetos channel ID confirmation is pending owner attestation (a single line in the Phase 2 spec checklist).

---

## Notes

- **Spelling**: the schema name `Tranformação_Digital` is missing one `s` (`Transformação` → `Tranformação`). All evidence files use the misspelled form consistently because that is the literal channel/group name in the tenant. M2 docs use both forms — recommend normalization in M2 Phase 8 docs.
- **Dual `shared_teams` refs**: 2 Teams connections exist; both are owned by the same UPN. Power Automate flow exports tend to pin one specific connectionId. M2 Phase 4 should ensure all 13 PM0 flows reference a single canonical Teams connection ref to avoid future drift.

---

*OPUS-2 — 2026-05-20T20:18:30-03:00*
