# Codex Forensics Audit - PMO Stop-Ship GAP-A1 through GAP-C1

Date: 2026-05-07
Agent: Codex / Agent B forensics
Scope: Programmatic evidence only. No browser actions. No deletion actions. Source files under `.planning/stop_ship`, V2 YAML, RCA, live export, and `EVIDENCE_LOG.md` were read only.

## Source Set Reviewed

- `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml`
- `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml`
- `.planning/stop_ship/AssistentePMO_Clean_EXTRACTED.yaml`
- `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/`
- `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md`
- `.planning/stop_ship/ISSUE_RCA_PACK.md`
- `.planning/stop_ship/EVIDENCE_LOG.md`
- `.planning/stop_ship/*_20260506.txt`, `.planning/stop_ship/*_20260507_1335.txt`
- `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md` for GAP definitions

## Commands Used

```powershell
Get-ChildItem -Force .planning\stop_ship
Get-ChildItem -Force .planning\stop_ship\live_export -Recurse
rg --files -g "*.yml" -g "*.yaml" -g "*RCA*" -g "EVIDENCE_LOG.md" .planning
rg -n "GAP-A1|GAP-A2|GAP-B1|GAP-B2|GAP-B3|GAP-B4|GAP-B5|GAP-B6|GAP-B7|GAP-C1" .planning
rg -n "PMO_PA_CriarTarefa_V3|3104124d|Fluxo V3 chamado" .planning\stop_ship .planning\CODEX_DEPLOYMENT_PLAN_20260507.md
rg -n "flowId: 42d9abd1|dialog: pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa|PMO_PA_CriarTarefa_V3|3104124d" .planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked
rg -n "BooleanPrebuiltEntity" .planning\stop_ship\AssistentePMO_V2_TEMPLATE.yaml .planning\stop_ship\AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml .planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked\botcomponents
rg -n "displayName: ConsultarPortfolio|displayName: ConsultarProjeto|displayName: RegistrarRisco|displayName: RegistrarBloqueio|displayName: PedirDecisao|displayName: AtualizarStatus|displayName: CriarTarefa|BeginDialog|SendActivity|BooleanPrebuiltEntity|dialog:" .planning\stop_ship\AssistentePMO_V2_TEMPLATE.yaml .planning\stop_ship\AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml
rg -n "NomeProjeto|PostItem|Create_Projeto_SharePoint|Get_Duplicate_Projects|item/ProjectID|item/PM/Claims|Tarefas|Projetos|dataset|table|DataAlvo" .planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked\Workflows\Clean_PMO_PA_CriarTarefa-42D9ABD1-8849-F111-BEC7-7CED8D955C6C.json
rg -n "pmo_AssistentePMO_Clean|pmo_AssistentePMO_V2|Assistente PMO Clean|Assistente PMO V2|CriarTarefa|PMO_PA_CriarTarefa|42d9abd1|3104124d|71f62da4|04b1acfe" .planning\stop_ship\v2_criartarefa_components_after_fix_20260507_1335.txt .planning\stop_ship\v2_criartarefa_bindings_after_fix_20260507_1335.txt .planning\stop_ship\v2_copilot_list_after_publish_20260507_1335.txt .planning\stop_ship\rnd_bot_rows_20260506.txt .planning\stop_ship\rnd_botcomponents_by_parent_20260506.txt .planning\stop_ship\t007_botcomponents_after_clean_schema_fix_20260506.txt .planning\stop_ship\t007_workflow_bindings_after_clean_schema_fix_20260506.txt
Select-String -Path .planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked\Assets\botcomponent_workflowset.xml -Pattern "PMO_PA_CriarTarefa|workflowid"
```

Read-only topic summary command:

```powershell
$root = Resolve-Path '.planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked\botcomponents'
$topics = 'ConsultarPortfolio','ConsultarProjeto','RegistrarRisco','RegistrarBloqueio','PedirDecisao','AtualizarStatus','CriarTarefa'
$rows = foreach ($topic in $topics) {
  $file = Join-Path $root "pmo_AssistentePMO_V2.topic.$topic\data"
  $text = Get-Content -Raw -LiteralPath $file
  [pscustomobject]@{
    Topic = $topic
    BeginDialog = ([regex]::Matches($text, 'kind:\s*BeginDialog')).Count
    SendActivity = ([regex]::Matches($text, 'kind:\s*SendActivity')).Count
    BooleanPrebuiltEntity = ([regex]::Matches($text, 'BooleanPrebuiltEntity')).Count
    DialogRefs = (($text -split "`n") | Where-Object { $_ -match '^\s*dialog:' } | ForEach-Object { $_.Trim() }) -join '; '
  }
}
$rows | Format-Table -AutoSize
```

Output summary:

| Topic | BeginDialog | SendActivity | BooleanPrebuiltEntity | DialogRefs |
|---|---:|---:|---:|---|
| ConsultarPortfolio | 0 | 1 | 0 | none |
| ConsultarProjeto | 0 | 1 | 0 | none |
| RegistrarRisco | 0 | 2 | 1 | none |
| RegistrarBloqueio | 0 | 2 | 1 | none |
| PedirDecisao | 0 | 2 | 1 | none |
| AtualizarStatus | 1 | 2 | 1 | `pmo_AssistentePMO_V2.action.PMO_PA_CheckInOnDemand` |
| CriarTarefa | 1 | 2 | 1 | `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` |

## GAP Definitions

The active gap list is defined in `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:129-138`:

- GAP-A1: V3 Flow has no real SharePoint logic.
- GAP-A2: `CriarTarefa` topic binds to dead flow `42d9abd1`.
- GAP-B1: `ConsultarPortfolio` is a stub.
- GAP-B2: `ConsultarProjeto` is a stub.
- GAP-B3: `RegistrarRisco` confirms but never writes.
- GAP-B4: `RegistrarBloqueio` confirms but never writes.
- GAP-B5: `PedirDecisao` confirms but never writes.
- GAP-B6: `AtualizarStatus` asks field-by-field, STT-incompatible.
- GAP-B7: `BooleanPrebuiltEntity` breaks STT confirmation.
- GAP-C1: Ghost bot components in Dataverse.

## Findings

### GAP-A1 - V3 Flow Has No Real SharePoint Logic

Status: Open, with partial RCA-only evidence. Programmatic export evidence is insufficient to prove the current UI-created V3 definition because V3 is not present in the inspected live export.

Evidence:

- RCA states current V3 condition: `FlowNotFound` resolved for UI-created `PMO_PA_CriarTarefa_V3`, topic can call V3 and receive `Fluxo V3 chamado com sucesso.`, but V3 is still a stub and does not write to SharePoint: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:16-19`.
- RCA identifies V3 workflow ID `3104124d-364a-f111-bec7-7ced8d955c6c`: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:33-34`, `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:112-118`.
- RCA read-only SharePoint verification found `MatchCount: 0` for the checked Tarefas markers: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:201-225`.
- RCA conclusion is explicit: `V3 is callable but is still a stub. It does not write to SharePoint yet.` at `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:234`.
- Inspected old flow `Clean_PMO_PA_CriarTarefa` writes to `Projetos`, not `Tarefas`: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/Workflows/Clean_PMO_PA_CriarTarefa-42D9ABD1-8849-F111-BEC7-7CED8D955C6C.json:95-106`, `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/Workflows/Clean_PMO_PA_CriarTarefa-42D9ABD1-8849-F111-BEC7-7CED8D955C6C.json:127-153`.
- `rg -n "PMO_PA_CriarTarefa_V3|3104124d" .planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked` returned no matches, so V3 is not evidenced in the inspected export.

Unverified browser-dependent claims:

- Whether the current Copilot Studio UI V3 flow still exists, is published, and is callable now.
- Whether any post-RCA UI edit added real SharePoint write logic after the inspected export/RCA.
- Whether the browser/UI run creates a `Tarefas` or `Projetos` item in the target tenant.

### GAP-A2 - CriarTarefa Topic Binds To Dead Flow `42d9abd1`

Status: Confirmed open in inspected V2 YAML and live export. RCA claims a UI rebind to V3, but that claim is not present in the inspected export and requires Opus browser evidence.

Evidence:

- V2 live YAML topic calls template action: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:755-758`.
- V2 live YAML action still has `flowId: 42d9abd1-8849-f111-bec7-7ced8d955c6c`: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:827-869`.
- V2 template has the same old action binding: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:927-930`, `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:1088-1125`.
- Live export topic calls `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.CriarTarefa/data:156-159`.
- Live export action uses `flowId: 42d9abd1-8849-f111-bec7-7ced8d955c6c`: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa/data:30-34`.
- Live export workflow binding points V2 action to `42d9abd1`: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/Assets/botcomponent_workflowset.xml:23`.
- Post-fix Dataverse text export still shows V2 action bound to `42d9abd1`: `.planning/stop_ship/v2_criartarefa_bindings_after_fix_20260507_1335.txt:5`.
- RCA says the UI-created V3 and topic edit removed `FlowNotFound`: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:142-156`, but this is not reflected in the inspected live export.

Unverified browser-dependent claims:

- Whether the current Copilot Studio browser UI now binds `CriarTarefa` to `PMO_PA_CriarTarefa_V3`.
- Whether a fresh published test no longer routes to `42d9abd1`.
- Whether browser-visible tool registration matches the Dataverse/export rows.

### GAP-B1 - ConsultarPortfolio Is A Stub

Status: Confirmed open in live export and V2 YAML.

Evidence:

- V2 live YAML defines `ConsultarPortfolio` with only a `SendActivity`: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:344-367`.
- V2 template defines `ConsultarPortfolio` with only a `SendActivity`: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:427-450`.
- Live export data has no `BeginDialog`; it sends static text instructing future queries such as `consultar lista Projetos`: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.ConsultarPortfolio/data:6-24`.
- Read-only summary counted `BeginDialog=0`, `SendActivity=1`, `DialogRefs=none`.

