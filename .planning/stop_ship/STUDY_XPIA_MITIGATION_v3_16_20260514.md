# STUDY: XPIA Mitigation Strategies for v3.16

**Type**: Research study — NO system changes  
**Date**: 2026-05-14  
**Author**: Research AI (Antigravity)  
**Owner**: Project Owner (sole authority for any system changes)  
**Status**: Study complete — awaiting owner's implementation decision  

---

## 1. Problem Statement

Copilot Studio's Responsible AI (RAI) dual-pass moderation layer triggers `openAIIndirectAttack` / `ContentFiltered` errors on the PMO Intelligent Hub v3.15 after successful Power Automate flow execution. The bot works (SharePoint writes succeed) but a "blocked step" is appended post-action, breaking the user experience. Current status: NO-SHIP.

---

## 2. Confirmed Root Cause

The XPIA (Cross-Prompt Injection Attack) detector scans ALL data in the orchestration pipeline, including hidden action/tool output variables and connector responses — not just the user-visible message. SharePoint PMO data patterns (field-value pairs, alphanumeric IDs, email addresses) are misclassified as indirect prompt injection.

Evidence: 18+ sources cross-referenced (Microsoft Learn, Reddit, GitHub, Power Platform community).

Full research: `.planning/stop_ship/DEEP_RESEARCH_OPENAIINDIRECTATTACK_CONTENTFILTERED_20260514.md`

---

## 3. Current Flow Output Analysis (v3.15)

### 3.1 ListarTarefas — What the Flow Returns Today

**Flow internal behavior:**
1. Queries SharePoint `Projetos` list (returns ProjectID, NomeProjeto, etc.)
2. Queries SharePoint `Tarefas` list (returns up to 100 rows with all fields)
3. Computes `Count_Total`, `Count_Concluidas`, `Select_Tarefas` (all task IDs)
4. Builds `Compose_Lista` string: `"Projeto PRJ-274E5ACC. Total 5. Concluidas 2. IDs 14, 15, 16, 17, 18."`

**Flow response to Copilot Studio (the `Respond_Lista` action):**
```json
{
  "result": "Consulta concluida. Dados lidos no SharePoint. Use os IDs ativos validados no roteiro de QA."
}
```

**Key finding:** The `Compose_Lista` string with all dynamic data is computed but NEVER returned to the bot. The flow returns a hardcoded static sentence. However, the SharePoint connector response data (up to 100 task rows) remains in the flow's runtime context and is likely visible to the RAI moderation layer.

**Topic YAML behavior:**
- Receives `result` into `Topic.tarefas` variable (contains the static string)
- Displays a SECOND hardcoded static message via `SendActivity` (does not even use `Topic.tarefas`)
- Result: user sees static text → then BLOCKED

**Conclusion:** The ListarTarefas flow performs expensive SharePoint queries with ZERO user-facing value. All computed data is discarded. The action call exists purely as overhead that triggers the XPIA detector.

### 3.2 CriarTarefa — What the Flow Returns Today

**Flow internal behavior:**
1. Validates date format (Brazilian dd/MM/aaaa)
2. Queries SharePoint `Projetos` to find the project
3. Creates a new item in SharePoint `Tarefas` list
4. Sets `responseMessage` variable with dynamic data

**Flow response to Copilot Studio (via `Valores_retornados_para_o_Power_Virtual_Agents`):**
```json
{
  "message": "@variables('responseMessage')"
}
```

**The `responseMessage` variable contains (by path):**

| Path | Value | XPIA Risk |
|---|---|---|
| Success | `"Tarefa criada com sucesso. ID: 16 ProjectID: PRJ-274E5ACC"` | HIGH — alphanumeric codes, field-value pairs |
| Not found | `"Projeto nao encontrado, inativo ou deletado. Codigo: PROJECT_NOT_FOUND."` | LOW — static error code |
| Invalid date | `"Prazo invalido. Use formato brasileiro dd/MM/aaaa. Codigo: INVALID_BR_DATE."` | LOW — static error code |

