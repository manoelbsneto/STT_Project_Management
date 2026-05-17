# CODEX 5.5 — COPY THIS ENTIRE BLOCK TO CODEX IDE

```
You are Codex 5.5 High-Thinking, orchestrator of a SEV-0 Stop-Ship finalization for the PMO Intelligent Hub.
You have 4 SUBAGENTS available. Use them for parallel execution of independent tasks.

Repository: D:/VMs/Projetos/STT_Project_Management
Branch: main

MANDATORY: Read these files FIRST, in order:
1. .planning/AGENT_CHECKIN_REGISTRY.md — Central coordination. Poll every 60s.
2. .planning/comms/CODEX_5_5_HANDOFF_20260510.md — Full task instructions.
3. .planning/COORDINATION_CONTRACT.md — Ownership boundaries.
4. .planning/CODEX_HANDOFF_GHOST_CLEANUP_20260506.md — Ghost cleanup ops.
5. .planning/stop_ship/PROD_DATA_CLEANUP_AND_QA_PLAN_20260510.md — Cleanup plan.
6. .planning/SHAREPOINT_ACCESS_RUNBOOK.md — SharePoint auth pattern.

YOUR ROLE: You own ALL programmatic/CLI/PAC/API tasks. Opus 4.6 ONLY handles browser-mandatory work (Copilot Studio UI publish, topic binding, bot chat testing).

SUBAGENT STRATEGY: When multiple tasks have no dependency conflicts, dispatch them to subagents in parallel. Example: PRE-02 and CLN-02 can run simultaneously after their deps are met.

CURRENTLY UNBLOCKED (check registry for latest):

TASK PRE-01 (IN PROGRESS or DONE — check registry):
Add 4 logical delete fields to 5 SharePoint lists.
Lists: Projetos, Tarefas, Status Diario, Riscos e Bloqueios, Decisoes do Board
Site: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
Fields: Deleted (Boolean, default=No), DeletedAt (DateTime), DeletedReason (Text), DeletedByUPN (Text)
Script: deploy/Add-LogicalDeleteFields.ps1
Auth: Windows PowerShell 5.1 + SharePointPnPPowerShellOnline 3.29 + Connect-PnPOnline -UseWebLogin

TASK CLN-02 (dep: CLN-01 DONE):
Discover test/trash data across all SP lists. Read-only scan.
Script: deploy/Discover-SharePointTestDataCandidates.ps1
Patterns: Teste, Test, Codex, Opus, Demo, Mock, Sample, Fixture, Clean Flow, Direct, RISK-OPUS, DEC-OPUS, PRJ-OPUS, PRJ-TEST, PRJ-CODEX, mojibake (A-tilde, A-circumflex, etc.)
Output: CSV + markdown summary to .planning/cleanup/

TASK PRE-02 (dep: PRE-01 DONE):
Verify delete fields exist via PnP Get-PnPField on all 5 lists. Script-based, no browser needed.

TASK CLN-03 (dep: PRE-02 + CLN-02 DONE):
Mark test/trash candidates as Deleted=Yes via PnP Set-PnPListItem with DeletedAt, DeletedReason, DeletedByUPN metadata.

TASK CLN-04 (dep: CLN-03 DONE):
Validate deleted records hidden via OData filter test: query each list with $filter=Deleted ne 1 and confirm zero trash rows returned.

WAVE 1 TASKS (dep: CLN-04 DONE):
W1-01: Verify/rebuild PMO_PA_CriarTarefa_V3 with real SP write + Deleted=false on new records. 60min.
W1-02: Verify V3 flow via ProcessSimple API test run + SP item check. 20min.
W1-07: Re-audit after Opus T-007 browser evidence (dep: W1-05 + W1-06 DONE). 15min.

WAVE 2 TASKS (dep: W1-07 DONE — use 2 subagents in parallel):
W2-01: Build/deploy ConsultarPortfolio flow (OData filter excludes Deleted=1). 45min.
W2-02: Build/deploy ConsultarProjeto flow (OData filter excludes Deleted=1). 45min.

WAVE 3 TASKS (dep: W2-03 + W2-04 DONE — use 3 subagents in parallel):
W3-01: Build/deploy RegistrarRisco flow. 40min.
W3-02: Build/deploy RegistrarBloqueio flow. 40min.
W3-03: Build/deploy PedirDecisao flow. 40min.

WAVE 5 TASKS (dep: W4-02 DONE — use 4 subagents in parallel):
W5-01: Ghost botcomponent discovery via PAC/script. 20min.
W5-04: Recurrence flow evidence via ProcessSimple API run history. 15min.
W5-05: Test SyncPlannerStats via script + verify SP metrics. 20min.
W5-06: Test AlertaProjetoVermelho: set red item + verify flow run via API. 20min.

REPORT VALIDATION (dep: CLN-04 + W4-02 DONE — use 4 subagents):
RPT-01: Validate daily portfolio flow run via ProcessSimple API. 15min.
RPT-02: Validate weekly portfolio flow run via API. 15min.
RPT-03: Validate red project alert flow run via API. 10min.
RPT-04: Validate critical risk escalation flow run via API. 10min.
RPT-05: Validate decision card approve/reject flow run via API. 15min.

WAVE 6 (dep: RPT-05B DONE):
EXP-01: Export final cleaned solution via pac solution export. 10min.
EXP-02: Post-cleanup static audits on exported solution. 20min.

COORDINATION RULES:
- After completing each task, update .planning/AGENT_CHECKIN_REGISTRY.md:
  Change task row status to: DONE | Codex 5.5 | <timestamp> | <evidence_path>
  Add entry to Agent Activity Log at bottom of file.
- Re-read registry every 60s to find next available tasks.
- NEVER publish the bot — Opus does that via Copilot Studio UI.
- All flow OData queries MUST include: Deleted ne 1
- All new SP records MUST set Deleted = false explicitly.
- ASCII-only text in all flow definitions.
- Standard-Only connectors — no Premium, no Graph, no HTTP with Entra.
- Atomic git commits with task ID: git commit -m "fix(<TASK_ID>): <description>"
- Run relevant tests after each change before marking DONE.

EXISTING RESOURCES:
- Flow deploy scripts: deploy/PA_*_Flow.ps1
- Test scripts: tests/Test-*.ps1
- YAML template: deploy/copilot/AssistentePMO.template.yaml
- Ghost discovery: deploy/Discover-GhostBotComponents.ps1
- SharePoint auth: .planning/SHAREPOINT_ACCESS_RUNBOOK.md

Start with your first unblocked task. Use subagents for parallel work. Go.
```
