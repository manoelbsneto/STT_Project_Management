# Phase 1 — SharePoint Provisioning Programático

## Plan 1-1: Criar Schema de Listas e Provisioning Script

### Context
O site SharePoint oficial `Grp_T_DN_Transformacao_Digital` já existe. O deploy deve criar programaticamente as 4 listas obrigatórias + 1 opcional, com todas as colunas, tipos, índices e views conforme o AGENT_CONTRACT.md.

### Approach
Usar PnP PowerShell (SharePoint Patterns & Practices) para provisioning automatizado. PnP PowerShell é o padrão Microsoft recomendado para provisioning programático de listas, colunas e views.

### Tenant Execution Constraint — Authoritative

O caminho que funciona neste tenant/workspace é o mesmo validado no projeto anterior `D:\VMs\Projetos\Copilot_Studio_VsCode`: Windows PowerShell 5.1 + módulo legado `SharePointPnPPowerShellOnline 3.29.2101.0` + `Connect-PnPOnline -UseWebLogin`.

Não usar `pwsh`/PowerShell 7 nem `PnP.PowerShell` moderno para este provisioning. O login e o comando operacional devem rodar no mesmo processo Windows PowerShell:

```powershell
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
$env:PNPLEGACYMESSAGE = "false"
Remove-Module PnP.PowerShell,SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin
.\deploy\SP_Provisioning.ps1 -SiteUrl $siteUrl -SkipConnection
```

Não usar `ClientId`, app registration, certificado, service principal, HTTP with Microsoft Entra ID, custom connector ou Graph direto. O site oficial compartilhado contém `/SitePages/Home.aspx`, mas scripts PnP devem usar a URL base do site: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`.

Runbook permanente: `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`.

### Execution Result
G1 foi provisionado e verificado em 2026-05-02.

- Provisioning evidence: `.planning/comms/g1_legacy_pnp_provisioning_20260502_115923.log`
- Verification evidence: `.planning/comms/g1_legacy_pnp_verify_20260502_120214.log`
- Resultado: 4 listas criadas, 62 campos customizados no total, views esperadas, 5 projetos piloto em `Projetos`.

### Reference
- https://pnp.github.io/powershell/
- https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-overview

### Tasks

<task type="auto">
  <name>Create PnP provisioning script for 4 SP Lists</name>
  <files>deploy/SP_Provisioning.ps1</files>
  <action>
    Create PowerShell script using PnP PowerShell to:
    1. Connect to SharePoint site
    2. Create 4 lists with full schema from AGENT_CONTRACT
    3. Add all columns with correct types
    4. Create indexes on critical columns
    5. Create views (Board, Gallery, List)
    6. Insert 5 pilot projects
  </action>
  <verify>Script executes without errors in test environment</verify>
  <done>All 4 lists created with correct schema, indexed columns, and views</done>
</task>

<task type="auto">
  <name>Create Adaptive Card JSON templates</name>
  <files>deploy/cards/CheckInDiario.json, deploy/cards/AlertaCritico.json, deploy/cards/DecisaoBoard.json</files>
  <action>
    Create 3 Adaptive Card JSON files following schema v1.4:
    1. Check-in Diário card (RAG, resumo, risco, bloqueio, ação, percentual)
    2. Alerta Projeto Crítico card (projeto, RAG, resumo, riscos)
    3. Decisão Board card (decisão, approve/reject/defer buttons)
    All cards must be <27KB and render in Teams Desktop + Mobile.
  </action>
  <verify>Cards validate at adaptivecards.io/designer and render in Teams</verify>
  <done>3 card JSONs ready for Power Automate flows</done>
</task>

<task type="auto">
  <name>Create Power Automate flow definitions document</name>
  <files>deploy/flows/FLOW_DEFINITIONS.md</files>
  <action>
    Document all 10 flows with step-by-step implementation instructions
    including exact trigger configurations, action parameters, and
    expression formulas for Power Automate.
  </action>
  <verify>Each flow definition is implementable without ambiguity</verify>
  <done>All 10 flow definitions documented with exact PA expressions</done>
</task>
