# Quality Gates

| gateId | gateType | requiredEvidence | currentStatus | blockerIfMissing | ownerApprovalNeeded | relatedOutputFile |
| --- | --- | --- | --- | --- | --- | --- |
| SEV-0 | mandatory | Required document presence | PASS | Yes | Yes | VALIDATION.md |
| Scope/write-scope | mandatory | Files under AQ-07 package and check-in only | PASS | Yes | No | PACKAGE_MANIFEST.json |
| Tenant action scope | mandatory | Owner-approved SharePoint Status schema update plus AQ-07 ProcessSimple flow saves; no item writes/Copilot publish/Teams production post/PAC import/`m365`/Graph direct | PASS | Yes | Yes | execution_evidence/execution_summary.json |
| AQ-03 SharePoint | dependency | AQ-03 output | PASS | Yes | Yes | FIELD_MAPPING.md |
| AQ-04 Planner ID | dependency | AQ-04 output | PASS | Yes | Yes | CONNECTION_REFERENCES.md |
| AQ-06 static | validation | JSON static checks | PASS | Yes | No | VALIDATION.md |
| AQ-07 status schema | dependency | Live `Tarefas.Status` contains canonical AQ-07 statuses and legacy choices | PASS | Yes | Yes | schema_update_20260515/post_write_schema_final/Tarefas/fields/Status.xml |
| AQ-07 build/import | deploy | AQ-07 ProcessSimple request/response evidence | PASS | Yes | Yes | execution_evidence/execution_summary.json |
| AQ-08 Copilot | dependency | Copilot publish ok | PENDING | Yes | Yes | None |
| AQ-09 runtime | test | Runtime smoke | PENDING | Yes | Yes | None |
| AQ-10 release | release | Final decision | NO-SHIP | Yes | Yes | None |

Release decision: NO-SHIP until AQ-07, AQ-08, AQ-09, and AQ-10 have current evidence.
