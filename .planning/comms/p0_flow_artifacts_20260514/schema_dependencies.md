# Schema Dependencies

Date: 2026-05-14
Scope: AQ-05 local planning only
Release decision: NO-SHIP

## SharePoint Lists

The local flow artifacts depend on these SharePoint lists:

| List | Use | Access type |
|---|---|---|
| `Projetos` | Project resolution, portfolio summary, Planner project config | Read; update for PM status after approval |
| `Status Diario` | PM status update history | Create after card confirmation |
| `Riscos e Bloqueios` | Portfolio risks and PM risk/blocker entries | Read and create after approval |
| `Decisoes do Board` | Executive pending decision counts | Read |
| `Tarefas` | Task list/create/update and Planner sync mapping | Read/create/update after approval |

## Required `Tarefas` Planner Fields

AQ-03 completed on 2026-05-15. These fields are now confirmed live in `Tarefas`.

| Display Name | Internal Name | Type | Required | Choices |
|---|---|---|---:|---|
| Planner Task ID | `PlannerTaskId` | Single line text | No | N/A |
| Planner Bucket ID | `PlannerBucketId` | Single line text | No | N/A |
| Planner Sync Status | `PlannerSyncStatus` | Choice | No | `Pendente`, `OK`, `Erro`, `Ignorado` |
| Planner Last Sync At | `PlannerLastSyncAt` | Date and time | No | N/A |
| Planner Sync Error | `PlannerSyncError` | Multiple lines text | No | N/A |

## Planner Dependencies

AQ-04 owner-provided Planner Standard connector evidence is accepted for local planning constants.

Canonical Planner context:

| Item | Value |
|---|---|
| Group / Team name | `Grp_T_DN_Transformacao_Digital` |
| `groupId` | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| Planner plan name | `Desenvolvimento de Software` |
| `planId` | `-1kBj1PLv0qQM-R4PwkqbpcABv_P` |
| Connector | `shared_planner` |

Canonical bucket mapping:

| Bucket / list | `bucketId` |
|---|---|
| `Piloto e Implantacao` | `4YAXH7iU9E-6jZE2P1DbG5cAMAzH` |
| `Testes` | `7QYPufh54kum7MP4KUzzAZcAL6Ik` |
| `Cancelado` | `90TcFTFup0CjiHIdzY4gG5cALWKL` |
| `Concluido` | `F2WYUsnXeEue5qlwQuu3GJcAN1Ns` |
| `Em andamento` | `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG` |
| `Pendente` | `HmzyGOgC4k6uOPm_cwG3zZcAGiAG` |

No P0 flow may add, delete, rename, or reorder Planner buckets.

AQ-04 does not authorize Planner writes. Runtime use of these IDs still requires owner-approved flow implementation, SharePoint schema readiness, and tenant execution approval.

## Schema Reconciliation Required Before Runtime

Before AQ-07/AQ-09, CODEX-LEAD must reconcile:

1. Actual internal field names in `Projetos`, `Status Diario`, `Riscos e Bloqueios`, and `Decisoes do Board`.
2. Whether `Deleted`, `Ativo`, and status fields use boolean, number, text, choice, or localized internal names.
3. Whether `ProjectID`, `TaskID`, and `NomeProjeto` filters are valid OData filters for the target lists.
4. Whether task fields use `Titulo`, `Title`, or another internal name.
5. Live `Tarefas.Status` choices from AQ-03 evidence must be mapped from canonical card values before SharePoint updates.
6. Whether future project-specific Planner configuration should use these AQ-04 constants directly or a governed SharePoint configuration field.

AQ-05 did not perform schema writes. AQ-03 later performed the approved schema write and captured evidence at `.planning/comms/AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md`.
