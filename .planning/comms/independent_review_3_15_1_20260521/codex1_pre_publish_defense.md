# Codex 1 Pre-Publish Defense - Hotfix 3.15.1

## 1. Readiness Verdict

Verdict: **PRE_PUBLISH_READY**

The pre-publish defense acceptance gate is satisfied:

- Live topic baseline count: `5 / 5`
- Live workflow baseline count: `12 / 12`
- Rollback ZIP SHA256: exact match
- Staged rollback script: present, marked `DO NOT EXECUTE WITHOUT OWNER APPROVAL`, and PowerShell parser clean

Tenant activity for this defense pass stayed read-only. No solution import, solution publish, rollback execution, SharePoint write, Planner write, Teams post, or Copilot UI mutation was performed.

## 2. Live Topic Baseline

Source field: live Dataverse `botcomponent.data` retrieved with read-only PAC FetchXML for the five in-scope topic rows.

Baseline directory:

```text
.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/topics/
```

| Topic | Baseline file | SHA256 |
|---|---|---|
| AtualizarStatus | `AtualizarStatus.botcomponent_data.live.yaml` | `68274DA1C7A86D6A1B409E0334CE8DAFDD8600234AD3CA53478A97816765F05F` |
| AtualizarTarefa | `AtualizarTarefa.botcomponent_data.live.yaml` | `6A5813393B8888CCA2EC1E26B6A027BDBB7EA0C7BAF32842F48892DEFFBFC1E8` |
| ConsultarPortfolio | `ConsultarPortfolio.botcomponent_data.live.yaml` | `3EA777469B7CD837B73D8476A82FCBE67F771A175AA69A86A8BD98073223DB3C` |
| CriarTarefa | `CriarTarefa.botcomponent_data.live.yaml` | `DB170F205F8F3D3FB0509BB3E3E6A577FEAA44E9F01B3743E25F4E553FD470B6` |
| ListarTarefas | `ListarTarefas.botcomponent_data.live.yaml` | `A90651BAC538BCF29B572A89447F5845F5712146BAD2BB8D09F652944F26CA1A` |

Supporting FetchXML and raw PAC fetch evidence are retained beside the five topic baseline files.

## 3. Live Workflow Baseline

Scope source: the 12 Type `29` `RootComponent` IDs in `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`.

Source field: live Dataverse `workflow.clientdata` retrieved with read-only PAC FetchXML for those 12 workflow IDs.

Baseline directory:

```text
.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/workflows/
```

| Workflow | Workflow ID | Baseline file | SHA256 |
|---|---|---|---|
| PMO_PA_CriarTarefa | `0a5d2a41-24c0-4d5e-9f6d-000000000241` | `PMO_PA_CriarTarefa.clientdata.live.json` | `B6B9C96632EEB33DEAF3C18762A655E6AEBF53AF4C34DAAA68B7D28030AF01FA` |
| PMO_PA_ExcluirProjeto | `16fbe313-2edc-406e-ad7f-d08cee0edc43` | `PMO_PA_ExcluirProjeto.clientdata.live.json` | `F01FD94F85F86FE2E47A1A330D976A01EAEAD91874C2ACF4CBBDC281F19ECB44` |
| PMO_PA_CriarProjeto | `3104124d-364a-f111-bec7-7ced8d955c6c` | `PMO_PA_CriarProjeto.clientdata.live.json` | `7E10E01A8C100A8B4908DFD7FB972ECB4D563E1E4B37BD52FBD8D9C0F79A3602` |
| PMO_PA_ConsultarPortfolio | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | `PMO_PA_ConsultarPortfolio.clientdata.live.json` | `BD8688D0B8F5F0C2C84F0C57819E3247C25593DB6C7DCBB3DA670DFC8B8B5F68` |
| PMO_PA_RegistrarBloqueioBot | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | `PMO_PA_RegistrarBloqueioBot.clientdata.live.json` | `8A1FF59597A9A7FA4369062E93FDBBA3CFEDE3DDCF67D4F2F2426AF3CA3DB442` |
| PMO_PA_ConsultarProjeto | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | `PMO_PA_ConsultarProjeto.clientdata.live.json` | `EF08B2FFBA9435537550D7E3787C323F7F5478538F4CCE32556426D7A341ED0D` |
| PMO_PA_ExcluirTarefa | `70b39334-5926-4fb1-bd22-f10bd99f0f6d` | `PMO_PA_ExcluirTarefa.clientdata.live.json` | `B9DBCA72F51B13EF79A5585A6E1FE18E813519347141B960AEA51143C5248B6B` |
| PMO_PA_ListarTarefas | `9544f14b-3748-f111-bec7-6045bdf42cae` | `PMO_PA_ListarTarefas.clientdata.live.json` | `AD00E5DC75DB247368DAFFAC7AE0177B1D65C087CBAAFB2EC9E4249F4EBCBDD9` |
| PMO_PA_AtualizarTarefa | `98408d55-3748-f111-bec7-000d3abc5cc6` | `PMO_PA_AtualizarTarefa.clientdata.live.json` | `0D137BE3DAA295221327AD73D43B324A75B7A114E015E370A66018D94033BD95` |
| PMO_PA_AtualizarStatus | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | `PMO_PA_AtualizarStatus.clientdata.live.json` | `724E5843A040F479FE8E0A31EB5556A40DD2F4FBD670B6C7CC79B778EB7E2730` |
| PMO_PA_RegistrarRiscoBot | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | `PMO_PA_RegistrarRiscoBot.clientdata.live.json` | `D7789B2958F991C0A20956F3DFD3A3FA011424E9D4D87F3C49F5BE36B0BFA617` |
| PMO_PA_PedirDecisaoBot | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | `PMO_PA_PedirDecisaoBot.clientdata.live.json` | `B3FA708475E11AD0E1A3D29521970C0DA2C1D19E0B0E82A83A3C810BABFCBC68` |

Workflow capture validation evidence:

```text
.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/workflows/workflow_clientdata_live_manifest.json
.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/workflows/workflow_baseline_validation.txt
```

Validation summary: manifest count `12`, JSON baseline file count `12`, hash rows checked `12`, status `PASS`.

## 4. Rollback Drill

Rollback ZIP:

```text
Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip
```

Expected SHA256:

```text
37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691
```

Observed SHA256:

```text
37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691
```

ZIP SHA verification: `MATCH`

Staged rollback script:

```text
.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/rollback_ready.ps1
```

Script status:

- Top marker present: `DO NOT EXECUTE WITHOUT OWNER APPROVAL`
- Confirmation commands staged: `pac auth list` and `pac env who`
- Rollback import command staged with `--force-overwrite --activate-plugins --publish-changes`
- Import command left commented out by default
- PowerShell parser validation via `[scriptblock]::Create(...)`: `PASS`
- Script execution and rollback import: `NOT RUN`

Local PAC CLI `2.6.4` does not expose a `pac solution import --dry-run` option. The script keeps the import block commented instead of staging an unsupported dry-run flag.

## 5. Recovery Time Estimate

Owner start estimate: under 5 minutes if current PAC authentication is valid, because the rollback ZIP path, hash, environment confirmation commands, and import command are already staged in `rollback_ready.ps1`.

Full rollback completion was not runtime-rehearsed by this agent because rollback execution is explicitly prohibited. The existing rollback procedure at `.planning/comms/rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md` still states a 15 minute target from rollback decision to published rollback bot.

## 6. Sign-off

- Agent: `Codex #1`
- UTC timestamp: `2026-05-21T18:36:05Z`
- Time spent: approximately `51 minutes` wall-clock including parallel subagent capture and consolidation

