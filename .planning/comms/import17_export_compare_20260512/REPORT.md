# Import 17 / Export Compare Report - 2026-05-12

## Artifacts

| Artifact | Path | SHA256 |
|---|---|---|
| Import log | `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (17).xml` | `859CDE92D668E23E1DC492CB69FD7ACCE22E6D18EB684E8303168FE0E36B0D6E` |
| UI export | `C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_2_7.zip` | `ABBAFBD9EDFC6C392CFEDCB5E83A1A43BF05DF9C12BF1A4BE41F3E80F106AF1A` |
| Local package baseline | `Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` | `4B0F2B5597BA1DFD18479A1D213A8DFC1D5D8BEB5B9060F933751CD2B69E90BC` |

## Import Log Findings

- Solution `PMO_v11_Tarefas` imported as version `2.8`, unmanaged.
- All named rows are `Procesado`.
- No named component has `Sin procesar`.
- All workflow activation rows are `Procesado`, including:
  - `PMO_PA_CriarTarefa` `{0a5d2a41-24c0-4d5e-9f6d-000000000241}`
  - `PMO_PA_Gerar_Multiplos_Projetos` `{0a5d2a42-24c0-4d5e-9f6d-000000000241}`
- Warning `0x80045042` appears for workflow replacement rows with message `The original workflow definition has been deactivated and replaced.` This is not a failed import row; subsequent activation rows are clean.

## Export Compare Findings

- File inventory between UI export and local 2.8 package is identical: no missing files on either side.
- All workflow JSON definitions are semantically identical after JSON canonicalization. Raw size/hash differences are formatting/serialization differences from Power Platform export.
- Critical topic/action bindings are preserved:
  - `CriarTarefa` topic uses `BeginDialog`.
  - `CriarTarefa` points to `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`.
  - `customizations.xml` includes workflow rows for `PMO_PA_CriarTarefa` and `PMO_PA_Gerar_Multiplos_Projetos`.
- No Dataverse schema components are present in `customizations.xml`:
  - `<EntityMaps />`
  - `<EntityRelationships />`
  - `<EntityDataProviders />`
  - no `<Entity>` / `<Attribute>` customizations detected.

## Notable Drift

- The UI export file name and exported `solution.xml` show version `2.7`, while the import log shows `2.8`.
- This is not a schema drift and not a workflow definition drift, but it is a release traceability issue. Treat the runtime as requiring Copilot Studio publish verification before SHIP.

## Decision

**NO-SHIP until Copilot Studio publish succeeds and smoke tests pass.**

No major schema break was found in the import log or export comparison. The only issue to track is solution version traceability between import log `2.8` and UI export `2.7`.
