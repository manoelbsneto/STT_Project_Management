# CODEX 5.5 HIGH-THINKING HANDOFF — SEV-0 Stop-Ship Tasks

> **Date:** 2026-05-10T10:40:00-03:00
> **From:** Opus 4.6 (Orchestrator)
> **To:** Codex 5.5 (Programmatic Executor)
> **Priority:** SEV-0
> **Coordination file:** `.planning/AGENT_CHECKIN_REGISTRY.md` — **READ EVERY 60 SECONDS**

---

## YOUR MANDATORY FIRST STEP

1. Read `.planning/AGENT_CHECKIN_REGISTRY.md`
2. Find tasks assigned to `Codex 5.5` with status `READY` or whose dependencies are all `DONE`
3. Change status to `IN_PROGRESS | Codex 5.5 | <current_timestamp>`
4. Execute the task
5. Change status to `DONE | Codex 5.5 | <current_timestamp> | <evidence_path>`
6. Re-read the registry to check for next available task

---

## CURRENTLY UNBLOCKED TASKS FOR YOU

### PRE-01 — Add Logical Delete Fields (READY, no dependencies)

**Goal:** Add 4 columns to 5 SharePoint lists for logical deletion support.

**Lists:** Projetos, Tarefas, Status Diario, Riscos e Bloqueios, Decisoes do Board  
**Site:** `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`

**Fields to add to each list:**

| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| Deleted | Yes/No (Boolean) | No | Logical delete flag |
| DeletedAt | DateTime | — | When the record was deleted |
| DeletedReason | Single line text | — | Why it was deleted |
| DeletedByUPN | Single line text | — | Who deleted it (UPN) |

**Script location:** Create `deploy/Add-LogicalDeleteFields.ps1`

**PowerShell approach (PnP legacy for WinPS 5.1):**
```powershell
# Connect using the established runbook pattern
# See: .planning/SHAREPOINT_ACCESS_RUNBOOK.md
Connect-PnPOnline -Url "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital" -UseWebLogin

$lists = @("Projetos", "Tarefas", "Status Diario", "Riscos e Bloqueios", "Decisoes do Board")
foreach ($list in $lists) {
    Add-PnPField -List $list -DisplayName "Deleted" -InternalName "Deleted" -Type Boolean -DefaultValue "0"
    Add-PnPField -List $list -DisplayName "DeletedAt" -InternalName "DeletedAt" -Type DateTime
    Add-PnPField -List $list -DisplayName "DeletedReason" -InternalName "DeletedReason" -Type Text
    Add-PnPField -List $list -DisplayName "DeletedByUPN" -InternalName "DeletedByUPN" -Type Text
}
```

**Evidence required:** Script output log, field existence proof per list.

**After completing PRE-01:** Update registry, then check if CLN-02 is ready.

---

### CLN-02 — Run Test/Trash Data Discovery (WAITING on CLN-01 — NOW DONE)

**Goal:** Inventory all test/trash data candidates across SharePoint lists.

**Script:** `deploy/Discover-SharePointTestDataCandidates.ps1` (already exists or create)

**Candidate patterns from `TEST_DATA_CLEANUP_DECISION_20260510.md`:**
```text
Teste, Test, Codex, Opus, Demo, Mock, Sample, Fixture, Clean Flow, Direct,
Agente qual offer, RISK-OPUS, DEC-OPUS, PRJ-OPUS, PRJ-TEST, PRJ-CODEX,
Ã, Â, â, ð, �
```

**Output:** CSV + markdown summary to `.planning/cleanup/` directory

**Evidence required:** Candidate CSV path, candidate count per list, zero deletion performed.

---

## TASKS TO WATCH FOR (WAITING on earlier tasks)

| Task | Depends On | What you'll do |
|------|------------|---------------|
| W1-01 | CLN-04 | Verify V3 flow has real SP write + Deleted=false on new records |
| W1-07 | W1-05, W1-06 | Re-audit Opus T-007 evidence |
| W2-01 | W1-07 | Build/deploy ConsultarPortfolio flow (exclude Deleted=1 in OData filter) |
| W2-02 | W1-07 | Build/deploy ConsultarProjeto flow (exclude Deleted=1) |
| W3-01 | W2-03, W2-04 | Build/deploy RegistrarRisco flow |
| W3-02 | W2-03, W2-04 | Build/deploy RegistrarBloqueio flow |
| W3-03 | W2-03, W2-04 | Build/deploy PedirDecisao flow |
| W5-01 | W4-02 | Ghost botcomponent discovery |
| EXP-02 | EXP-01 | Post-cleanup static audits on exported solution |

---

## HARD RULES

1. **NEVER edit files owned by Opus** (see `.planning/COORDINATION_CONTRACT.md`)
2. **NEVER publish the bot** — that's Opus's job via Copilot Studio UI
3. **Always add `Deleted ne 1` or equivalent filter** to any new flow OData query
4. **All new records must set `Deleted = false`** explicitly
5. **ASCII-only text** — no emoji, accents, or cedilla in flow definitions
6. **Standard-Only connectors** — no Premium, no Graph, no HTTP with Entra
7. **Atomic git commits** with task ID: `fix(PRE-01): Add logical delete fields to SharePoint lists`
8. **Run relevant tests** after each change before marking DONE

## EXISTING RESOURCES

| Resource | Path |
|----------|------|
| Flow deploy scripts | `deploy/PA_*_Flow.ps1` |
| Build-only JSONs | `.planning/comms/pa_*_buildonly_*.json` |
| Test scripts | `tests/Test-*.ps1` |
| YAML template | `deploy/copilot/AssistentePMO.template.yaml` |
| SharePoint access | `.planning/SHAREPOINT_ACCESS_RUNBOOK.md` |
| Ghost discovery | `deploy/Discover-GhostBotComponents.ps1` |
| Coordination contract | `.planning/COORDINATION_CONTRACT.md` |
| Check-in registry | `.planning/AGENT_CHECKIN_REGISTRY.md` |
