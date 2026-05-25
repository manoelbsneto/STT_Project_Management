# READING_SUMMARY - PM0 3.20 Canonical Full Validate V2

- Agent: Codex #2 Lead
- Timestamp BRT: 2026-05-24 10:42:30 BRT
- Escopo: resumo em portugues simples dos 4 docs master lidos linearmente.

## 1. `.planning/TENANT_COMMAND_RUNBOOK.md`

### Valores Fixos Do Tenant
O tenant correto e sempre `ColOfertasBrasilPro`, com environment ID `e2d10003-4d8e-e007-9d63-76d5fe89ef56`, URL Dataverse `https://colofertasbrasilpro.crm4.dynamics.com/`, tenant ID `7808e005-1489-4374-954b-d3b08f193920`, e SharePoint site `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`. Esses valores devem ser usados explicitamente para evitar cair no Default environment.

### Versoes Instaladas Confirmadas
O documento fixa as versoes validadas: Windows PowerShell 5.1, PAC CLI 2.6.4, SharePointPnPPowerShellOnline 3.29.2101.0, Microsoft.PowerApps.PowerShell 1.0.45 e Microsoft.PowerApps.Administration.PowerShell 2.0.217. Os caminhos absolutos dos modulos importam porque ja foram o caminho que funcionou no tenant.

### Regras Que Nao Podem Ser Quebradas
Nao usar Default environment, PowerShell 7 para PnP legado, PnP moderno, ClientId/app registration/service principal/certificate/Graph direto/HTTP Premium, nem `Test-PowerAppsAccount` como pre-teste obrigatorio. A regra central para esta missao e nao declarar bloqueio antes de testar Windows PowerShell 5.1 com import absoluto dos modulos.

### 1. SharePoint - Login E Execucao Correta
SharePoint deve usar Windows PowerShell 5.1 e SharePointPnPPowerShellOnline 3.29.2101.0. O login correto e `Connect-PnPOnline -UseWebLogin`, e login + comando devem acontecer no mesmo processo. `-SkipConnection` e intencional quando o script reaproveita o contexto PnP aberto.

### 2. PAC CLI - Ambiente, Conexoes E Solutions
PAC deve ser validado com `pac auth list` e `pac env who`. Se houver problema, criar profile com `pac auth create --name COLQA0424 --deviceCode --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56`, selecionar o ambiente e verificar novamente. Operacoes de solution devem sempre apontar para o environment ID.

### 3. Power Automate - Metodo Que Funciona
Power Automate deve usar Windows PowerShell 5.1 com import absoluto dos modulos Microsoft.PowerApps. Se precisar login, usar `Add-PowerAppsAccount -Endpoint prod` e deixar o usuario completar MFA. Nao usar `Test-PowerAppsAccount`; testar diretamente `Get-Flow -EnvironmentName $envId -Top 5`.

### 4. Inventario Dos Flows PMO
O inventario PMO recomendado usa `Get-Flow -Top 200`, filtra `PMO_PA_*`, e captura DisplayName, FlowName, Enabled, CreatedTime, LastModifiedTime, state e workflowEntityId. Este caminho e fallback importante se PAC Dataverse falhar.

### 5. Exportar Definicao De Um Flow
Para auditar um flow, usar `Get-Flow -EnvironmentName $envId -FlowName $flowName` e exportar `Internal.properties.definition` em JSON profundo. Tambem ha caminho para `definitionSummary`.

### 6. Patch ProcessSimple De Flow Existente
O runbook documenta o corpo ProcessSimple para patch de flow existente, com connectionReferences reais de SharePoint, Teams e Office 365. Nesta missao e read-only, entao este padrao serve como evidencia de rota conhecida, nao como autorizacao para patch.

### 7. Criar Flow Via ProcessSimple
Criacao de flow via ProcessSimple e documentada apenas quando o flow ainda nao existe. Nesta missao e proibida porque seria tenant write.

### 8. Capturar Runs E Actions De Um Flow
Run history e actions podem ser lidos via `InvokeApi` em ProcessSimple para evidenciar execucao real. Isso e util para runtime evidence quando auth PowerApps funciona.

### 9. G2 Wiring - Campos Corretos
O documento confirma os campos reais do `Status Diario`, incluindo `StatusID`, `ProjectID`, `DataRegistro`, `PM`, `RAG`, `Resumo`, `Risco`, `Bloqueio`, `ProximaAcao`, `Percentual`, `OrigemEntrada`, `ResumoTarefas`, `CardVersion`. Nao usar nomes errados como `StatusRAG`, `DataCheckin` ou `Bloqueios` na lista `Status Diario`.

