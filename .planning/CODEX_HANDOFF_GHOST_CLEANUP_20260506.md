# Codex Handoff — Ghost Bot Cleanup & T-007 FlowNotFound Resolution

**From**: Principal Architect (Opus 4.6 Review)
**To**: Codex (R&D Senior Developer)
**Date**: 2026-05-06
**Priority**: SEV-0 — Release Blocker
**Environment**: `ColOfertasBrasilPro`
**Bot**: `Assistente PMO Clean` (ID `77cfb838-6ed1-4488-9e57-ab98751081d3`)

---

## 1. Problem Statement

T-007 Copilot create path returns `FlowNotFound` for flow `71f62da4-9748-f111-bec7-6045bdf42cae` even though:
- The flow is active in Dataverse
- The `_Clean` action component exists and points to the correct flowId
- The `botcomponent_workflow` binding exists

## 2. Root Cause (Confirmed by Evidence)

### The Ghost Bot Schema

The solution and Dataverse contain **TWO full sets** of CriarTarefa bot components:

| Schema | Bot Exists? | Status |
|--------|------------|--------|
| `pmo_AssistentePMO` (original) | **NO** — deleted from `bot` table | ORPHAN — 20+ botcomponent rows with no parent bot |
| `pmo_AssistentePMO_Clean` (active) | **YES** — bot ID `77cfb838-...` | ACTIVE — this is the production bot |

Evidence file: `.planning/stop_ship/rnd_bot_rows_20260506.txt` — only 3 bots exist, none with schema `pmo_AssistentePMO`.

The orphaned `pmo_AssistentePMO` components pollute the Copilot runtime's action→flow binding resolution, causing `FlowNotFound`.

### What We Already Did

1. ✅ Removed all `pmo_AssistentePMO.*` directories from the solution source package (`FLOW_AUDIT_FIX_src`)
2. ✅ Repacked into `PMO_v11_Tarefas_GHOST_CLEANUP_20260506.zip`
3. ✅ Imported the cleaned solution — `Solution Imported successfully`, `Published All Customizations`
4. ❌ `pac copilot publish` failed — returns cached failure from `18:56:09 UTC`
5. ⚠️ **The orphaned Dataverse rows still exist** — unmanaged solution import does NOT delete components

### Current Live Dataverse State (Still Dirty)

From `pac org fetch` after import, the `botcomponent_workflow` table still shows:

```
8495ade0-...  pmo_AssistentePMO.action.PMO_PA_CriarTarefa       → flowId 71f62da4-...  (ORPHAN)
b7fbf995-...  pmo_AssistentePMO.topic.CriarTarefa               → flowId 71f62da4-...  (ORPHAN)
51347593-...  pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa  → flowId 71f62da4-...  (ACTIVE)
c746c335-...  pmo_AssistentePMO_Clean.topic.CriarTarefa          → flowId 71f62da4-...  (ACTIVE)
```

## 3. What Codex Must Do

### Step 1 — Delete Orphaned botcomponent Rows from Dataverse

Delete **all** `botcomponent` rows where `schemaname` starts with `pmo_AssistentePMO.` (NOT `pmo_AssistentePMO_Clean.`).

These are the confirmed orphan botcomponent IDs from the CriarTarefa fetch. But **ALL** `pmo_AssistentePMO.*` components must be deleted, not just CriarTarefa ones.

**Method**: Use the Dataverse Web API or Power Apps to delete. Example:

```http
DELETE [org-url]/api/data/v9.2/botcomponents(8495ade0-cbcd-4461-80f4-794ff9a68292)
DELETE [org-url]/api/data/v9.2/botcomponents(b7fbf995-ffd8-4657-ba76-d289f6a9d3a8)
```

**To get the full list of orphan IDs**, run this FetchXML:

```xml
<fetch>
  <entity name="botcomponent">
    <attribute name="botcomponentid" />
    <attribute name="schemaname" />
    <attribute name="name" />
    <attribute name="componenttype" />
    <filter>
      <condition attribute="schemaname" operator="like" value="pmo_AssistentePMO.%" />
    </filter>
  </entity>
</fetch>
```

Then delete each returned row. **Do NOT delete rows where schemaname starts with `pmo_AssistentePMO_Clean.`**

### Step 2 — Delete Orphaned botcomponent_workflow Binding Rows

After deleting the botcomponent rows, their `botcomponent_workflow` N:N relationship rows should be cleaned up automatically by Dataverse cascading. But verify:

