# Inventory — Topic YAMLs (Track F)

**Agent:** OPUS-2
**Date:** 2026-05-20
**Source:** `phases/01_discovery/A_dataverse_inventory/topic_inventory.json` (extracted by CODEX-1-LEAD via PAC `pac org fetch` against `botcomponent.data` for `pmo_AssistentePMO_V2`, env `ColOfertasBrasilPro`)
**Output folder:** `phases/01_discovery/F_topic_yamls/`
**Files extracted:** 16 (12 user-facing + 4 system)

---

## Verification of pre-existing as_is/ YAMLs

5 topic YAMLs were previously extracted to `.planning/comms/topic_remediation_20260520/as_is/` during M1 stop-ship work. Per the Track F brief, these were verified against current tenant state.

**Result: NONE are byte-identical to live state.** SHA-256 comparison (LF-normalized, BOM-stripped):

| as_is file | live file | bytes asIs | bytes live | hash equal | content equal (normalized) |
|---|---|---:|---:|---|---|
| `atualizarstatus.yml` | `AtualizarStatus.yaml` | 8874 | 9090 | NO | NO |
| `atualizartarefa.yml` | `AtualizarTarefa.yaml` | 16161 | 15255 | NO | NO |
| `consultarportfolio.yml` | `ConsultarPortfolio.yaml` | 995 | 1260 | NO | NO |
| `criartarefa.yml` | `CriarTarefa.yaml` | 6925 | 6889 | NO | NO |
| `listartarefas.yml` | `ListarTarefas.yaml` | 2107 | 2095 | NO | NO |

The 5 `as_is/` files were saved at an earlier point in time (pre-M2 governance bootstrap, during M1 stop-ship cycles) and are stale. The 16 YAMLs in `F_topic_yamls/` reflect the **current `botcomponent.data` field** as of 14/05/2026 / 15/05/2026 modifications — they are the authoritative Phase 1 baseline for M2 architecture spec.

---

## User-Facing Topics (12)

