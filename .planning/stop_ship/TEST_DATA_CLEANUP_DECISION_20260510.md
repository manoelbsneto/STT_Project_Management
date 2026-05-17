# Test Data Cleanup Decision

Date: 2026-05-10
Decision source: Project Owner instruction in active session
Decision status: Business classification approved

## Decision

All currently identified cleanup candidates are non-real data. They do not represent real PROD records.

This includes current polluted/test records visible in Teams and SharePoint-derived reports, such as:

- `Teste Opus T001 20260506`
- `Teste Clean Flow Direct 20260506`
- `Agente qual offer`
- `RISK-OPUS-*`
- `DEC-OPUS-*`
- `PRJ-OPUS-*`
- `PRJ-TEST-*`
- `PRJ-CODEX-*`
- records containing `Teste`, `Test`, `Codex`, `Opus`, `Clean Flow`, `Direct`, `Demo`, `Mock`, `Sample`, `Fixture`
- records with mojibake such as `Ã`, `�`, `â`, `Â`

## Operational Meaning

| Area | Decision |
|---|---|
| Business classification | Treat current candidates as trash/test data, not real PROD data |
| Official QA baseline | Must start after these records are removed or archived |
| Official reports | Must be generated from real PROD data only |
| Placeholder/mock data | Not accepted |
| Screenshots from polluted state | Historical evidence only, not official QA evidence |

## Required Control Before Deletion

This decision approves classification, but the deletion process still requires operational controls:

1. Export/backup affected SharePoint lists before deletion.
2. Produce candidate inventory CSV/MD.
3. Delete/archive only rows matching the approved cleanup patterns.
4. Keep delete log with list name, item ID, title/key, timestamp, and executor.
5. Re-run discovery after deletion and prove zero unapproved trash candidates remain.

## Release Impact

Official QA cannot start until cleanup is complete and the clean baseline is validated.