```xml
<fetch>
  <entity name="botcomponent_workflow">
    <all-attributes />
    <link-entity name="botcomponent" from="botcomponentid" to="botcomponentid" alias="bc">
      <filter>
        <condition attribute="schemaname" operator="like" value="pmo_AssistentePMO.%" />
      </filter>
    </link-entity>
  </entity>
</fetch>
```

If any rows remain after the botcomponent delete, delete them manually.

### Step 3 — Publish the Bot from Copilot Studio UI

`pac copilot publish` is returning a cached failure. **Do NOT use pac for this publish.**

Instead:
1. Open Copilot Studio web UI
2. Open `Assistente PMO Clean`
3. Open the `CriarTarefa` topic
4. Make a trivial no-op edit (add a space to any message text, then remove it)
5. Save the topic
6. Click **Publish** from the Copilot Studio UI
7. Wait 5 minutes for CDN/edge cache propagation

### Step 4 — Retest T-007

After the 5-minute wait:

**T-007 Create Path:**
```
Criar tarefa: Titulo=Teste Codex T007 Retest 20260506, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=336, Prioridade=Alta
```
- Bot should parse all fields
- Bot should ask confirmation
- Reply `sim`
- Verify: NO `FlowNotFound`
- Verify: Power Automate run appears for `PMO_PA_CriarTarefa`
- Verify: Flow run is green
- Verify: SharePoint `Projetos` item is created
- Verify: Bot returns success message

**T-007 Cancel Path:**
```
Criar tarefa: Titulo=Teste Codex Cancel 20260506, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=100, Prioridade=Baixa
```
- Reply `nao` at confirmation
- Verify: NO Power Automate run created
- Verify: NO SharePoint row created
- Verify: Bot says cancellation message

### Step 5 — Post-Fix Export and Audit

After T-007 passes:

```powershell
# Export cleaned solution
pac solution export --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --name PMO_v11_Tarefas --managed false --path ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260506.zip" --overwrite

# Unpack for audit
pac solution unpack --zipfile ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260506.zip" --folder ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260506" --packagetype Unmanaged --allowDelete

# Run all regression tests
powershell -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260506"
powershell -File tests\Test-CriarTarefaFlowDefinition.ps1 -Path ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260506\Workflows\PMO_PA_CriarTarefa-71F62DA4-9748-F111-BEC7-6045BDF42CAE.json" -AllowRuntimeRawAuthentication

# Verify no ghost components in export
powershell -NoProfile -Command "Get-ChildItem -LiteralPath '.planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260506\botcomponents' -Directory | Where-Object { `$_.Name -match '^pmo_AssistentePMO\.' -and `$_.Name -notmatch '^pmo_AssistentePMO_Clean\.' } | Select-Object -ExpandProperty Name"
# Expected output: EMPTY (no ghost components)

# Verify ASCII compliance
rg -n "[^\x00-\x7F]" ".planning\canonical\PMO_v11_Tarefas_POST_GHOST_CLEANUP_20260506"
# Expected output: no matches
```

### Step 6 — Verify Orphan Cleanup in Dataverse

Run the CriarTarefa workflow bindings fetch again:

```powershell
pac org fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile ".planning\stop_ship\fetch_t007_criartarefa_workflow_bindings.xml"
```

Expected output should show **ONLY** `pmo_AssistentePMO_Clean.*` rows, NOT `pmo_AssistentePMO.*` rows.

---

## 4. Architect's Answers to Report §7 Questions

### Q1: Most likely cause of FlowNotFound
**Ghost bot schema orphan pollution.** The orphaned `pmo_AssistentePMO` components confuse the Copilot runtime's action→flow binding resolution. The runtime encounters duplicate action definitions pointing to the same flow from two different bot schemas, and fails to resolve unambiguously for the `_Clean` bot.

### Q2: What Dataverse tables/columns to inspect
- `bot` table: confirm `pmo_AssistentePMO` does NOT exist as a bot row
- `botcomponent` table: delete all rows with `schemaname LIKE 'pmo_AssistentePMO.%'`
- `botcomponent_workflow` N:N: verify orphan bindings are cleaned after botcomponent delete
- After cleanup: verify only `_Clean` components remain

### Q3: Is pac copilot publish enough?
**No.** `pac copilot publish` is currently returning a cached failure. Use the Copilot Studio UI publish instead. The UI forces a full runtime snapshot rebuild scoped to the bot's own component graph.

