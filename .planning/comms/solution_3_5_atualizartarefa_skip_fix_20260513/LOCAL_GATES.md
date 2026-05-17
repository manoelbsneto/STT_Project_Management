# PMO v3.5 Local Gates - AtualizarTarefa Skip Semantics Fix

Status: LOCAL PASS / PRODUCTION NO-SHIP until owner import, owner publish, and runtime tests pass.

Package:
- `Solution/PMO_v11_Tarefas_3_5_ATUALIZARTAREFA_SKIP_FIX.zip`
- SHA256: `81AA202FE1BDE006B5824898C505FA34FD1E5B13B1005D102916FE3F702E4FF7`
- Version: `3.5`
- Source baseline: `Solution/PMO_v11_Tarefas_3_4_STOPSHIP_FIX.zip`

Changes:
- `PMO_PA_AtualizarTarefa` preserves existing `HorasRealizadas` when the Copilot input is null or `0`.
- `PMO_PA_AtualizarTarefa` preserves existing `Responsavel`, `DataFim`, and `Prioridade` when the Copilot input is blank or a skip token.
- Supported skip tokens now include blank, `n`, `no`, `nao`, and short tokens that start with `n` and have length <= 3.
- The fix prevents optional-field skip answers from being sent to SharePoint person/date/choice fields.
- `solution.xml` package version updated to `3.5`.

Subagent evidence:
- Hume: mapped the current 3.4 implementation locations and confirmed the safest baseline is `PMO_v11_Tarefas_3_4_STOPSHIP_FIX.zip`.
- Pascal: mapped the test/package gate plan and recommended the dedicated `AtualizarTarefa` skip-semantics regression.

Local gates:
- `tests/Test-AtualizarTarefaSkipSemantics.ps1` - PASS.
- `tests/Test-PMOFlowStopShipAudit.ps1` - PASS.
- `tests/Test-SolutionZipP24Contracts.ps1 -ExpectedVersion 3.5` - PASS.
- `tests/Test-SolutionZipP0Contracts.ps1` - PASS.
- `tests/Test-CriarTarefaCreatesTarefas.ps1` - PASS.
- `tests/Test-PedirDecisaoTopicValidation.ps1` - PASS.
- `tests/Test-CriarProjetoContentSafeOutput.ps1` - PASS.
- `tests/Test-CopilotRoutingInstructions.ps1` - PASS.
- `tests/Test-ExcluirSoftDeleteCapability.ps1` - PASS.
- `tests/Test-CopilotPowerFxRegexSafety.ps1` - PASS.
- `git diff --check` on touched files - PASS with one pre-existing CRLF warning on `tests/Test-PMOFlowStopShipAudit.ps1`.
- ASCII scan on touched markdown/test files - PASS.

Manual owner actions:
1. Owner imports `Solution/PMO_v11_Tarefas_3_5_ATUALIZARTAREFA_SKIP_FIX.zip`.
2. Owner publishes `Assistente PMO V2`.
3. Runtime validation starts from a fresh Copilot Studio test session.

Runtime tests required after owner publish:
1. `CMD-13A`: update an existing task and answer `nao` for optional person/date/priority fields and `0` for hours.
   - Expected: flow succeeds; existing `Responsavel`, `DataFim`, `Prioridade`, and `HorasRealizadas` are preserved.
2. `CMD-13B`: update the same task with explicit valid values.
   - Expected: explicit values are written correctly and project counters still recalculate.
3. `CMD-12-H`: list tasks for `QA Robust 20260513 F`.
   - Expected: soft-deleted task `13` remains hidden.
4. `CMD-09`: test invalid decision approver `UPN ?`.
   - Expected: controlled invalid-UPN message; no flow invocation failure.
5. `CMD-08`: test valid decision approver `mbenicios@minsait.com`.
   - Expected: decision row/card created with no regression.

Known remaining release blockers not fixed in 3.5:
- `AtualizarStatus` free-text/STT multiline still only partially extracts structured fields unless the product owner accepts reduced criteria.
- Adaptive Card recurrence and red-project alert E2E evidence still open.
- Planner sync pilot evidence still open.