| # | Topic | YAML file | Bytes | Lines | Modified (UTC-3) | Routing | Target ID / dialog | Workflow | Workflow ID | Status vs ADR-M2-001 / REQ-M2-18 |
|---:|---|---|---:|---:|---|---|---|---|---|---|
| 1 | AtualizarStatus | `AtualizarStatus.yaml` | 9090 | 168 | 14/05/2026 15:02 | InvokeFlowAction `flowId` | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | **PMO_PA_AtualizarStatus** (legacy) | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | STALE — must rebind to `PM0_PA_Card_AtualizarStatus` (`1721e0a3-a250-f111-bec7-000d3abc5cc6`) |
| 2 | AtualizarTarefa | `AtualizarTarefa.yaml` | 15255 | 192 | 14/05/2026 15:02 | BeginDialog `dialog` | `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` | **PMO_PA_AtualizarTarefa** (legacy) | `98408d55-3748-f111-bec7-000d3abc5cc6` | STALE — must rebind to `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` |
| 3 | ConsultarPortfolio | `ConsultarPortfolio.yaml` | 1260 | 40 | 14/05/2026 15:03 | InvokeFlowAction `flowId` | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | **PMO_PA_ConsultarPortfolio** (legacy) | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | STALE — must rebind to `PM0_PA_Card_ResumoExecutivoPortfolio` (`8333bd91-a250-f111-bec7-000d3abc5cc6`) per ADR semantic merge |
| 4 | ConsultarProjeto | `ConsultarProjeto.yaml` | 2798 | 62 | 14/05/2026 15:02 | InvokeFlowAction `flowId` | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | **PMO_PA_ConsultarProjeto** (legacy) | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | STALE — `PM0_PA_Card_ConsultarProjeto` does NOT yet exist; M2 Phase 4 must create it |
| 5 | CriarProjeto | `CriarProjeto.yaml` | 6752 | 143 | 14/05/2026 15:03 | BeginDialog `dialog` | `pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto` | **PMO_PA_CriarProjeto** (legacy) | `3104124d-364a-f111-bec7-7ced8d955c6c` | STALE — `PM0_PA_Card_CriarProjeto` does NOT yet exist; M2 Phase 4 must create it |
| 6 | CriarTarefa | `CriarTarefa.yaml` | 6889 | 161 | 14/05/2026 15:03 | BeginDialog `dialog` | `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` | **PMO_PA_CriarTarefa** (legacy) | `0a5d2a41-24c0-4d5e-9f6d-000000000241` | STALE — must rebind to `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` |
| 7 | ExcluirProjeto | `ExcluirProjeto.yaml` | 3580 | 92 | 14/05/2026 15:03 | InvokeFlowAction `flowId` | `16fbe313-2edc-406e-ad7f-d08cee0edc43` | **PMO_PA_ExcluirProjeto** (legacy) | `16fbe313-2edc-406e-ad7f-d08cee0edc43` | STALE — `PM0_PA_Card_ExcluirProjeto` does NOT yet exist; M2 Phase 4 must create it |
| 8 | ExcluirTarefa | `ExcluirTarefa.yaml` | 5152 | 110 | 14/05/2026 15:03 | InvokeFlowAction `flowId` | `70b39334-5926-4fb1-bd22-f10bd99f0f6d` | **PMO_PA_ExcluirTarefa** (legacy) | `70b39334-5926-4fb1-bd22-f10bd99f0f6d` | STALE — `PM0_PA_Card_ExcluirTarefa` does NOT yet exist; M2 Phase 4 must create it |
| 9 | ListarTarefas | `ListarTarefas.yaml` | 2095 | 47 | 14/05/2026 15:03 | BeginDialog `dialog` | `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` | **PMO_PA_ListarTarefas** (legacy) | `9544f14b-3748-f111-bec7-6045bdf42cae` | STALE — must rebind to `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` |
| 10 | PedirDecisao | `PedirDecisao.yaml` | 8254 | 185 | 14/05/2026 15:03 | InvokeFlowAction `flowId` | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | **PMO_PA_PedirDecisaoBot** (legacy) | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | STALE — `PM0_PA_Card_PedirDecisao` does NOT yet exist; M2 Phase 4 must create it |
| 11 | RegistrarBloqueio | `RegistrarBloqueio.yaml` | 5685 | 128 | 14/05/2026 15:02 | InvokeFlowAction `flowId` | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | **PMO_PA_RegistrarBloqueioBot** (legacy) | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | STALE — `PM0_PA_Card_RegistrarBloqueio` does NOT yet exist; M2 Phase 4 must create it |
| 12 | RegistrarRisco | `RegistrarRisco.yaml` | 6195 | 139 | 14/05/2026 15:02 | InvokeFlowAction `flowId` | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | **PMO_PA_RegistrarRiscoBot** (legacy) | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | STALE — `PM0_PA_Card_RegistrarRisco` does NOT yet exist; M2 Phase 4 must create it |

**User-facing topics summary:**
- Total bytes: 73,005
- Total lines: 1,467
- Routing pattern split: 7 use `InvokeFlowAction` with hard-coded `flowId`; 5 use `BeginDialog` with `dialog: pmo_AssistentePMO_V2.action.<workflow>`
- 12/12 still on legacy `PMO_PA_*` — **0 topics are bound to PM0_PA_Card_*** (matches AQ-08 verification)

---

## System Topics (4)

| # | Topic | YAML file | Bytes | Lines | Modified (UTC-3) | Routing | Notes |
|---:|---|---|---:|---:|---|---|---|
| 13 | Greeting | `Greeting.yaml` | 266 | 10 | 14/05/2026 15:02 | none | Auto-message on session start (Cold-Start NLU warm-up); no flow invocation |
| 14 | LowConfidence | `LowConfidence.yaml` | 10615 | 126 | 14/05/2026 15:02 | `BeginDialog` to topics | Smart-redirect to 5 topics: `CriarProjeto`, `CriarTarefa`, `AtualizarStatus`, `AtualizarTarefa`, `ConsultarPortfolio`. Comments mention `RegistrarRisco`, `PedirDecisao`, `RegistrarBloqueio`, `ConsultarProjeto` but only 5 active dialog branches found in YAML body |
| 15 | SeHouverErro | `SeHouverErro.yaml` | 298 | 11 | 14/05/2026 15:03 | none | Standard error handler; no flow invocation |
| 16 | Gerar_Multiplos_Projetos | `Gerar_Multiplos_Projetos.yaml` | 1170 | 30 | 14/05/2026 15:03 | none | Preview-only stub; no flow invocation |

**System topics summary:**
- Total bytes: 12,349
- Total lines: 177
- All 4 are non-flow-invoking, so REQ-M2-18 (`zero PMO_PA_* references in active topics`) is automatically satisfied for these. LowConfidence redirects topic→topic; once user-facing topics get rebound, the redirects automatically resolve to the new PM0 path.