### Q4: Should topic call _Clean.action or pmo_AssistentePMO.action?
**Must call `pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa`.** The exported solution data file already uses this reference correctly (line 159 of `pmo_AssistentePMO_Clean.topic.CriarTarefa/data`). However, the live Dataverse topic content uses `InvokeFlowAction` with a direct `flowId` reference instead of `BeginDialog` with a `dialog:` reference. Both should work after orphan cleanup, but the `BeginDialog` form is more maintainable.

### Q5: Controlled terminate vs clean response for T-003 negative
**Change to `Terminate(Cancelled)` instead of `Terminate(Failed)`.** The missing-project path is a business logic decision, not a system error. `Failed` status pollutes monitoring dashboards. Use `RunStatus = Cancelled` to keep operations clean while still halting execution.

### Q6: Duplicate idempotency key
**`NomeProjeto + DataAlvo`** is correct. This is the natural business key already used in the `Get_Duplicate_Projects` OData filter. No change needed.

### Q7: ASCII-only policy
**Keep it.** The encoding chain (Copilot YAML → Dataverse → solution export → ZIP → import → runtime → Teams) has too many boundary opportunities for mojibake. The current `rg -n "[^\x00-\x7F]"` gate is working and should remain.

### Q8: Additional regression tests
Three new automated tests are recommended:
1. **Orphan detector** — verify no `pmo_AssistentePMO.*` (without `_Clean`) components exist in the solution export. **Already added to `Test-PMOFlowStopShipAudit.ps1`** by the Architect.
2. **Binding completeness** — for every `_Clean` action, verify a `botcomponent_workflow` row exists pointing to an active workflow.
3. **Post-publish freshness** — after publish, verify the bot's `publishedon` timestamp is recent.

---

## 5. Test Script Fixes Already Applied by Architect

### Fix A — `Test-CriarTarefaRawDataverse.ps1` line 6
Changed default `$BotSchema` from `"pmo_AssistentePMO"` to `"pmo_AssistentePMO_Clean"`.
The old default validated the wrong bot's data and gave false green results.

### Fix B — `Test-CriarTarefaContract.ps1` line 127
Changed regex from `(template-content|pmo_AssistentePMO)` to `(template-content|pmo_AssistentePMO(_Clean)?)`.
The old regex would not match the `_Clean` schema, missing the correct action reference.

### Fix C — `Test-PMOFlowStopShipAudit.ps1` new check (line 100-107)
Added orphan detection check: verifies no `pmo_AssistentePMO.*` (without `_Clean`) directories exist in the solution export's `botcomponents/` directory. This check will fail on the current post-import export (which still has ghosts from the Dataverse round-trip) and will pass only after the ghost cleanup + re-export.

---

## 6. Artifacts and Rollback

| Artifact | Path | Purpose |
|----------|------|---------|
| Cleaned source package | `.planning/canonical/PMO_v11_Tarefas_FLOW_AUDIT_FIX_src` | Source of truth (ghosts removed) |
| Cleaned ZIP | `.planning/canonical/PMO_v11_Tarefas_GHOST_CLEANUP_20260506.zip` | Already imported |
| Pre-cleanup rollback | `.planning/canonical/PMO_v11_Tarefas_PRE_GHOST_CLEANUP_20260506.zip` | Rollback if needed |
| Ghost cleanup script | `.planning/stop_ship/Remove-GhostBotComponents.ps1` | Reusable for future packages |
| Architect review | `OPUS_4_6_REVIEW.md` (in antigravity artifacts) | Full review document |

### Rollback Plan
If the ghost cleanup causes regressions:
1. Import `.planning/canonical/PMO_v11_Tarefas_PRE_GHOST_CLEANUP_20260506.zip`
2. Publish all customizations
3. Republish bot from Copilot Studio UI
4. Retest T-001 through T-006

---

## 7. Release Gate Update

After Codex completes steps 1-6:

| Gate | Required Status |
|------|----------------|
| Orphan `pmo_AssistentePMO` components deleted from Dataverse | ✅ |
| Bot published from Copilot Studio UI | ✅ |
| T-007 create path passes (no FlowNotFound) | ✅ |
| T-007 cancel path passes | ✅ |
| Post-cleanup export has no ghost components | ✅ |
| All 4 test scripts pass against post-cleanup export | ✅ |
| T-001 duplicate branch evidenced OR formally waived | ⚠️ Nice-to-have |
| All evidence committed to git | ✅ |

**Only after ALL required gates are green can the release move from NO-SHIP to SHIP.**
