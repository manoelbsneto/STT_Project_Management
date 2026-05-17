# Teams Routing Inventory - Adaptive Cards + Planner P0

Date: 2026-05-14  
Owner: CODEX-QA  
Status: Initial readiness report and template  
Scope: Read-only local documentation/evidence. No tenant changes, no Teams writes, no flow saves.

## 1. Readiness Summary

| Area | Current Readiness | Evidence Basis | Release Impact |
|---|---|---|---|
| Official Teams target exists | Confirmed locally and owner-approved for Board/PMO P0 | `PRD/PRD_PMO_M365.md`, `PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md`, `.planning/comms/GATE_STATUS.md`, owner decision 2026-05-14 | Use for executive/Board and PMO operations P0 route. |
| Teams group/channel IDs known | Confirmed locally | PRD endpoints and exported flow definitions | Required by Teams connector channel posts. |
| Prior Adaptive Card channel posting | Confirmed locally for legacy/card flows | `.planning/comms/GATE_STATUS.md`, `solution_3_7_workflowset_hygiene_20260513/unpacked/Workflows` | Useful implementation precedent for GEMINI-PA. |
| Board Status channel | Owner-approved as official channel for P0 | Owner decision 2026-05-14 | Executive portfolio cards can use `Projetos_Tranformação_Digital`. |
| PM status update route | Owner-approved as `QA_Projetos` for P0 | Owner decision 2026-05-14 | PM update cards should use `QA_Projetos`, not direct chat, for P0. |
| Project task-card route | Owner-approved as direct chat to `mbenicios@minsait.com` for P0 | Owner decision 2026-05-14 | Task list/create/update cards can be piloted in direct chat. |
| PMO operations channel | Owner-approved as official channel for P0 | Owner decision 2026-05-14 | Planner sync failures and operational alerts can use official channel for P0. |

Recommended P0 default is now confirmed: use the existing official Teams channel for director/Board and PMO operations, use `QA_Projetos` for PM status update cards, and use direct chat to `mbenicios@minsait.com` for task cards during P0.

## 2. Confirmed Local Teams Endpoint

| Field | Value | Source |
|---|---|---|
| Official channel name | `Projetos_Tranformação_Digital` | `PRD/PRD_PMO_M365.md`, adjusted PRD |
| Channel ID | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | PRD endpoints, exported flow definitions |
| Group ID | `96c5b0c4-46cc-46cd-8695-50451db74994` | PRD endpoints, exported flow definitions |
| Tenant ID | `7808e005-1489-4374-954b-d3b08f193920` | PRD endpoints |
| Deep link | `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920` | PRD endpoints |
| Prior created tabs | `Portfolio_Executivo`, `Projetos_Criticos`, `Decisoes do Board` | `.planning/comms/GATE_STATUS.md` G5 |

## 2.1 Owner-Confirmed P0 Routes

