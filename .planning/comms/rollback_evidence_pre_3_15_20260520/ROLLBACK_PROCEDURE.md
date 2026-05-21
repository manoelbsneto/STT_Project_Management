# Pre-Publish Rollback Procedure - 3.15

Date: 2026-05-20  
Owner: Manoel Benicio  
Prepared by: CODEX-PA  
Environment: `ColOfertasBrasilPro`  
Bot: `Assistente PMO V2`

## Scope

This procedure is an Owner-executed rollback path if the 3.15 import/publish or post-publish smoke gate fails. CODEX-PA captured the evidence read-only and did not execute import, publish, Copilot Studio edits, Power Automate saves, SharePoint writes, Planner writes, or chat tests.

## Pre-Publish State Summary

| Item | Value |
|---|---|
| Environment ID | `e2d10003-4d8e-e007-9d63-76d5fe89ef56` |
| Organization ID | `e0b9c35e-79a2-ef11-8a66-000d3a24857a` |
| Organization URL | `https://colofertasbrasilpro.crm4.dynamics.com/` |
| User | `mbenicios@minsait.com` |
| Solution unique name | `PMO_v11_Tarefas` |
| Solution friendly name | `PMO v1.1 - Task Management Topics` |
| Current solution version in tenant | `3.15` |
| Current solution type | Unmanaged |
| Copilot name | `Assistente PMO V2` |
| Copilot ID | `df148bf8-0a3e-495b-80c4-841dcb61d9a4` |
| Copilot status | Published / Active / Provisioned |
| Candidate package | `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` |
| Candidate package SHA256 | `0A68BB03F9C79440EA9AA09F7E5EE067681FCBDE0241F51F4C27BEB8EA61A9A6` |
| Rollback package target | `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` |
| Rollback package SHA256 | `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691` |
| Latest reviewed import log pointer | `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (29).xml` |

Evidence files:

```text
.planning/comms/rollback_evidence_pre_3_15_20260520/pac_env_who_pre_publish.txt
.planning/comms/rollback_evidence_pre_3_15_20260520/pac_solution_list_pre_publish.txt
.planning/comms/rollback_evidence_pre_3_15_20260520/pac_copilot_list_pre_publish.txt
.planning/comms/rollback_evidence_pre_3_15_20260520/botcomponent_workflow_pre_publish.txt
```

## Rollback Trigger Criteria

Trigger rollback if any of these occur after Owner import/publish:

| Symptom | Rollback Decision |
|---|---|
| AQ-08 post-remediation verifier returns `BLOCK` after publish | Roll back before runtime smoke. |
| Any in-scope P0 topic still routes to `PMO_PA_*` instead of expected `PM0_PA_Card_*` | Roll back or stop and manually remediate before publish, depending on timing. |
| AQ-09 Section A command returns `FlowNotFound`, `FlowActionBadGateway`, missing action, or wrong action binding | Roll back. |
| AQ-09 Section A command appends `ContentFiltered` / `openAIIndirectAttack` after a successful action | Roll back unless Owner explicitly accepts a new fallback strategy from Opus 4.7. |
| `pac solution import` or Copilot publish fails or leaves bot not Published/Active | Roll back. |
| SharePoint side effect violates the runbook for in-scope P0 tests | Roll back or stop for data-correction triage before further tests. |

Legacy out-of-scope topics (`ConsultarProjeto`, `CriarProjeto`, `ExcluirProjeto`, `ExcluirTarefa`, `PedirDecisao`, `RegistrarBloqueio`, `RegistrarRisco`) are accepted debt for this release. Their XPIA recurrence is evidence for backlog, not an automatic rollback trigger, unless the Owner decides it creates unacceptable production risk.

## Owner Rollback Commands

Run only after Owner explicitly decides to rollback.

```powershell
pac env select --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56

pac solution import `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --path "Solution\PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip" `
  --force-overwrite `
  --publish-changes `
  --async `
  --max-async-wait-time 60

pac copilot publish `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --bot df148bf8-0a3e-495b-80c4-841dcb61d9a4
```

If `pac copilot publish` does not refresh runtime state, Owner may publish `Assistente PMO V2` manually in Copilot Studio UI and capture a screenshot.

## Post-Rollback Read-Only Verification

```powershell
pac env who

pac solution list `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56

pac copilot list `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

Then re-run the Owner smoke test that originally failed and capture:

```text
.planning/comms/rollback_evidence_pre_3_15_20260520/post_rollback/
```

## Recovery Time Objective

Target RTO: 15 minutes from rollback decision to published rollback bot, assuming current PAC authentication remains valid and the rollback package is present at the path above.

