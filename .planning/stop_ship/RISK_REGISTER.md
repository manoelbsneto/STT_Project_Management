# RISK REGISTER

Status: Active stop-ship risk register
Last Codex programmatic refresh: 2026-05-07 20:25 BRT

| Risk ID | Severity | GAP | Area | Risk | Evidence | Mitigation | Status |
|---|---|---|---|---|---|---|---|
| RISK-001 | SEV-0 | GAP-A1 | CriarTarefa V3 | V3 flow may remain a stub or may not write to `Projetos` until runtime is proven. | Static script PASS; programmatic deploy attempt timed out. | Opus/admin validates V3 in UI/runtime and captures success + duplicate evidence. | Pending runtime |
| RISK-002 | SEV-0 | GAP-A2 | Copilot runtime binding | Static YAML can point to V3 while Copilot runtime still uses stale tool registration. | Local template references V3; browser publish/chat not yet captured. | Opus rebinds/publishes in Copilot Studio and captures T-007 proof. | Pending runtime |
| RISK-003 | P0 | GAP-B1/GAP-B2 | Read topics | New read flows may be locally prepared but not registered in Copilot runtime. | Scripts/tests PASS; runtime flow IDs pending after deploy timeout. | Opus creates/binds read flows and tests live responses. | Pending runtime |
| RISK-004 | P0 | GAP-B3/GAP-B4/GAP-B5 | Write topics | New write flows may be locally prepared but not registered or may fail SharePoint person/choice fields live. | Scripts/tests PASS; runtime flow IDs pending after deploy timeout. | Opus creates/binds write flows and captures SharePoint item evidence. | Pending runtime |
| RISK-005 | P0 | GAP-B6/GAP-B7 | STT and confirmation | Local STT/String confirmation fixes may not be published in the bot runtime. | Local `Test-CopilotStopShipGaps.ps1` PASS; live proof missing. | Opus publishes and tests long text plus `sim/s/yes/confirmo`. | Pending runtime |
| RISK-006 | P1 | GAP-C1 | Dataverse bot components | Ghost bot components may pollute routing or cause edits/tests on wrong bot. | `Discover-GhostBotComponents.ps1` created and tested; PAC execution skipped locally. | Run discovery with authenticated session; delete only after Human/Admin approval. | Pending admin |
| RISK-007 | P1 | GAP-C2/GAP-C3/GAP-C4 | Runtime evidence | Recurrence, planner sync, and red project alert are still not proven in current gate. | No new runtime evidence captured by Codex. | Opus captures scheduled/e2e run evidence. | Open |
| RISK-008 | P1 | GAP-C5 | Operations | Manual may not yet be reviewed by PMO users. | `docs/MANUAL_OPERACIONAL_PMO.md` delivered and test PASS. | Owner/Opus review and incorporate runtime details after browser tests. | Mitigated local |
| RISK-009 | P1 | Cross-cutting | Live bot text violates ASCII-only operational rule. | `Test-PMOFlowStopShipAudit.ps1` still fails on live GPT data non-ASCII/mojibake. | Remove/replace non-ASCII GPT instructions in UI/export and republish. | Open |
