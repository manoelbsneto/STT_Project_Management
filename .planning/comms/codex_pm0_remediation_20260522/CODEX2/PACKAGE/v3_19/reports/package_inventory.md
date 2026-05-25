# PMO_v11_Tarefas 3.19 Runtime Fix Inventory

Package: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/v3_19/package/PMO_v11_Tarefas_3_19_PM0_RUNTIME_FIX.zip
SHA256: 43A33783ABC30E7A3DC74EAED162558FBA0781AC163804F85FDC559023D514BF
Baseline: 3.18 unpacked source
Version: 3.19.0.0

Runtime fixes:
- PM0_PA_Card_AtualizarStatus: item/OrigemEntrada -> item/OrigemEntrada/Value = CopilotStudio.
- PM0_PA_Card_AtualizarStatus: item/Percentual update project -> coalesce(triggerBody()?['percentual'], existing Percentual, 0).
- PM0_PA_Card_AtualizarStatus: item/Percentual create Status Diario -> coalesce(triggerBody()?['percentual'], 0).
- PM0_PA_Card_AtualizarTarefa: item/HorasRealizadas -> coalesce(triggerBody()?['horasRealizadas'], existing HorasRealizadas, 0).
