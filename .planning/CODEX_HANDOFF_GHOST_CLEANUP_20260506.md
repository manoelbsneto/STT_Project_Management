# Codex Handoff - Ghost Bot Cleanup and T-007 FlowNotFound Resolution

From: Principal Architect / Codex stop-ship handoff
To: Opus browser executor + Human/Admin approver + Codex verifier
Original date: 2026-05-06
Last update: 2026-05-09
Priority: SEV-0 - Release blocker
Environment: `ColOfertasBrasilPro`
Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`
Bot: `Assistente PMO Clean`
Bot ID: `77cfb838-6ed1-4488-9e57-ab98751081d3`

---

## 1. Goal

Resolve the T-007 Copilot `CriarTarefa` failure where the bot returns `FlowNotFound` for flow/action binding during runtime, even when the flow and Dataverse binding appear to exist.

The cleanup goal is:

1. Prove which bot components are active and which are orphaned.
2. Remove only orphaned `pmo_AssistentePMO.*` Dataverse `botcomponent` rows after Human/Admin approval.
3. Preserve all `pmo_AssistentePMO_Clean.*` active bot components.
4. Republish the active bot from Copilot Studio UI.
5. Retest T-007 create and cancel paths.
6. Export and audit the cleaned state.
7. Provide a second verification layer so Opus browser evidence and Codex static/audit evidence must agree.

Release remains NO-SHIP until every required gate in section 11 is green.

---

## 2. Root Cause Summary

T-007 create path returns `FlowNotFound` for flow `71f62da4-9748-f111-bec7-6045bdf42cae` even though:

- The flow exists and is active in Dataverse.
- The `_Clean` action component exists.
- The `botcomponent_workflow` binding exists.

Confirmed root cause:

The tenant contains two component families:

| Schema family | Parent bot exists? | Runtime role | Action |
|---|---:|---|---|
| `pmo_AssistentePMO.*` | No | Orphan / ghost | Delete after approval |
| `pmo_AssistentePMO_Clean.*` | Yes | Active production bot | Preserve |

The orphaned `pmo_AssistentePMO.*` components pollute Copilot runtime action-to-flow resolution and can produce ambiguous/stale tool registration.

Evidence:

| Evidence | Path / source |
|---|---|
| Active bot inventory | `.planning/stop_ship/rnd_bot_rows_20260506.txt` |
| Flow/action binding evidence | `.planning/stop_ship/fetch_t007_criartarefa_workflow_bindings.xml` |
| Browser failure | User Copilot Studio screenshot, T-007 FlowNotFound, 2026-05-06 |

---

## 3. Safety Rules

| Rule | Requirement |
|---|---|
| Delete scope | Delete only `botcomponent` rows where `schemaname LIKE 'pmo_AssistentePMO.%'`. |
| Preserve scope | Never delete rows where `schemaname LIKE 'pmo_AssistentePMO_Clean.%'`. |
| Destructive action owner | Human/Admin only. Codex may discover/report; Opus may verify in UI; deletion requires explicit approval. |
| Publish method | Use Copilot Studio UI publish. Do not rely on `pac copilot publish` for final proof. |
| Runtime proof | Browser chat + Power Automate run + SharePoint evidence are mandatory. |
| Rollback | Export before deletion/publish; keep rollback ZIP path recorded. |

---

## 4. Activity Ownership Matrix

| Activity ID | Activity | Primary owner | Second-layer verifier | Destructive? |
|---|---|---|---|---:|
| GC-00 | Pre-cleanup backup/export | Opus or Human/Admin | Codex | No |
| GC-01 | Discover orphan bot rows | Codex or Human/Admin | Opus | No |
| GC-02 | Review deletion candidate list | Human/Admin | Opus + Codex | No |
| GC-03 | Delete orphan `botcomponent` rows | Human/Admin | Opus + Codex | Yes |
| GC-04 | Verify `botcomponent_workflow` cleanup | Codex or Human/Admin | Opus | No unless manual cleanup needed |
| GC-05 | Publish active bot from Copilot Studio UI | Opus | Codex via export/audit | No |
| GC-06 | Retest T-007 create path | Opus | Codex via evidence review | No |
| GC-07 | Retest T-007 cancel path | Opus | Codex via evidence review | No |
| GC-08 | Export cleaned solution | Opus or Human/Admin | Codex | No |
| GC-09 | Run post-cleanup audits | Codex | Opus reviews result | No |
| GC-10 | Decide SHIP/NO-SHIP gate | Project Owner | Codex + Opus | No |

---

## 5. End-to-End Checklist

| ID | Status target | Activity | Output artifact |
|---|---|---|---|
| GC-00 | Complete | Backup/export before changes | Pre-cleanup ZIP |
| GC-01 | Complete | Fetch all orphan candidates | Candidate report |
| GC-02 | Complete | Approval review | Approval note / risk acceptance |
| GC-03 | Complete | Delete approved orphan components | Delete log |
| GC-04 | Complete | Verify N:N workflow bindings are clean | Fetch output |
| GC-05 | Complete | Publish bot from UI | Publish screenshot |
| GC-06 | Complete | T-007 create path proof | Chat screenshot, flow run URL, SharePoint item |
| GC-07 | Complete | T-007 cancel path proof | Chat screenshot, no flow run/no SP row proof |
| GC-08 | Complete | Export/unpack cleaned solution | Post-cleanup ZIP + unpack folder |
| GC-09 | Complete | Static regression audits | Test output |
| GC-10 | Complete | Final gate decision | SHIP/NO-SHIP note |

---

## 6. Step-by-Step Execution Plan

### GC-00 - Pre-Cleanup Backup / Export

Purpose: preserve a rollback point before any destructive Dataverse cleanup.

Owner: Opus or Human/Admin

Codex recommendation:

1. Confirm current environment:
   ```powershell
   pac auth list
   ```
2. Export the current solution:
   ```powershell
   pac solution export `
     --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
     --name PMO_v11_Tarefas `
     --managed false `
     --path ".planning\canonical\PMO_v11_Tarefas_PRE_GHOST_CLEANUP_20260509.zip" `
     --overwrite
   ```
3. Record ZIP path, timestamp, and command output in the evidence log.
4. Do not proceed to deletion without this backup.

Opus second-layer verification:

| Check | Expected |
|---|---|
| ZIP exists | `.planning/canonical/PMO_v11_Tarefas_PRE_GHOST_CLEANUP_20260509.zip` |
| Export command succeeded | Output contains solution export success |
| Rollback path recorded | Evidence log updated |

Failure handling:

- If export fails, stop. Do not delete anything.

---

### GC-01 - Discover Orphan Bot Components

Purpose: produce the full candidate list before deletion.

Owner: Codex or Human/Admin

Current Codex artifact:

- `deploy/Discover-GhostBotComponents.ps1`

Recommended command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File deploy\Discover-GhostBotComponents.ps1 `
  -EnvironmentId e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

