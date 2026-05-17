# Solution 3.11 AtualizarTarefa Response/Date Fix - Risk Register

Generated: 2026-05-14
Agent: Agent A - Incident Commander / Program Control
Release state: `NO-SHIP`

## Risk Summary

| Risk ID | Severity | Status | Risk | Impact | Mitigation / Required Evidence |
|---|---|---|---|---|---|
| R-001 | SEV-0 | OPEN | ISSUE-001 response display uses raw `nao` skip input rather than effective persisted values. | Users may believe the task was updated to invalid values even when SharePoint preserved the correct fields. This blocks trustworthy runtime UX. | Patch response composition to use normalized/effective field values. Runtime evidence must show both SharePoint outputs and bot response display correct effective values. |
| R-002 | SEV-0 | OPEN | ISSUE-002 BR due date input reaches SharePoint as `dd/MM/yyyy` and fails date conversion. | Common pt-BR input fails at runtime with `BadGateway` / `OpenApiOperationParameterTypeConversionFailed`; stop-ship for PMO task update. | Normalize `dd/MM/yyyy` to `yyyy-MM-dd` before `Update_Tarefa`. Runtime evidence must include successful `Prazo=21/05/2026` or equivalent. |
| R-003 | HIGH | OPEN | Patch may regress existing skip write semantics. | `Responsavel`, `DataFim`, `Prioridade`, or `HorasRealizadas` could be overwritten by skip tokens or zeros. | Run `tests/Test-AtualizarTarefaSkipSemantics.ps1` and runtime skip retest. Evidence: `.planning/comms/solution_3_8_post_import_export_validation_20260513/RUNTIME_QA_20260513_TASK15.md` is the current comparison baseline. |
| R-004 | HIGH | OPEN | Date normalization may mishandle whitespace, null, ISO input, or invalid dates. | Valid dates could fail, invalid dates could write incorrectly, or preserved date behavior could break. | Static tests must cover blank/skip, ISO `yyyy-MM-dd`, BR `dd/MM/yyyy`, and invalid strings. Runtime must include at least one BR date success and one preserved-date skip success. |
| R-005 | HIGH | OPEN | Package version/export mismatch after owner import. | Runtime tests could target a stale or different artifact, invalidating evidence. | Post-import export must be reviewed before publish/runtime QA. Record package path, SHA256, solution metadata version, and workflow/action bindings. |
| R-006 | HIGH | OPEN | Copilot action/topic binding could point to stale flow metadata. | Bot may call old `PMO_PA_AtualizarTarefa`, reproducing 3.10 or earlier behavior. | Validate `botcomponent_workflowset.xml` and topic/action components in post-import export; runtime run URL must show intended flow. |
| R-007 | MEDIUM | OPEN | Response fix may introduce non-ASCII app-facing text. | Violates project ASCII rule and can cause stop-ship under current baseline. | Run ASCII scan on changed package artifacts and tests. Keep app-facing labels ASCII safe. |
| R-008 | MEDIUM | OPEN | Accepted `gstf_sharepoint` residue could be mistaken for an active runtime dependency. | Misclassification could cause unnecessary tenant delete risk or a false blocker. | Preserve prior accepted residue decision from `.planning/comms/solution_3_8_post_import_export_validation_20260513/EXPORT_3_10_POST_WFSET_CLEAN_REVIEW.md`; verify PMO workflows still reference `pmo_sharedsharepointonline_6e373`. |
| R-009 | MEDIUM | OPEN | Remaining runtime gates outside AtualizarTarefa remain unresolved. | Even after ISSUE-001/002 are fixed, final ship may still be blocked. | Complete or formally accept CMD-12-H, CMD-09, CMD-08, CMD-15, and CMD-10 per `.planning/START_HERE_CURRENT_STATUS.md`. |
| R-010 | MEDIUM | ACCEPTED FOR THIS MISSION | CI gate excluded by owner. | CI evidence will not be available for this SEV-0 control packet. | Treat CI as explicitly excluded only for this mission. Do not waive local static tests, package gates, export review, publish validation, or runtime QA. |
| R-011 | HIGH | CONTROLLED | Tenant writes/imports/publishes/deletes are disallowed for Agent A. | Accidental runtime or environment change would violate golden rules and invalidate incident control. | Agent A creates only the two planning files in this directory. Owner retains import/publish/runtime responsibility unless explicit written delegation is given later. |

## Open Evidence Requirements

| Evidence ID | Required Artifact | Blocks Ship Until |
|---|---|---|
| E-001 | 3.11 local gate report | Static/package gates pass, including targeted AtualizarTarefa response/date regressions. |
| E-002 | 3.11 package SHA256 and source baseline | Exact artifact identity is recorded. |
| E-003 | Post-import export review | Export proves tenant contains intended 3.11 artifact and clean bindings. |
| E-004 | Copilot publish evidence | Owner confirms publish succeeded after import/export review. |
| E-005 | ISSUE-001 runtime retest | Bot response displays effective persisted values after skip inputs. |
| E-006 | ISSUE-002 runtime retest | BR date input succeeds and SharePoint receives/stores ISO-compatible date. |
| E-007 | Regression runtime queue | Explicit update, concluded update, list hidden-deleted, PedirDecisao invalid/valid UPN, portfolio totals, and CMD-10 decision are closed or formally accepted. |

## Current Blocking Risks

The active ship blockers are R-001, R-002, R-005, R-006, and R-009.

No production ship decision should be made until those risks are closed with current evidence tied to the exact imported and published 3.11 artifact.
