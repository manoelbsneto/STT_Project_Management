# Inventory - Copilot Studio Topic Errors RCA

**Agent:** CODEX-1-SUB-C  
**Generated:** 2026-05-20T20:39:27-03:00  
**Scope:** M2 Phase 1 Task A.5  
**Tenant:** ColOfertasBrasilPro  
**Evidence used:** Track A.1 `topic_inventory.json`, Track A.2 `workflow_inventory.json`, Track F live YAMLs, Track D flow definitions/schemas/run histories.

## Executive Finding

The dominant root cause hypothesis is **stale legacy action binding**, not inactive legacy workflows. Track D shows all 12 legacy `PMO_PA_*` workflows are still `Activado`, but Track F shows 12/12 user-facing topics still call legacy `PMO_PA_*` actions or hard-coded legacy `flowId` values. This violates REQ-M2-18 and explains why M2 Phase 5 must rebind topics to `PM0_PA_Card_*`.

Connection-reference orphaning remains **unconfirmed** at this point because Track A.4 parsed `connection_audit.json` was not available when this RCA was written. Raw A.4 files existed, but CODEX-1-SUB-A still held the A.3/A.4 deliverable lock.

## RCA Matrix

| Topic | UI error count | Severity | Phase | Root cause hypothesis | Evidence | Proposed M2 fix |
|---|---:|---|---|---|---|---|
| AtualizarStatus | 1 | P0 blocks publish | Phase 5 topic update; Phase 4 refactor target | Hard-coded legacy `InvokeFlowAction` still points to active `PMO_PA_AtualizarStatus`; target PM0 flow exists but topic is not rebound. Regex lines are parser-sensitive but not the strongest evidence. | `AtualizarStatus.yaml:139` invokes flow; `:153` flowId `c11a165b-c64c-f111-bec7-7ced8d9559c1`; Track D D.1 says legacy flow active with 23 failures/27 runs; PM0 target D.13 active. | Replace final invocation with `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` / PM0 flow ID `1721e0a3-a250-f111-bec7-000d3abc5cc6`; preserve collection logic. |
| AtualizarTarefa | 1 | P0 blocks publish | Phase 5 topic update; Phase 4 BLK-AT-001 refactor | Legacy `BeginDialog` points to `PMO_PA_AtualizarTarefa`; PM0 target exists but topic is not rebound. Skip semantics are also incomplete for M2 target. | `AtualizarTarefa.yaml:179-183`; dialog `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa`; Track D D.2 active; PM0 target D.14 active. | Rebind final dialog to `PM0_PA_Card_AtualizarTarefa`; implement `nao/n/blank/0` preserve behavior in PM0 flow and card display. |
| ConsultarPortfolio | 1 | P0 blocks publish | Phase 5 topic update; Phase 4 read-card refactor | Hard-coded legacy `flowId` points to `PMO_PA_ConsultarPortfolio`; M2 semantic target is `PM0_PA_Card_ResumoExecutivoPortfolio`. | `ConsultarPortfolio.yaml:27-32`; flowId `39cf292d-c64c-f111-bec7-7ced8d955c6c`; Track D D.3 active; PM0 target D.17 active. | Rebind to `PM0_PA_Card_ResumoExecutivoPortfolio` and return/post the portfolio summary card. |
| ConsultarProjeto | 1 | P0 blocks publish | Phase 4 flow build; Phase 5 topic update | Legacy `flowId` is active, but M2 target `PM0_PA_Card_ConsultarProjeto` does not exist yet. | `ConsultarProjeto.yaml:46-54`; flowId `4a33b53e-c64c-f111-bec7-000d3abc5cc6`; Track F gap says PM0 target missing. | Build and activate `PM0_PA_Card_ConsultarProjeto`, then rebind the final action. |
| CriarProjeto | 5 | P0 blocks publish | Phase 4 flow build; Phase 5 topic update | Multi-issue: legacy `BeginDialog` to `PMO_PA_CriarProjeto`, PM0 target missing, and output-dependent result branching likely creates multiple schema validation errors after import. | `CriarProjeto.yaml:106-112` BeginDialog output binds `message` to `Topic.Result`; `:113-134` branches on `Topic.Result`; Track D D.5 output schema exposes `message`; PM0 target missing. | Build `PM0_PA_Card_CriarProjeto`; replace final legacy call and simplify result handling to static ack/result card contract. |
| CriarTarefa | 1 | P0 blocks publish | Phase 5 topic update; Phase 4 refactor target | Legacy `BeginDialog` points to `PMO_PA_CriarTarefa`; PM0 target exists but topic is not rebound. | `CriarTarefa.yaml:146-150`; dialog `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`; Track D D.6 active; PM0 target D.15 active. | Rebind final dialog to `PM0_PA_Card_CriarTarefa`; preserve collection prompts. |
| ExcluirProjeto | 1 | P0 blocks publish | Phase 4 flow build; Phase 5 topic update | Legacy hard-coded flow is active, but M2 target `PM0_PA_Card_ExcluirProjeto` does not exist yet. | `ExcluirProjeto.yaml:70-77`; flowId `16fbe313-2edc-406e-ad7f-d08cee0edc43`; Track F gap says PM0 target missing. | Build `PM0_PA_Card_ExcluirProjeto`; rebind action to card-first soft-delete confirmation. |
| ExcluirTarefa | 1 | P0 blocks publish | Phase 4 flow build; Phase 5 topic update | Legacy hard-coded flow is active, but M2 target `PM0_PA_Card_ExcluirTarefa` does not exist yet. | `ExcluirTarefa.yaml:84-95`; flowId `70b39334-5926-4fb1-bd22-f10bd99f0f6d`; Track F gap says PM0 target missing. | Build `PM0_PA_Card_ExcluirTarefa`; rebind action to card-first soft-delete confirmation. |
| ListarTarefas | 1 | P0 blocks publish | Phase 5 topic update; Phase 4 read-card refactor | Legacy `BeginDialog` points to `PMO_PA_ListarTarefas`; PM0 target exists but topic is not rebound. | `ListarTarefas.yaml:38-42`; dialog `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas`; Track D D.9 active; PM0 target D.16 active. | Rebind final dialog to `PM0_PA_Card_ListarTarefas`; return/post useful task list card instead of static text. |
| PedirDecisao | 1 | P0 blocks publish | Phase 4 flow build; Phase 5 topic update | Legacy `InvokeFlowAction` points to active `PMO_PA_PedirDecisaoBot`; M2 target missing. UPN regex at line 112 is now escaped and appears less likely than stale binding. | `PedirDecisao.yaml:112` escaped UPN regex; `:158-170` legacy flow invocation; Track F gap says PM0 target missing. | Build `PM0_PA_Card_PedirDecisao`; keep/validate UPN regex; rebind final invocation. |
| RegistrarBloqueio | 1 | P0 blocks publish | Phase 4 flow build; Phase 5 topic update | Legacy `InvokeFlowAction` points to active `PMO_PA_RegistrarBloqueioBot`; M2 target missing. | `RegistrarBloqueio.yaml:103-113`; flowId `3ec37952-c64c-f111-bec7-000d3abc5cc6`; Track F gap says PM0 target missing. | Build `PM0_PA_Card_RegistrarBloqueio`; rebind to card-first confirmation/result pattern. |
| RegistrarRisco | 1 | P0 blocks publish | Phase 4 flow build; Phase 5 topic update | Legacy `InvokeFlowAction` points to active `PMO_PA_RegistrarRiscoBot`; M2 target missing. | `RegistrarRisco.yaml:113-124`; flowId `ee732d46-c64c-f111-bec7-7ced8d955c6c`; Track F gap says PM0 target missing. | Build `PM0_PA_Card_RegistrarRisco`; rebind to card-first confirmation/result pattern. |