If direct script execution is blocked, use this FetchXML manually:

```xml
<fetch>
  <entity name="botcomponent">
    <attribute name="botcomponentid" />
    <attribute name="schemaname" />
    <attribute name="name" />
    <attribute name="componenttype" />
    <attribute name="statecode" />
    <attribute name="statuscode" />
    <attribute name="modifiedon" />
    <filter>
      <condition attribute="schemaname" operator="like" value="pmo_AssistentePMO.%" />
    </filter>
    <order attribute="modifiedon" descending="true" />
  </entity>
</fetch>
```

Expected candidate rule:

| Include for deletion candidate | Exclude / preserve |
|---|---|
| `pmo_AssistentePMO.topic.*` | `pmo_AssistentePMO_Clean.topic.*` |
| `pmo_AssistentePMO.action.*` | `pmo_AssistentePMO_Clean.action.*` |
| `pmo_AssistentePMO.gpt.*` | `pmo_AssistentePMO_Clean.gpt.*` |

Opus second-layer verification:

1. Open Dataverse/Power Apps advanced find or table view if available.
2. Filter `botcomponent.schemaname starts with pmo_AssistentePMO.`
3. Confirm the result list matches the Codex discovery report.
4. Confirm no row with `_Clean` is in the deletion candidate list.

Evidence required:

| Evidence | Required |
|---|---:|
| Discovery report path | Yes |
| Candidate row count | Yes |
| Candidate IDs | Yes |
| Screenshot or export of candidate list | Preferred |

Failure handling:

- If candidate list includes `_Clean`, stop and fix the filter.
- If candidate list is empty, proceed to GC-04 verification instead of deletion.

