# PMO Single Solution Consolidation Plan 3.21

- Agent: Codex #2 Lead
- Scope: consolidate PMO runtime into one canonical solution package
- Source reviewed: `C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_3_20_0_1.zip`
- Source SHA256: `ADD7FD64F23BFE6363265A0C642B9FFA3BEB8C00551AD65093284A2E6070D872`
- Current solution version: `3.20.0.1`
- Target package version: `3.21.0.0`
- Tenant mode: no tenant delete/import/publish without explicit Owner approval

## Executive Decision

Use `PMO_v11_Tarefas` as the only canonical deployable solution.

Do not keep parallel deployable solutions for the same bot/runtime. The current package still contains mixed dependencies from the old runtime and CopilotStudioAccelerator. The consolidation must be done in a reproducible package build, then imported by the Owner, instead of manual random tenant cleanup.

## Current Findings From 3.20.0.1

| Area | Finding | Action |
|---|---|---|
| Package identity | `PMO_v11_Tarefas` version `3.20.0.1`, unmanaged | Keep as canonical source line |
| Runtime mix | New `PM0_PA_Card_*` components coexist with legacy `PMO_PA_*` components | Consolidate by dependency graph, not by name |
| External dependency | `cat_DataverseIndexerSharePoint` and `cat_sharedteams_1ef7e` come from `CopilotStudioAccelerator` | Replace with PMO-owned connection references |
| Missing action target | `PM0_PA_OpsFailureHandling` points to missing flow `9531fbc7-a250-f111-bec7-000d3abc5cc6` | Remove or rebuild explicitly |
| Unused connection ref | `gstf_sharepoint` has no workflow JSON usage | Remove from canonical package |
| Legacy dead flows | `PMO_PA_AtualizarStatus`, `PMO_PA_ConsultarPortfolio` are not workflowset-bound and not referenced by botcomponent flow IDs | Remove after peer review confirmation |
| Legacy still-used flows | Several `PMO_PA_*` flows are still bound to non-card topics | Keep until migrated or confirmed retired |

## Work Split

| Owner | Workstream | Output |
|---|---|---|
| Codex #2 Lead | Build automation and canonical package generation | `3.21.0.0` local package candidate |
| Codex #2 Lead | Dependency graph scanner | JSON/MD graph of topics, actions, workflows, connection refs |
| Codex #2 Lead | Package cleanup script | Reproducible removal/rebind operations |
| Codex #1 Lead | Independent peer review | Blocker review and signoff before Owner import |
| Owner | Tenant writes only | Import package, publish all customizations, publish bot |

## Programmatic Backlog

| ID | Priority | Owner | Task | Acceptance Criteria |
|---|---:|---|---|---|
| CONS-001 | P0 | Codex #2 | Create a reusable package inventory script for solution ZIPs | Script outputs topics/actions/workflows/connection refs/root components/missing dependencies |
| CONS-002 | P0 | Codex #2 | Build a topic -> action -> workflow -> connection reference dependency graph | Every component has `KEEP`, `MIGRATE`, `DELETE_CANDIDATE`, or `INVESTIGATE_FIRST` classification |
| CONS-003 | P0 | Codex #2 | Replace `cat_DataverseIndexerSharePoint` usage in PM0 card flows with PMO-owned SharePoint connection reference | No `cat_DataverseIndexerSharePoint` references remain in workflow JSON |
| CONS-004 | P0 | Codex #2 | Replace `cat_sharedteams_1ef7e` usage with a PMO-owned Teams connection reference | No `cat_sharedteams_1ef7e` references remain in workflow JSON |
| CONS-005 | P0 | Codex #2 | Remove unused `gstf_sharepoint` connection reference from package metadata | No `gstf_sharepoint` root component/customization entry remains |
| CONS-006 | P0 | Codex #2 | Remove `PM0_PA_OpsFailureHandling` action or rebuild it with an included workflow | No action points to a missing flow ID |
| CONS-007 | P0 | Codex #2 | Remove legacy dead workflows `PMO_PA_AtualizarStatus` and `PMO_PA_ConsultarPortfolio` from package | They are absent from `Workflows`, root components, and workflowset |
| CONS-008 | P1 | Codex #2 | Evaluate legacy actions `PMO_PA_AtualizarTarefa`, `PMO_PA_CriarTarefa`, `PMO_PA_ListarTarefas` | Delete only if no topic/action/workflowset dependency remains after graph rebuild |
| CONS-009 | P1 | Codex #2 | Keep or migrate non-card legacy flows still used by active topics | No active topic references a deleted flow/action |
| CONS-010 | P0 | Codex #2 | Generate canonical `3.21.0.0` package candidate locally | Package SHA256 recorded and `solution.xml` version is `3.21.0.0` |
| CONS-011 | P0 | Codex #2 | Run static package gates | StatusID, OrigemEntrada, coalesce, topic binding, workflowset, and dependency checks pass |
| CONS-012 | P0 | Codex #1 | Peer review dependency graph and cleanup decisions | Codex #1 signs off or lists blockers with component IDs |
| CONS-013 | P0 | Codex #1 | Peer review package diff from `3.20.0.1` to `3.21.0.0` | Every removed/changed component has a documented reason |
| CONS-014 | P0 | Owner | Import approved `3.21.0.0` package | Import log has zero activation/validation errors |
| CONS-015 | P0 | Owner | Publish all customizations after import | Power Platform confirms all customizations published |
| CONS-016 | P0 | Codex #2 | Read-only post-import validation | Solution version, workflow activation, AQ-08, bot state, and topic validation pass |
| CONS-017 | P0 | Owner | Publish bot in Copilot Studio | Gate 4B publish succeeds |
| CONS-018 | P0 | Codex #2 | AQ-09 smoke after bot publish | A1-A5 pass |

