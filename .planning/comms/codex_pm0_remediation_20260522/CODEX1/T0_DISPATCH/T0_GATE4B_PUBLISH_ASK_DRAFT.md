# T0 Gate 4B Publish ASK Draft

Last updated: 2026-05-23 16:33:20 BRT | Codex #1 Lead | Drafted locally after Sub 1B platform auth failure.

## Status

Draft status: SIGNATURE-READY AFTER Gate 4A import succeeds and post-import SHA/read-back evidence matches.

This draft is not an execution record. Codex #2 owns the actual publish after Gate 4A evidence is accepted.

## Gate Summary

| Field | Value |
|---|---|
| Gate | 4B - publish Copilot |
| Authorization status | 4B standing authorization exists per owner ratification 2026-05-23 16:15 BRT |
| Bot | `Assistente PMO V2` |
| Target environment | `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) |
| Required prior gate | Gate 4A import PASS with matching post-import read-back/SHA evidence |
| Expected publish UTC label | `<<TODO_BACKFILL: publish UTC label captured after Gate 4B execution (depends on: Codex #2 Gate 4B publish evidence)>>` |
| Expected PAC list state | `Published / Active / Provisioned` |

## Preconditions

- Gate 4A import completed without non-deterministic retry failure.
- Post-import read-back/SHA comparison matches expected SHA `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`.
- No active Gate 4A blocker remains in `T0_PROGRESS_BOARD.md`.
- Codex #2 has captured pre-publish bot inventory.

## Publish Command

Official Microsoft PAC reference: `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot`

Use the bot ID or schema name resolved by Codex #2 from pre-publish inventory:

```powershell
pac copilot publish `
  --bot "<BOT_ID_OR_SCHEMA_NAME_FOR_Assistente_PMO_V2>" `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

## Post-Publish Validation

```powershell
pac copilot list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

Expected row for `Assistente PMO V2`:

```text
Assistente PMO V2    <bot id>    Published    <managed state>    <solution id>    Active    Provisioned
```

The publish UTC label must be captured from the post-publish evidence and backfilled into this ASK draft.

## Drift Monitor Start Commands

Start T+5min and T+1h drift monitoring immediately after publish UTC is known:

```powershell
$PublishUtc = "<TODO_PUBLISH_UTC_LABEL>"
$OutputDir = ".planning\comms\aq08_topic_routing_verification_20260520\post_publish_verify\drift_monitoring_post_3_16_<UTC>"

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tests\Test-Aq08PublishDriftMonitor.ps1" `
  -PublishUtc $PublishUtc `
  -OutputDir $OutputDir
```

Track E may stage the T+6h command, but Gate 4B minimum asks for T+5min and T+1h starts.

## Mandatory Follow-On

AQ-09 Section A smoke remains mandatory after Gate 4B and before Gate 4C. Gate 4B publish does not create SHIP readiness by itself.

## Evidence Requirements

Every Gate 4B evidence entry must include:

- Agent name.
- Timestamp BRT in `YYYY-MM-DD HH:MM:SS BRT`.
- Screenshot path to a `.png`.
- Publish command transcript with secrets redacted.
- `pac copilot list` output showing `Published / Active / Provisioned`.
- Publish UTC label.
- Drift monitor output path for T+5min and T+1h.

## ASK Text

Approve Gate 4B publish for `Assistente PMO V2` in `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) after Gate 4A import read-back confirms SHA `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`, using `pac copilot publish`, then validate with `pac copilot list` expecting `Published / Active / Provisioned`, capture the publish UTC label, and start drift monitoring for T+5min and T+1h.

## Backfill Manifest

| Placeholder | Upstream evidence | Responsible agent | Trigger |
|---|---|---|---|
| `<<TODO_BACKFILL: publish UTC label captured after Gate 4B execution (depends on: Codex #2 Gate 4B publish evidence)>>` | Codex #2 Gate 4B publish evidence | Codex #2 Lead | Publish command succeeds |
