# AQ-07 Acceptance Matrix

| Criteria | Pass/Fail |
| --- | --- |
| all required files exist | PASS |
| manifest JSON parses | PASS |
| each flow has exact action sequence | PASS |
| each flow has exact allowed route key (board.status, pmo.ops, pm.status.updates, task.card.route) | PASS |
| each flow has static ASCII Copilot return | PASS |
| no raw SharePoint/Planner output to Copilot | PASS |
| Planner IDs from AQ-04 used | PASS |
| SharePoint fields from AQ-03 used | PASS |
| live SharePoint Status choices include AQ-07 canonical statuses without removing legacy values | PASS |
| FI-04 Create SharePoint Item includes Title, ProjectID, Status | PASS |
| FI-04 Create SharePoint Item includes all 5 Planner sync fields | PASS |
| no hard-coded unknown bucket IDs | PASS |
| exact create inputs and explicit status mapping used with fallback to Pendente | PASS: `CreateTask_V3` create behavior proven by owner evidence and saved programmatically |
| exact update parameters and status mapping used | PASS FOR SAVE: `UpdateTask_V2` uses Planner `id` plus `body/percentComplete`; SharePoint stores selected Status and mapped PlannerBucketId |
| no client-submitted PlannerTaskId trusted | PASS |
| FI-03 correlation ambiguity documented | PASS |
| tenant writes within owner-approved scope | PASS: SharePoint Status schema update plus six AQ-07 ProcessSimple flow saves; no item writes, Copilot publish, Teams production posts, PAC solution import, `m365`, or Graph direct calls |
| AQ-07 remains blocked until owner approval | PASS: owner approval received; AQ-07 save completed; release still NO-SHIP pending AQ-08/AQ-09/AQ-10 |
