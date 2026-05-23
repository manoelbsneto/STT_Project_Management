# Forensic Tenant State - Incident 3.15.1

Date: 2026-05-21 BRT
Environment: `ColOfertasBrasilPro`
Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`
Surface: Power Platform Solutions framework, Dataverse solution import, PAC CLI FetchXML read-only evidence.

## Read-Only Route

No tenant write was executed. Evidence was captured with:

```powershell
pac auth list
pac env who
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <FetchXML file>
pac modelbuilder build --entitynamesfilter solutioncomponent --outdirectory <local evidence folder>
```

Primary evidence folder:

```text
.planning/comms/incident_3_15_1_import_failure_20260521/codex_phd_analysis/evidence/
```

## Headline Result

- `PMO_v11_Tarefas` is still version `3.15` in the tenant.
- All 12 in-scope `PMO_PA_*` workflow rows queried by known workflow ID are `statecode=Activado` and `statuscode=Activado`.
- All 12 post-failure `workflow.clientdata` payload hashes match the pre-publish live baseline.
- All 5 in-scope topic botcomponent PAC raw `data` fetches are byte-equal to the pre-publish live PAC raw baselines.
- Solutioncomponent rows exist for all five botcomponent IDs. Dataverse range-filter proof over those rows establishes canonical live `solutioncomponent.componenttype = 10163` for the ten matched rows.

## PAC Auth And Environment Evidence

Evidence:

- `evidence/pac_auth_list.txt`
- `evidence/pac_env_who.txt`

Observed active PAC context:

| Field | Value |
|---|---|
| User | `mbenicios@minsait.com` |
| Environment | `ColOfertasBrasilPro` |
| Environment URL | `https://colofertasbrasilpro.crm4.dynamics.com/` |
| PAC version | `2.6.4+ga488322` |

## Solution Version

FetchXML:

- `evidence/fetch_solution_pmo_v11_tarefas.xml`

Raw PAC output:

- `evidence/pac_fetch_solution_pmo_v11_tarefas.txt`

| Unique name | Friendly name | Version | Managed | Modified on from PAC |
|---|---|---:|---|---|
| `PMO_v11_Tarefas` | `PMO v1.1 - Task Management Topics` | `3.15` | `No administrada` | `14/05/2026 15:03` |

Conclusion: the failed import did not leave solution version `3.15.1` installed.

## Workflow Runtime State

Accepted workflow-state FetchXML:

- `evidence/fetch_workflow_runtime_state_supported_columns.xml`
- `evidence/pac_fetch_workflow_runtime_state_supported_columns.txt`

Rejected probes retained as evidence:

- `evidence/pac_fetch_workflow_runtime_state.txt`: Dataverse rejected `workflow.isactive`.
- `evidence/pac_fetch_workflow_runtime_state_supported.txt`: Dataverse rejected `workflow.crmversion`.

`workflow.isactive` and `workflow.crmversion` were requested by the incident prompt, but those logical attributes are not available on the Dataverse `workflow` table through this tenant FetchXML path. They are therefore recorded as `NOT QUERYABLE IN THIS PAC FETCHXML PATH`, not inferred.

| Workflow | Workflow ID | StateCode | StatusCode | IsActive | CRMVersion | Clientdata vs pre-publish |
|---|---|---|---|---|---|---|
| `PMO_PA_AtualizarStatus` | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_AtualizarTarefa` | `98408d55-3748-f111-bec7-000d3abc5cc6` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_ConsultarPortfolio` | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_ConsultarProjeto` | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_CriarProjeto` | `3104124d-364a-f111-bec7-7ced8d955c6c` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_CriarTarefa` | `0a5d2a41-24c0-4d5e-9f6d-000000000241` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_ExcluirProjeto` | `16fbe313-2edc-406e-ad7f-d08cee0edc43` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_ExcluirTarefa` | `70b39334-5926-4fb1-bd22-f10bd99f0f6d` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_ListarTarefas` | `9544f14b-3748-f111-bec7-6045bdf42cae` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_PedirDecisaoBot` | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_RegistrarBloqueioBot` | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |
| `PMO_PA_RegistrarRiscoBot` | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | `Activado` | `Activado` | Not queryable | Not queryable | SHA256 equal |

Definition drift evidence:

- `evidence/pac_fetch_workflow_clientdata_post_failure.txt`
- `evidence/workflow_clientdata_post_failure_split/workflow_clientdata_live_manifest.json`
- `evidence/workflow_clientdata_hash_compare.txt`

The PAC raw workflow fetch hash changed because PAC table rendering includes row context. Per-workflow `clientdata` hashes are the deterministic comparison and all 12 are equal to the baseline manifest.

## Five In-Scope Botcomponents

Inventory FetchXML:

- `evidence/fetch_botcomponents_in_scope.xml`
- `evidence/pac_fetch_botcomponents_in_scope.txt`

Post-failure single-topic payload captures:

- `evidence/pac_fetch_AtualizarStatus_botcomponent_data_post_failure.raw.txt`
- `evidence/pac_fetch_AtualizarTarefa_botcomponent_data_post_failure.raw.txt`
- `evidence/pac_fetch_ConsultarPortfolio_botcomponent_data_post_failure.raw.txt`
- `evidence/pac_fetch_CriarTarefa_botcomponent_data_post_failure.raw.txt`
- `evidence/pac_fetch_ListarTarefas_botcomponent_data_post_failure.raw.txt`
- `evidence/topic_raw_fetch_hash_compare.txt`