### 10. Comandos Que Geraram Perda De Tempo
Evitar `pwsh` para PnP, `Connect-PnPOnline -Interactive`, `Import-Module PnP.PowerShell`, `Test-PowerAppsAccount`, username/password com MFA, `m365 status` e `pac flow`. Esses caminhos ja foram testados e sao inadequados para este projeto.

### 11. Protocolo Antes De Declarar Bloqueio
Antes de bloqueio, executar a sequencia: `pac env who`, connection list, Windows PowerShell 5.1 com imports absolutos, `Get-Flow`, inventario PMO, export definition, ProcessSimple evidence e validacao por run history. Se pedir senha/MFA, parar e pedir ao usuario para completar a janela interativa, sem trocar automaticamente para outro metodo.

## 2. `.planning/power-platform-tooling-guide.md`

### 1. Overview
PAC e a CLI oficial da Microsoft para Power Platform. Ela cobre ciclo de vida de solutions, ambientes, auth, Dataverse, Pages, PCF e flows dentro de solutions. Pode ser usada via VSIX, MCP oficial, MCPs comunitarios, GitHub Actions ou standalone CLI.

### 2. Official VS Code Extension (VSIX)
A extensao oficial e Microsoft Power Platform Tools (`microsoft-IsvExpTools.powerplatform-vscode`). Ela traz PAC CLI, painel de auth, browser de ambientes, solution explorer, Power Pages actions, IntelliSense e suporte a Copilot/CodeQL. O setup basico e criar auth profile, verificar auth/env e testar `pac solution list`.

### 3. Official PAC MCP Server
O PAC inclui servidor MCP oficial embutido para expor capacidades PAC a clientes MCP. O comando documentado e `pac copilot mcp --run`, com configuracao via `dnx Microsoft.PowerApps.CLI.Tool --yes copilot mcp --run` ou caminho direto para `pac-mcp.exe`. As operacoes expostas incluem solution, environment, auth, Dataverse, Pages e PCF. Isso corrige a ideia de chamar `pac mcp start` como se fosse comando raiz.

### 4. Community MCP Servers (GitHub)
Ha MCPs comunitarios como `michsob/powerplatform-mcp` e `Cliveo/Power-Platform-MCP`. Eles podem ajudar em metadata, plugins, workflows, CRUD Dataverse e flow management, mas sao beta/comunitarios. O MCP oficial e mais adequado para solution import/export e operacoes PAC completas.

### 5. GitHub Actions for CI/CD
O repositorio oficial `microsoft/powerplatform-actions` cobre install, export, import, unpack, pack, publish, delete, solution checker, deploy package, version, clone, create/delete/copy/backup/restore environment. O exemplo usa service principal e secrets, mas nesta missao essa rota nao e autorizada por causa das regras do projeto contra app registration/service principal.

### 6. Full PAC CLI Command Reference
A secao lista comandos PAC para solution list/export/import/pack/unpack/clone/publish/delete/version, auth create/list/select/delete/clear, env list/select/create/copy/backup/restore, data export/import, pages, PCF e MCP. Para auth interativo, `pac auth create --environment <url>` e profile select/delete/clear sao comandos oficiais.

### 7. Decision Matrix - Which Tool to Use
Para desenvolvimento interativo, usar VSIX; para AI-assisted, PAC MCP oficial; para exploration profunda, MCPs comunitarios; para CI/CD, GitHub Actions; para automacao shell, standalone PAC; para operacao pontual, PAC CLI. Nesta missao, PAC CLI e, se disponivel, MCP oficial sao os caminhos coerentes.

### 8. Installation Checklist
Checklist: instalar .NET 6+, instalar PAC CLI, verificar instalacao, instalar VSIX, criar auth profile, verificar `pac env list` e `pac solution list`, opcionalmente configurar MCP e GitHub Actions. O item de verificacao `pac --version` pode ser incompatível com PAC 2.6.4 observado, que mostra versao junto com erro de argumento.

### 9. References & Links
A secao lista Microsoft Learn para PAC CLI, VSIX, solution/auth/environment commands, GitHub Actions e repositorios oficiais/comunitarios. Para comportamento Microsoft, usar esses links oficiais como fonte primaria.

