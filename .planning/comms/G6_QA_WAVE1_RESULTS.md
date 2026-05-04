# G6 QA Wave 1 Results

- Timestamp: 2026-05-04T08:33:14.8044624-03:00
- Environment: ColOfertasBrasilPro (e2d10003-4d8e-e007-9d63-76d5fe89ef56)
- Summary: PASS=9; FAIL=0; CHECK=3; NOT_RUN=2
- JSON evidence: `.planning\comms\g6_qa_wave1_20260504_083244.json`

| ID | Teste | Status | Detalhes | Timestamp |
|----|-------|--------|----------|-----------|
| A1 | Verificar 4 listas SP existem com campos corretos | CHECK | Evidence mode. Prior G1 verification: g1_legacy_pnp_verify_20260502_120214.log | 2026-05-04T08:32:44.3585697-03:00 |
| A2 | Verificar views SP existem | CHECK | Evidence mode. Latest G5 view export: g5_sharepoint_views_20260503_142829.json | 2026-05-04T08:32:44.3662885-03:00 |
| A3 | Criar item teste via PnP em cada lista | NOT_RUN | Requires -RunSharePointPnP interactive SharePoint login. | 2026-05-04T08:32:44.3665936-03:00 |
| A4 | Atualizar StatusRAG via PnP | NOT_RUN | Requires A3 live test item. | 2026-05-04T08:32:44.3668130-03:00 |
| A5 | Verificar indexação de colunas | CHECK | Evidence mode. Prior G1 verification: g1_legacy_pnp_verify_20260502_120214.log | 2026-05-04T08:32:44.3670157-03:00 |
| B1 | Verificar 10 flows existem e estado correto | PASS | [{"Name":"PMO_PA_EnviarCheckInDiario","Expected":"Started","Actual":"Started","FlowId":"e117bbc5-5684-4191-8d03-fb183452ac5f"},{"Name":"PMO_PA_ProcessarRespostaCheckIn","Expected":"Stopped","Actual":"Stopped","FlowId":"6c8ae320-46e0-42da-bc05-5d5a9622be03"},{"Name":"PMO_PA_AlertaProjetoVermelho","Ex... | 2026-05-04T08:32:59.4628100-03:00 |
| B2 | Verificar run-history flows recurrence | PASS | [{"Flow":"PMO_PA_EnviarCheckInDiario","Status":"OK","RunCount":2,"LatestStart":"2026-05-03T12:00:33.6755582Z","Recent":true},{"Flow":"PMO_PA_ResumoDiarioBoard","Status":"OK","RunCount":2,"LatestStart":"2026-05-03T20:00:34.1252032Z","Recent":true},{"Flow":"PMO_PA_ResumoSemanal","Status":"OK","RunCoun... | 2026-05-04T08:33:03.6564455-03:00 |
| B3 | Verificar trigger types | PASS | [{"Name":"PMO_PA_EnviarCheckInDiario","Triggers":"Recurrence"},{"Name":"PMO_PA_ProcessarRespostaCheckIn","Triggers":"Request/TeamsCardTrigger"},{"Name":"PMO_PA_AlertaProjetoVermelho","Triggers":"OpenApiConnection/GetOnUpdatedItems"},{"Name":"PMO_PA_CheckInOnDemand","Triggers":"Request"},{"Name":"PMO... | 2026-05-04T08:33:03.6637688-03:00 |
| B4 | Verificar Standard connectors only | PASS | [{"Flow":"PMO_PA_RegistrarDecisaoBoard","Apis":"shared_sharepointonline,shared_teams","Unexpected":""},{"Flow":"PMO_PA_EscalarRiscoCritico","Apis":"shared_sharepointonline,shared_teams,shared_office365","Unexpected":""},{"Flow":"PMO_PA_CheckInOnDemand","Apis":"shared_sharepointonline,shared_teams","... | 2026-05-04T08:33:03.6832809-03:00 |
| B5 | Validar 6 card JSON schemas | PASS | [{"File":"AlertaCritico.json","SizeKB":1.46,"Valid":true,"Version":"1.4","Under27KB":true},{"File":"CheckInDiario.json","SizeKB":2.34,"Valid":true,"Version":"1.4","Under27KB":true},{"File":"DecisaoBoard.json","SizeKB":2.07,"Valid":true,"Version":"1.4","Under27KB":true},{"File":"EscalacaoRisco.json",... | 2026-05-04T08:33:03.7009237-03:00 |
| C1 | Verificar bot Published/Active/Provisioned | PASS | pac copilot list contains Assistente PMO Published/Active/Provisioned. | 2026-05-04T08:33:08.8919992-03:00 |
| C2 | Verificar segurança Copilot | PASS | Evidence: g4_assistente_pmo_export_complete_final_20260503_1400.yaml | 2026-05-04T08:33:08.8986106-03:00 |
| C3 | Verificar language pt-BR | PASS | Validated from G4 live evidence in GATE_STATUS/exports; PAC bot fetch does not expose language cleanly. | 2026-05-04T08:33:08.8988891-03:00 |
| C4 | Verificar 3 action bindings ativos | PASS | Missing: ; FetchXML: .planning\comms\g6_wave1_fetch_actions_20260504_083244.xml | 2026-05-04T08:33:14.7640255-03:00 |

## Notes

- A3/A4 are only executed when `-RunSharePointPnP` is supplied because they create and delete SharePoint test data through interactive PnP authentication.
- B1/B2/B3/B4 use live ProcessSimple API through cached Microsoft.PowerApps.PowerShell auth.
- C2/C3 rely on G4 export/gate evidence where PAC does not expose the fields cleanly.
