# CODEX DEPLOYMENT PROMPT — CriarTarefa Flow + Copilot Studio Patch

> **Author:** Senior Solutions Architect (Microsoft M365 Low-Code R&D)
> **Executor:** Codex (Principal Deployment Engineer)
> **Scope:** End-to-end programmatic deployment — zero manual steps
> **Date:** 2026-05-05
> **Environment:** ColOfertasBrasilPro (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)

---

## ARCHITECTURAL CONTEXT

### Current State
- **Bot:** Assistente PMO (`pmo_AssistentePMO`, BotId: `0c4a9729-d55d-483c-8ec3-db9369583155`)
- **Generative Orchestration:** ✅ ENABLED (user confirmed, see Settings > IA Generativa)
- **GPT Instructions:** ✅ UPDATED (rules 6-8 for structured multiline input)
- **CriarTarefa Topic:** EXISTS in Copilot Studio (created manually) BUT:
  - ❌ Not wired to any Power Automate flow (no SharePoint write action)
  - ❌ Asks for ProjectID (should be auto-generated)
  - ❌ Not in the deploy template (was added manually, won't survive redeployment)

### SharePoint Schema (from `SP_Provisioning.ps1`)
**There is NO "Tarefas" list.** The existing lists are:
1. **Projetos** — Has `ProjectID` (Text, indexed), `NomeProjeto` (Text), `PM` (User), `StatusRAG` (Choice), `Percentual` (Number), `DataAlvo` (DateTime), `Prioridade` (Choice: Alta/Media/Baixa), `Ativo` (Boolean)
2. **Status Diario** — Daily status entries per project
3. **Riscos e Bloqueios** — Risks and blockers
4. **Decisoes do Board** — Board decisions

### Design Decision: Where Does "CriarTarefa" Write?
Since there is no Tarefas list, the `CriarTarefa` flow must create an item in the **Projetos** list. This aligns with the PRD: creating a "task" in this context means **registering a new project entry** with:
- `NomeProjeto` = Título provided by user
- `PM` = Responsável (lookup or text)
- `DataAlvo` = Prazo
- `Prioridade` = Prioridade (Alta/Media/Baixa → mapped)
- `ProjectID` = AUTO-GENERATED (format: `PRJ-XXX` where XXX = max existing ID + 1)
- `StatusRAG` = "Verde" (default for new projects)
- `Percentual` = 0 (default)
- `Ativo` = true

The `Horas` field does NOT exist in the Projetos schema. Two options:
1. **Store in ResumoExecutivo** (Note field, already exists) — `"Horas estimadas: 336h"`
2. **Add a new field** — `HorasEstimadas` (Number)

**Recommendation:** Use option 1 (ResumoExecutivo) to avoid schema changes in MVP. The Horas value is informational, not computed.

### Connection References (from `PA_Phase3_P1P2.ps1`)
```
SharePoint: 44f187cde7f54f208cf22bac4e533816 (pmo_sharepoint)
Teams:      shared-teams-1440d346-f1dd-44ea-912f-3787038ac333 (pmo_teams)
Outlook:    306d783533364cb6948ab2830fc3b188 (pmo_office365)
Site URL:   https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
```

### Flow Trigger Pattern for Copilot Studio Actions
The `PMO_PA_CheckInOnDemand` flow (lines 338-376 of `PA_Provisioning_P0.ps1`) uses:
```
Trigger: type = "Request", kind = "Skills"
Response: type = "Response", kind = "Skills"
```
This is the standard Copilot Studio → Power Automate integration pattern (Standard connector, no Premium required).

---

## EXECUTION PLAN — 3 SCRIPTS TO RUN SEQUENTIALLY

### Script 1: `deploy/PA_CriarTarefa_Flow.ps1`
**Purpose:** Create the `PMO_PA_CriarTarefa` Power Automate flow in ColOfertasBrasilPro.

**Flow Logic:**
```
TRIGGER: Request/Skills (from Copilot Studio)
  INPUT SCHEMA:
    - nomeProjeto (string, required)
    - titulo (string, required)
    - responsavel (string, required)
    - prazo (string, required)
    - horas (integer, optional)
    - prioridade (string, required: Alta|Media|Baixa|Critica)

ACTIONS:
  1. Get_Max_ProjectID
     → SharePoint GetItems on "Projetos", $top=5000, $orderby=ID desc, $top=1
     → Extract the highest numeric suffix from existing ProjectIDs
  
  2. Compose_New_ProjectID
     → Format: PRJ-{padLeft(add(int(last(split(first(body('Get_Max_ProjectID')?['value'])?['ProjectID'], '-'))), 1), 6, '0')}
     → Fallback if no projects exist: PRJ-000001
  
  3. Map_Prioridade
     → Normalize: "Crítica" → "Alta", "Critica" → "Alta" (Projetos schema only has Alta/Media/Baixa)
  
  4. Create_Projeto_Item
     → SharePoint PostItem on "Projetos"
     → Fields:
        - Title = titulo
        - ProjectID = Compose_New_ProjectID output
        - NomeProjeto = titulo
        - PM = responsavel (as text; User field lookup is deferred to V2)
        - DataAlvo = prazo
        - Prioridade = mapped prioridade
        - StatusRAG = "Verde"
        - Percentual = 0
        - Ativo = true
        - UltimaAtualizacao = utcNow()
        - ResumoExecutivo = "Projeto criado via Copilot. Horas estimadas: {horas}h. Responsável: {responsavel}."
  
  5. Response_OK (Skills response)
     → Return: { success: true, message: "Projeto {titulo} criado com código {ProjectID}.", projectId: "{ProjectID}" }
  
  6. Response_Error (on failure)
     → Return: { success: false, message: "Erro ao criar projeto.", errorcode: "SP_CREATE_FAILED" }
```

**Implementation Pattern:** Follow exactly `PA_Provisioning_P0.ps1` lines 338-376 (CheckInOnDemand pattern), with:
- Same `New-FlowDefinition`, `New-FlowPayload`, `New-ProcessSimpleFlow` functions
- Same connection references (SharePoint only needed for this flow)
- Same evidence collection pattern

**SharePoint PostItem action:**
```powershell
New-OpenApiAction `
    -ApiId "/providers/Microsoft.PowerApps/apis/shared_sharepointonline" `
    -OperationId "PostItem" `
    -ConnectionName "shared_sharepointonline" `
    -Parameters @{
        dataset = $SiteUrl
        table = "Projetos"
        "item/Title" = "@{triggerBody()?['titulo']}"
        "item/ProjectID" = "@{outputs('Compose_New_ProjectID')}"
        "item/NomeProjeto" = "@{triggerBody()?['titulo']}"
        "item/StatusRAG/Value" = "Verde"
        "item/Percentual" = 0
        "item/Ativo" = $true
        "item/UltimaAtualizacao" = "@utcNow()"
        "item/Prioridade/Value" = "@outputs('Map_Prioridade')"
        "item/ResumoExecutivo" = "@concat('Projeto criado via Copilot. Horas estimadas: ', coalesce(string(triggerBody()?['horas']), 'N/A'), 'h. Responsável: ', triggerBody()?['responsavel'], '.')"
    } `
    -RunAfter @{ Map_Prioridade = @("Succeeded") }
```

**Evidence Output:** `.planning/comms/pa_criartarefa_flow_{timestamp}.json`

---

### Script 2: `deploy/CS_CriarTarefa_Patch.ps1`
**Purpose:** Wire the CriarTarefa topic to the new `PMO_PA_CriarTarefa` flow AND update bot configuration.

**This script must:**
1. **Discover** the newly created `PMO_PA_CriarTarefa` flow's FlowName and WorkflowEntityId
2. **Set flow as solution-aware** using `Set-FlowAsSolutionAware`
3. **Build a solution package** with:
   - Bot component for `pmo_AssistentePMO.action.PMO_PA_CriarTarefa` (componenttype=9)
   - TaskDialog data pointing to the flow's WorkflowEntityId
   - Workflow association XML (`botcomponent_workflowset`)
   - `GenerativeActionsEnabled = true` in bot configuration
4. **Import** via `pac solution import --environment {env} --publish-changes`
5. **Publish** via `pac copilot publish --environment {env} --bot {botId}`
6. **Extract** updated template via `pac copilot extract-template`

**Implementation Pattern:** Follow exactly `CS_G4_Complete.ps1` (the full script is the reference). Key differences:
- Solution unique name: `PMO_CriarTarefa_Patch`
- Only 1 flow to wire (PMO_PA_CriarTarefa)
- Bot configuration must include `GenerativeActionsEnabled = $true`

**Evidence Output:** `.planning/comms/cs_criartarefa_patch_{timestamp}.json`

---

### Script 3: Verification (inline in Script 2 or separate)
**Purpose:** Validate the deployment succeeded.

**Checks:**
1. `pac copilot list --environment {env}` — Bot must appear and show as Published
2. `pac copilot extract-template --environment {env} --bot {botId}` — Extracted template must contain:
   - `GenerativeActionsEnabled: true`
   - `PMO_PA_CriarTarefa` action component
   - `CriarTarefa` topic
3. `Get-Flow -EnvironmentName {env} -FlowName {flowName}` — Flow must be enabled and state = "Started"

---

## CRITICAL CONSTRAINTS

1. **Standard Connectors ONLY** — No HTTP, no Custom, no Graph API, no Dataverse. SharePoint + Teams + Outlook + Planner only.
2. **No Premium** — All flows must use Standard tier connectors.
3. **PM Field Limitation** — The `PM` field in Projetos is type `User`. Writing a string (e.g., "Manoel Benicio") to a User field requires the UPN (email). For MVP, write to `ResumoExecutivo` note field and leave `PM` empty. In V2, implement UPN lookup.
4. **ProjectID Collision** — The auto-generation uses `$orderby=ID desc, $top=1` which is NOT atomic. For MVP pilot (3 PMs, <250 interactions/day), collision risk is negligible. For production scale, implement a dedicated counter list.
5. **DataAlvo Format** — The user sends dates in various formats (dd/mm/yyyy, yyyy-mm-dd). The flow should normalize via Power Automate's `formatDateTime()` or accept ISO 8601 directly.
6. **Prioridade Mapping** — Projetos list allows: `Alta`, `Media`, `Baixa`. If user says "Crítica", map to "Alta" (highest available). This is a schema limitation, not a bug.

---

## Q1 RESOLUTION — CriarTarefa Flow

**Answer:** There is NO existing flow for CriarTarefa. The topic was created manually in Copilot Studio without a backing flow. Script 1 above creates `PMO_PA_CriarTarefa` and Script 2 wires it to the bot. This follows the same pattern as `PMO_PA_CheckInOnDemand` (Skills trigger → SharePoint action → Skills response).

## Q2 RESOLUTION — Generative Orchestration Capacity

**Answer:** ✅ WITHIN CAPACITY.

| Metric | Value |
|--------|-------|
| Copilot Studio Standard allocation | 25,000 messages/month (M365 E3/E5 included) |
| Estimated daily interactions | 100-250 (PRD Section 5) |
| Working days/month | ~22 |
| Max interactions/month | 250 × 22 = 5,500 |
| Generative Orchestration overhead | ~2-3x per interaction (LLM orchestrator calls) |
| Worst-case messages/month | 5,500 × 3 = 16,500 |
| **Headroom** | **8,500 messages (~34% margin)** |
| Pilot users | 3 PMs |
| Production users (future) | ~50 PMs → re-evaluate at scale |

**Risk:** LOW for MVP pilot. Monitor via Copilot Studio Analytics dashboard (Configurações > Análise).

---

## EXECUTION ORDER

```
1. Run: deploy/PA_CriarTarefa_Flow.ps1
   → Creates PMO_PA_CriarTarefa flow in ColOfertasBrasilPro
   → Output: flow evidence JSON

2. Run: deploy/CS_CriarTarefa_Patch.ps1 -ExistingFlowEvidence <path from step 1>
   → Wires flow to Copilot Studio bot
   → Enables GenerativeActionsEnabled = true
   → Imports solution, publishes bot, extracts template
   → Output: patch evidence JSON

3. Verify: Extract template YAML and confirm:
   ✅ CriarTarefa topic present
   ✅ PMO_PA_CriarTarefa action present  
   ✅ GenerativeActionsEnabled = true
   ✅ No ProjectID question in CriarTarefa flow
```

---

## FILES TO CREATE

| File | Purpose |
|------|---------|
| `deploy/PA_CriarTarefa_Flow.ps1` | Power Automate flow creation script |
| `deploy/CS_CriarTarefa_Patch.ps1` | Copilot Studio solution patch + publish |

## FILES ALREADY UPDATED

| File | Changes |
|------|---------|
| `deploy/copilot/AssistentePMO.template.yaml` | ✅ GenerativeActionsEnabled=true, CriarTarefa topic added, Greeting updated |
| `deploy/CS_G4_Complete.ps1` | ✅ GenerativeActionsEnabled=$true, GPT rules 8-10 added |