Unverified browser-dependent claims:

- Whether a post-export UI change added a real `PMO_PA_ConsultarPortfolio` tool or live data retrieval.
- Whether browser chat can return real portfolio counts from SharePoint.

### GAP-B2 - ConsultarProjeto Is A Stub

Status: Confirmed open in live export and V2 YAML.

Evidence:

- V2 live YAML defines `ConsultarProjeto` with a question plus `SendActivity`, no flow call: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:969-998`.
- V2 template is equivalent: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:361-390`.
- Live export sends static placeholders like `consultar Projetos.StatusRAG`, `consultar Projetos.Percentual`, and `consultar Riscos e Bloqueios`: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.ConsultarProjeto/data:22-31`.
- Read-only summary counted `BeginDialog=0`, `SendActivity=1`, `DialogRefs=none`.

Unverified browser-dependent claims:

- Whether a post-export UI change added live `ConsultarProjeto` retrieval.
- Whether browser chat can retrieve a real project by `ProjectID` or project name.

### GAP-B3 - RegistrarRisco Confirms But Never Writes

Status: Confirmed open in live export and V2 YAML.

Evidence:

- V2 live YAML defines `RegistrarRisco` as "confirma antes de qualquer gravacao" but has no `BeginDialog` or write action in the confirmed branch; it sends a message only: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:480-537`.
- V2 template is equivalent: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:17-74`.
- Live export confirmed branch sends text saying the write "deve criar item" but does not call a flow: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.RegistrarRisco/data:34-47`.
- Read-only summary counted `BeginDialog=0`, `SendActivity=2`, `BooleanPrebuiltEntity=1`, `DialogRefs=none`.

Unverified browser-dependent claims:

- Whether a post-export UI change added a write path for `Riscos e Bloqueios`.
- Whether browser chat creates a SharePoint risk item and triggers escalation for critical severity.

### GAP-B4 - RegistrarBloqueio Confirms But Never Writes

Status: Confirmed open in live export and V2 YAML.

Evidence:

