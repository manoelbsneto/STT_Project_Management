# PMO Intelligent Hub — Post-Publish Monitoring Runbook v3.16

Last updated: 2026-05-22 20:20:00 BRT | Gemini sub-1 | Post-Publish Monitoring Runbook Drafted

---

This runbook defines the post-publish monitoring procedures for the **PMO Intelligent Hub Release 3.16** in the `ColOfertasBrasilPro` production environment. This plan covers a 30-day window following the deployment of Milestone 2 (M2) hybrid card-first capabilities.

---

## 1. 24-Hour Sentinel (Post-Deployment Phase)

The first 24 hours post-deployment represent the highest risk window for runtime failures. The primary operator must monitor the following five critical indicators:

### 1.1. Core Indicators and Sentinel Thresholds

| Service | Indicator | Sentinel Threshold | Alerting Mechanism |
|---|---|---|---|
| **Power Automate** | Cloud Flow Success Rate | `< 99.0%` on target card flows | Power Automate Native Run Alerts |
| **Copilot Studio** | Chat Session Errors | `> 2.0%` of user sessions | Dataverse System Session Logs |
| **SharePoint Online** | List Write Failures | `Any single failure` | Flow-level Try-Catch alerts to Teams |
| **Microsoft Teams** | Card Rendering Failures | `Any render error / truncation` | Teams User/Operator direct reports |
| **OpenAI/Safety Gate** | ContentFiltered Occurrences | `Any safety block on card submission` | Flow Audit logs |