---

## Aggregate Stats

| Metric | User-facing | System | Total |
|---|---:|---:|---:|
| Topic count | 12 | 4 | 16 |
| Total bytes | 73,005 | 12,349 | 85,354 |
| Total lines | 1,467 | 177 | 1,644 |
| Topics with flow invocation | 12 | 0 | 12 |
| Topics on legacy PMO_PA_* | **12** | 0 | **12** |
| Topics on PM0_PA_Card_* | **0** | 0 | **0** |

---

## M2 Remediation Inventory (input to Phase 2 architecture spec)

For each of the 12 user-facing topics, M2 must change exactly the final invocation step (per REQ-M2-06: "diff per topic <30 lines, ~80% preserved"):

### Group A — PM0 flow already exists, just rebind topic (5 topics)

| Topic | Current binding | Target binding | New flow ID |
|---|---|---|---|
| AtualizarStatus | `flowId: c11a165b-c64c-f111-bec7-7ced8d9559c1` | Replace with `dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` (or new flowId) | `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| AtualizarTarefa | `dialog: pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` | `dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| ConsultarPortfolio | `flowId: 39cf292d-c64c-f111-bec7-7ced8d955c6c` | `dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` (semantic merge per ADR-M2-001) | `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| CriarTarefa | `dialog: pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` | `dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| ListarTarefas | `dialog: pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` | `dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |

### Group B — PM0 flow does NOT YET exist; M2 Phase 4 must build + activate (7 topics)

| Topic | Current binding | M2 target flow to create |
|---|---|---|
| ConsultarProjeto | `flowId: 4a33b53e-c64c-f111-bec7-000d3abc5cc6` | `PM0_PA_Card_ConsultarProjeto` (NEW) |
| CriarProjeto | `dialog: pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto` | `PM0_PA_Card_CriarProjeto` (NEW) |
| ExcluirProjeto | `flowId: 16fbe313-2edc-406e-ad7f-d08cee0edc43` | `PM0_PA_Card_ExcluirProjeto` (NEW) |
| ExcluirTarefa | `flowId: 70b39334-5926-4fb1-bd22-f10bd99f0f6d` | `PM0_PA_Card_ExcluirTarefa` (NEW) |
| PedirDecisao | `flowId: feb79d54-c64c-f111-bec7-7ced8d955c6c` | `PM0_PA_Card_PedirDecisao` (NEW) |
| RegistrarBloqueio | `flowId: 3ec37952-c64c-f111-bec7-000d3abc5cc6` | `PM0_PA_Card_RegistrarBloqueio` (NEW) |
| RegistrarRisco | `flowId: ee732d46-c64c-f111-bec7-7ced8d955c6c` | `PM0_PA_Card_RegistrarRisco` (NEW) |

This matches REQ-M2-17 ("Refactor 5 + Create 7" = 12 PM0_PA_Card_* flows total + 1 reusable PM0_PA_OpsFailureHandling = 13 flows).

---

## Source / Method (read-only audit trail)

- Source field: `botcomponent.data` (componenttype = 9 / "Tema (V2)")
- Source bot: `pmo_AssistentePMO_V2`
- Tenant: `ColOfertasBrasilPro` (env id `e2d10003-4d8e-e007-9d63-76d5fe89ef56`, org id `e0b9c35e-79a2-ef11-8a66-000d3a24857a`)
- PAC FetchXML: `phases/01_discovery/A_dataverse_inventory/query_topics.fetchxml`
- Raw output: `phases/01_discovery/A_dataverse_inventory/all_topics_inventory.txt`
- Parsed JSON: `phases/01_discovery/A_dataverse_inventory/topic_inventory.json` (98,416 bytes; 16 records)
- Re-extraction script (deterministic, idempotent): `phases/01_discovery/F_topic_yamls/_extract_yamls.ps1`
- Verification script (against `as_is/`): `phases/01_discovery/F_topic_yamls/_compare_asis.ps1`
- Per-file extraction summary: `phases/01_discovery/F_topic_yamls/_extraction_summary.json`

No tenant writes were performed. Read-only PAC `pac org fetch` (run by CODEX-1-LEAD on Track A.1) supplied all the source bytes; OPUS-2 only re-formatted them per-file.

---

*OPUS-2 — 2026-05-20T20:14:30-03:00*
