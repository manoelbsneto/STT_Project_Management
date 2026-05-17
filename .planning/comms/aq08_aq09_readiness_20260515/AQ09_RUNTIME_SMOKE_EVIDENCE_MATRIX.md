# AQ-09 Runtime Smoke Evidence Matrix

Date: 2026-05-15
Status: BLOCKED_FOR_AQ08_PUBLISH (AQ-07 Flow IDs are now available)

## Prerequisites
- [x] AQ-07 Flow save/import completed and evidence recorded.
- [ ] AQ-08 Copilot update/publish completed and evidence recorded.
- [ ] Owner approval for AQ-09 explicitly granted.

## Smoke Queue

| Order | Evidence ID | Target Flow ID | Route | Action | Expected Result | Pass/Fail | Run ID/Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | DV-01 | `b4df90ec-a721-44cf-adbd-a5ced1d7f9f7` | Copilot chat | Send `status executivo dos projetos` | Short acknowledgement. No raw rows. No ContentFiltered. | PENDING | |
| 2 | DV-02 | `b7678a81-df01-4070-b6db-3c0dbcc7f924` | `Projetos_Transformacao_Digital` | Verify card posted. | Card appears with correct title/version and timestamp. | PENDING | |
| 3 | DV-04 | N/A | Executive portfolio card | Click red-projects action. | Bounded drilldown card/result. | PENDING | |
| 4 | DV-05 | N/A | Executive portfolio card | Click no-update action. | Bounded drilldown card/result. | PENDING | |
| 5 | DV-06 | N/A | Executive portfolio card | Click PM update request. | Appears in `QA_Projetos` or controlled route. | PENDING | |
| 6 | PMU-01 | `b7678a81-df01-4070-b6db-3c0dbcc7f924` | `QA_Projetos` | Submit structured status card values. | Write succeeds, capture run ID. | PENDING | |
| 7 | PMU-02 | N/A | `QA_Projetos` | Submit single-box text. | Review card shows parsed fields. | PENDING | |
| 8 | PMU-03 | `b7678a81-df01-4070-b6db-3c0dbcc7f924` | `QA_Projetos` review card | Click `Confirmar`. | SharePoint write happens. Capture run ID. | PENDING | |
| 9 | TPL-01 | `c9e44878-77ed-4b17-9b6f-0bab008a0587` | Copilot chat | Send `listar tarefas do projeto QA Robust 20260513 F` | Static acknowledgement. No task table. | PENDING | |
| 10 | TPL-01-CARD | N/A | Direct chat | Verify task list card. | Card shows bounded active tasks. | PENDING | |
| 11 | TPL-02 | `76146280-a6c2-4068-8a3f-3310e3e9210f` | Direct chat task card | Submit create-task card. | Planner and SharePoint writes succeed. Capture run ID. | PENDING | |

## XPIA and Filter Checks
- [ ] No `ContentFiltered` in Copilot response, Teams card output, or flow error output.
- [ ] No `openAIIndirectAttack` in runtime output or flow error details.
- [ ] No raw SharePoint/Planner payload exposure to Copilot.
- [ ] Cards post only to the approved route/channel/direct chat targets.
