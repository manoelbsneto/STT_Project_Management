# AQ-07 Status Schema Alignment

Date: 2026-05-15
Owner: CODEX-LEAD
Task ID: AQ-07-STATUS-SCHEMA-ALIGNMENT
Release decision: NO-SHIP

## Verdict

STATUS: SCHEMA_ALIGNMENT_COMPLETE

The SharePoint `Tarefas.Status` blocker found during AQ-07 read-only discovery is resolved.

AQ-07 overall is still not green because Planner `CreateTask_V3` tenant-compatible ProcessSimple save contract remains unproven.

## Product Decision

Chosen path: extend `Tarefas.Status` instead of shrinking AQ-07 behavior to the older four statuses.

Reason:

- Preserves existing task lifecycle values.
- Adds the richer Planner bucket workflow values required by AQ-07.
- Avoids item rewrites and avoids changing existing task records.
- Makes future create/update flows able to write valid SharePoint choice values while keeping legacy values selectable.

## Tenant Actions Performed

Performed:

- SharePoint schema write only: updated the `Status` choice set on list `Tarefas`.

Not performed:

- SharePoint item writes: none.
- Planner writes: none.
- Power Automate flow save/import: none.
- Copilot publish: none.
- Teams production posts: none.
- Microsoft 365 CLI / `m365`: none.
- `pac solution import`: none.

## Final Status Choices

Final read-only XML evidence:

```text
.planning/comms/aq07_power_automate_build_20260515/schema_update_20260515/post_write_schema_final/Tarefas/fields/Status.xml
```

Final choices:

```text
Pendente
Em Andamento
Concluida legacy value preserved
Cancelada legacy value preserved
Testes
Piloto e Implantacao
Concluido
Cancelado
```

The XML export renders the accented legacy value as `ConcluÃ­da`; this is an encoding artifact from the read-only export. The semantic legacy value is `Concluida`.

## Local AQ-07 Rework

Updated canonical AQ-07 new-write status set:

```text
Pendente
Em Andamento
Testes
Piloto e Implantacao
Concluido
Cancelado
```

Updated files:

```text
.planning/comms/aq07_power_automate_build_20260515/Invoke-AQ07ProcessSimpleBuild.ps1
.planning/comms/aq07_power_automate_build_20260515/flows/FI-04_PM0_PA_Card_CriarTarefa.md
.planning/comms/aq07_power_automate_build_20260515/flows/FI-05_PM0_PA_Card_AtualizarTarefa.md
.planning/comms/aq07_power_automate_build_20260515/FIELD_MAPPING.md
.planning/comms/aq07_power_automate_build_20260515/VALIDATION.md
.planning/comms/aq07_power_automate_build_20260515/AQ07_ACCEPTANCE_MATRIX.md
.planning/comms/aq07_power_automate_build_20260515/QUALITY_GATES.md
.planning/comms/aq07_power_automate_build_20260515/AQ07_DELIVERY_DECISION.md
.planning/comms/aq07_power_automate_build_20260515/PACKAGE_MANIFEST.json
.planning/comms/GEMINI_AQ07_EXECUTION_PROMPT_POWER_AUTOMATE_BUILD_SAVE_IMPORT_20260515.md
.planning/comms/GEMINI_AQ07_REWORK_PROMPT_CREATE_STATUS_MAPPING_20260515.md
```

## Validation Performed

Passed:

- `PACKAGE_MANIFEST.json` parses.
- AQ-07 build script parses.
- AQ-07 status schema script parses.
- Build-only generation completed with `BUILD_ONLY_LOCAL_READY`.
- Final read-only SharePoint XML contains legacy choices plus AQ-07 canonical choices.
- No stale lowercase `Em andamento` remains in active AQ-07 flow build files or build script.
- No `UNKNOWN_BLOCKER` remains in active AQ-07 flow build files or build script.
- FI-04 no longer has hard-coded `Status='Pendente'` assignment.

## Remaining Blocker

AQ07-BLOCK-12 remains:

```text
Planner CreateTask_V3 tenant-compatible ProcessSimple parameter shape is still unproven.
```

Do not retry AQ-07 save/import until this is resolved or FI-04/FI-05 are built manually in the Power Automate portal with evidence.

## Current Status

```text
TASK_ID: AQ-07-STATUS-SCHEMA-ALIGNMENT
STATUS: SCHEMA_ALIGNMENT_COMPLETE
AQ-07_OVERALL_STATUS: BLOCKED_CREATE_TASK_CONTRACT
TENANT_ACTIONS_PERFORMED: SharePoint schema choice update only
FORBIDDEN_ACTIONS_CONFIRMED_NOT_PERFORMED: SharePoint item writes, Planner writes, flow save/import, Copilot publish, Teams production posts, m365, pac solution import
RELEASE_DECISION: NO-SHIP
```
