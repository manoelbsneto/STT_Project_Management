# PROD Data Cleanup and Full QA Plan

Date: 2026-05-10
Decision: NO-SHIP until cleanup, fixes, and full QA evidence are complete
Scope: PMO Intelligent Hub production-readiness cleanup and official test plan

## 1. Executive Position

The Teams screenshots show good progress: daily portfolio, weekly portfolio, stale-project reminders, and critical risk escalation are posting to the channel. This is useful evidence that runtime notifications are active.

However, the visible content also proves the environment is polluted with test/trash records:

- `Teste Opus T001 20260506`
- `Teste Clean Flow Direct 20260506`
- `Agente qual offer`
- malformed text such as `AutomaÃ§Ã£o RPA Financeiro`
- repeated reminder messages
- historical test risk `RISK-OPUS-20260506-1138`

Official tests must start from a controlled baseline with real PROD data only. No placeholder, mock, typo, stale test, or unmanaged fixture data is acceptable in official evidence.

## 1.1 Project Owner Data Classification Decision

On 2026-05-10, the Project Owner clarified that the current cleanup candidates are not real PROD records. They are all current test/trash data and must be removed or archived before official QA starts.

Decision record: `.planning/stop_ship/TEST_DATA_CLEANUP_DECISION_20260510.md`

Operational consequence:

| Area | Decision |
|---|---|
| Candidate classification | Treat current candidates as non-real data |
| Cleanup scope | Delete/archive all approved candidates after backup |
| Official QA | Must start only after the clean baseline is validated |
| Historical screenshots | Useful diagnostic evidence, not official QA evidence |

## 2. Non-Negotiable Rules

| Rule | Requirement |
|---|---|
| PROD data only | Official tests must use real projects, real owners, real dates, and real board/risk scenarios. |
| No placeholder data | No `Teste`, `Test`, `Codex`, `Opus`, `Demo`, `Mock`, `Sample`, `Agente qual offer`, or direct-flow trash in official lists. |
| Cleanup before official QA | Dirty historical data must be removed or archived before the official test cycle starts. |
| Approval before deletion | Deletion from SharePoint, Teams, Dataverse, Planner, or Power Automate history requires owner approval and backup/export. |
| Evidence over screenshots alone | Screenshots are useful, but every official pass must include data source proof, run URL, timestamps, and expected/actual result. |
| Reports must be tested by scenario | Daily, weekly, monthly, stale-update, red-project, critical-risk, decision approval/rejection/deferral, and bot-driven write/read topics must be covered. |

## 3. Cleanup Scope

| System | Data to clean | Method | Owner | Destructive? |
|---|---|---|---|---:|
| SharePoint `Projetos` | Test projects, typo projects, direct-flow fixtures, old bot-created test rows | Inventory, approve, delete/archive | Human/Admin + Opus | Yes |
| SharePoint `Tarefas` | Test task fixtures from prior T-002/T-003 runs | Inventory, approve, delete/archive | Human/Admin + Opus | Yes |
| SharePoint `Status Diario` | Test check-in/status rows | Inventory, approve, delete/archive | Human/Admin + Opus | Yes |
| SharePoint `Riscos e Bloqueios` | Test risks/blocks including `RISK-OPUS-*` | Inventory, approve, delete/archive | Human/Admin + Opus | Yes |
| SharePoint `Decisoes do Board` | Test decisions including `DEC-OPUS-*` | Inventory, approve, delete/archive | Human/Admin + Opus | Yes |
| Teams channel posts | Historical bot cards and repeated reminders from test data | Prefer archive/new channel for official QA; delete manually only if policy permits | Opus + Teams owner | Maybe |
| Power Automate run history | Historical runs | Do not delete unless governance requires; mark as pre-QA evidence | Opus | No |
| Dataverse bot components | Ghost `pmo_AssistentePMO.*` rows | Follow ghost cleanup handoff | Human/Admin | Yes |