## Keep List For 3.21

These must stay unless explicitly replaced by an equivalent component in the same package:

| Component | Type | Reason |
|---|---|---|
| `Assistente PMO V2` | Agent | Canonical bot |
| `PM0_PA_Card_AtualizarStatus` | Topic/action/workflow | In-scope PM0 action |
| `PM0_PA_Card_AtualizarTarefa` | Topic/action/workflow | In-scope PM0 action |
| `PM0_PA_Card_CriarTarefa` | Topic/action/workflow | In-scope PM0 action |
| `PM0_PA_Card_ListarTarefas` | Topic/action/workflow | In-scope PM0 action |
| `PM0_PA_Card_ResumoExecutivoPortfolio` | Action/workflow used by `ConsultarPortfolio` | In-scope PM0 action |
| `PMO_PA_CriarProjeto` | Action/workflow | Still called by `CriarProjeto` topic |
| `PMO_PA_ConsultarProjeto` | Workflow | Still bound to active topic |
| `PMO_PA_ExcluirProjeto` | Workflow | Still bound to active topic |
| `PMO_PA_ExcluirTarefa` | Workflow | Still bound to active topic |
| `PMO_PA_PedirDecisaoBot` | Workflow | Still bound to active topic |
| `PMO_PA_RegistrarBloqueioBot` | Workflow | Still bound to active topic |
| `PMO_PA_RegistrarRiscoBot` | Workflow | Still bound to active topic |

## Delete Candidate List

Delete from the canonical package only after graph confirmation and Codex #1 review.

| Component | Type | Reason |
|---|---|---|
| `gstf_sharepoint` | Connection reference | No workflow JSON uses this logical name |
| `PM0_PA_OpsFailureHandling` | Action component | Points to missing workflow ID and no topic calls it |
| `PMO_PA_AtualizarStatus` | Workflow | Legacy flow superseded by PM0 card flow and no package reference found |
| `PMO_PA_ConsultarPortfolio` | Workflow | Legacy flow superseded by PM0 card flow and no package reference found |

## Migration Candidates

These are not deleted in the first cleanup pass unless the graph proves they are fully unused.

| Component | Type | Current Status | Required Decision |
|---|---|---|---|
| `PMO_PA_AtualizarTarefa` | Action/workflow | Workflowset-bound, but no topic call found in package | Remove old action binding or keep for compatibility |
| `PMO_PA_CriarTarefa` | Action/workflow | Workflowset-bound, but no topic call found in package | Remove old action binding or keep for compatibility |
| `PMO_PA_ListarTarefas` | Action/workflow | Workflowset-bound, but no topic call found in package | Remove old action binding or keep for compatibility |
| Remaining non-card `PMO_PA_*` flows | Workflows | Still used by non-card topics | Keep now, migrate later if desired |

## Required Gates Before Owner Import

| Gate | Expected Result |
|---|---|
| Package version | `3.21.0.0` |
| Managed flag | `0` |
| Missing dependencies | No dependency on `CopilotStudioAccelerator` for runtime-critical PM0 flows |
| Topic bindings | All in-scope topics call included action components |
| Workflowset bindings | No binding points to a missing workflow |
| Connection refs | No workflow references removed connection refs |
| StatusID fix | `Create_StatusDiario.inputs.parameters.item/StatusID` present |
| Activation risk scan | No known `0x80040216` trigger pattern |
| Static AQ-08 package scan | PASS |
| Peer review | Codex #1 PASS before Owner import |

## Tenant Execution Boundary

Codex agents can do local package analysis, local package generation, and read-only tenant verification.

Only the Owner performs tenant writes:

1. Import `3.21.0.0`.
2. Publish all customizations.
3. Publish bot.
4. Delete tenant components manually only if a written cleanup ticket says the package no longer depends on them.

## Immediate Next Step

Codex #2 should implement `CONS-001` and `CONS-002` as reusable scripts, then produce a `3.21` cleanup diff. Codex #1 should review the graph before any package is imported.
