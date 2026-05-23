# AQ-08 Flow Output Schema Audit

Generated: 2026-05-21 10:40:40 -03:00
Mode: live PAC read-only
Environment: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`

## Result

Overall: **MISMATCH**

| Topic | PM0 flow | Workflow ID | Actual output JSON keys | Expected topic binding key | Live topic binding key | Status |
|---|---|---|---|---|---|---|
| AtualizarStatus | `PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` | `result` | `result` | `message` | MISMATCH |
| AtualizarTarefa | `PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` | `result` | `result` | `result` | PASS |
| ConsultarPortfolio | `PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` | `result` | `result` | `result` | PASS |
| CriarTarefa | `PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` | `result` | `result` | `message` | MISMATCH |
| ListarTarefas | `PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` | `result` | `result` | `result` | PASS |

## Evidence

- Workflow FetchXML: `fetch_pm0_card_workflow_clientdata.xml`
- Topic FetchXML: `fetch_pmo_v2_topic_data.xml`
- Raw workflow fetch: `workflow_clientdata_fetch_raw.txt`
- Raw topic fetch: `topic_data_fetch_raw.txt`
- Machine report: `flow_output_schema_audit.json`

## Interpretation

All five `workflow.clientdata` response schemas expose a single output JSON key: `result`. Any topic binding using `message` for these PM0 action components is stale or incorrect.
