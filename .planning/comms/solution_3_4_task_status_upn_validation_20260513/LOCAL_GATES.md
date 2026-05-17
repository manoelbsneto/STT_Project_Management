# PMO v3.4 Local Gates - Task Status And UPN Validation Fix

Status: LOCAL PASS / PRODUCTION NO-SHIP until owner import, owner publish, and runtime tests pass.

Package:
- `Solution/PMO_v11_Tarefas_3_4_TASK_STATUS_UPN_VALIDATION_FIX.zip`
- SHA256: `98566792D80397276256B10BF9FB6D3C227E46EAE140263F3BE6544CA5909A1F`
- Version: `3.4`

Changes:
- `PMO_PA_CriarTarefa` now writes `Tarefas.Status/Value = Pendente`.
- `PedirDecisao` validates `Topic.Aprovador` as an email/UPN before invoking Power Automate.
- Invalid approver input now returns a controlled user message instead of reaching the flow and surfacing `FlowActionInternalServerError`.

Evidence source:
- Live SharePoint XML: `.planning/comms/sharepoint_schema_xml_20260513/Tarefas/fields/Status.xml`
- Flow inventory: `.planning/comms/adaptive_cards_flow_inventory_20260513/flow_inventory.json`

Local gates:
- `tests/Test-CriarTarefaCreatesTarefas.ps1` - PASS.
- `tests/Test-PedirDecisaoTopicValidation.ps1` - PASS.
- `tests/Test-SolutionZipP24Contracts.ps1 -ExpectedVersion 3.4` - PASS.
- `tests/Test-SolutionZipP0Contracts.ps1` - PASS.
- `tests/Test-PMOFlowStopShipAudit.ps1` - PASS.
- `tests/Test-CriarProjetoContentSafeOutput.ps1` - PASS.
- `tests/Test-CopilotRoutingInstructions.ps1` - PASS.
- `tests/Test-CriarProjetoFlowDefinition.ps1` - PASS.
- `tests/Test-ExcluirSoftDeleteCapability.ps1` - PASS.

Direct ZIP scan:
- `HasAberta = False`
- `HasPendente = True`
- `HasUpnValidation = True`

Manual owner actions:
1. Owner imports `Solution/PMO_v11_Tarefas_3_4_TASK_STATUS_UPN_VALIDATION_FIX.zip`.
2. Owner publishes `Assistente PMO V2`.
3. Runtime validation starts from a fresh Copilot Studio test session.

Runtime tests required after owner publish:
1. `criar tarefa: projeto=QA Robust 20260513 F, tarefa=Validar status choice 3.4, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Alta`
   - Expected: task created in `Tarefas`; SharePoint `Status=Pendente`; no project created.
2. `solicitar decisao` with approver `UPN ?`
   - Expected: controlled invalid-UPN message; no `FlowActionInternalServerError`; no new decision row.
3. `solicitar decisao` with approver `mbenicios@minsait.com`
   - Expected: decision row created and Teams decision card posted.

Known remaining release blockers not fixed in 3.4:
- `AtualizarStatus` free-text/STT multiline still only partially extracts structured fields.
- Adaptive Card recurrence and red-project alert E2E evidence still open.
- Planner sync pilot evidence still open.
