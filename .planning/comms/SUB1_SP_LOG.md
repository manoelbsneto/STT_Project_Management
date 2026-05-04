# CODEX Sub-1 — SharePoint Provisioning Log

### 2026-05-02T11:48:57-03:00 — CODEX-SP — EXECUTION RESULT
- **Phase:** 1
- **Task:** Tenant execution of `deploy/SP_Provisioning.ps1`
- **Status:** FAILED
- **Details:** Script was executed with PowerShell 7 after Windows PowerShell 5.1 hit a UTF-8 parsing issue. PowerShell 7 parsed the script, but PnP authentication failed before provisioning: `Connect-PnPOnline -Interactive` returned `Specified method is not supported` with a valid ClientId warning. Subsequent PnP commands reported `You are not signed in`.
- **Gate:** G1 final FAIL until an approved interactive/auth path is available and tenant objects are verified.

### 2026-05-02T11:56:00-03:00 — CODEX-SP — SCRIPT COMPATIBILITY + RETRY
- **Phase:** 1
- **Task:** Align script to PnP.PowerShell 3.1.0 and retry login + provisioning in same session.
- **Status:** FAILED AT LOGIN
- **Details:** Updated `deploy/SP_Provisioning.ps1` to import `PnP.PowerShell 3.1.0`, fail on errors, support `-SkipConnection`, and replace unsupported `Add-PnPField -DateFormat` with `Add-PnPFieldFromXml` for DateOnly columns. Parser check passed. Retried with `Connect-PnPOnline -Interactive` and provisioning command in the same PowerShell session; login still failed before provisioning.
- **Evidence:** `.planning/comms/g1_pnp_provisioning_20260502_115551.log`
- **Gate:** G1 remains FAIL until interactive PnP login succeeds and lists are verified.