## 3. `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`

### Status
Este e o caminho autoritativo para SharePoint no workspace.

### Do Not Use
Nao usar PowerShell 7/pwsh para provisioning, PnP.PowerShell moderno com Interactive, device code, ClientId/app registration/certificate/service principal/Graph direto/premium HTTP connector, nem separar login e provisioning em processos diferentes.

### Required Runtime
SharePoint exige Windows PowerShell 5.1, SharePointPnPPowerShellOnline 3.29.2101.0, auth `Connect-PnPOnline -UseWebLogin`, e site `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`.

### Required Command Pattern
Login e comando alvo devem rodar no mesmo processo. O padrao remove modulos conflitantes, importa SharePointPnPPowerShellOnline, conecta com `-UseWebLogin` e roda o comando/script com `-SkipConnection` para reaproveitar contexto.

### Evidence
O runbook referencia logs historicos e atuais que provaram o caminho legado PnP.

### G1 Verification Result
As listas principais ja foram verificadas: `Projetos`, `Status Diario`, `Riscos e Bloqueios`, `Decisoes do Board`, com campos e views esperados. Isso confirma o lado SharePoint do schema.

### Operational Note
`deploy/SP_Provisioning.ps1` nao e migracao repeat-safe. G1 ja esta provisionado; nao rerodar provisioning sem limpeza intencional ou idempotencia.

## 4. `.planning/GOLDEN_RULES.md`

### Mandatory Read Before Work
Todo agente deve ler Golden Rules, Current Baseline, Agent Registry, Manual Operacional quando toca PMO, Agent Access Protocol quando toca tenant e SEV0 protocol antes de ship/release/import/publish/runtime-readiness.

### Human Approval Gate
Nenhum agente pode importar, publicar, deployar, commitar, deletar, modificar runtime/portal ou escrever em producao sem aprovacao explicita do Owner. Edicoes locais e testes locais sao permitidos.

### Access Runbook Gate
Nao improvisar acesso tenant/remoto. Usar docs/runbooks master. M365 CLI nao aprovado sem mudanca explicita. Antes de comando de acesso, postar rota/comando no board e respeitar approval gate.

### Agent Budget Gate
Usar no maximo 3 subagentes sem aprovacao explicita, preferindo execucao local quando claro.

### SEV-0 Stop-Ship Diligence Mission
Default e NO-SHIP ate evidencia provar o contrario. Qualquer runtime evidence ausente/stale, binding antigo, placeholder, falta de teste, risco de data loss/permissao, ghost components, ou comportamento Microsoft inferido sem docs oficiais deve parar ship.

### Official Microsoft Docs Rule
Para Power Platform, Copilot Studio, Power Automate, Dataverse, SharePoint, Teams, Graph, Entra e M365 CLI, usar Microsoft Learn/docs oficiais e evidencia tenant/runtime. Se docs e runtime conflitam, capturar ambos e manter NO-SHIP ate resolucao/aceite.

### Continuous Documentation Update Rule
Docs de status devem refletir a realidade imediatamente apos claims, blockers, testes, evidencias, tenant writes, imports, publishs e decisoes. Stale docs causam decisoes erradas. Se tenant diverge dos docs, docs estao errados e devem ser corrigidos.

### Evidence Triplet Rule
Qualquer teste, deploy, gate, smoke ou DONE exige screenshot, timestamp BRT e agente. Evidencia incompleta nao prova PASS/DONE/PUBLISH. Para CLI, render ou screenshot do output tambem conta.

### Placeholder Backfill Rule
Documentos antecipados devem usar `<<TODO_BACKFILL: ...>>`, manifestar dependencias e ser preenchidos em ate 10 minutos quando evidencia chega. Documento com placeholder aberto e incompleto.

### Functional Definition of Done Rule
Flow/topico/action so e DONE com chamada runtime real retornando dados reais, evidencia triplet, teste end-to-end do bot, schema de inputs correto, mapping Power Fx correto, e sem DONE/PASS/PUBLISH antes dessas provas.

### Pre-Code-Ship Rules
Antes de alterar codigo, ler obrigatorios, checar registry/locks/baseline, preservar alteracoes de outros, identificar rollback, manter ASCII app-facing. Antes de ship-ready, rodar testes e runtime checks, anexar evidencias, reler registry/baseline e manter NO-SHIP se evidencia incompleta.