| Route Key | Purpose | Target Type | Group ID | Channel ID / UPN | Owner Status |
|---|---|---|---|---|---|
| `board.status` | Executive portfolio and Board cards | Teams channel | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | Approved |
| `pmo.ops` | Operational alerts and Planner sync failures | Teams channel | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | Approved for P0 |
| `pm.status.updates` | PM status update cards | Teams channel | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` | Approved for P0 |
| `task.card.route` | Task list/create/update cards | Direct chat | N/A | `mbenicios@minsait.com` | Approved for P0 |

## 3. Existing Flow Routing Evidence

| Flow | Local Route Type | Group ID | Channel ID | Notes |
|---|---|---|---|---|
| `PMO_PA_CheckInOnDemand` | Teams channel, `PostCardAndWaitForResponse` | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | Current evidence uses channel route, not PM direct chat. |
| `PMO_PA_RegistrarDecisaoBoard` | Teams channel, `PostCardAndWaitForResponse` | Same as above | Same as above | Decision card pattern exists locally. |
| `PMO_PA_EscalarRiscoCritico` | Teams channel post | Same as above | Same as above | Escalation pattern exists locally. |
| `PMO_PA_ResumoDiarioBoard` | Teams channel card | Not visible in local summary | Not visible in local summary | `.planning/comms/GATE_STATUS.md` records runtime screenshot evidence in the official channel. |
| `PMO_PA_ResumoSemanal` | Teams channel card | Not visible in local summary | Not visible in local summary | `.planning/comms/GATE_STATUS.md` records runtime screenshot evidence in the official channel. |

## 4. P0 Routing Matrix

| P0 Scenario | Target Audience | Recommended Route | Current Local Evidence | Owner Confirmation Needed | Ready for Flow Design |
|---|---|---|---|---|---|
| Executive portfolio summary card | Director, Board, PMO Lead | Channel post to official PMO channel | Official channel IDs confirmed; owner approved `Projetos_Tranformação_Digital` | Approved | Yes |
| Red projects drilldown | Director, PMO Lead | Reply/update card in same Board route | Existing card action standard requires action metadata; route target approved | Approved to use same route for P0 | Yes |
| Projects without update | Director, PMO Lead | Same Board route and PMO ops official channel for follow-up | Owner approved official channel for PMO ops P0 | Approved | Yes |
| Request PM update | Director/PMO to PM | Direct chat to PM UPN preferred | SharePoint `Projetos.PM` exists; direct-chat Teams route not proven in local evidence | Confirm direct-chat policy and PM UPN source field; confirm whether PMs allow 1:1 bot/card messages | No |
| PM structured status update card | PM | `QA_Projetos` Teams channel | Owner provided temporary route and channel link | Approved for P0 | Yes |
| PM single-box review card | PM | `QA_Projetos` Teams channel | Owner provided temporary route and channel link | Approved for P0 | Yes |
| Task list card | PM/Project team | Direct chat to `mbenicios@minsait.com` | Owner approved temporary direct chat route | Approved for P0 | Yes |
| Create/update task confirmation | PM / task owner | Direct chat to `mbenicios@minsait.com`; Planner links suppressed | Owner approved route and no Planner links for now | Approved for P0 | Yes |
| Planner sync failure alert | PMO operations | Official PMO channel | Owner approved same official channel for P0 | Approved | Yes |

## 5. Template for Owner/Runtime Completion

| Route Key | Purpose | Team/Chat Target | Group ID | Channel ID or User UPN | Deep Link | Privacy Level | Owner Confirmed | Runtime Evidence |
|---|---|---|---|---|---|---|---|---|
| `board.status` | Executive portfolio and Board cards | Channel | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | PRD deep link | Board/PMO visible | Yes | Pending |
| `pmo.ops` | PMO operational alerts and Planner sync errors | Channel | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | PRD deep link | PMO only | Yes for P0 | Pending |
| `pm.status.updates` | PM update cards and review-before-write | Channel | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` | Owner-provided QA_Projetos link | PM pilot route | Yes for P0 | Pending |
| `task.card.route` | Task list/create/update cards | Direct chat | N/A | `mbenicios@minsait.com` | N/A | Pilot direct chat | Yes for P0 | Pending |

## 6. Blocking Decisions

| Decision ID | Decision | Owner Input Needed | Default if Approved |
|---|---|---|---|
| `ROUTE-01` | Board route for executive card | Confirm existing official channel vs separate Board Status channel | Use `Projetos_Tranformação_Digital` for P0 evidence. |
| `ROUTE-02` | PM card route | Confirm direct chat vs channel posting | Direct chat to `Projetos.PM` UPN. |
| `ROUTE-03` | PMO operations route | Provide PMO ops channel ID or approve fallback | Use official channel only for controlled P0 pilot alerts. |
| `ROUTE-04` | Project task-card route | Confirm per-project channels exist or defer to direct chat | Direct chat/requester route for P0. |
| `ROUTE-05` | Link policy | Confirm whether SharePoint/Planner links may appear in cards | Show only approved Teams/SharePoint deep links; suppress Planner links until confirmed. |

Owner status: `ROUTE-01`, `ROUTE-03`, and `ROUTE-04` are approved for P0 as listed above. `ROUTE-02` is approved as `QA_Projetos` for PM status updates. Planner links are suppressed for P0 per owner decision.

## 7. Handoff Notes

- GEMINI-PA can reuse the known `groupId` and `channelId` for Board/PMO channel-post proof flows because owner confirmed this is the intended P0 route.
- PM status updates must route to `QA_Projetos` for P0.
- Task cards must route to direct chat `mbenicios@minsait.com` for P0.
- Direct-chat runtime behavior still needs runtime validation, but the target policy is owner-approved.
- CODEX-CARDS should keep card action payloads route-neutral by carrying `operationId`, `projectId`, `taskId`, `source=AdaptiveCard`, and a route key instead of hard-coded channel values.
