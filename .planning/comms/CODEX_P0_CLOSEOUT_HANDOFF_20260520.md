# CODEX P0 Closeout Handoff

Date: 2026-05-20  
Executor: CODEX-PA  
Environment: ColOfertasBrasilPro  
Bot: Assistente PMO V2  
Release decision: STOP - remediate and re-verify five P0 topic bindings before AQ-08-PUBLISH

## Summary

Opus 4.7 reinterpreted TASK 1 scope after CODEX-PA found legacy bindings. The release target is hybrid:

- Five P0 card-first topics must migrate to `PM0_PA_Card_*`.
- Seven legacy topics remain on `PMO_PA_*` as accepted technical debt for this release.

No tenant writes, imports, publishes, Copilot Studio saves, SharePoint writes, Planner writes, or chat tests were executed by CODEX-PA.

## PASS / BLOCK Matrix

| Task | Deliverable | Status | Ship Impact |
|---|---|---|---|
| TASK 1 - AQ-08-PRE | Topic/action routing verification | CONDITIONAL BLOCK | Five in-scope P0 topics still require Owner manual remediation and CODEX read-only re-verification before publish. Seven legacy topics accepted as debt. |
| TASK 2 - BLK-AT-001-DISPLAY | Patch spec + regression test | READY | Spec/test complete. Current 3.15 intentionally fails display regression because field-level `(mantido)` display is not present. Owner applies manually if field-level display is required. |
| TASK 3 - AQ-09-SMOKE | Runtime smoke runbook + evidence template | READY | Owner can execute after AQ-08 remediation, import, and publish. Section A is ship-gating; Section B is legacy debt evidence. |
| TASK 4 - XPIA-01-VERIFY | XPIA harness + evidence validator | READY | Validator is ready to consume Owner evidence. XPIA decision uses only five in-scope P0 topics. |

## In-Scope P0 Manual Remediation

Owner must complete these Copilot Studio UI changes before publish:

| Topic | Required Manual UI Change | Gate |
|---|---|---|
| AtualizarStatus | Replace direct legacy call with `PM0_PA_Card_AtualizarStatus` | Required |
| AtualizarTarefa | Replace `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` with `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | Required |
| ConsultarPortfolio | Replace direct legacy call with `PM0_PA_Card_ResumoExecutivoPortfolio` | Required |
| CriarTarefa | Replace `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` with `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | Required |
| ListarTarefas | Replace `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` with `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | Required |

## Legacy Debt Register

These topics are accepted out-of-scope for this release. They remain on `PMO_PA_*` and must be migrated in a future full card-first replan.

| Legacy Topic | Current Route | Severity | Backlog Item |
|---|---|---|---|
| ConsultarProjeto | `PMO_PA_ConsultarProjeto` | P3 | Migrate to card-first read/display pattern and reduce XPIA surface. |
| CriarProjeto | `PMO_PA_CriarProjeto` | P2 | Migrate create-project write path to card-first guarded UX. |
| ExcluirProjeto | `PMO_PA_ExcluirProjeto` | P2 | Migrate soft-delete path to card-first audit-safe UX. |
| ExcluirTarefa | `PMO_PA_ExcluirTarefa` | P2 | Migrate soft-delete task path to card-first audit-safe UX. |
| PedirDecisao | `PMO_PA_PedirDecisaoBot` | P2 | Migrate decision request path to card-first approval UX. |
| RegistrarBloqueio | `PMO_PA_RegistrarBloqueioBot` | P2 | Migrate blocker registration to card-first guarded UX. |
| RegistrarRisco | `PMO_PA_RegistrarRiscoBot` | P2 | Migrate risk registration to card-first guarded UX. |

Legacy XPIA recurrence is backlog evidence only for this release unless it causes data loss, duplicate writes, or unexpected writes after cancel/invalid input.

## Re-Validation Checklist Before Publish

Owner/CODEX sequence after manual topic remediation:

1. Owner completes the five manual topic binding changes in Copilot Studio UI.
2. Owner does not publish yet.
3. CODEX-PA reruns read-only AQ-08 verification:
   - `pac env who`
   - PAC FetchXML for topic `botcomponent` data
   - PAC FetchXML for `botcomponent_workflow`
   - PAC FetchXML for `PMO_PA_*` and `PM0_PA_*` workflows
4. CODEX-PA confirms these five topic data blocks reference `PM0_PA_Card_*` and no longer reference their legacy `PMO_PA_*` action/flow route:
   - `AtualizarStatus`
   - `AtualizarTarefa`
   - `ConsultarPortfolio`
   - `CriarTarefa`
   - `ListarTarefas`
5. CODEX-PA confirms all six AQ-07 `PM0_PA_*` action components remain active and bound:
   - `PM0_PA_Card_ResumoExecutivoPortfolio`
   - `PM0_PA_Card_AtualizarStatus`
   - `PM0_PA_Card_ListarTarefas`
   - `PM0_PA_Card_CriarTarefa`
   - `PM0_PA_Card_AtualizarTarefa`
   - `PM0_PA_OpsFailureHandling`
6. If BLK-AT-001 display patch is applied, run:

```powershell
.\tests\Test-AtualizarTarefaResponseDisplay.ps1 -PackagePath "<post-remediation-export.zip>"
```

7. If all read-only checks pass, Owner may proceed with import/publish per project contract.
8. Owner runs AQ-09 smoke runbook.
9. CODEX-PA or Owner runs evidence validator:

```powershell
.\tests\Test-Aq09SmokeEvidence.ps1 -EvidenceDir ".planning\comms\aq09_smoke_runbook_20260520\evidence"
```

## Deliverables

| Area | Path |
|---|---|
| AQ-08 topic routing verification | `.planning/comms/aq08_topic_routing_verification_20260520/AQ08_TOPIC_ROUTING_VERIFICATION.md` |
| AQ-08 PAC evidence | `.planning/comms/aq08_topic_routing_verification_20260520/` |
| BLK-AT-001 patch spec | `.planning/comms/blk_at_001_display_patch_20260520/BLK_AT_001_DISPLAY_PATCH_SPEC.md` |
| BLK-AT-001 regression | `tests/Test-AtualizarTarefaResponseDisplay.ps1` |
| BLK-AT-001 expected fail evidence | `.planning/comms/blk_at_001_display_patch_20260520/Test-AtualizarTarefaResponseDisplay_current_3_15_FAIL_expected.txt` |
| AQ-09 smoke runbook | `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md` |
| AQ-09 evidence template | `.planning/comms/aq09_smoke_runbook_20260520/EVIDENCE_TEMPLATE.md` |
| XPIA harness | `.planning/comms/xpia_01_verify_20260520/XPIA_01_VERIFY_HARNESS.md` |
| XPIA validator | `tests/Test-Aq09SmokeEvidence.ps1` |

## Final Decision

Owner cannot proceed with AQ-08-PUBLISH yet.

Conditional unblock path:

```text
Owner manually remediates five P0 topics -> CODEX-PA reruns read-only AQ-08 verification -> if PASS, Owner may proceed with AQ-08-PUBLISH and AQ-09 smoke.
```

Until that re-verification passes:

```text
STOP - fix/rebind the five in-scope P0 topic bindings first.
```