---

### GC-02 - Human/Admin Approval Review

Purpose: prevent accidental deletion of active bot components.

Owner: Human/Admin

Inputs:

- Discovery report from GC-01.
- Backup ZIP from GC-00.
- This handoff document.

Approval checklist:

| Check | Required answer |
|---|---|
| Backup exists | Yes |
| All candidates start with `pmo_AssistentePMO.` | Yes |
| No candidates start with `pmo_AssistentePMO_Clean.` | Yes |
| Candidate count and IDs saved | Yes |
| Admin understands deletion is destructive | Yes |

Approval record format:

```text
Approved ghost cleanup deletion.
Date/time:
Environment:
Candidate count:
Approved by:
Backup ZIP:
Discovery report:
```

Opus second-layer verification:

- Opus checks that the approval record references the exact candidate count from GC-01.
- If counts differ, stop before deletion.

Failure handling:

- If approval is not explicit, do not delete.
- If there is uncertainty, accept risk temporarily and leave NO-SHIP blocker open.

---

### GC-03 - Delete Orphan `botcomponent` Rows

Purpose: remove only orphaned legacy components that can pollute runtime binding resolution.

Owner: Human/Admin

Recommended method:

Use Dataverse Web API, Power Apps UI, or an approved admin script. Delete one row at a time from the approved candidate list.

Example Web API pattern:

```http
DELETE [org-url]/api/data/v9.2/botcomponents(<botcomponentid>)
```

Example rows from previous evidence:

```http
DELETE [org-url]/api/data/v9.2/botcomponents(8495ade0-cbcd-4461-80f4-794ff9a68292)
DELETE [org-url]/api/data/v9.2/botcomponents(b7fbf995-ffd8-4657-ba76-d289f6a9d3a8)
```

Required execution discipline:

1. Use only IDs approved in GC-02.
2. Delete in small batches.
3. After each batch, record success/failure.
4. Never delete a row if its `schemaname` contains `_Clean`.
5. Keep the delete log.

Opus second-layer verification:

| Verification | Expected |
|---|---|
| Spot-check before delete | Row schemaname starts `pmo_AssistentePMO.` |
| Spot-check after delete | Row no longer appears |
| Active bot still opens | `Assistente PMO Clean` still accessible |

Failure handling:

- If an unexpected row is deleted, execute rollback plan in section 10.
- If delete API returns dependency errors, proceed to GC-04 to identify remaining relationship rows and escalate to Human/Admin.

---

### GC-04 - Verify `botcomponent_workflow` Binding Cleanup

Purpose: confirm relationship rows no longer point from orphan bot components to workflows.

Owner: Codex or Human/Admin

FetchXML:

```xml
<fetch>
  <entity name="botcomponent_workflow">
    <all-attributes />
    <link-entity name="botcomponent" from="botcomponentid" to="botcomponentid" alias="bc">
      <attribute name="schemaname" />
      <filter>
        <condition attribute="schemaname" operator="like" value="pmo_AssistentePMO.%" />
      </filter>
    </link-entity>
  </entity>
</fetch>
```

Expected result:

| Query | Expected output |
|---|---|
| Orphan workflow bindings | 0 rows |
| `_Clean` workflow bindings | Rows still exist for active actions |

Opus second-layer verification:

1. Confirm no `pmo_AssistentePMO.*` rows appear in relationship output.
2. Confirm `pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa` still has a workflow binding.
3. Confirm the workflow row points to an active `PMO_PA_CriarTarefa` / V3-equivalent flow.

Failure handling:

- If orphan relationship rows remain, do not manually delete unless Human/Admin approves.
- Capture rows and escalate.

---

### GC-05 - Publish the Active Bot from Copilot Studio UI

Purpose: force a fresh runtime snapshot after cleanup.

Owner: Opus

Important:

Do not use `pac copilot publish` as final proof. Previous evidence showed cached failure behavior. Use Copilot Studio UI.

Step-by-step:

1. Open Copilot Studio web UI.
2. Select environment `ColOfertasBrasilPro`.
3. Open bot `Assistente PMO Clean`.
4. Open topic `CriarTarefa`.
5. Confirm the action call references the active `_Clean` action or the intended V3-bound action.
6. Make a no-op edit if needed:
   - Add one temporary character in a non-critical message.
   - Remove it.
   - Save.