- V2 live YAML defines `RegistrarBloqueio` with no `BeginDialog` or write action; confirmed branch sends a message only: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:415-472`.
- V2 template is equivalent: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:464-521`.
- Live export confirmed branch says write "deve criar item em Riscos e Bloqueios" but contains no flow call: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.RegistrarBloqueio/data:34-47`.
- Read-only summary counted `BeginDialog=0`, `SendActivity=2`, `BooleanPrebuiltEntity=1`, `DialogRefs=none`.

Unverified browser-dependent claims:

- Whether a post-export UI change added a write path for blockers.
- Whether browser chat creates a SharePoint blocker item.

### GAP-B5 - PedirDecisao Confirms But Never Writes

Status: Confirmed open in live export and V2 YAML.

Evidence:

- V2 live YAML defines `PedirDecisao` with no `BeginDialog` or write action; confirmed branch sends a message only: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:17-88`.
- V2 template is equivalent: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:529-600`.
- Live export confirmed branch says SharePoint recording "deve criar item em Decisoes do Board" and then the SharePoint-triggered flow should run, but the topic itself has no write action: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.PedirDecisao/data:48-61`.
- Read-only summary counted `BeginDialog=0`, `SendActivity=2`, `BooleanPrebuiltEntity=1`, `DialogRefs=none`.
- Direct SharePoint-triggered decision flow paths have evidence from manually created rows, but that does not prove the bot topic writes the row: `.planning/stop_ship/EVIDENCE_LOG.md:42-51`.

Unverified browser-dependent claims:

- Whether a post-export UI change added a bot write path to `Decisoes do Board`.
- Whether browser chat creates a decision item that triggers `PMO_PA_RegistrarDecisaoBoard`.

### GAP-B6 - AtualizarStatus Asks Field-By-Field, STT-Incompatible

Status: Confirmed open in inspected V2 YAML/live export. The topic calls a real flow, but the collection UX is field-by-field and still uses Boolean confirmation.

Evidence:

- V2 live YAML asks separate questions for project/status/responsible/resumo/risco/proxima acao/percentual/confirmation: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:881-944`.
- V2 live YAML calls `PMO_PA_CheckInOnDemand` only after confirmation: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:946-956`.
- V2 template has the same field-by-field structure: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:82-157`.
- Live export shows the same topic asks separate variables and uses `BooleanPrebuiltEntity` at confirmation: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarStatus/data:20-56`.
- Live export confirmed branch calls `pmo_AssistentePMO_V2.action.PMO_PA_CheckInOnDemand`: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarStatus/data:64-66`.

Unverified browser-dependent claims:

- Whether a post-export UI edit redesigned this topic for single long STT input.
- Whether a browser test with natural spoken/multiline input populates all fields correctly.

### GAP-B7 - BooleanPrebuiltEntity Breaks STT Confirmation

Status: Not fixed in inspected V2 template, V2 live YAML, or live export. This conflicts with the deployment plan's claim that GAP-B7 is fixed in template.

Evidence:

- Deployment plan marks GAP-B7 as fixed in template: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:137`, but later says confirm-before-action is only partial and not yet published: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:300`.
- V2 template still contains `BooleanPrebuiltEntity` in six topic confirmations: `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:61`, `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:145`, `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:508`, `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:587`, `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:894`, `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml:1020`.
- V2 live YAML also contains six `BooleanPrebuiltEntity` confirmations: `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:75`, `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:167`, `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:459`, `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:524`, `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:722`, `.planning/stop_ship/AssistentePMO_V2_live_after_flownotfound_20260507_1342.yaml:944`.
- Live export contains the same six confirmation uses: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.CriarTarefa/data:123`, `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data:64`, `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.RegistrarRisco/data:37`, `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarStatus/data:56`, `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.RegistrarBloqueio/data:37`, `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/botcomponents/pmo_AssistentePMO_V2.topic.PedirDecisao/data:51`.
- RCA says `BooleanPrebuiltEntity` behaved poorly for pt-BR and `StringPrebuiltEntity` with explicit text matching made `sim` work: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:172-174`, `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:307-309`.
- RCA final status says `sim` confirmation passed, but topic end-after-success still needs publish verification: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:458-460`.

Unverified browser-dependent claims:

- Whether Copilot Studio code editor now has a post-export version with `StringPrebuiltEntity` and explicit `sim` matching.
- Whether a fresh browser session confirms `sim` works for all topics, not only the V3 CriarTarefa path.

### GAP-C1 - Ghost Bot Components In Dataverse

Status: Confirmed open programmatically. No cleanup was performed.

Evidence:

- Deployment plan lists GAP-C1 as open and human-delete gated: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:138`, `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:235`, `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md:304`.
- `pac copilot list` output after publish shows both `Assistente PMO Clean` and `Assistente PMO V2` published/active/provisioned: `.planning/stop_ship/v2_copilot_list_after_publish_20260507_1335.txt:4`, `.planning/stop_ship/v2_copilot_list_after_publish_20260507_1335.txt:10`.
- May 6 Dataverse bot rows show `Assistente PMO Clean` exists: `.planning/stop_ship/rnd_bot_rows_20260506.txt:7`.
- Component inventory shows many `pmo_AssistentePMO_Clean.*` components coexisting with V2 work, including Clean `CriarTarefa`: `.planning/stop_ship/rnd_botcomponents_by_parent_20260506.txt:77`, `.planning/stop_ship/rnd_botcomponents_by_parent_20260506.txt:275`, `.planning/stop_ship/rnd_botcomponents_by_parent_20260506.txt:1755`, `.planning/stop_ship/rnd_botcomponents_by_parent_20260506.txt:2179`.
- V2 fix export still includes `pmo_AssistentePMO_Clean.topic.CriarTarefa` alongside V2 `CriarTarefa`: `.planning/stop_ship/v2_criartarefa_components_after_fix_20260507_1335.txt:5`, `.planning/stop_ship/v2_criartarefa_components_after_fix_20260507_1335.txt:177`, `.planning/stop_ship/v2_criartarefa_components_after_fix_20260507_1335.txt:218`.
- RCA calls out ghost/duplicate risk because `Assistente PMO Clean` and `Assistente PMO V2` coexist: `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:273`, `.planning/stop_ship/RCA_CRIARTAREFA_V3_FLOWNOTFOUND_20260507.md:319-320`.

Unverified browser-dependent claims:

- Whether the user has manually removed/hid Clean components after these exports.
- Whether Copilot Studio UI is showing only V2 as the active tested bot.
- Whether deleting/removing Clean from solution dependencies is safe. This requires human approval and dependency review.

## Cross-Cutting Evidence Notes

- `EVIDENCE_LOG.md` proves several direct flow paths, but not the missing bot-topic write paths B1-B5. Direct decision flow evidence at `.planning/stop_ship/EVIDENCE_LOG.md:42-51` came from scripted/manual SharePoint fixture rows, not bot-created rows.
- `EVIDENCE_LOG.md` documents the original T-007 Clean bot `FlowNotFound` and live Dataverse binding contradiction: `.planning/stop_ship/EVIDENCE_LOG.md:57-59`.
- The old Clean flow has valid SharePoint project-create logic, but it creates `Projetos` records and is tied to the stale runtime binding problem: `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/Workflows/Clean_PMO_PA_CriarTarefa-42D9ABD1-8849-F111-BEC7-7CED8D955C6C.json:95-153`.
- The inspected live export contains no `PMO_PA_CriarTarefa_V3` or `3104124d` match, so all V3 current-state claims depend on RCA/browser evidence rather than export evidence.

## Stop-Ship Summary

Programmatic evidence supports keeping the release blocked.

- GAP-A1 remains open unless Opus browser evidence shows V3 has real SharePoint write logic and fresh SharePoint verification finds the created item.
- GAP-A2 is open in the inspected source/export; any claimed V3 UI rebind is unverified without browser evidence.
- GAP-B1 through GAP-B5 are static stubs or confirmation-only topics in the inspected V2 package.
- GAP-B6 remains field-by-field and STT-risky in the inspected package.
- GAP-B7 is not fixed in the inspected V2 template/live YAML/export despite a planning claim.
- GAP-C1 is confirmed: Clean and V2 bot/component rows coexist, and cleanup is still human-gated.
