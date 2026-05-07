# RISK REGISTER

| Risk ID | Severity | Area | Risk | Evidence | Mitigation | Status |
|---|---|---|---|---|---|---|
| RISK-001 | SEV-0 | PMO_PA_CriarTarefa | Flow cannot create project because expressions fail before SharePoint write. | Screenshot: Compose_DataAlvo failed on padLeft; later Get_Duplicate_Projects failed on date filter. | Replace unsupported function and repair SharePoint date OData filter. | OPEN |
| RISK-002 | SEV-0 | Release | Bot testing cannot prove flow execution while flows fail independently. | Manual Power Automate run fails before bot call can succeed. | Validate flows directly before Copilot tests. | OPEN |
| RISK-003 | HIGH | PMO_PA_AtualizarTarefa | Uses first(Get_Projeto_Item) without empty-result guard; project lookup can fail after task update. | .planning/canonical/PMO_v11_Tarefas_VERIFY_FLOW_FIX_20260506_072447/Workflows/PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json lines 276-282. | Add explicit condition before Update_Projeto_Counters. | OPEN |
| RISK-004 | HIGH | PMO_PA_CheckInOnDemand | Project lookup can return zero rows but adaptive card uses first(Get_Projeto) in message composition. | PMO_PA_CheckInOnDemand JSON line 94. | Add zero-row response before Teams card. | OPEN |
| RISK-005 | HIGH | Teams-triggered flows | Teams adaptive cards and channel IDs are hardcoded; failures depend on channel access and connector permissions. | PMO_PA_CheckInOnDemand, PMO_PA_RegistrarDecisaoBoard, PMO_PA_EscalarRiscoCritico use Teams actions. | Manual connector/channel verification required. | OPEN |
| RISK-006 | MEDIUM | PMO_PA_CriarTarefa | Priority mapping collapses Critica to Alta. | Map_Prioridade expression maps b->Baixa, m->Media, else Alta. | Confirm SharePoint choice values; add Critica mapping if supported. | OPEN |