### 1.2. Monitoring Mechanics
- **Flow Run History**: Operators must check the Power Automate run history every 2 hours during the first 12 hours. Search specifically for the 5 target workflow IDs (`AtualizarStatus`, `AtualizarTarefa`, `CriarTarefa`, `ListarTarefas`, `ConsultarPortfolio`).
- **Sentinel Logs Inspection**: Check Dataverse session transcripts via the Power Platform Admin Center to confirm zero `ContentFiltered` or `BadGateway` blocks.
- **Learn Reference**: Based on official Microsoft Learn guidelines for Power Automate enterprise flows: [Power Automate Monitoring and Alerting Guidance](https://learn.microsoft.com/en-us/power-automate/guidance/coding-guidelines/monitoring-and-alerting).

---

## 2. Daily Checks (T+1d to T+30d)

To ensure stability during the 30-day post-publish window, the operator will execute a daily checklist at **18:00 BRT** every business day.

### 2.1. Daily Checklist Tasks
1. **Flow Run Inventory**:
   - Extract the success/failure logs for all five `PMO_PA_Card_*` flows.
   - Record run counts, average execution duration, and failure reasons in the daily monitoring journal.
2. **Schema Drift Monitor**:
   - Run the automated `Discover-GhostBotComponents.ps1` and `Verify-LogicalDeleteFields.ps1` scripts in the `deploy/` directory.
   - Confirm zero configuration drift on SharePoint lists or active flow bindings.
3. **Card Render Audit**:
   - Perform a manual transaction (e.g., triggering `AtualizarStatusCard_v316`) on a mobile and desktop Teams client to ensure rendering consistency.
4. **Escalation Thresholds**:
   - If any single flow fails more than **3 times consecutively**, escalate immediately to Tier 2 support.

---

## 3. Weekly Checks

Executed every **Friday at 16:00 BRT** by the designated monitoring agent.

### 3.1. Weekly Checklist Tasks
1. **Partial AQ-09 Smoke Suite**:
   - Run three primary smoke test scenarios:
     - **Scenario A1**: Task list retrieval verification (`ListarTarefasCard_v316`).
     - **Scenario A2**: Executive portfolio aggregation dashboard (`ResumoExecutivoPortfolioCard_v316`).
     - **Scenario A5**: Status report creation and SharePoint record validation (`AtualizarStatusCard_v316`).
2. **Weekly Evidence Archive**:
   - Consolidate all daily runs, drift outputs, and test logs.
   - Save screenshots and JSON results to the designated project evidence registry: `.planning/comms/codex_pm0_remediation_20260522/GEMINI/MONITORING_RUNBOOK/evidence/weekly/`.
3. **Status Report Synchronization**:
   - Update the executive dashboard progress tracker and planner CSV files.

---

## 4. Escalation Paths

In the event of an anomaly or service degradation, follow the structured escalation pathways. All contacts are routed based on UPNs in compliance with the **AGENT_ACCESS_PROTOCOL_P0_20260514.md** guidelines.

### 4.1. Incident Escalation Matrix

| Incident Type | Triggering Condition | Initial Tier (T1) | Escalation Tier (T2) | Target Resolution |
|---|---|---|---|---|
| **Tenant Outage** | Complete M365/Teams/SharePoint unresponsiveness | `m365-admin@stt.com` | Microsoft Support Ticket | 1 Hour |
| **ContentFiltered Storm** | AI safety gates blocking > 5% of inputs | `gemini-sub2@stt.com` | `codex-lead@stt.com` | 2 Hours |
| **SharePoint Throttling** | SharePoint List queries returns HTTP 429 | `sp-admin@stt.com` | `codex-lead@stt.com` | 2 Hours |
| **Planner Quota Exceeded** | Planner Standard connector limits hit | `m365-admin@stt.com` | `codex-lead@stt.com` | 4 Hours |
| **Bot Sync Stalled** | Copilot Studio bot updates fail to publish | `bot-dev@stt.com` | `owner-manoel@stt.com` (Manoel Benicio) | 4 Hours |

---

## 5. Rollback Triggers and Procedure

If production instabilities cannot be remediated within **4 hours** of initial alert, the operator must trigger the emergency Rollback procedure to restore the last known working baseline (Release 3.10).

### 5.1. Rollback Triggers
- **Fatal Stalling**: Flow failures on core card actions exceed **15%** of daily transactions.
- **Data Corruption**: SharePoint list columns show corrupt data, orphaned project relationships, or logical deletion failures that cannot be resolved in-place.
- **Content Gaps**: Critical workflows fail to trigger, blocking PMs from submitting status reports for more than **6 business hours**.

### 5.2. Rollback Procedure (Step-by-Step)

> [!CAUTION]
> A rollback requires a tenant write and MUST have written authorization from **Manoel Benicio** (Owner) in the active thread before execution.

1. **Verify Target Environment**:
   Confirm that the active CLI session is pointed to `ColOfertasBrasilPro`:
   ```powershell
   pac auth list
   pac env who
   ```
2. **Verify Baseline Rollback Package**:
   Check the integrity of the 3.10 package:
   ```powershell
   Get-FileHash 'Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip' -Algorithm SHA256
   ```
   *Expected SHA256*: `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`
3. **Execute Solution Re-import**:
   Import the baseline package, which overwrites the 3.16 components and publishes baseline modifications:
   ```powershell
   pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path 'Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip' --publish-changes
   ```
4. **Post-Rollback Verification**:
   - Re-run the structural route inventory to confirm the legacy M1 flow bindings are restored.
   - Run the 12-scenario standard smoke suite (`AQ-09 Smoke Suite`) to verify normal M1 operational state.
   - Log all outcomes and timestamps in `DOC_UPDATES_LOG.md` and alert the Owner.

---

## 6. T+30 Decommission Checklist

Thirty days after successful deployment (T+30), once the 3.16 hybrid architecture is proven stable in production, the legacy components can be safely decommissioned to eliminate technical debt.

### 6.1. Decommissioning Tasks
1. **Identify Legacy Flows**:
   - Locate old `PMO_PA_*` flows (e.g., text-first triggers for tasks and status reports).
2. **Deactivation**:
   - Turn off legacy flows within the Power Apps Solutions interface to prevent duplicate triggers.
3. **Clean-up check**:
   - Confirm that the new `PMO_PA_Card_*` flows are the sole active endpoints for target topics.
4. **Permanent Deletion**:
   - Delete legacy flows from the solution after a further 7 days of deactivation with no anomalies observed.
