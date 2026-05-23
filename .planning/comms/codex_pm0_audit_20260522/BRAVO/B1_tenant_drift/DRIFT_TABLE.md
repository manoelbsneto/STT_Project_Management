# B1 Tenant Drift Table

Last updated: 2026-05-22 15:32:32 -03:00 | Codex #2 B1 | Consolidated PAC read-only tenant drift evidence

## Evidence Boundary

Only PAC read-only commands were used against environment `e2d10003-4d8e-e007-9d63-76d5fe89ef56`. Identity evidence is in `PAC_OUTPUTS/pac_auth_list.txt` and `PAC_OUTPUTS/pac_env_who.txt`; the active PAC profile is `COLQA0424` for `mbenicios@minsait.com` in `ColOfertasBrasilPro`.

Raw FetchXML and PAC outputs are under `PAC_OUTPUTS/`. Live `workflow.clientdata` was extracted from `pac_fetch_pm0_card_workflow_clientdata.txt`. The field-level comparison flattened local and live JSON leaves and wrote per-flow diff JSON. Empty diff JSON files contain `[]`.

## Consolidated Definition Drift

| Flow | Workflow ID | Live PAC status | Modified | Last successful PAC `flowrun` row | Failed PAC `flowrun` row | Local SHA256 | Live SHA256 | Field drift |
|---|---|---|---|---|---|---|---|---|
| `PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` | `Activado` / `Activado` | `15/05/2026 19:10` | None returned | None returned | `763D9EA3...DDB8` | `E4A63936...CDB2` | `0` |
| `PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` | `Activado` / `Activado` | `15/05/2026 19:10` | None returned | None returned | `C842A77F...3A4C` | `30EC6F70...4B25` | `0` |
| `PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` | `Activado` / `Activado` | `15/05/2026 22:31` | `fd0ab159...af0e9`, `22/05/2026 10:10`, `Succeeded` | None returned | `B5BCD309...0050` | `519DB115...73B3` | `0` |
| `PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` | `Activado` / `Activado` | `15/05/2026 19:10` | None returned | None returned | `9FF2FED6...682F` | `DAE5B72E...9306` | `0` |
| `PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` | `Activado` / `Activado` | `22/05/2026 8:41` | `1c53e508...9ccc`, `22/05/2026 14:42`, `Succeeded` | None returned | `7C9F42DE...ADEE` | `F9FE2992...5EE0` | `0` |

All five local byte hashes differ from the compact live JSON hashes. The field comparisons show zero leaf-level definition differences, so the hash mismatch is formatting/serialization evidence rather than definition drift.

## Binding and Connection Status

| Flow | Copilot action binding | Live connection references from `clientdata` | Connection-reference status evidence | Adaptive Card status |
|---|---|---|---|---|
| `AtualizarStatus` | Active action component bound to expected workflow ID | Teams `cat_sharedteams_1ef7e` | Owner `Manoel Benicio De Souza Filho`; `Activa`; backing PAC connection `Connected` | Applicable: live `Post_Status_Card` posts Adaptive Card `1.5` through Teams `PostCardToConversation` |
| `AtualizarTarefa` | Active action component bound to expected workflow ID | SharePoint `cat_DataverseIndexerSharePoint`; Planner `pmo_sharedplanner_87b5f` | Both owner/status rows returned as `Manoel Benicio De Souza Filho` / `Activa`; backing PAC connections `Connected` | No Teams adaptive-card post action in live JSON |
| `ResumoExecutivoPortfolio` | Active action component bound to expected workflow ID | SharePoint `pmo_cat_DataverseIndexerSharePoint` | Owner `Manoel Benicio De Souza Filho`; `Activa`; backing PAC connection `Connected` | No Teams adaptive-card post action in live JSON |
| `CriarTarefa` | Active action component bound to expected workflow ID | SharePoint `cat_DataverseIndexerSharePoint`; Planner `pmo_sharedplanner_87b5f` | Both owner/status rows returned as `Manoel Benicio De Souza Filho` / `Activa`; backing PAC connections `Connected` | No Teams adaptive-card post action in live JSON |
| `ListarTarefas` | Active action component bound to expected workflow ID | SharePoint `cat_DataverseIndexerSharePoint`; Planner `pmo_sharedplanner_87b5f` | Both owner/status rows returned as `Manoel Benicio De Souza Filho` / `Activa`; backing PAC connections `Connected` | No Teams adaptive-card post action in live JSON |

Binding rows are in `pac_fetch_pm0_card_botcomponent_workflow_bindings.txt`. Action component data in `pac_fetch_pm0_card_action_botcomponents.txt` shows each `InvokeFlowTaskAction.flowId` points to the expected workflow ID and exposes `result`.

## Bot Publish-History Result

Approved PAC FetchXML captured the current `bot` row in `pac_fetch_assistente_pmo_v2_bot_current.txt`. It shows:

- Bot: `Assistente PMO V2`, schema `pmo_AssistentePMO_V2`, state `Activo`, component state `Publicado`.
- `publishedon`: `22/05/2026 14:40` in PAC display.
- `synchronizationstatus.lastFinishedPublishOperation`: start `2026-05-22T17:40:01.6763587Z`, end `2026-05-22T17:40:38.1069122Z`, status `Succeeded`.
- `synchronizationstatus.lastPublishedOnUtc`: `2026-05-22T17:40:36.5620391`.

PAC FetchXML did not return a full publish timeline since `2026-05-15`. The scoped `audit` query for the bot ID and date floor returned `No results returned` in `pac_fetch_assistente_pmo_v2_bot_audit_since_20260515.txt`. B1 therefore preserves latest publish evidence but records the requested historical timeline as unavailable through the approved PAC FetchXML evidence captured here.

## Run-History Route Notes

The first `flowrun` query attempt filtered on invalid logical attribute `flowid`; PAC returned the exact error in `pac_fetch_pm0_card_flowrun_attempt.txt`. The column probe showed the `flowrun` table is readable, and the corrected target query filters by logical lookup attribute `workflow` in `fetch_pm0_card_flowruns_by_workflow.xml`.

The corrected target query returned successful rows for `PM0_PA_Card_ListarTarefas` and `PM0_PA_Card_ResumoExecutivoPortfolio` only. It returned no failed rows for the five target workflow IDs and no rows at all for `PM0_PA_Card_AtualizarStatus`, `PM0_PA_Card_AtualizarTarefa`, or `PM0_PA_Card_CriarTarefa`.

## Per-Flow Reports

- `PM0_PA_Card_AtualizarStatus_live_vs_local.md`
- `PM0_PA_Card_AtualizarTarefa_live_vs_local.md`
- `PM0_PA_Card_ResumoExecutivoPortfolio_live_vs_local.md`
- `PM0_PA_Card_CriarTarefa_live_vs_local.md`
- `PM0_PA_Card_ListarTarefas_live_vs_local.md`