7. Click Publish.
8. Wait for publish success.
9. Wait 5 minutes for runtime/cache propagation.

Opus evidence:

| Evidence | Required |
|---|---:|
| Topic/action binding screenshot | Yes |
| Publish success screenshot | Yes |
| Timestamp of publish | Yes |
| Any publish error screenshot | If applicable |

Codex second-layer verification:

After Opus exports or fetches updated bot artifacts, Codex reruns:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File tests\Test-CopilotStopShipGaps.ps1 `
  -TemplatePath <fresh-exported-yaml>
```

Failure handling:

- If publish fails, capture screenshot and exact error.
- Do not retest T-007 until publish succeeds.

---

### GC-06 - Retest T-007 Create Path

Purpose: prove `CriarTarefa` no longer fails with `FlowNotFound` and successfully writes to SharePoint.

Owner: Opus

Test input:

```text
Criar tarefa: Titulo=Teste Codex T007 Retest 20260509, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=336, Prioridade=Alta
```

Confirmation:

```text
sim
```

Expected sequence:

| Step | Expected result |
|---|---|
| Bot parses fields | Title, responsavel, prazo, horas, prioridade captured |
| Bot asks confirmation | User can answer `sim` |
| Flow invocation | No `FlowNotFound` |
| Power Automate run | Green/succeeded run appears |
| SharePoint write | New `Projetos` item created |
| Bot response | Success message with generated ProjectID/code |

Evidence required:

| Evidence | Required |
|---|---:|
| Full chat screenshot | Yes |
| Power Automate run URL | Yes |
| Run status screenshot | Yes |
| SharePoint item screenshot or item ID | Yes |
| Generated ProjectID/code | Yes |

Codex second-layer verification:

1. Review evidence for exact test input.
2. Confirm run timestamp is after GC-05 publish.
3. Confirm SharePoint item timestamp is after the run.
4. Confirm no `FlowNotFound` appears in chat.

Failure handling:

- If `FlowNotFound` remains, return to GC-01/GC-04 and inspect remaining ghosts/bindings.
- If flow runs but SharePoint write fails, treat as a separate V3 flow logic issue, not ghost cleanup.

---

### GC-07 - Retest T-007 Cancel Path

Purpose: prove confirm-before-action works and cancellation does not create data.

Owner: Opus

Test input:

```text
Criar tarefa: Titulo=Teste Codex Cancel 20260509, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=100, Prioridade=Baixa
```

Confirmation:

```text
nao
```

Expected sequence:

| Step | Expected result |
|---|---|
| Bot parses fields | Fields captured |
| Bot asks confirmation | User answers `nao` |
| Flow invocation | No Power Automate run should be created for this cancel |
| SharePoint write | No `Projetos` item should be created |
| Bot response | Cancellation message |

Evidence required:

| Evidence | Required |
|---|---:|
| Chat screenshot | Yes |
| Proof no matching SharePoint item exists | Yes |
| Proof no new flow run was created for cancel path | Preferred |

Codex second-layer verification:

1. Search evidence for title `Teste Codex Cancel 20260509`.
2. Confirm no SharePoint `Projetos` row with that title.
3. Confirm no run was created after the cancel response.

Failure handling:

- If cancel creates a row, stop release and inspect topic confirm branch.
- If cancel calls the flow but flow does not write, still treat as a confirm-before-action failure.

---

### GC-08 - Post-Cleanup Export and Unpack

Purpose: preserve the clean state and provide Codex with an auditable artifact.

Owner: Opus or Human/Admin

Commands:

```powershell
pac solution export `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --name PMO_v11_Tarefas `
  --managed false `
  --path ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260509.zip" `
  --overwrite

pac solution unpack `
  --zipfile ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260509.zip" `
  --folder ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260509" `
  --packagetype Unmanaged `
  --allowDelete
```

Expected output:

| Artifact | Expected |
|---|---|
| ZIP | Exists |
| Unpacked folder | Exists |
| `botcomponents` folder | Contains only active `_Clean` components for this bot |

Opus evidence:

- Export command output.
- Unpack command output.
- ZIP path.
- Folder path.

Failure handling:

- If export fails, do not claim cleanup complete.
- If unpack fails, keep ZIP and rerun unpack with corrected path.

---

### GC-09 - Post-Cleanup Audits

Purpose: prove the cleaned export is structurally safe.

Owner: Codex

Commands:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File tests\Test-PMOFlowStopShipAudit.ps1 `
  -SolutionSourcePath ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260509"

powershell -NoProfile -ExecutionPolicy Bypass `
  -File tests\Test-CriarTarefaFlowDefinition.ps1 `
  -Path ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260509\Workflows\PMO_PA_CriarTarefa-71F62DA4-9748-F111-BEC7-6045BDF42CAE.json" `
  -AllowRuntimeRawAuthentication
```

Ghost component audit:

```powershell
Get-ChildItem -LiteralPath ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260509\botcomponents" -Directory |
  Where-Object {
    $_.Name -match "^pmo_AssistentePMO\." -and
    $_.Name -notmatch "^pmo_AssistentePMO_Clean\."
  } |
  Select-Object -ExpandProperty Name
```

Expected output:

```text
<empty>
```

ASCII/mojibake audit:

```powershell
rg -n "[^\x00-\x7F]|Ã|�|ð|â|Â" ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260509"
```

Expected output:

```text
<empty>
```

Opus second-layer verification:

- Opus confirms Codex audit result is attached to evidence pack.
- If Codex audit fails, Opus does not mark browser task complete.

Failure handling:

- If ghost components remain in export, go back to GC-01.
- If ASCII/mojibake fails, fix bot text in UI/export path and republish.

---

### GC-10 - Verify Orphan Cleanup in Live Dataverse

Purpose: prove live Dataverse no longer has orphaned workflow bindings.

Owner: Codex or Human/Admin

Command:

```powershell
pac org fetch `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --xmlFile ".planning\stop_ship\fetch_t007_criartarefa_workflow_bindings.xml"
```

Expected output:

| Expected | Not allowed |
|---|---|
| `pmo_AssistentePMO_Clean.*` rows | `pmo_AssistentePMO.*` rows |

Opus second-layer verification:

- Check the fetch output manually.
- Confirm only `_Clean` components remain.
- Confirm no duplicate action/topic binding from deleted schema exists.

Failure handling:

- If orphan rows still exist, reopen GC-01/GC-03.

---

## 7. Specific Architect Answers and Actions

| Question | Decision | Action required |
|---|---|---|
| Most likely cause of FlowNotFound | Ghost bot schema orphan pollution | Remove orphan `pmo_AssistentePMO.*` components after approval |
| Tables/columns to inspect | `bot`, `botcomponent`, `botcomponent_workflow` | Fetch and compare active vs orphan schema rows |
| Is `pac copilot publish` enough? | No | Publish from Copilot Studio UI |
| Which action schema should topic call? | `pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa` | Preserve `_Clean`; never use legacy schema |
| T-003 negative terminate behavior | Use controlled/cancelled business outcome | Future improvement: avoid `Failed` status for expected no-match |
| Duplicate idempotency key | `NomeProjeto + DataAlvo` | Keep this business key |
| ASCII-only policy | Keep it | Continue `rg` gate and live export audit |
| Additional tests | Orphan detector, binding completeness, publish freshness | Add/run as regression gates |

---

## 8. Test Script Fixes Already Applied

| Fix | File | Purpose | Verification |
|---|---|---|---|
| Fix A | `Test-CriarTarefaRawDataverse.ps1` | Default `$BotSchema` should be `pmo_AssistentePMO_Clean` | Prevents false green against deleted bot |
| Fix B | `Test-CriarTarefaContract.ps1` | Regex accepts `_Clean` schema | Ensures correct action reference is recognized |
| Fix C | `Test-PMOFlowStopShipAudit.ps1` | Detect orphan `pmo_AssistentePMO.*` directories | Fails until ghost export is clean |

Recommended additional checks:

| Test | Goal |
|---|---|
| Binding completeness | For every `_Clean` action, verify `botcomponent_workflow` points to active workflow |
| Publish freshness | Verify bot published timestamp is after cleanup |
| Runtime T-007 trace | Link chat timestamp to flow run timestamp and SharePoint item timestamp |

---

## 9. Artifacts

