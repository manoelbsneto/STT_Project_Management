# RULES_INTERNALIZED - PM0 3.20 Canonical Full Validate V2

- Agent: Codex #2 Lead
- Timestamp BRT: 2026-05-24 10:42:45 BRT
- Declaracao: regras abaixo foram extraidas apos leitura linear dos docs master e contexto. Elas governam a execucao desta missao antes de qualquer PAC.

1. R-001 - `.planning/TENANT_COMMAND_RUNBOOK.md:9` - Usar tenant ID `7808e005-1489-4374-954b-d3b08f193920`.
2. R-002 - `.planning/TENANT_COMMAND_RUNBOOK.md:10` - Usar environment `ColOfertasBrasilPro`.
3. R-003 - `.planning/TENANT_COMMAND_RUNBOOK.md:11` - Usar environment ID `e2d10003-4d8e-e007-9d63-76d5fe89ef56`.
4. R-004 - `.planning/TENANT_COMMAND_RUNBOOK.md:12` - Usar URL Dataverse `https://colofertasbrasilpro.crm4.dynamics.com/`.
5. R-005 - `.planning/TENANT_COMMAND_RUNBOOK.md:15` - SharePoint site correto e `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`.
6. R-006 - `.planning/TENANT_COMMAND_RUNBOOK.md:23` - Windows PowerShell validado e 5.1.
7. R-007 - `.planning/TENANT_COMMAND_RUNBOOK.md:25` - PAC CLI instalado observado e 2.6.4.
8. R-008 - `.planning/TENANT_COMMAND_RUNBOOK.md:26` - SharePointPnPPowerShellOnline validado e 3.29.2101.0 com caminho absoluto documentado.
9. R-009 - `.planning/TENANT_COMMAND_RUNBOOK.md:27` - Microsoft.PowerApps.PowerShell validado e 1.0.45 com caminho absoluto documentado.
10. R-010 - `.planning/TENANT_COMMAND_RUNBOOK.md:28` - Microsoft.PowerApps.Administration.PowerShell validado e 2.0.217 com caminho absoluto documentado.
11. R-011 - `.planning/TENANT_COMMAND_RUNBOOK.md:32` - Nao usar Default environment; sempre `ColOfertasBrasilPro`.
12. R-012 - `.planning/TENANT_COMMAND_RUNBOOK.md:33` - Nao usar PowerShell 7 para SharePoint legado PnP.
13. R-013 - `.planning/TENANT_COMMAND_RUNBOOK.md:34` - Nao usar `Connect-PnPOnline -Interactive` neste projeto.
14. R-014 - `.planning/TENANT_COMMAND_RUNBOOK.md:35` - Nao usar PnP.PowerShell moderno para provisionamento SharePoint deste tenant.
15. R-015 - `.planning/TENANT_COMMAND_RUNBOOK.md:36` - Nao usar ClientId, app registration, service principal, certificate auth, Graph direto ou HTTP Premium.
16. R-016 - `.planning/TENANT_COMMAND_RUNBOOK.md:37` - Nao usar `Test-PowerAppsAccount` como pre-teste obrigatorio.
17. R-017 - `.planning/TENANT_COMMAND_RUNBOOK.md:38` - Nao declarar bloqueio antes de testar Windows PowerShell 5.1 com import absoluto dos modulos.
18. R-018 - `.planning/TENANT_COMMAND_RUNBOOK.md:42` - SharePoint deve usar Windows PowerShell 5.1 e SharePointPnPPowerShellOnline 3.29.2101.0.
19. R-019 - `.planning/TENANT_COMMAND_RUNBOOK.md:60` - Login SharePoint recomendado e `Connect-PnPOnline -UseWebLogin`.
20. R-020 - `.planning/TENANT_COMMAND_RUNBOOK.md:65` - `Connect-PnPOnline` e script PnP devem rodar no mesmo processo PowerShell.
21. R-021 - `.planning/TENANT_COMMAND_RUNBOOK.md:87` - Verificar PAC auth com `pac auth list`.
22. R-022 - `.planning/TENANT_COMMAND_RUNBOOK.md:88` - Verificar ambiente PAC com `pac env who`.
23. R-023 - `.planning/TENANT_COMMAND_RUNBOOK.md:94` - Se auth/ambiente errado, criar profile com `pac auth create --name COLQA0424 --deviceCode --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56`.
24. R-024 - `.planning/TENANT_COMMAND_RUNBOOK.md:95` - Selecionar ambiente com `pac env select --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56`.
25. R-025 - `.planning/TENANT_COMMAND_RUNBOOK.md:102` - Listar conexoes com environment ID explicito.
26. R-026 - `.planning/TENANT_COMMAND_RUNBOOK.md:116` - Listar solutions com `pac solution list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56`.
27. R-027 - `.planning/TENANT_COMMAND_RUNBOOK.md:122` - Exportar solution com environment ID explicito e path controlado.
28. R-028 - `.planning/TENANT_COMMAND_RUNBOOK.md:145` - Power Automate deve usar Windows PowerShell 5.1 com import absoluto de Microsoft.PowerApps.PowerShell.
29. R-029 - `.planning/TENANT_COMMAND_RUNBOOK.md:160` - Importar Microsoft.PowerApps.PowerShell via caminho absoluto documentado.
30. R-030 - `.planning/TENANT_COMMAND_RUNBOOK.md:161` - Importar Microsoft.PowerApps.Administration.PowerShell via caminho absoluto documentado.
31. R-031 - `.planning/TENANT_COMMAND_RUNBOOK.md:171` - Se precisar login PowerApps, usar `Add-PowerAppsAccount -Endpoint prod`.
32. R-032 - `.planning/TENANT_COMMAND_RUNBOOK.md:174` - Se senha/MFA for exigido, o usuario deve completar a janela interativa; nao usar username/password.
33. R-033 - `.planning/TENANT_COMMAND_RUNBOOK.md:176` - Nao rodar `Test-PowerAppsAccount` como bloqueio.
34. R-034 - `.planning/TENANT_COMMAND_RUNBOOK.md:179` - Testar PowerApps diretamente com `Get-Flow -EnvironmentName $envId -Top 5`.
35. R-035 - `.planning/TENANT_COMMAND_RUNBOOK.md:186` - Inventario PMO via `Get-Flow -Top 200`.
36. R-036 - `.planning/TENANT_COMMAND_RUNBOOK.md:187` - Filtrar inventario PMO por `DisplayName -like "PMO_PA_*"`.
37. R-037 - `.planning/TENANT_COMMAND_RUNBOOK.md:211` - Exportar definicao de flow alvo com `Get-Flow -FlowName`.
38. R-038 - `.planning/TENANT_COMMAND_RUNBOOK.md:224` - Patch ProcessSimple e padrao conhecido, mas nesta missao nao e permitido por ser write.
39. R-039 - `.planning/TENANT_COMMAND_RUNBOOK.md:296` - Criar flow via ProcessSimple so quando flow nao existe; nesta missao nao autorizado.
40. R-040 - `.planning/TENANT_COMMAND_RUNBOOK.md:340` - Capturar runs/actions via ProcessSimple e caminho de runtime evidence.
41. R-041 - `.planning/TENANT_COMMAND_RUNBOOK.md:384` - `StatusID` e campo real da lista `Status Diario`.
42. R-042 - `.planning/TENANT_COMMAND_RUNBOOK.md:398` - Nao usar `StatusRAG`, `DataCheckin` ou `Bloqueios` como campos de `Status Diario`.
43. R-043 - `.planning/TENANT_COMMAND_RUNBOOK.md:400` - Para atualizar `Projetos`, primeiro buscar item por ProjectID.
44. R-044 - `.planning/TENANT_COMMAND_RUNBOOK.md:408` - A secao de comandos que perderam tempo deve ser respeitada.
45. R-045 - `.planning/TENANT_COMMAND_RUNBOOK.md:413` - Nao usar `pwsh -File .\deploy\SP_Provisioning.ps1` para esse caminho SharePoint.
46. R-046 - `.planning/TENANT_COMMAND_RUNBOOK.md:414` - Nao usar `Connect-PnPOnline -Interactive`.
47. R-047 - `.planning/TENANT_COMMAND_RUNBOOK.md:415` - Nao usar `Import-Module PnP.PowerShell`.
48. R-048 - `.planning/TENANT_COMMAND_RUNBOOK.md:416` - Nao usar `Test-PowerAppsAccount`.
49. R-049 - `.planning/TENANT_COMMAND_RUNBOOK.md:417` - Nao usar `Add-PowerAppsAccount -Username -Password` com MFA.
50. R-050 - `.planning/TENANT_COMMAND_RUNBOOK.md:419` - PAC CLI 2.6.4 nao possui `pac flow`.
51. R-051 - `.planning/TENANT_COMMAND_RUNBOOK.md:431` - Antes de declarar bloqueio, seguir protocolo sequencial de 8 passos.
52. R-052 - `.planning/TENANT_COMMAND_RUNBOOK.md:435` - Primeiro passo do protocolo e `pac env who`.
53. R-053 - `.planning/TENANT_COMMAND_RUNBOOK.md:436` - Segundo passo e `pac connection list` com environment ID.
54. R-054 - `.planning/TENANT_COMMAND_RUNBOOK.md:437` - Terceiro passo e Windows PowerShell 5.1 com import absoluto.
55. R-055 - `.planning/TENANT_COMMAND_RUNBOOK.md:438` - Quarto passo e `Get-Flow -Top 5`.
56. R-056 - `.planning/TENANT_COMMAND_RUNBOOK.md:439` - Quinto passo e inventario PMO_PA_*.
57. R-057 - `.planning/TENANT_COMMAND_RUNBOOK.md:440` - Sexto passo e export da definicao do flow alvo.
58. R-058 - `.planning/TENANT_COMMAND_RUNBOOK.md:442` - Oitavo passo e validacao via Get-Flow e run history.
59. R-059 - `.planning/TENANT_COMMAND_RUNBOOK.md:444` - Se algum passo pedir senha/MFA, pedir ao usuario para completar auth interativa naquela janela, sem trocar automaticamente de metodo.
60. R-060 - `.planning/power-platform-tooling-guide.md:27` - PAC e ferramenta oficial Microsoft para Power Platform.
61. R-061 - `.planning/power-platform-tooling-guide.md:49` - Power Platform Tools VSIX e canal oficial para VS Code.
62. R-062 - `.planning/power-platform-tooling-guide.md:93` - VSIX tem painel visual para auth profiles.
63. R-063 - `.planning/power-platform-tooling-guide.md:106` - Setup PAC inclui criar auth profile.
64. R-064 - `.planning/power-platform-tooling-guide.md:116` - Testar operacoes solution com `pac solution list`.
65. R-065 - `.planning/power-platform-tooling-guide.md:125` - PAC inclui servidor MCP oficial para expor capacidades CLI a modelos.
66. R-066 - `.planning/power-platform-tooling-guide.md:136` - Comando documentado para MCP oficial e `pac copilot mcp --run`.
67. R-067 - `.planning/power-platform-tooling-guide.md:178` - MCP expõe operacoes de solution, environment, auth, Dataverse, Pages e PCF.
68. R-068 - `.planning/power-platform-tooling-guide.md:281` - MCP oficial usa PAC auth profiles.
69. R-069 - `.planning/power-platform-tooling-guide.md:472` - Auth commands incluem criar/listar/selecionar/deletar/limpar profiles.
70. R-070 - `.planning/power-platform-tooling-guide.md:476` - Auth por browser usa `pac auth create --environment <org url>`.
71. R-071 - `.planning/power-platform-tooling-guide.md:489` - Selecionar profile com `pac auth select --index 1`.
72. R-072 - `.planning/power-platform-tooling-guide.md:495` - `pac auth clear` existe, mas nao deve ser usado destrutivamente sem necessidade/approval.
73. R-073 - `.planning/power-platform-tooling-guide.md:546` - MCP oficial tambem aparece como `pac copilot mcp --run` na referencia.
74. R-074 - `.planning/power-platform-tooling-guide.md:552` - Decision matrix define ferramenta conforme use case.
75. R-075 - `.planning/power-platform-tooling-guide.md:557` - Para AI-assisted operations, usar PAC MCP oficial.
76. R-076 - `.planning/power-platform-tooling-guide.md:608` - PAC CLI docs oficiais estao em Microsoft Learn.
77. R-077 - `.planning/power-platform-tooling-guide.md:611` - PAC Auth Commands docs oficiais devem ser consultados quando auth falha.
78. R-078 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:4` - Esse runbook e caminho SharePoint autoritativo do workspace.
79. R-079 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:7` - Nao usar PowerShell 7 para tenant provisioning SharePoint.
80. R-080 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:8` - Nao usar PnP.PowerShell moderno com Interactive.
81. R-081 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:9` - Nao usar device code para SharePoint PnP.
82. R-082 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:10` - Nao usar ClientId/app registration/certificate/service principal/Graph/premium HTTP para SharePoint.
83. R-083 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:11` - Nao separar login e provisioning SharePoint em processos diferentes.
84. R-084 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:14` - Shell SharePoint requerido e Windows PowerShell 5.1.
85. R-085 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:15` - Modulo SharePoint requerido e SharePointPnPPowerShellOnline.
86. R-086 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:17` - Auth SharePoint requerida e `Connect-PnPOnline -UseWebLogin`.
87. R-087 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:21` - Login e comando SharePoint alvo devem rodar no mesmo processo.
88. R-088 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:32` - `-SkipConnection` e intencional para reaproveitar contexto legado.
89. R-089 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:45` - `deploy/SP_Provisioning.ps1` nao e migracao repeat-safe.
90. R-090 - `.planning/SHAREPOINT_ACCESS_RUNBOOK.md:46` - Nao rerodar provisioning G1 salvo limpeza intencional ou idempotencia.
91. R-091 - `.planning/GOLDEN_RULES.md:7` - Antes de code/deploy/import/publish/tenant write/release decision, ler obrigatorios.
92. R-092 - `.planning/GOLDEN_RULES.md:13` - Para tenant access, ler Agent Access Protocol.
93. R-093 - `.planning/GOLDEN_RULES.md:14` - Antes de ship/release/import/publish/package/runtime-readiness, ler protocolo SEV0.
94. R-094 - `.planning/GOLDEN_RULES.md:20` - Sem import/publish/deploy/commit/delete/modify runtime/prod write sem approval explicita.
95. R-095 - `.planning/GOLDEN_RULES.md:24` - Nao improvisar tenant/remote access; usar master docs/runbooks.
96. R-096 - `.planning/GOLDEN_RULES.md:33` - Antes de access command, postar rota/comando no board e aguardar approval gate requerido.
97. R-097 - `.planning/GOLDEN_RULES.md:41` - Default e NO-SHIP ate evidencia provar o contrario.
98. R-098 - `.planning/GOLDEN_RULES.md:47` - Stop ship se runtime evidence esta missing/stale/not tied to current artifact.
99. R-099 - `.planning/GOLDEN_RULES.md:51` - Stop ship se qualquer non-CI gate esta missing/failed/stale/unverified/not tied to artifact.
100. R-100 - `.planning/GOLDEN_RULES.md:58` - Usar documentacao oficial Microsoft para comportamento Microsoft.
101. R-101 - `.planning/GOLDEN_RULES.md:65` - Se docs oficiais e runtime conflitarem, capturar ambos e manter NO-SHIP ate resolucao/aceite.
102. R-102 - `.planning/GOLDEN_RULES.md:73` - Atualizar status docs imediatamente apos evento de task.
103. R-103 - `.planning/GOLDEN_RULES.md:85` - Se evidencia tenant diverge dos docs, docs estao errados e devem ser corrigidos.
104. R-104 - `.planning/GOLDEN_RULES.md:98` - Evidencia triplet exige screenshot.
105. R-105 - `.planning/GOLDEN_RULES.md:99` - Evidencia triplet exige timestamp BRT.
106. R-106 - `.planning/GOLDEN_RULES.md:100` - Evidencia triplet exige agent name.
107. R-107 - `.planning/GOLDEN_RULES.md:116` - Sem triplet completo, entrada e INCOMPLETE e nao prova DONE/PASS/PUBLISH.
108. R-108 - `.planning/GOLDEN_RULES.md:142` - Flow DONE exige chamada runtime real retornando dados reais.
109. R-109 - `.planning/GOLDEN_RULES.md:149` - Verifier deve incluir checks funcionais, nao so estrutura.
110. R-110 - `.planning/GOLDEN_RULES.md:170` - Antes de ship-ready, reler registry/baseline para decidir com estado mais recente.