### 2026-05-02T12:02:30-03:00 — CODEX-SP — G1 PROVISIONED AND VERIFIED
- **Phase:** 1
- **Task:** Tenant execution of `deploy/SP_Provisioning.ps1`
- **Status:** PASSED
- **Details:** Corrected auth path from previous project: Windows PowerShell 5.1 + `SharePointPnPPowerShellOnline 3.29.2101.0` + `Connect-PnPOnline -UseWebLogin`. Login and provisioning executed in the same process. Script was updated for legacy PnP compatibility and Windows PowerShell parsing.
- **Provisioned:** `Projetos`, `Status Diario`, `Riscos e Bloqueios`, `Decisoes do Board`
- **Verified:** 62 custom fields total, expected views present, 5 pilot records in `Projetos`.
- **Evidence:** `.planning/comms/g1_legacy_pnp_provisioning_20260502_115923.log`, `.planning/comms/g1_legacy_pnp_verify_20260502_120214.log`
- **Runbook:** `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
- **Gate:** G1 final PASS.

### 2026-05-01T23:42:00Z — CODEX-SP — PROGRESS
- **Phase:** 1
- **Task:** Criar script PnP PowerShell para provisioning das 4 listas
- **Status:** COMPLETED
- **Details:** Script `deploy/SP_Provisioning.ps1` criado com:
  - 4 listas: Projetos (22 colunas), Status Diario (13 colunas), Riscos e Bloqueios (13 colunas), Decisoes do Board (14 colunas)
  - Índices em todas as colunas críticas (ProjectID, StatusRAG, PM, Sponsor, UltimaAtualizacao, Ativo, DataRegistro, Severidade, StatusRisco, StatusDecisao)
  - Views: Board RAG (agrupada), Gallery, Todos, Por Projeto, Abertos, Pendentes
  - 5 projetos piloto com dados realistas
- **Artifacts:** `deploy/SP_Provisioning.ps1`
- **Next:** CODEX-LEAD deve validar script e agendar execução no tenant
- **Gate:** G1 — Script ready, awaiting execution

### 2026-05-01T23:44:00Z — CODEX-SP — PROGRESS
- **Phase:** 1 (sub-task)
- **Task:** Criar 3 Adaptive Cards JSON
- **Status:** COMPLETED
- **Details:** 3 cards criados:
  - `deploy/cards/CheckInDiario.json` — formulário de check-in diário (~2.5KB)
  - `deploy/cards/AlertaCritico.json` — alerta projeto vermelho (~1.8KB)
  - `deploy/cards/DecisaoBoard.json` — decisão com approve/reject/defer (~2.8KB)
  - Todos <27KB ✅ | Schema v1.4 | Compatíveis Teams Desktop/Mobile
- **Artifacts:** `deploy/cards/CheckInDiario.json`, `deploy/cards/AlertaCritico.json`, `deploy/cards/DecisaoBoard.json`
- **Next:** Cards prontos para uso nos flows Power Automate (Phase 2)
- **Gate:** N/A (sub-deliverable)

### 2026-05-03T14:40:00-03:00 — CODEX-SP — G5 PARTIAL / AUTH BLOCKED
- **Phase:** 5
- **Task:** Teams Integration e Visibilidade — SharePoint views and Teams tabs.
- **Status:** PARTIAL / BLOCKED
- **Details:** Legacy SharePoint PnP auth succeeded via Windows PowerShell 5.1 + `SharePointPnPPowerShellOnline` + `Connect-PnPOnline -UseWebLogin`. Created/verified the SharePoint view `Projetos Críticos` on `Projetos` filtered to `StatusRAG=Vermelho`; existing `Board RAG` and `Pendentes` views were resolved to absolute URLs. Teams tab creation is blocked because legacy PnP has no Microsoft Graph OAuth token, `Connect-PnPOnline -Graph/-PnPManagementShell` fails with `Identificador inválido`, M365 CLI cannot auth because the CLI app is not consented in the tenant (`AADSTS700016`), and Microsoft Graph PowerShell device-code login timed out before user completion.
- **Artifacts:** `deploy/Teams_Phase5_Tabs.ps1`, `deploy/Teams_Phase5_GraphTabs.ps1`, `.planning/comms/g5_sharepoint_views_20260503_142829.json`, `.planning/comms/g5_graph_tabs_error_20260503_143611.txt`.
- **Next:** User must complete a fresh Microsoft Graph PowerShell device-code login within 120 seconds; then rerun `pwsh -NoProfile -ExecutionPolicy Bypass -File .\deploy\Teams_Phase5_GraphTabs.ps1`.
- **Gate:** G5 BLOCKED pending Graph authentication.

### 2026-05-03T22:47:00-03:00 — CODEX-SP — G5 AUTH RETRY RESULT
- **Phase:** 5
- **Task:** Retry Microsoft Graph authentication for Teams tab provisioning.
- **Status:** BLOCKED
- **Details:** Three additional Microsoft Graph PowerShell device-code attempts were started for `deploy/Teams_Phase5_GraphTabs.ps1`. Codes were surfaced to the user, one attempt also opened `https://login.microsoft.com/device` and copied the code to the Windows clipboard. All attempts expired after 120 seconds without completed login/MFA, before any Teams tab Graph API calls were made.
- **Artifacts:** `.planning/comms/mggraph_g5_retry_20260503_223826.out`, `.planning/comms/mggraph_g5_retry_20260503_224109.out`, `.planning/comms/mggraph_g5_retry_20260503_224444.out`, `.planning/comms/g5_graph_tabs_error_20260503_224444.txt`.
- **Gate:** G5 remains BLOCKED pending successful interactive Microsoft Graph login.

### 2026-05-04T00:00:00-03:00 — CODEX-SP — G5 NO-GRAPH CONFIRMATION
- **Phase:** 5
- **Task:** Teams tab provisioning route decision.
- **Status:** BLOCKED / NEEDS OWNER-ADMIN OR MANUAL TEAMS UI
- **Details:** User confirmed they do not have Microsoft Graph access. Teams channel tab creation is a Microsoft Graph-backed operation; PnP Teams tab cmdlets and MicrosoftTeams/CLI routes also require Graph permissions or tenant app consent. Therefore the three Teams tabs cannot be created programmatically by the current account/session.
- **Completed:** SharePoint view work remains complete and ready for embedding: `Board RAG`, `Projetos Críticos`, and `Pendentes` URLs exported in `.planning/comms/g5_sharepoint_views_20260503_142829.json`.
- **Next:** Have a Teams owner/admin with Graph permissions run `deploy/Teams_Phase5_GraphTabs.ps1`, or add the three SharePoint list-view tabs manually in Teams using the URLs documented in `.planning/comms/G5_NO_GRAPH_FALLBACK.md`.
- **Gate:** G5 remains BLOCKED for programmatic completion.