| Topic | Botcomponent ID | Schema name | StateCode | StatusCode | Botcomponent componenttype display | PAC raw topic data vs baseline |
|---|---|---|---|---|---|---|
| `AtualizarStatus` | `ec4416d0-0744-4e8c-b937-aae4ad9c605b` | `pmo_AssistentePMO_V2.topic.AtualizarStatus` | `Activo` | `Activo` | `Tema (V2)` | Byte-equal |
| `AtualizarTarefa` | `6750ff2f-822b-45ab-83ec-058704c7808a` | `pmo_AssistentePMO_V2.topic.AtualizarTarefa` | `Activo` | `Activo` | `Tema (V2)` | Byte-equal |
| `ConsultarPortfolio` | `74c5fdcc-c121-452e-85af-24d3f260b3c7` | `pmo_AssistentePMO_V2.topic.ConsultarPortfolio` | `Activo` | `Activo` | `Tema (V2)` | Byte-equal |
| `CriarTarefa` | `bcbecd76-3158-40ac-b225-5ae7c3874ed1` | `pmo_AssistentePMO_V2.topic.CriarTarefa` | `Activo` | `Activo` | `Tema (V2)` | Byte-equal |
| `ListarTarefas` | `d58258b4-b17f-4bb9-9e1f-161287a041c4` | `pmo_AssistentePMO_V2.topic.ListarTarefas` | `Activo` | `Activo` | `Tema (V2)` | Byte-equal |

## Solutioncomponent Rows For The Five Topic IDs

Solutioncomponent row FetchXML:

- `evidence/fetch_solutioncomponents_for_in_scope_botcomponents.xml`
- `evidence/pac_fetch_solutioncomponents_for_in_scope_botcomponents.txt`
- `evidence/fetch_solutioncomponents_componenttype_not_null_probe.xml`
- `evidence/pac_fetch_solutioncomponents_componenttype_not_null_probe.txt`

PAC table output leaves `solutioncomponent.componenttype` blank for these rows. The field is not null: the not-null probe returns the same ten rows. Aggregate grouping also returns one blank-rendered group with row count ten:

- `evidence/pac_fetch_solutioncomponents_componenttype_aggregate_probe.txt`

Canonical integer proof:

- Range `10000..99999` returns count ten: `evidence/pac_fetch_solutioncomponents_componenttype_range_10000_99999.txt`
- Narrowed PAC range probes are saved as `evidence/pac_fetch_solutioncomponent_componenttype_range_probe_2.txt` through `probe_7.txt`
- Exact equality probe returns count zero for `10162` and count ten for `10163`: `evidence/pac_fetch_solutioncomponent_componenttype_range_probe_7.txt`

Therefore, for the matched live solutioncomponent rows below:

```text
solutioncomponent.componenttype = 10163
```

| Solutioncomponent ID | Object ID | Canonical live componenttype | Root component behavior |
|---|---|---:|---|
| `27d59178-154a-f111-bec7-000d3abc5cc6` | `6750ff2f-822b-45ab-83ec-058704c7808a` | `10163` | `Incluir subcomponentes` |
| `29d59178-154a-f111-bec7-000d3abc5cc6` | `6750ff2f-822b-45ab-83ec-058704c7808a` | `10163` | `Incluir subcomponentes` |
| `30d59178-154a-f111-bec7-000d3abc5cc6` | `74c5fdcc-c121-452e-85af-24d3f260b3c7` | `10163` | `Incluir subcomponentes` |
| `31d59178-154a-f111-bec7-000d3abc5cc6` | `74c5fdcc-c121-452e-85af-24d3f260b3c7` | `10163` | `Incluir subcomponentes` |
| `40d59178-154a-f111-bec7-000d3abc5cc6` | `bcbecd76-3158-40ac-b225-5ae7c3874ed1` | `10163` | `Incluir subcomponentes` |
| `41d59178-154a-f111-bec7-000d3abc5cc6` | `bcbecd76-3158-40ac-b225-5ae7c3874ed1` | `10163` | `Incluir subcomponentes` |
| `49d59178-154a-f111-bec7-000d3abc5cc6` | `ec4416d0-0744-4e8c-b937-aae4ad9c605b` | `10163` | `Incluir subcomponentes` |
| `4ad59178-154a-f111-bec7-000d3abc5cc6` | `ec4416d0-0744-4e8c-b937-aae4ad9c605b` | `10163` | `Incluir subcomponentes` |
| `2ed59178-154a-f111-bec7-000d3abc5cc6` | `d58258b4-b17f-4bb9-9e1f-161287a041c4` | `10163` | `Incluir subcomponentes` |
| `2fd59178-154a-f111-bec7-000d3abc5cc6` | `d58258b4-b17f-4bb9-9e1f-161287a041c4` | `10163` | `Incluir subcomponentes` |

## Evidence Limitations

1. PAC FetchXML did not expose `workflow.isactive` or `workflow.crmversion` because those attributes are not present on the live `workflow` entity in this query path. The rejection outputs are retained.
2. PAC displays the five topic solutioncomponent choice value as blank. Exact Dataverse filter counts prove the live value `10163`; the report does not infer that number from a label.
3. This capture is read-only forensic evidence. It proves current queried row state and hashes; it is not a runtime bot smoke test.