## 4. Cleanup Workflow

### CLN-01 - Freeze Test Data Creation

1. Pause ad-hoc bot tests.
2. Tell Opus/Codex/Human testers not to create new SharePoint/Teams records outside the cleanup plan.
3. Record freeze timestamp.
4. Any test after freeze must use official QA IDs and be tracked.

Acceptance:

| Check | Expected |
|---|---|
| Freeze timestamp recorded | Yes |
| All testers informed | Yes |
| No ad-hoc test records after freeze | Yes |

### CLN-02 - Inventory Candidate Trash/Test Data

Use the read-only script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File deploy\Discover-SharePointTestDataCandidates.ps1 `
  -SiteUrl "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital" `
  -OutputDir ".planning\cleanup"
```

Candidate patterns:

```text
Teste, Test, Codex, Opus, Demo, Mock, Sample, Fixture, Clean Flow, Direct,
Agente qual offer, RISK-OPUS, DEC-OPUS, PRJ-OPUS, PRJ-TEST, PRJ-CODEX,
Ã, �, â, Â
```

Acceptance:

| Check | Expected |
|---|---|
| Candidate CSV produced | Yes |
| Candidate markdown summary produced | Yes |
| No deletion performed by script | Yes |

### CLN-03 - Business Review of Candidate List

1. PMO owner reviews every candidate.
2. Classify each row:
   - `Delete`
   - `Archive`
   - `Keep as real PROD`
   - `Investigate`
3. No row is removed without classification and approval.

Acceptance:

| Check | Expected |
|---|---|
| Every candidate classified | Yes |
| Approver named | Yes |
| Backup/export created | Yes |

### CLN-04 - Backup Before Deletion

Before deleting or archiving, export affected lists to CSV/Excel.

Required exports:

| List | Required export |
|---|---|
| Projetos | Full list export |
| Tarefas | Full list export if list exists |
| Status Diario | Full list export |
| Riscos e Bloqueios | Full list export |
| Decisoes do Board | Full list export |

Acceptance:

| Check | Expected |
|---|---|
| Backup files exist | Yes |
| Backup location recorded | Yes |
| Backup timestamp before deletion | Yes |

### CLN-05 - Delete or Archive Approved Candidates

Preferred action:

1. Archive rows to a backup file/list where available.
2. Delete only approved test/trash candidates.
3. Record item ID, list, title/key, deleted by, and timestamp.

Teams channel notes:

- If Teams policy allows message deletion, delete obvious test/trash messages manually.
- If deletion is not practical or violates retention policy, create a new clean official QA channel or mark old messages as pre-QA evidence.
- Official evidence must not rely on pre-cleanup Teams messages.

Acceptance:

| Check | Expected |
|---|---|
| Delete log exists | Yes |
| Deleted IDs match approval list | Yes |
| No real PROD rows deleted | Yes |

### CLN-06 - Validate Clean Baseline

Run the discovery script again.

Expected:

| Area | Expected result |
|---|---|
| SharePoint candidate script | 0 unapproved test/trash candidates |
| Portfolio daily/weekly card | Shows real project names only |
| Encoding | No mojibake in project names |
| Teams official QA evidence | Starts after cleanup timestamp |

## 5. PROD Baseline Data Requirements

Before official QA starts, PMO must provide or validate:

| Data type | Minimum required real records |
|---|---:|
| Active green project | 1 |
| Active yellow project | 1 |
| Active red project | 1 |
| Project with update in last 24h | 1 |
| Project without update >24h | 1 |
| Project with future target date | 1 |
| Project with overdue target date | 1 |
| Open non-critical risk | 1 |
| Open critical risk | 1 |
| Open block | 1 |
| Pending board decision | 1 |
| Decision to approve | 1 |
| Decision to reject | 1 |
| Decision to defer/adiar | 1 |
| Project with Planner IDs | 1 |

No official test should fabricate fake business records. If a scenario does not exist naturally, PMO must approve a controlled PROD-like pilot record with a real owner and clear business purpose.

## 6. Official QA Test Matrix

### 6.1 Bot Topics

| ID | Scenario | Type | Evidence required |
|---|---|---|---|
| BOT-01 | CriarTarefa success | Manual + flow run | Chat, flow URL, SharePoint `Projetos` item |
| BOT-02 | CriarTarefa duplicate | Manual + flow run | Duplicate response, proof no second item |
| BOT-03 | CriarTarefa cancel | Manual | Chat proof, no flow run/no row |
| BOT-04 | AtualizarStatus long text | Manual + flow run | STT-style input, parsed fields, result |
| BOT-05 | AtualizarStatus missing fields | Manual | Bot asks only missing fields |
| BOT-06 | ConsultarPortfolio | Manual | Live portfolio response matches SharePoint counts |
| BOT-07 | ConsultarProjeto found | Manual | Response matches project data and open risk count |
| BOT-08 | ConsultarProjeto not found | Manual | Controlled not-found response |
| BOT-09 | RegistrarRisco success | Manual + flow run | Risk item created |
| BOT-10 | RegistrarBloqueio success | Manual + flow run | Block item created |
| BOT-11 | PedirDecisao success | Manual + flow run | Decision item created |
| BOT-12 | Confirm `sim/s/yes/confirmo` | Manual | All confirmation synonyms accepted |
| BOT-13 | Negative confirmation | Manual | No write action occurs |

### 6.2 Adaptive Cards

| ID | Card / Flow | Scenario | Evidence required |
|---|---|---|---|
| CARD-01 | Check-in card | Submit green status | Teams card, run URL, SharePoint status item |
| CARD-02 | Check-in card | Submit yellow status | Teams card, run URL, SharePoint status item |
| CARD-03 | Check-in card | Submit red status | Teams card, run URL, red escalation path |
| CARD-04 | Check-in card | Decimal percent | Percent stores as number, not integer crash |
| CARD-05 | Check-in card | Missing/invalid ProjectID | Controlled not-found response |
| CARD-06 | Critical risk card | Critical risk created | Teams escalation + email/action proof |
| CARD-07 | Critical risk card | Non-critical risk created | No escalation |
| CARD-08 | Board decision card | Approve | SharePoint item `Aprovada`, response metadata |
| CARD-09 | Board decision card | Reject with justification | SharePoint item `Rejeitada`, justification retained |
| CARD-10 | Board decision card | Defer/adiar | SharePoint item reflects deferral outcome |
| CARD-11 | Board decision card | Timeout/no response | Controlled behavior documented |

### 6.3 Reports and Scheduled Flows

| ID | Report / Flow | Frequency | Scenario coverage | Evidence required |
|---|---|---|---|---|
| RPT-01 | Resumo Diario do Portfolio | Daily | Normal portfolio counts | Teams card, run URL, SharePoint count reconciliation |
| RPT-02 | Resumo Diario do Portfolio | Daily | Decisions pending present | Card shows pending decisions |
| RPT-03 | Resumo Diario do Portfolio | Daily | No pending decisions | Card shows none |
| RPT-04 | AlertaSemAtualizacao | Daily | Projects stale >24h | Reminder/card, matching SharePoint rows |
| RPT-05 | AlertaSemAtualizacao | Daily | No stale projects | No noise or controlled empty result |
| RPT-06 | Resumo Semanal do Portfolio | Weekly | Weekly summary | Teams card, run URL, data reconciliation |
| RPT-07 | Resumo Semanal do Portfolio | Weekly | Projects overdue | Overdue section correct |
| RPT-08 | Monthly report | Monthly | Portfolio month snapshot | Teams/card/report proof, if flow exists |
| RPT-09 | Critical risk escalation | Event-driven | Critical risk | Teams escalation + email/action proof |
| RPT-10 | Red project escalation | Event-driven | StatusRAG Vermelho | Teams alert proof |
| RPT-11 | Planner sync | Scheduled/manual | Real Planner IDs | Metrics updated from real data |

### 6.4 SharePoint Data Integrity

| ID | Scenario | Evidence required |
|---|---|---|
| DATA-01 | Required PM person field writes as Claims | Item field proof |
| DATA-02 | Choice fields use valid values | Item proof for RAG, priority, severity |
| DATA-03 | DateTime duplicate uses day range | Flow definition + duplicate runtime proof |
| DATA-04 | ProjectID/RiskID/DecisionID unique | Query proof |
| DATA-05 | No orphan risk/decision without project | Negative flow proof |
| DATA-06 | No mojibake in PROD records | Search/export proof |
| DATA-07 | No test/trash rows after cleanup | Discovery script output |

## 7. Automation Strategy

| Layer | Automated? | Tooling |
|---|---:|---|
| Flow definition static tests | Yes | Existing `tests/Test-*FlowDefinition.ps1` |
| Copilot YAML/topic static tests | Yes | `tests/Test-CopilotStopShipGaps.ps1` |
| SharePoint test data discovery | Yes, read-only | `deploy/Discover-SharePointTestDataCandidates.ps1` |
| SharePoint data reconciliation | Yes, read-only where possible | Future `tests/Test-SharePointProdDataBaseline.ps1` |
| Adaptive Card schema validation | Yes | Future card contract tests |
| Teams rendered proof | Manual/browser | Opus screenshots |
| Approval/rejection/deferral | Manual/browser + flow run | Opus evidence |
| Daily/weekly/monthly scheduled reports | Manual/runtime + reconciliation | Opus + Codex review |

## 8. Official QA Evidence Standard

Every official test row must include:

| Field | Required |
|---|---:|
| Test ID | Yes |
| Scenario | Yes |
| Preconditions | Yes |
| Input data | Yes |
| Expected result | Yes |
| Actual result | Yes |
| Pass/fail | Yes |
| Teams screenshot | If Teams/card scenario |
| Bot chat screenshot | If bot scenario |
| Power Automate run URL | If flow scenario |
| SharePoint item ID/link | If data write/read scenario |
| Timestamp | Yes |
| Owner | Yes |
| Defect/RCA link if failed | If failed |

## 9. Entry Criteria for Official QA

Official QA cannot start until:

| Gate | Status required |
|---|---|
| Pending SEV-0/P0 fixes complete | Green |
| Ghost cleanup complete or formally risk-accepted | Green |
| SharePoint test/trash inventory complete | Green |
| Approved cleanup executed | Green |
| Clean baseline validated | Green |
| PROD baseline data approved by PMO | Green |
| Official QA channel/evidence location selected | Green |

## 10. Exit Criteria for Release

Release cannot move to SHIP until:

| Gate | Required result |
|---|---|
| All bot topic tests pass | 100% |
| All adaptive card scenarios pass | 100% |
| Daily report tested | Pass |
| Weekly report tested | Pass |
| Monthly report tested or formally not in current scope | Pass / waiver |
| Critical risk escalation tested | Pass |
| Red project escalation tested | Pass |
| Decision approve/reject/defer tested | Pass |
| Planner sync tested with real data | Pass |
| No test/trash data remains in official evidence | Pass |
| All defects closed or formally accepted | Pass |

## 11. Immediate Next Actions

| Priority | Action | Owner |
|---|---|---|
| P0 | Finish pending SEV-0/P0 fixes from current stop-ship plan | Opus + Codex |
| P0 | Freeze ad-hoc test data creation | Project Owner |
| P0 | Run SharePoint test/trash discovery script | Codex/Human |
| P0 | Review and approve cleanup candidates | PMO owner + Human/Admin |
| P0 | Delete/archive approved trash data | Human/Admin + Opus |
| P0 | Validate clean baseline | Codex + Opus |
| P0 | Execute official QA matrix with real PROD data | Opus + Codex |