## Cross-Checks

- **Workflow state:** Track D confirms all 12 legacy `PMO_PA_*` workflows are `Activado`, so the topic errors are not explained by deactivated legacy workflows.
- **PM0 availability:** 5 PM0 card flows exist and are active: AtualizarStatus, AtualizarTarefa, CriarTarefa, ListarTarefas, ResumoExecutivoPortfolio. 7 PM0 target flows do not exist yet and must be built in Phase 4.
- **Regex risk:** Current `PedirDecisao` UPN regex uses escaped hyphen (`\\-`) at line 112. Prior local notes mention this exact topic had a historical Power Fx regex issue, but current evidence points more strongly to stale binding / missing PM0 target.
- **Connection references:** Not closed by this RCA. CODEX-1-SUB-A A.4 was still in progress, so Phase 2 should merge this RCA with `connection_audit.json` once A.4 is checked out.

## Phase Impact

| Phase | Impact |
|---|---|
| Phase 4 Flow Build | Build 7 missing PM0 card flows; refactor 5 existing PM0 flows to dual-entry/card-first contracts. |
| Phase 5 Topic Update | Rebind 12 final topic invocations from `PMO_PA_*` to `PM0_PA_Card_*`, preserving collection logic. |
| Phase 6 Schema | No direct schema root cause found here; schema may still affect runtime after PM0 flows write to SharePoint/Planner. |

## Blockers / Dependencies

- Await CODEX-1-SUB-A A.4 final `connection_audit.json` before ruling out connection-reference orphaning.
- Await Phase 4 creation of 7 missing PM0 flows before Phase 5 can produce PM0-only topics for those operations.