| Artifact | Path | Purpose |
|---|---|---|
| Cleaned source package | `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_src` | Ghost-free package source |
| Cleaned ZIP | `.planning/canonical/PMO_v11_Tarefas_GHOST_CLEANUP_20260506.zip` | Already imported historically |
| Pre-cleanup rollback | `.planning/canonical/PMO_v11_Tarefas_PRE_GHOST_CLEANUP_20260506.zip` | Historical rollback |
| New recommended rollback | `.planning/canonical/PMO_v11_Tarefas_PRE_GHOST_CLEANUP_20260509.zip` | Required before current deletion attempt |
| Ghost discovery script | `deploy/Discover-GhostBotComponents.ps1` | Read-only candidate discovery |
| Browser request handoff | `.planning/comms/CODEX_BROWSER_REQUESTS_20260507.md` | Related browser execution checklist |
| Current status table | `.planning/stop_ship/CURRENT_STATUS_TABLE_20260507.md` | Overall status |

---

## 10. Rollback Plan

Use rollback only if cleanup causes regression, active bot corruption, or publish failure that cannot be corrected.

Steps:

1. Import pre-cleanup rollback ZIP:
   ```powershell
   pac solution import `
     --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
     --path ".planning\canonical\PMO_v11_Tarefas_PRE_GHOST_CLEANUP_20260509.zip" `
     --publish-changes `
     --async false
   ```
2. Publish all customizations.
3. Open Copilot Studio UI.
4. Republish `Assistente PMO Clean`.
5. Retest T-001 through T-007 minimum smoke paths.
6. Record rollback evidence and keep NO-SHIP.

Rollback success criteria:

| Criterion | Expected |
|---|---|
| Solution import | Successful |
| Bot opens | Yes |
| Publish | Successful |
| Existing proven paths T-001 through T-006 | Still pass or formally documented |
| T-007 | Re-evaluate after rollback |

---

## 11. Release Gates

Required gates before moving from NO-SHIP to SHIP:

| Gate | Owner | Required evidence | Status target |
|---|---|---|---|
| Pre-cleanup rollback export exists | Opus/Human | ZIP path + export output | Green |
| Orphan `pmo_AssistentePMO.*` candidate list reviewed | Codex/Human | Discovery report + approval | Green |
| Orphan components deleted | Human/Admin | Delete log | Green |
| No `_Clean` components deleted | Opus + Codex | Candidate/deletion comparison | Green |
| `botcomponent_workflow` has no orphan bindings | Codex/Human | Fetch output | Green |
| Bot published from Copilot Studio UI | Opus | Publish screenshot | Green |
| T-007 create path passes | Opus | Chat screenshot, run URL, SharePoint item | Green |
| T-007 cancel path passes | Opus | Chat screenshot, no run/no row proof | Green |
| Post-cleanup export has no ghosts | Codex | Export audit output | Green |
| Regression tests pass | Codex | Test output | Green |
| Evidence committed/attached | Codex + Opus | Evidence log update | Green |

Nice-to-have but not blocker unless Project Owner decides:

| Item | Reason |
|---|---|
| T-001 duplicate branch evidenced | Strengthens idempotency proof |
| Publish freshness automated test | Helps prevent cached runtime ambiguity |

---

## 12. Opus Matching Checklist

Use this table to map Opus browser actions to Codex verification.

| Opus planned action | Codex matching verification | Pass condition |
|---|---|---|
| Capture pre-cleanup export | Check ZIP exists and path is in evidence | Export available before deletion |
| Review ghost candidate list | Compare candidate schemanames to allowed pattern | Only `pmo_AssistentePMO.*` candidates |
| Delete approved rows | Compare delete log to approved IDs | No extra IDs deleted |
| Publish bot in UI | Re-run Copilot static tests after export | Publish time after cleanup |
| Test T-007 create | Validate chat/run/SP timestamps align | No FlowNotFound and row created |
| Test T-007 cancel | Validate no run/no row | Confirm-before-action enforced |
| Export post-cleanup | Run stop-ship audit | No ghosts, no ASCII/mojibake defects |
| Attach evidence | Review evidence completeness | Every gate has proof link |

---

## 13. Final Decision Rule

If any required gate in section 11 is not green, the answer remains:

```text
NO-SHIP
```

Only after all required gates are green and evidence is attached can the release decision change to:

```text
SHIP
```