**Topic YAML behavior:**
- Receives `message` into `Topic.Result` variable
- Displays `"{Topic.Result}"` directly via `SendActivity` — the dynamic string with ID and ProjectID is shown to the user
- Result: user sees dynamic text with SharePoint IDs → then BLOCKED

**Conclusion:** The CriarTarefa success path returns `ID: 16 ProjectID: PRJ-274E5ACC` which contains structured field-value pairs that the XPIA detector interprets as suspicious. The error paths return static codes and do NOT trigger the filter.

---

## 4. Proposed Mitigation — What Would Need to Change

### 4.1 ListarTarefas — Two Options

**Option A1 (Recommended): Remove the action call entirely**
- The topic would only send a static message directing the user to SharePoint
- No flow executes → no SharePoint data in the moderation pipeline → XPIA risk = ZERO
- User impact: NONE (the flow was already not showing any data)

**Option A2 (Fallback): Keep action call, minimize output**
- The flow would still execute but return only `{"result": "ok"}`
- SharePoint data still loaded in flow context → XPIA risk = REDUCED but not zero

### 4.2 CriarTarefa — One Option

**Option B1 (Recommended): Return status codes only**
- Success path: flow sets `responseMessage = "success"` (instead of `"Tarefa criada com sucesso. ID: 16 ProjectID: PRJ-274E5ACC"`)
- Not found path: flow sets `responseMessage = "not_found"`
- Invalid date path: flow sets `responseMessage = "invalid_date"`
- The topic YAML would use conditional branching to display static messages based on the status code

### 4.3 Agent-Level Settings (Manual in Copilot Studio UI)

- Verify orchestration mode is Classic (not Generative)
- Lower content moderation from High to Medium at agent level

---

## 5. Impact Assessment

### What the User LOSES

| Topic | Lost Feature | Impact Level |
|---|---|---|
| ListarTarefas | Nothing | ZERO — data was never shown |
| CriarTarefa | Task ID display in chat (`ID: 16`) | LOW — visible in SharePoint |
| CriarTarefa | ProjectID display in chat (`PRJ-274E5ACC`) | LOW — user already knows the project |

### What the User GAINS

| Gain | Value |
|---|---|
| Working bot — no "Etapa Bloqueada" | CRITICAL |
| Clean conversation UX | HIGH |
| Path to production release (v3.16) | CRITICAL |
| Reduced RAI false positive surface | HIGH |

### NET TRADE

Lose `"ID: 16"` in chat → Gain a working bot.

---

## 6. Risk Matrix

| Risk | Probability | Mitigation |
|---|---|---|
| Minimal output still triggers XPIA | 20% | Option A1 eliminates 100% for ListarTarefas |
| User needs task ID for follow-up | 30% | Add lookup command later |
| Error messages too generic | 15% | Status codes + topic branching provide same info |

---

## 7. Diagnostic Recommendations

### Connect Application Insights
1. Create Azure Application Insights resource
2. Connect in Copilot Studio Settings → Agent details → Application Insights
3. Run KQL queries to identify exact trigger payload:

```kusto
customEvents
| where customDimensions contains "ContentFiltered"
| extend cd = parse_json(customDimensions)
| project timestamp, session_Id, errorCode = cd.errorCode, details = cd
| order by timestamp desc
```

---

## 8. Related Documents

| Document | Path |
|---|---|
| Full Deep Research Report | `.planning/stop_ship/DEEP_RESEARCH_OPENAIINDIRECTATTACK_CONTENTFILTERED_20260514.md` |
| Original RCA (with Section 22 update) | `.planning/stop_ship/RCA_COPILOT_STUDIO_OPENAIINDIRECTATTACK_3_15_20260514.md` |
| SharePoint Content Scan | `.planning/comms/rai_content_scan_20260514/sharepoint_suspicious_content_scan_20260514_181246.json` |
| v3.16 Reference Drafts (local only) | `.planning/comms/solution_3_16_xpia_mitigation/` |

---

*Study completed: 2026-05-14T18:17 BRT*  
*All implementation decisions belong exclusively to the project owner.*  
*No system changes were made during this research.*
