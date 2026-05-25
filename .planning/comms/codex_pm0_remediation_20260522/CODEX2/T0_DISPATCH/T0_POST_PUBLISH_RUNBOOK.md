# T0 Post-Publish Runbook - Gate 4B to AQ-09

Owner: Codex #2 Sub 2C  
Environment: `ColOfertasBrasilPro` / `e2d10003-4d8e-e007-9d63-76d5fe89ef56`  
Solution unique name: `PMO_v11_Tarefas`  
Target bot: `Assistente PMO V2`  
Active package SHA256: `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`

## Publish UTC Label

Backfill after Gate 4B publish:

```text
publish_utc_label = <GATE4B_PUBLISH_UTC_LABEL_TODO>
bot_id_or_schema_name = <ASSISTENTE_PMO_V2_BOT_ID_OR_SCHEMA_NAME_FROM_PAC_LIST>
```

Do not start AQ-09 Section A until the publish UTC label, Copilot verification output, and T+5min drift monitor pass are captured.

## Evidence Triplet Placeholders

Use the same timestamp for each `.txt`, `.json`, and `.png` triplet.

| Step | Text/JSON evidence | Screenshot evidence |
|---|---|---|
| Pre-publish bot list | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/evidence/<UTC>_Codex2Sub2C_gate4b_pre_publish_copilot_list.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/<UTC>_Codex2Sub2C_gate4b_pre_publish_copilot_list.png` |
| Publish command | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/evidence/<UTC>_Codex2Sub2C_gate4b_publish.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/<UTC>_Codex2Sub2C_gate4b_publish.png` |
| Post-publish status/list | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/evidence/<UTC>_Codex2Sub2C_gate4b_post_publish_verify.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/<UTC>_Codex2Sub2C_gate4b_post_publish_verify.png` |
| Drift monitor T+5min | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/evidence/<UTC>_Codex2Sub2C_drift_t5min.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/<UTC>_Codex2Sub2C_drift_t5min.png` |
| AQ-09 handoff | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/evidence/<UTC>_Codex2Sub2C_aq09_handoff.{txt,json}` | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/screenshots/<UTC>_Codex2Sub2C_aq09_handoff.png` |

## 1. Pre-Publish Bot Discovery

Run from repo root after Gate 4A import and SHA read-back have passed.

```powershell
$ErrorActionPreference = "Stop"
$EnvironmentId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
$BotDisplayName = "Assistente PMO V2"
$EvidenceRoot = ".planning\comms\codex_pm0_remediation_20260522\CODEX2\T0_DISPATCH"
$Stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMdd_HHmmss")

pac copilot list --environment $EnvironmentId |
  Tee-Object -FilePath "$EvidenceRoot\evidence\$($Stamp)_Codex2Sub2C_gate4b_pre_publish_copilot_list.txt"
```

From the list output, copy the Copilot ID or schema name for `Assistente PMO V2` into:

```powershell
$BotIdOrSchemaName = "<ASSISTENTE_PMO_V2_BOT_ID_OR_SCHEMA_NAME_FROM_PAC_LIST>"
```

Stop if `Assistente PMO V2` is absent, duplicated, or not in the expected environment.

## 2. Gate 4B Publish

This is the write step. Execute only after the signed Gate 4B authorization is present.

```powershell
$PublishOutputPath = "$EvidenceRoot\evidence\$($Stamp)_Codex2Sub2C_gate4b_publish.txt"

pac copilot publish --environment $EnvironmentId --bot $BotIdOrSchemaName |
  Tee-Object -FilePath $PublishOutputPath
```

Immediately record the publish label:

```powershell
$PublishUtcLabel = "<GATE4B_PUBLISH_UTC_LABEL_FROM_PUBLISH_OUTPUT_OR_OPERATOR_CLOCK>"
$PublishUtcLabel | Set-Content "$EvidenceRoot\evidence\$($Stamp)_Codex2Sub2C_gate4b_publish_utc_label.txt"
```

## 3. Post-Publish Verification

Verify status first, then list the bot inventory again.

```powershell
pac copilot status --environment $EnvironmentId --bot $BotIdOrSchemaName |
  Tee-Object -FilePath "$EvidenceRoot\evidence\$($Stamp)_Codex2Sub2C_gate4b_status_after_publish.txt"

pac copilot list --environment $EnvironmentId |
  Tee-Object -FilePath "$EvidenceRoot\evidence\$($Stamp)_Codex2Sub2C_gate4b_post_publish_verify.txt"
```

Expected result for `Assistente PMO V2`: published/active/provisioned state is visible in the captured PAC output. Halt before AQ-09 if the bot is missing, stale, failed, disabled, or not provisioned.

## 4. Drift Monitor Before AQ-09

Start the drift monitor with the exact Gate 4B publish UTC label. The script waits for T+5min, T+1h, and T+6h windows; AQ-09 Section A may begin only after the T+5min pass is captured.

```powershell
$DriftOutputDir = ".planning\comms\codex_pm0_remediation_20260522\drift_monitoring_post_3_16_$($PublishUtcLabel.Replace(':','').Replace('-','').Replace('Z','').Replace(' ','_'))"

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tests\Test-Aq08PublishDriftMonitor.ps1 `
  -PublishUtc $PublishUtcLabel `
  -OutputDir $DriftOutputDir
```

Expected files:

```text
$DriftOutputDir\T+5min\aq08_post_remediation_reverify_report.json
$DriftOutputDir\T+1h\aq08_post_remediation_reverify_report.json
$DriftOutputDir\T+6h\aq08_post_remediation_reverify_report.json
$DriftOutputDir\DRIFT_DECISION.md
```

Minimum AQ-09 handoff condition:

```powershell
Get-Content "$DriftOutputDir\T+5min\aq08_post_remediation_reverify_report.json"
```

Proceed to AQ-09 Section A only if T+5min reports overall `PASS` and `blockingTopicCount=0`. Continue the same drift monitor process through T+1h and T+6h while AQ-09 evidence is collected.

## 5. AQ-09 Handoff

After the T+5min drift result is PASS, hand off these values to the AQ-09 executor:

```text
publish_utc_label = <GATE4B_PUBLISH_UTC_LABEL_TODO>
bot = Assistente PMO V2
environment = e2d10003-4d8e-e007-9d63-76d5fe89ef56
aq09_stub_folder = .planning/comms/aq09_smoke_runbook_20260520/evidence/post_3_16_TODO_BACKFILL_UTC/
drift_monitor_output = <DRIFT_OUTPUT_DIR_TODO>
```

AQ-09 Section A remains the ship gate. Any missing screenshot, missing PnP read-back, failed side-effect, `ContentFiltered`, or `openAIIndirectAttack` is NO-SHIP until resolved.
