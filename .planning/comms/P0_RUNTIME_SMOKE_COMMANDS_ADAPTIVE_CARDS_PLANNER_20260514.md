# P0 Runtime Smoke Commands - Adaptive Cards + Planner

Date: 2026-05-14  
Owner: CODEX-QA / Mendel  
Status: Executable evidence plan; refreshed 2026-05-15 for AQ-04 owner-provided Planner ID evidence; runtime execution requires owner approval  
Scope: Copilot/Teams smoke commands only. No tenant access by agents, no `m365`, no flow saves, no SharePoint writes, no Planner writes from this document.

Release decision remains `NO-SHIP` until runtime gates are green. AQ-04 owner-provided Planner IDs are accepted only as read-only Power Automate evidence; they do not authorize Planner writes, SharePoint writes, flow saves/imports, Copilot publish/update, Teams production posts, or SHIP.

## Preconditions

| Item | Required State |
|---|---|
| Bot | Imported/published by owner after P0 implementation package is ready. |
| Board route | `Projetos_Transformacao_Digital` route by confirmed IDs, `groupId=96c5b0c4-46cc-46cd-8695-50451db74994`, `channelId=19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2`. |
| PM status route | `QA_Projetos`, `groupId=96c5b0c4-46cc-46cd-8695-50451db74994`, `channelId=19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2`. |
| Task card route | Direct chat to `mbenicios@minsait.com`. |
| Planner IDs and bucket IDs | PASS OWNER EVIDENCE for AQ-04 read-only discovery via `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`. Do not use Microsoft 365 CLI / `m365`. Do not perform Planner writes from this evidence. |

## Smoke Queue

| Order | Evidence ID | Surface | Exact Command / Action | Expected Evidence |
|---:|---|---|---|---|
| 1 | `DV-01` | Copilot chat | `status executivo dos projetos` | Copilot returns a short acknowledgement/summary only, with no raw SharePoint/Planner rows and no `ContentFiltered`. |
| 2 | `DV-02` | Teams `Projetos_Transformacao_Digital` route by confirmed IDs | Verify the executive portfolio card posted after `DV-01`. | Screenshot showing card title/version, RAG counts, route, and timestamp. |
| 3 | `DV-04` | Executive portfolio card | Click `Ver projetos vermelhos` or the equivalent red-projects action. | Bounded red-project drilldown card/result; no raw JSON in Copilot. |
| 4 | `DV-05` | Executive portfolio card | Click `Ver sem atualizacao` or the equivalent no-update action. | Bounded no-update card/result; no raw JSON in Copilot. |
| 5 | `DV-06` | Executive portfolio card | Click `Solicitar atualizacao do PM` for one pilot project. | Update request appears in `QA_Projetos` or a controlled route result is shown; capture flow run ID. |
| 6 | `PMU-01` | `QA_Projetos` Teams channel | Submit structured status card values: `Projeto=QA Robust 20260513 F`, `RAG=Amarelo`, `Percentual=45`, `Resumo=Smoke P0 via card`, `Risco=Dependencia de validacao`, `Bloqueio=Nenhum`, `Proxima acao=Validar evidencia runtime`. | Status review/write succeeds only through card path; capture card screenshot, flow run ID, and SharePoint before/after evidence. |
| 7 | `PMU-02` | `QA_Projetos` Teams channel | Submit single-box text: `Projeto: QA Robust 20260513 F` newline `RAG: Amarelo` newline `Percentual: 45` newline `Resumo: Smoke single-box P0` newline `Risco: Validacao pendente` newline `Bloqueio: Nenhum` newline `Proxima acao: Confirmar card de revisao`. | Review card shows parsed fields before write; no direct write before confirmation. |
| 8 | `PMU-03` | `QA_Projetos` review card | Click `Confirmar` on the single-box review card. | SharePoint write happens after confirmation; capture run ID and item evidence. |
| 9 | `TPL-01` | Copilot chat | `listar tarefas do projeto QA Robust 20260513 F` | Copilot returns static acknowledgement only, e.g. card sent to Teams; no task table and no `ContentFiltered`. |
| 10 | `TPL-01-CARD` | Direct chat to `mbenicios@minsait.com` | Verify task list card from `TPL-01`. | Direct-chat card shows bounded active tasks and card actions. |
| 11 | `TPL-02` | Direct chat task card | Submit create-task card with `Projeto=QA Robust 20260513 F`, `Titulo=Smoke task P0 card`, `Responsavel=mbenicios@minsait.com`, `Prazo=30/06/2026`, `Prioridade=Media`, `Bucket=Pendente`. | Until AQ-03/AQ-07/AQ-08/AQ-09/AQ-10 are green, Planner write is not attempted. SharePoint write evidence also requires owner-approved runtime execution. |
| 12 | `TPL-03-PENDING` | Planner readiness | Do not run Planner bucket discovery from this smoke queue. | AQ-04 discovery is already PASS OWNER EVIDENCE for read-only mapping; Planner create/update remains blocked until runtime/write approvals are green. |

## Planner Bucket Discovery Control

Planner bucket discovery is intentionally not an executable command in this file. AQ-04 owner-provided Power Automate evidence is accepted as the read-only mapping baseline.

Required control:

```text
Use only the project master docs/runbooks:
- .planning/TENANT_COMMAND_RUNBOOK.md
- .planning/SHAREPOINT_ACCESS_RUNBOOK.md
- docs/TAILSCALE_SSH_CONNECTIVITY_GUIDE.md
- .planning/CURRENT_BASELINE.md
- .planning/GOLDEN_RULES.md

Forbidden:
- m365 / Microsoft 365 CLI
- Graph direct calls
- HTTP Premium paths
- service principal / app registration paths
```

Accepted AQ-04 read-only Planner bucket mapping:

| Bucket Name | Bucket ID |
|---|---|
| `Pendente` | `HmzyGOgC4k6uOPm_cwG3zZcAGiAG` |
| `Em andamento` | `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG` |
| `Concluido` | `F2WYUsnXeEue5qlwQuu3GJcAN1Ns` |
| `Cancelado` | `90TcFTFup0CjiHIdzY4gG5cALWKL` |
| `Testes` | `7QYPufh54kum7MP4KUzzAZcAL6Ik` |
| `Piloto e Implantacao` | `4YAXH7iU9E-6jZE2P1DbG5cAMAzH` |

This mapping does not authorize Planner writes.

## Evidence Capture Checklist

For every executed smoke row, capture:

| Evidence Field | Required |
|---|---|
| Timestamp BRT | Yes |
| User executing | Yes |
| Copilot transcript or Teams screenshot | Yes |
| Route/channel/direct chat target | Yes |
| Card name and card version | Yes, if visible |
| Power Automate run ID/URL | Yes, when applicable |
| SharePoint item before/after | Yes, for write tests |
| Planner task/bucket evidence | AQ-04 read-only mapping evidence is accepted; Planner task create/update evidence only after AQ-03/AQ-07/AQ-08/AQ-09/AQ-10 are green |

Remaining stop-ship gates: AQ-03, AQ-07, AQ-08, AQ-09, and AQ-10. Current release decision: `NO-SHIP`.
