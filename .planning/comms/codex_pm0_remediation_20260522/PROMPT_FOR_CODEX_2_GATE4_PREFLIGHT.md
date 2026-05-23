# PROMPT — Codex #2 Bravo — Gate 4 Preflight (Read-Only) — Build & Execute

| Field | Value |
|---|---|
| Issued | 2026-05-22 18:55 BRT |
| Issuer | Project Owner (via Kiro consolidation session) |
| Recipient | Codex #2 Bravo |
| Phase | Gate 4 Preflight (read-only). NO tenant write authorized. |
| Predecessor doc | `.planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md` |
| Owner adjudication | 2026-05-22 18:50 BRT — see "Locked Decisions" below |

---

## 1. Your Role In This Phase

You are the centralized executor for the Gate 4 phase. Owner has decided that all preflight script authoring, execution, and tenant-touching commands flow through Codex #2 only. Codex #1 and Kiro do not run tenant commands in this phase.

You will:
1. Read the mandatory references (Section 2) before any command.
2. Author your own PowerShell script(s) following the proven patterns in `TENANT_COMMAND_RUNBOOK.md`.
3. Execute the read-only preflight (Section 7) against environment `e2d10003-4d8e-e007-9d63-76d5fe89ef56` only.
4. Generate Evidence Triplets per Golden Rules.
5. Draft the Gate 4A ASK (Section 9).
6. Update trail documents (Section 10).
7. Halt before any tenant write. Hand back to owner.

---

## 2. Mandatory References (read in this order before any command)

1. `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`
2. `.planning/TENANT_COMMAND_RUNBOOK.md`
3. `.planning/GOLDEN_RULES.md`
4. `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`
5. `.planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md` (entire document — all 3 agent columns)
6. `.planning/power-platform-tooling-guide.md`
7. `.planning/CURRENT_BASELINE.md` (for current 3.16 baseline state)
8. `docs/MANUAL_OPERACIONAL_PMO.md` (PMO operational behavior — required by access protocol §2 when PMO flows/cards/SP lists/Teams cards/release evidence are involved)
9. `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` (active check-in board — required for the access check-in entry per access protocol §7)

If any reference contradicts this prompt, the project master docs win. State the contradiction in your output and stop. Note: a prior halt at `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/PREFLIGHT_HALT_20260522_220116.md` flagged a SHA contradiction between this prompt and the master baseline — Section 6.5 (Pre-Step A) below resolves it deterministically before any tenant command is allowed.

---

## 3. Locked Decisions (owner-ratified — do not re-litigate)

| # | Decision | Source |
|---|---|---|
| Q1 | Package consistency closed locally; corrected SHA256 = `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` | Codex #2 own evidence at `CODEX2/PACKAGE/evidence/20260522_180600_Codex2_package_consistency_strict.{md,png}` |
| Q2 | AQ07 cleanup = staged Option (d). Cleanup verb = `pac solution delete` (full retirement) — NOT `pac solution remove-solution-component` (does not exist). | Owner ratified; runbook §2; consolidated doc §3.1/§3.2/§3.3 |
| Q3 | Preflight uses runbook-proven verbs only. `pac env fetch` and `pac copilot list` are NOT in the runbook proven set at PAC 2.6.4 — replace with Web API direct via `InvokeApi` and with `Get-Flow`. | Owner ratified |
| Q4 | **3 gates** (Codex #1's split): 4A import → 4B publish → 4C AQ07 cleanup. Runtime smoke is captured but folded into post-publish QA, NOT a separate owner approval. Functional DoD Rule still applies. | Owner ratified 2026-05-22 18:50 BRT |
| Q5 | Next 60–90 min = read-only preflight + Gate 4A ASK draft. No tenant write in this turn. | Owner ratified |
| Channel | Channel A — interactive PAC CLI on the dev box. NOT GitHub Actions. NOT service principal. | Owner ratified |
| Auth | Device code only: `pac auth create --name COLQA0424 --deviceCode --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56`. SP / ClientId / certificate auth FORBIDDEN by runbook §"Regras Que Não Podem Ser Quebradas". | Runbook |
| Execution | Centralized on Codex #2. | Owner ratified |

---

## 4. Pinned Tenant Values (do not improvise)

```
Tenant ID            7808e005-1489-4374-954b-d3b08f193920
Environment          ColOfertasBrasilPro
Environment ID       e2d10003-4d8e-e007-9d63-76d5fe89ef56
Environment URL      https://colofertasbrasilpro.crm4.dynamics.com/
Organization ID      e0b9c35e-79a2-ef11-8a66-000d3a24857a
Org unique name      unqe0b9c35e79a2ef118a66000d3a248
PAC CLI version      2.6.4+ga488322
PowerApps PS module  Microsoft.PowerApps.PowerShell 1.0.45 (absolute path per runbook §3)
PowerApps Admin PS   Microsoft.PowerApps.Administration.PowerShell 2.0.217 (absolute path per runbook §3)
Shell                Windows PowerShell 5.1 ONLY for PowerApps PS / SharePoint PnP. PAC CLI may run in either shell.
Connection IDs       SharePoint=44f187cde7f54f208cf22bac4e533816 · Teams=shared-teams-1440d346-f1dd-44ea-912f-3787038ac333 · O365=306d783533364cb6948ab2830fc3b188
Five PM0 flow GUIDs  1721e0a3-…  7c6300c2-…  7f662db7-…  e0e3c6b0-…  8333bd91-…
                     (resolve full GUIDs from CODEX2/PACKAGE/diffs/diff_*_local_vs_packaged.md)
```

---

## 5. Critical PAC 2.6.4 Constraints (runbook §10 — do not improvise)

| Verb / Path | Status | Source |
|---|---|---|
| `pac auth create --deviceCode` | ALLOWED — proven | runbook §2 |
| `pac env who` / `pac env select` / `pac env list` | ALLOWED — proven | runbook §2 |
| `pac solution list` / `export` / `unpack` / `pack` / `import` / `delete` | ALLOWED — proven | runbook §2 |
| `pac connection list` | ALLOWED — proven | runbook §2 |
| `Get-Flow -EnvironmentName` (PowerApps PS 1.0.45 absolute import) | ALLOWED — proven runtime read path | runbook §3, §4 |
| `InvokeApi` for ProcessSimple endpoints (`https://{flowEndpoint}/providers/Microsoft.ProcessSimple/...`) | ALLOWED — proven | runbook §6, §7, §8 |
| `InvokeApi` for Dataverse Web API (`https://<org>.crm4.dynamics.com/api/data/v9.2/...`) | **FORBIDDEN** — fails `AADSTS65002` (consent / pre-authorization gap). Replaced by Section 6.7 token-based wrapper `Invoke-DataverseGet`. | Owner-ratified Option B 2026-05-22 23:18 BRT |
| `pac flow ...` | **FORBIDDEN — does not exist at PAC 2.6.4** | runbook §10 |
| `pac env fetch` | UNVERIFIED at 2.6.4 — replace with Web API direct via `InvokeApi` | runbook silent |
| `pac copilot list` / `pac copilot publish` | UNVERIFIED at 2.6.4 — replace with Web API direct on `bot` entity | runbook silent |
| `pac solution remove-solution-component` | **DOES NOT EXIST in PAC CLI** — use `pac solution delete` or Web API `RemoveSolutionComponent` | runbook §2 + MS Learn |
| `Test-PowerAppsAccount` | **FORBIDDEN — can hang** | runbook §3, §10 |
| `Add-PowerAppsAccount -Username -Password` | **FORBIDDEN — fails on MFA** | runbook §10 |
| `Connect-PnPOnline -Interactive` | **FORBIDDEN** for SharePoint | runbook §10 |
| `pwsh` / `PnP.PowerShell` modern for SP provisioning | **FORBIDDEN** | runbook §10 |
| `m365` CLI | **FORBIDDEN** | runbook §10 |
| Service Principal / ClientId / Certificate auth / Graph direct / HTTP Premium | **FORBIDDEN** for this tenant | access protocol §3 + runbook |

---

## 6. Authoring Rules For Your PowerShell Script(s)

You will author your own scripts. Required properties:

1. **Idempotency**: each step writes to a timestamped path under `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/`. Re-runs do not overwrite prior runs; new timestamped files are created.
2. **Halt on first error**: `$ErrorActionPreference = 'Stop'`. If any step fails, write the failure into the evidence triplet for that step and stop. Do NOT auto-retry tenant calls.
3. **No tenant writes**: every command in the script must be a read or local operation. If you find yourself reaching for `pac solution import`, `pac solution publish`, `pac solution delete`, `pac copilot publish`, or any `InvokeApi -Method PATCH/POST/DELETE` — STOP. Those belong to Gates 4A/4B/4C, not preflight.
4. **Auth verification first**: the script must run `pac auth list` and `pac env who` before any other command. If env != `e2d10003-…ef56`, run `pac env select` per runbook §2. If no auth profile, halt and prompt the operator to run `pac auth create --name COLQA0424 --deviceCode --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56` interactively.
5. **Shell discipline**: PAC CLI in either shell; PowerApps PS module ONLY in Windows PowerShell 5.1 with absolute `Import-Module` per runbook §3.
6. **No improvisation**: every command in the script must trace back to a runbook section. Add a comment per step citing the runbook section number.
7. **Transcript**: wrap the script body in `Start-Transcript`/`Stop-Transcript` writing to `CODEX2/PREFLIGHT/_transcript_<UTC-stamp>.log`.
8. **Output format**: every read produces `.json` (raw), `.txt` (pretty-printed), and `.md` stub for Evidence Triplet. Screenshots are captured manually (you describe what to capture; the operator captures the .png).
9. **PSScriptAnalyzer clean**: no warnings under default ruleset.
10. **No PII or secrets in logs**: scrub any access tokens or device-code URLs from saved transcripts before committing evidence files.
11. **Access check-in entry**: per access protocol §7, write a check-in entry in `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` BEFORE running step 0. Entry must state: master doc read (TENANT_COMMAND_RUNBOOK.md), exact command plan (the steps in Section 7), read-only flag, owner approval reference (this prompt), expected output folder (`CODEX2/PREFLIGHT/`).
12. **Pre-Step A first**: complete the SHA reconciliation in Section 6.5 BEFORE writing the check-in entry or running step 0. Otherwise the check-in will reference a contradicted baseline.

Suggested split (you decide the final layout):

- `scripts/Run-Gate4-Preflight.ps1` — orchestrator covering steps 0–4 and 7–8 (PAC + local).
- `scripts/Invoke-DataversePreflightReads.ps1` — Web API direct GETs (steps 5, 6, 9) using `InvokeApi`.
- `scripts/Get-PMO0FlowInventory.ps1` — `Get-Flow` filtered by `PMO_PA_*` and the 5 PM0 GUIDs.

If you prefer one master script, that is acceptable. Document your choice at the top.

---

## 6.5 Pre-Step A — Master Doc SHA Reconciliation (run BEFORE step 0)

The prior halt (`PREFLIGHT_HALT_20260522_220116.md`) is correct: the master baseline still records the failed SHA `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`, while this prompt locks `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`. Owner ratifies the new SHA as current. Reconcile the docs deterministically per the table below — no other files. Then write a single Evidence Triplet for the reconciliation pass.

### 6.5.0 Idempotency check — detect current state BEFORE applying any edit

Pre-Step A may run multiple times across sessions. A previous run may have already applied some or all of U1-U6 + A1 (e.g., the partial application before `PREFLIGHT_HALT_20260522_234427.md`). To avoid a "literal Old string not found" halt loop, you MUST first classify each entry by inspecting the current file state, and apply only entries marked `PENDING`.

For each `Ui` (i = 1..6):
- Read the target file from §6.5.1.
- If the file contains the literal `New` string from §6.5.1 → mark `Ui` as `ALREADY_APPLIED`. Do NOT run strReplace.
- Else if the file contains the literal `Old` string from §6.5.1 → mark `Ui` as `PENDING`. Run strReplace per §6.5.1.
- Else → mark `Ui` as `DRIFTED` and halt per §6.5.5.

For `A1`, read `.planning/AGENT_CHECKIN_REGISTRY.md`:
- If `Select-String -SimpleMatch -Pattern 'PM0-REMED-PACKAGE-CORRECTED'` returns exactly 1 hit → mark `A1` as `ALREADY_APPLIED`.
- Else if the §6.5.2 `Old` junction exists verbatim in the file → mark `A1` as `PENDING`. Apply strReplace per §6.5.2.
- Else → mark `A1` as `DRIFTED` and halt per §6.5.5.

Record the dispatch table verbatim in `00a_sha_reconciliation_<UTC>.md`:

| Entry | Target file | State | Action this run |
|---|---|---|---|
| U1 | `.planning/CURRENT_BASELINE.md` | ALREADY_APPLIED \| PENDING \| DRIFTED | Skip \| Apply \| Halt |
| U2 | `.planning/STATE.md` | … | … |
| U3 | `.planning/START_HERE_CURRENT_STATUS.md` | … | … |
| U4 | `.planning/stop_ship/MASTER_CHECKLIST.md` | … | … |
| U5 | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_EN.md` | … | … |
| U6 | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_PT_BR.md` | … | … |
| A1 | `.planning/AGENT_CHECKIN_REGISTRY.md` | … | … |

If ALL 7 entries are `ALREADY_APPLIED`, the apply phase is a no-op for this run; proceed directly to verification (§6.5.4). V1+V2+V4 must still PASS; V3's `$expectedDelta` is empty and `$delta` scoped to the 7 target paths must also be empty.

### 6.5.1 UPDATE these 6 files — apply each Old→New pair exactly via string-replace (only for entries marked PENDING in §6.5.0)

For every entry below: the Old string is unique within its file and matches verbatim. Apply via `strReplace` (or equivalent) — do NOT improvise or add anything beyond what New specifies. After all 6 are applied, run the V1–V4 verification suite in §6.5.4. **Note: U1-U4 New strings intentionally retain the old SHA `4280EC92…EDD15` inside a "supersedes …" supersession clause — that is the audit trail and is correct. Do NOT treat its presence as a failure.**

---

**U1 — `.planning/CURRENT_BASELINE.md` (line 26)**

Old:
```
- Local package SHA256: `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`
```

New:
```
- Local package SHA256: `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` (corrected 2026-05-22 18:06 BRT by Codex #2 Bravo; supersedes failed candidate `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`; evidence: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/evidence/20260522_180600_Codex2_package_consistency_strict.md`)
```

---

**U2 — `.planning/STATE.md` (line 13)**

Old:
```
gates with SHA256 `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`. AQ-08
```

New:
```
gates with SHA256 `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` (corrected 2026-05-22 18:06 BRT by Codex #2 Bravo; supersedes `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`). AQ-08
```

---

**U3 — `.planning/START_HERE_CURRENT_STATUS.md` (line 75)**

Old:
```
Rebuilt scoped 3.16 ZIP SHA256 `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`; source guards
```

New:
```
Rebuilt scoped 3.16 ZIP SHA256 `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` (corrected 2026-05-22 18:06 BRT by Codex #2 Bravo; supersedes `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`); source guards
```

---

**U4 — `.planning/stop_ship/MASTER_CHECKLIST.md` (line 28)**

Old:
```
; ZIP SHA256 `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15` |
```

New:
```
; ZIP SHA256 `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` (corrected 2026-05-22 18:06 BRT by Codex #2 Bravo; supersedes `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`) |
```

---

**U5 — `.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_EN.md` (line 71)**

Old:
```
   # Verified SHA256 Checksum: 4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15
```

New:
```
   # Verified SHA256 Checksum: 3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB
```

Release notes contain only the shipped checksum value — no inline reconciliation note here. Reconciliation lives in the planning docs only (U1-U4).

NOTE — separate doc-debt: the same code block contains `--publish-changes`, which conflicts with the owner-locked 3-gate split (Gate 4A is import-only; publish is Gate 4B). DO NOT FIX THIS in Pre-Step A. Flag it as outstanding doc-debt in your output manifest. Owner will adjudicate separately.

---

**U6 — `.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_PT_BR.md` (line 71)**

Old:
```
   # Verified SHA256 Checksum: 4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15
```

New:
```
   # Verified SHA256 Checksum: 3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB
```

Same `--publish-changes` doc-debt note as U5 applies. Flag, do not fix.

### 6.5.2 APPEND in 1 file — register a NEW check-in row, leave existing rows untouched

**A1 — `.planning/AGENT_CHECKIN_REGISTRY.md`**

Insert one new row chronologically between the existing `2026-05-22T17:13:10-03:00 Codex` row and the `2026-05-22T20:05:00-03:00 Gemini Lead` row. Apply via a single `strReplace` of the 2-line junction. Do NOT modify the surrounding rows; the patch only adds one new line in between.

Old:
```
No tenant command or write performed. |
| 2026-05-22T20:05:00-03:00 | Gemini Lead | CLAIMED | GEM-WS1-6
```

New:
```
No tenant command or write performed. |
| 2026-05-22T18:06:00-03:00 | Codex #2 Bravo | OBSERVED | PM0-REMED-PACKAGE-CORRECTED | Patched scoped 3.16 ZIP after PM0 workflowset and authentication-literal fixes. SHA256 `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`. Supersedes `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15`. Strict consistency: 5 PM0 workflowset mappings, 5 PM0 sets, 0 duplicates, 0 placeholder hits, 0 unexplained leaf diffs. Evidence: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/evidence/20260522_180600_Codex2_package_consistency_strict.md`. No tenant command performed. |
| 2026-05-22T20:05:00-03:00 | Gemini Lead | CLAIMED | GEM-WS1-6
```

### 6.5.3 LEAVE these 7 files untouched (forensic / immutable record)

Do NOT modify any of the following — they are historical record. Any edit corrupts the audit trail.

| # | File | Why immutable |
|---|---|---|
| L1 | `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` (lines 36, 58) | Historical log entries: line 36 records the moment the failed SHA was generated; line 58 is your own halt log. Both must remain as-written. |
| L2 | `.planning/comms/codex_pm0_remediation_20260522/MESSAGE_TO_CODEX_1_UPDATED_OPINION_20260522.md` | Historical agent-to-agent message. Immutable. |
| L3 | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173428_Codex1_package_consistency_strict.md` | Codex #1 evidence file. Evidence files are immutable per Golden Rules. |
| L4 | `.planning/comms/codex_pm0_remediation_20260522/EXPORT_RECONCILIATION_20260522_1712.md` | Historical reconciliation snapshot. Immutable. |
| L5 | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/PREFLIGHT_HALT_20260522_220116.md` | Your own halt record. Immutable. |
| L6 | `.planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md` (line 52) | Intentional record of Codex #1's findings table at 17:36 BRT. The corrected SHA is documented separately in §2.3 of the same file. Do not edit line 52. |
| L7 | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/PACKAGE_STATUS.md` (line 40) | Intentional retrospective: the line literally says "Do not use that SHA for Gate 4." This is correct and must remain. |

### 6.5.4 Reconciliation Verification (V1-V4 — must all PASS to declare Pre-Step A green)

The worktree may already contain unrelated dirty files when you start. That is allowed; the verification below scopes to Pre-Step A's own delta only.

**Step 0 — capture baseline BEFORE applying U1-U6 + A1:**

```powershell
$utc    = (Get-Date).ToUniversalTime().ToString("yyyyMMdd_HHmmss")
$pfDir  = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT"
New-Item -ItemType Directory -Force -Path $pfDir | Out-Null

# V3 baseline — full status snapshot of the worktree as it stands NOW (pre-edit)
git status --porcelain | Set-Content -Encoding utf8 "$pfDir/_pre_step_a_status_$utc.txt"

# V4 baseline — content hash of every L1-L7 LEAVE file
$leaveFiles = @(
  ".planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md",
  ".planning/comms/codex_pm0_remediation_20260522/MESSAGE_TO_CODEX_1_UPDATED_OPINION_20260522.md",
  ".planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173428_Codex1_package_consistency_strict.md",
  ".planning/comms/codex_pm0_remediation_20260522/EXPORT_RECONCILIATION_20260522_1712.md",
  ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/PREFLIGHT_HALT_20260522_220116.md",
  ".planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md",
  ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/PACKAGE_STATUS.md"
)
$leaveFiles | ForEach-Object { Get-FileHash -Algorithm SHA256 $_ } |
  Select-Object Path, Hash | Format-Table -AutoSize |
  Out-String | Set-Content -Encoding utf8 "$pfDir/_leave_files_pre_$utc.txt"
```

**Step 1 — apply the 7 edits (U1-U6 + A1) per Sections 6.5.1 and 6.5.2.**

**Step 2 — run V1, V2, V3, V4 AFTER all 7 edits:**

**V1 — New SHA present in every UPDATE file (positive check):**

```powershell
$updateFiles = @(
  ".planning/CURRENT_BASELINE.md",
  ".planning/STATE.md",
  ".planning/START_HERE_CURRENT_STATUS.md",
  ".planning/stop_ship/MASTER_CHECKLIST.md",
  ".planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_EN.md",
  ".planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_PT_BR.md"
)
$newSha = "3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB"
$v1Pass = $true
foreach ($f in $updateFiles) {
  if (-not (Select-String -Path $f -SimpleMatch -Pattern $newSha -Quiet)) {
    Write-Host "V1 FAIL: new SHA missing in $f"
    $v1Pass = $false
  }
}
```

V1 passes when every UPDATE file contains the new SHA at least once. The presence of the old SHA in UPDATE files is expected (supersession audit trail) and is NOT a failure.

**V2 — New check-in row present exactly once:**

```powershell
$v2Hits = (Select-String -Path ".planning/AGENT_CHECKIN_REGISTRY.md" `
                         -SimpleMatch -Pattern "PM0-REMED-PACKAGE-CORRECTED").Count
if ($v2Hits -ne 1) { Write-Host "V2 FAIL: expected exactly 1 hit, got $v2Hits" }
```

**V3 — Delta diff scope (only the PENDING target paths from §6.5.0 are NEW changes from Pre-Step A):**

```powershell
git status --porcelain | Set-Content -Encoding utf8 "$pfDir/_post_step_a_status_$utc.txt"

$pre  = Get-Content "$pfDir/_pre_step_a_status_$utc.txt"  -ErrorAction SilentlyContinue
$post = Get-Content "$pfDir/_post_step_a_status_$utc.txt"
$delta = Compare-Object -ReferenceObject $pre -DifferenceObject $post |
         Where-Object SideIndicator -EQ "=>" |
         Select-Object -ExpandProperty InputObject

# Build $expectedDelta from the §6.5.0 dispatch table — include ONLY paths whose entry is PENDING this run.
# Mapping:
#   U1 → .planning/CURRENT_BASELINE.md
#   U2 → .planning/STATE.md
#   U3 → .planning/START_HERE_CURRENT_STATUS.md
#   U4 → .planning/stop_ship/MASTER_CHECKLIST.md
#   U5 → .planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_EN.md
#   U6 → .planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_PT_BR.md
#   A1 → .planning/AGENT_CHECKIN_REGISTRY.md
# If all 7 entries are ALREADY_APPLIED, $expectedDelta = @() (empty).
$expectedDelta = @( <populate from §6.5.0 PENDING entries only> )

# Full 7-target list (for the "no rogue files touched" check):
$allTargets = @(
  ".planning/CURRENT_BASELINE.md",
  ".planning/STATE.md",
  ".planning/START_HERE_CURRENT_STATUS.md",
  ".planning/stop_ship/MASTER_CHECKLIST.md",
  ".planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_EN.md",
  ".planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_PT_BR.md",
  ".planning/AGENT_CHECKIN_REGISTRY.md"
)
```

V3 passes when:
1. Every path in `$expectedDelta` is present in `$delta` (each PENDING target was actually modified by this run); AND
2. No path in `$delta` falls outside `$allTargets` (Pre-Step A did not touch anything else).

If all 7 entries were `ALREADY_APPLIED`, `$expectedDelta` is empty AND `$delta` (filtered to `$allTargets`) must also be empty — V3 trivially PASSes.

Files that were already dirty BEFORE Pre-Step A started (present in `$pre`) are out of scope for V3 and not failures.

**V4 — LEAVE files preserve the historical OLD SHA anchor (positive forensic check):**

```powershell
$oldSha = "4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15"
$v4Pass = $true
foreach ($f in $leaveFiles) {
  if (-not (Select-String -Path $f -SimpleMatch -Pattern $oldSha -Quiet)) {
    Write-Host "V4 FAIL: forensic anchor (OLD SHA) missing in $f"
    $v4Pass = $false
  }
}

# Optional supplementary diagnostic — not the V4 gate:
$leaveFiles | ForEach-Object { Get-FileHash -Algorithm SHA256 $_ } |
  Select-Object Path, Hash | Format-Table -AutoSize |
  Out-String | Set-Content -Encoding utf8 "$pfDir/_leave_files_post_$utc.txt"
```

V4 passes when every L1-L7 LEAVE file still contains at least one occurrence of the OLD SHA `4280EC92…EDD15`. This proves the forensic record is intact and the supersession audit trail is preserved.

If the OLD SHA is missing from any LEAVE file → halt (forensic anchor lost; historical audit trail corrupted).

The pre/post hash snapshots (`_leave_files_pre_<UTC>.txt`, `_leave_files_post_<UTC>.txt`) are diagnostic supplements only, NOT the V4 gate. Pre-Step A may run idempotently across sessions where prior runs already updated some LEAVE files for legitimate reasons (e.g., halt-log appends to `INVESTIGATION_LOG.md` line 58, or new `PREFLIGHT_HALT_*.md` files); a byte-identical pre/post hash is therefore not required.

**Step 3 — write the reconciliation evidence triplet only if V1+V2+V3+V4 all PASS:**

- `00a_sha_reconciliation_<UTC>.md` — list each of the 7 edited file paths, the V1/V2/V3/V4 results (PASS per check), and the four supporting files: `_pre_step_a_status_<UTC>.txt`, `_post_step_a_status_<UTC>.txt`, `_leave_files_pre_<UTC>.txt`, `_leave_files_post_<UTC>.txt`. Include the final delta listing from V3.
- `00a_sha_reconciliation_<UTC>.png` — optional screenshot of the verification run output.

If ANY of V1-V4 fails, do NOT write the green triplet. Halt per §6.5.5.

### 6.5.5 Halt Conditions Specific to Pre-Step A (idempotency-aware)

Halt if any of these occur:

- Any `Ui` or `A1` entry in §6.5.0 is marked `DRIFTED` — the target file's content matches NEITHER the expected `Old` nor the expected `New` state. The file may have drifted since this prompt was written; ask owner before improvising.
- V1 fails: the new SHA `3327BD0F…E7EB` is missing from any of the 6 UPDATE files.
- V2 fails: `PM0-REMED-PACKAGE-CORRECTED` is not present exactly once in `AGENT_CHECKIN_REGISTRY.md`.
- V3 fails: `$delta` either omits a path that §6.5.0 marked `PENDING`, or includes any path outside the 7-target list (`$allTargets`).
- V4 fails: any LEAVE file no longer contains the OLD SHA `4280EC92…EDD15` (forensic anchor lost).
- The `_pre_step_a_status_*.txt` or `_post_step_a_status_*.txt` files cannot be written.
- The `00a_sha_reconciliation_<UTC>.md` evidence triplet cannot be written.

In a halt, write `PREFLIGHT_HALT_<UTC>.md` per Section 11 with: which V check or §6.5.0 entry failed, the offending lines or paths, and a recommendation. Do NOT proceed to step 0. Do NOT write the green `00a` reconciliation triplet.

**Out-of-scope for Pre-Step A halt:**
- Files that were already dirty in the worktree BEFORE Pre-Step A started (they appear in both `_pre_step_a_status_*.txt` and `_post_step_a_status_*.txt` and are NOT new changes from Pre-Step A).
- The `--publish-changes` doc-debt in U5/U6 release notes — Section 6.5 explicitly defers this. Flag it in the output manifest; do not patch.

---

## 6.6 Universal Pre-Write Rollback Rule (MANDATORY before every tenant write)

Before ANY tenant operation that imports, updates, overwrites, deletes, or publishes a solution or its components, you MUST first capture a complete rollback artifact set. The artifact set is the only authorized recovery path if the subsequent write produces an unintended outcome. No tenant write may proceed without a green rollback artifact for that specific gate already on disk.

This rule applies to:
- Gate 4A — `pac solution import` (will overwrite `PMO_v11_Tarefas` in tenant)
- Gate 4B — `pac solution publish` (will publish customizations across the env)
- Gate 4C — `pac solution delete` (will delete `PMO_AQ07_CopilotBinding`)
- Any future tenant write in any subsequent turn

### 6.6.1 Storage convention

Path:
```
.planning/comms/codex_pm0_remediation_20260522/CODEX2/ROLLBACK/<gate>_pre_<operation>_<UTC>/
```

`<gate>` ∈ {`4A`, `4B`, `4C`}. `<operation>` ∈ {`import`, `publish`, `aq07_delete`}.

### 6.6.2 Required contents per artifact set

For every solution the upcoming write will touch:

1. `<SolutionUniqueName>_unmanaged.zip` — `pac solution export --managed false …` per runbook §2
2. `<SolutionUniqueName>_managed.zip` — `pac solution export --managed true …` per runbook §2
3. `<SolutionUniqueName>_unmanaged.sha256.txt` — SHA256 of the unmanaged ZIP
4. `<SolutionUniqueName>_managed.sha256.txt` — SHA256 of the managed ZIP

Plus, in the same folder:

5. `manifest.md` — Evidence Triplet listing all ZIPs + their hashes + agent name `Codex #2 Bravo` + BRT timestamp + the gate this rollback arms.
6. `restore_runbook.md` — exact `pac solution import` command(s) needed to restore the captured pre-write state, parameterized for env `e2d10003-4d8e-e007-9d63-76d5fe89ef56`. Must reference each ZIP by its absolute repo-relative path.

### 6.6.3 Solutions to capture per gate

| Gate | Solutions to capture |
|---|---|
| 4A pre-import | `PMO_v11_Tarefas` (managed + unmanaged) AND `PMO_AQ07_CopilotBinding` (managed + unmanaged). PMO_v11 is being overwritten; AQ07 is adjacent and held for traceability. |
| 4B pre-publish | `PMO_v11_Tarefas` (now-imported 3.16 state, managed + unmanaged). Plus `pac copilot list` snapshot and Web API GET on `bot` entity for `Assistente PMO V2`. |
| 4C pre-delete | `PMO_AQ07_CopilotBinding` (managed + unmanaged) — fresh export immediately before delete. |

### 6.6.4 Verification (per artifact set)

After capturing, all of the following must PASS:

- **R1** Both managed and unmanaged ZIPs are present and non-empty.
- **R2** Each ZIP's SHA256 matches the value recorded in its `.sha256.txt`.
- **R3** `manifest.md` lists every ZIP path with its hash; agent name is `Codex #2 Bravo`; timestamp is BRT.
- **R4** `restore_runbook.md` contains a runnable `pac solution import` line per captured ZIP, with absolute repo-relative paths and the pinned env ID.

If R1-R4 all PASS → the rollback artifact set is GREEN for that gate. Only then may the gate's own ASK be drafted (or for non-this-prompt gates, only then may the gate write proceed).

### 6.6.5 Halt condition

Halt before any tenant write if:
- The artifact set for that gate is missing, incomplete, or any of R1-R4 fails.
- A captured ZIP is unreadable or its SHA256 verification fails.
- `restore_runbook.md` is missing or its referenced ZIP paths do not exist on disk.

### 6.6.6 Scope of THIS prompt

This prompt's enforcement covers ONLY Gate 4A. After preflight steps 0-11 are GREEN, you MUST execute Section 7.5 (pre-Gate-4A rollback backup) and produce the artifact set at:
```
.planning/comms/codex_pm0_remediation_20260522/CODEX2/ROLLBACK/4A_pre_import_<UTC>/
```

Gates 4B and 4C rollbacks are owned by their own future prompts. State the rule in your output manifest so future prompts inherit it.

---

## 6.7 Dataverse Web API Token Acquisition Pattern (Option B — owner-ratified 2026-05-22 23:18 BRT)

The runbook proves `InvokeApi` for ProcessSimple endpoints. It does NOT prove `InvokeApi` for Dataverse Web API. The previous attempt halted at `AADSTS65002` — a consent / pre-authorization gap between PowerApps Admin PowerShell's first-party app and the Dataverse Web API on `colofertasbrasilpro.crm4.dynamics.com`.

Owner ratified Option B: bypass `InvokeApi` for Dataverse Web API. Acquire an explicit Dataverse-audience Bearer token and call the Web API directly via `Invoke-RestMethod`. Once proven in this turn, the chosen path becomes the new authorized pattern for Dataverse Web API GETs in this tenant (the runbook will be amended in a later maintenance turn).

### 6.7.1 Token acquisition — candidate paths in priority order

Author a helper function `Get-DataverseToken` that returns a Bearer token with audience `https://colofertasbrasilpro.crm4.dynamics.com/`. Try the candidates below in order. Use the FIRST one that succeeds. Document the chosen path in the Step 03 evidence triplet.

| # | Candidate | Acquisition command (template) | Notes |
|---|---|---|---|
| 1 | **Az CLI** | `az account get-access-token --resource https://colofertasbrasilpro.crm4.dynamics.com/ --query accessToken -o tsv` | Az CLI's first-party app is generally pre-authorized for Dataverse. Requires Az CLI installed and `az login` complete with the same UPN that ran `pac auth create`. |
| 2 | **`MSAL.PS` module** | `Get-MsalToken -ClientId <pac-public-client-id> -Scopes "https://colofertasbrasilpro.crm4.dynamics.com/.default" -DeviceCode` | Reuses PAC CLI's well-known public client ID (resolve from PAC docs or cached profile metadata). PAC's app is already pre-authorized — Steps 01/02 prove it. Requires `MSAL.PS` module install. |
| 3 | **`Microsoft.Xrm.Tooling.Connector`** | `Get-CrmConnection -ServerUrl https://colofertasbrasilpro.crm4.dynamics.com/ -OnlineType Office365` (interactive); read `.AccessToken` from the resulting `CrmServiceClient` | Older path. May still hit `AADSTS65002` depending on the module's app registration. |

If candidate 1 fails with `AADSTS65002` or any other error, try 2. If 2 fails, try 3. If all three fail, halt H8 (Section 11). Do NOT install new modules without owner approval — if a candidate is unavailable, skip to the next; only halt after all three are exhausted.

### 6.7.2 Wrapper function `Invoke-DataverseGet`

Once `Get-DataverseToken` returns a Bearer token, every Dataverse Web API GET in Steps 03, 04, 06, 09 goes through this wrapper:

```powershell
function Invoke-DataverseGet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,           # e.g., "/api/data/v9.2/solutioncomponents?..."
        [Parameter(Mandatory)][string]$Token
    )
    $envUrl  = "https://colofertasbrasilpro.crm4.dynamics.com"
    $headers = @{
        Authorization      = "Bearer $Token"
        Accept             = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version"    = "4.0"
        "Prefer"           = "odata.include-annotations=*"
    }
    Invoke-RestMethod -Method Get -Uri ($envUrl + $Path) -Headers $headers -ErrorAction Stop
}
```

### 6.7.3 Token handling safety rules (mandatory)

- **Never persist the token to disk.** Token lives only in process memory.
- **Never echo the token to console.** Suppress stdout/stderr of any command that emits the raw token.
- **Pass tokens as parameters only.** Do not store in script-scope variables that survive across function calls.
- **Clear the variable after the last GET completes:** `$token = $null`.
- **Scrub the transcript** before committing any evidence file. Example:
  ```powershell
  (Get-Content $transcriptPath) -replace 'Bearer\s+[A-Za-z0-9\-_\.]+', 'Bearer <REDACTED>' |
    Set-Content $transcriptPath -Encoding utf8
  ```
  Then verify with two greps that must each return zero matches:
  ```powershell
  Select-String -Path $transcriptPath -SimpleMatch -Pattern 'Bearer eyJ' -Quiet  # token JWT prefix
  Select-String -Path $transcriptPath -SimpleMatch -Pattern 'accessToken'   -Quiet
  ```
- **Halt if scrub fails.** A leaked token in committed evidence is a Section 11 halt regardless of preflight progress.

### 6.7.4 Documenting the chosen path

In the Step 03 evidence triplet (`03_solutioncomponents_<UTC>.md`), include this header section verbatim, filled in with actual values:

```markdown
## Token acquisition path used (Section 6.7)
- Path: AZ_CLI | MSAL_PS | XRM_TOOLING
- Tool version: <e.g., az 2.59.0 / MSAL.PS 4.2.1.5 / Microsoft.Xrm.Tooling.Connector 5.0.0.0>
- Resource: https://colofertasbrasilpro.crm4.dynamics.com/
- Acquisition outcome: SUCCESS
- Time to acquire: <seconds>
- Token redacted in transcript: YES (scrub verified — 0 'Bearer eyJ' hits, 0 'accessToken' hits)
```

This documents the now-proven Dataverse Web API pattern for future remediation cycles.

### 6.7.5 Halt conditions specific to Section 6.7

Halt if:

- All three token-acquisition candidates fail. Record the AAD error from each in the halt evidence; do NOT include any partial token.
- Any token leaks into a committed evidence file or transcript (scrub failed or scrub-verification grep returned non-zero).
- The first successful Dataverse GET still returns `AADSTS65002` (token audience mismatch — likely the candidate acquired a token for the wrong resource).
- Owner approval is needed to install a new PowerShell or CLI module (e.g., Az CLI not present, MSAL.PS not present).

In a halt, the halt evidence file MUST NOT contain the token, the access-token JSON response, or any header line containing `Bearer`.

---

## 7. Preflight Steps (read-only, owner-pre-approved)

Execute in this order. Each step produces an Evidence Triplet at `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/<NN>_<slug>_<UTC-stamp>.{json,txt,md,png}`.

| # | Step | Channel | Expected output |
|---|---|---|---|
| 0 | Auth verify: `pac auth list` → if needed `pac auth create --deviceCode` → `pac env select` → `pac env who` | PAC CLI (runbook §2) | Auth profile name, env ID, env URL, user UPN |
| 1 | `pac solution list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56` — capture rows for `PMO_v11_Tarefas` and `PMO_AQ07_CopilotBinding` (versions, IDs, isManaged, friendly name) | PAC CLI (runbook §2) | Solution rows + IDs |
| 2 | `pac connection list --environment e2d10003-…ef56` — confirm SharePoint/Teams/O365 connection IDs match pinned values in runbook §2 | PAC CLI (runbook §2) | Connection inventory |
| 3 | Web API GET: `/api/data/v9.2/solutioncomponents?$filter=_solutionid_value eq <PMO_v11_id>&$select=componenttype,objectid,rootcomponentbehavior` AND same query for AQ07 solution ID | `Invoke-DataverseGet` (§6.7) | Component inventory per solution; classify Workflow=29, BotComponent rows |
| 4 | Web API GET: query the bot↔workflow binding entity (resolve correct entity name — likely `botcomponent` with category=Action, expecting 5 rows for PM0) for both solutions | `Invoke-DataverseGet` (§6.7) | Workflowset/binding row inventory |
| 5 | `Get-Flow -EnvironmentName $envId -Top 200` filtered to the 5 PM0 GUIDs → capture per flow: `Enabled`, `state`, `LastModifiedTime`, `definitionSummary` | PowerApps PS 1.0.45 (runbook §3, §4) | Flow inventory + per-flow definition summary |
| 6 | Web API GET: `/api/data/v9.2/bots?$filter=name eq 'Assistente PMO V2'&$select=name,statecode,statuscode,publishedon,configuration` | `Invoke-DataverseGet` (§6.7) | Bot row + publish state (CLI side) |
| 7 | AQ-08 structural verifier rerun against current tenant state. Use existing `tests/Test-CopilotRoutingInstructions.ps1` (or whichever AQ-08 verifier exists in repo). | Local + tenant read | AQ-08 PASS/FAIL with evidence |
| 8 | Strict consistency rerun on corrected ZIP — confirm on-disk SHA256 of `CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` matches `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`. Use existing `scripts/New-Solution316Pm0PackageEvidence.ps1`. | Local | Strict-pass evidence triplet (regenerated) |
| 9 | Web API GET: `/api/data/v9.2/processsessions?$filter=_regardingobjectid_value in (<5 PM0 flow GUIDs>)&$select=processid,regardingobjectid,startedon,completedon,status&$top=50&$orderby=startedon desc` — pre-import forensic baseline | `Invoke-DataverseGet` (§6.7) | Per-flow recent execution baseline (5 sets) |
| 10 | Operator captures Copilot Studio UI screenshot — `Assistente PMO V2` overview page showing publish state, version, and visible PM0 topic list. Screenshot only; no UI write. | Browser UI | `10_copilot_studio_pre_import_<UTC>.png` + `.md` stub |
| 11 | AQ-09 Section A smoke-harness readiness check — open `tests/Test-PMOFlowStopShipAudit.ps1` (or AQ-09 harness path) and confirm component IDs, action schema names, and the 5 PM0 GUIDs in the harness map 1:1 to the corrected package's botcomponent rows. No tenant call — config inspection only. | Local | Readiness report MD |

---

## 7.5 Pre-Gate-4A Rollback Backup (MANDATORY — runs after Section 7 preflight is GREEN, before Section 9 ASK draft)

Once preflight steps 0-11 all PASS, capture the Gate 4A rollback artifact set per Section 6.6 before drafting the Gate 4A ASK.

### 7.5.1 Solutions to capture

| Solution unique name | Managed | Unmanaged |
|---|---|---|
| `PMO_v11_Tarefas` | required | required |
| `PMO_AQ07_CopilotBinding` | required | required |

### 7.5.2 Command shape (per runbook §2 — author exact instances yourself)

For each solution unique name and each of `false`/`true` for `--managed`, run a `pac solution export` per runbook §2 and write its SHA256 to a sibling `.sha256.txt`. The command shape:

```powershell
$utc   = (Get-Date).ToUniversalTime().ToString("yyyyMMdd_HHmmss")
$rbDir = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/ROLLBACK/4A_pre_import_$utc"
New-Item -ItemType Directory -Force -Path $rbDir | Out-Null

# Repeat for each (SolutionUniqueName, mode) pair: 2 solutions × 2 modes = 4 ZIPs
pac solution export `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --name <SolutionUniqueName> `
  --path "$rbDir/<SolutionUniqueName>_<unmanaged|managed>.zip" `
  --managed <false|true> `
  --overwrite

(Get-FileHash -Algorithm SHA256 "$rbDir/<SolutionUniqueName>_<unmanaged|managed>.zip").Hash |
  Set-Content -Encoding utf8 "$rbDir/<SolutionUniqueName>_<unmanaged|managed>.sha256.txt"
```

The 4 expected ZIP filenames in `4A_pre_import_<UTC>/`:
- `PMO_v11_Tarefas_unmanaged.zip` + `.sha256.txt`
- `PMO_v11_Tarefas_managed.zip` + `.sha256.txt`
- `PMO_AQ07_CopilotBinding_unmanaged.zip` + `.sha256.txt`
- `PMO_AQ07_CopilotBinding_managed.zip` + `.sha256.txt`

### 7.5.3 Manifest and restore runbook

Author both files in the same `4A_pre_import_<UTC>/` folder per Section 6.6.2.

`restore_runbook.md` MUST contain a runnable `pac solution import` line per captured ZIP, e.g.:

```powershell
pac solution import `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --path "<absolute repo-relative path to .zip>" `
  --activate-plugins
```

…repeated for each of the 4 ZIPs, with explicit ordering recommendation (which to import first if a multi-ZIP rollback is needed).

### 7.5.4 Verification

Run R1-R4 from Section 6.6.4. If any fails, halt per Section 6.6.5 and Section 11. Do NOT draft the Gate 4A ASK on a failed rollback artifact set.

### 7.5.5 Output

The Gate 4A ASK draft (Section 9) MUST include the absolute repo-relative path to this rollback artifact folder and reference `restore_runbook.md` as the rollback procedure.

---

## 7.6 Canonical Artifact Relocation (MANDATORY — runs after Section 7.5 rollback is GREEN, before Section 9 ASK draft)

Owner-ratified 2026-05-22 21:25 BRT (Option A): the corrected ZIP must reside at the conventional ship path `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` so that release notes, runbooks, and the Gate 4A ASK all reference one canonical artifact.

### 7.6.1 Detect divergence (idempotency check)

Compute SHA256 of `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` on disk.

- If SHA = `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` → relocation already complete; mark `ALREADY_AT_TARGET`; skip §7.6.2; proceed to §7.6.3 verification.
- If SHA = `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15` (old failed candidate) → mark `RELOCATION_NEEDED`; proceed to §7.6.2.
- If SHA is anything else (file missing, corrupted, or unexpected bytes) → halt per Section 11. Do NOT improvise.

### 7.6.2 Relocate corrected ZIP to canonical ship path

```powershell
$src         = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip"
$dst         = "Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip"
$expectedSha = "3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB"

# Pre-flight: verify the source bytes are what we expect.
$srcSha = (Get-FileHash -Algorithm SHA256 -LiteralPath $src).Hash
if ($srcSha -ne $expectedSha) {
  throw "Source SHA mismatch: actual $srcSha vs expected $expectedSha"
}

# Capture the pre-relocation destination SHA for the evidence triplet.
$dstShaPre = (Get-FileHash -Algorithm SHA256 -LiteralPath $dst).Hash

# Copy (overwrite the old failed bytes).
Copy-Item -LiteralPath $src -Destination $dst -Force

# Post-flight: verify destination SHA equals the expected.
$dstShaPost = (Get-FileHash -Algorithm SHA256 -LiteralPath $dst).Hash
if ($dstShaPost -ne $expectedSha) {
  throw "Destination SHA mismatch after copy: actual $dstShaPost vs expected $expectedSha"
}
```

The source at `CODEX2/PACKAGE/package/...zip` REMAINS in place as historical evidence. Do NOT delete it. The two locations now hold byte-identical copies — `Solution/…zip` is the canonical ship path; `CODEX2/PACKAGE/package/…zip` is the remediation history.

### 7.6.3 Verification

- `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` exists and `Get-FileHash` SHA256 = `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`.
- `CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` still exists with the same SHA (historical evidence intact).

If either fails → halt per Section 11.

### 7.6.4 Evidence Triplet

Write `.planning/comms/codex_pm0_remediation_20260522/CODEX2/SHIP_ARTIFACT/relocation_<UTC>.md` (and optional `.png` of the verification run) with:

- Source path + source SHA256
- Destination path + destination SHA256 (post-copy)
- Destination SHA256 BEFORE the copy (the old `4280EC92…EDD15` if relocation was needed; or `3327BD0F…E7EB` if already idempotent)
- Outcome: `COPIED` | `ALREADY_AT_TARGET`
- Agent: `Codex #2 Bravo`
- Timestamp BRT

### 7.6.5 Output

The Gate 4A ASK draft (Section 9) MUST reference `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` as the import path. The `CODEX2/PACKAGE/package/...zip` path is no longer the import target — it is preserved only as remediation history.

---

## 8. Evidence Folder Layout (create ahead, populate per step)

```
.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/
├── _transcript_<UTC>.log                 # Start-Transcript output
├── 00_auth_verify_<UTC>.{json,txt,md}
├── 01_pac_solution_list_<UTC>.{json,txt,md}
├── 02_pac_connection_list_<UTC>.{json,txt,md}
├── 03_solutioncomponents_<UTC>.{json,txt,md}     # both solutions in one capture or two files
├── 04_workflowset_binding_<UTC>.{json,txt,md}
├── 05_pm0_flow_inventory_<UTC>.{json,txt,md}
├── 06_bot_row_<UTC>.{json,txt,md}
├── 07_aq08_verifier_<UTC>.{txt,md,png}
├── 08_strict_consistency_<UTC>.{md,png}          # regenerated; SHA must match locked value
├── 09_processsession_baseline_<flow>_<UTC>.{json,txt,md}  # 5 files (one per PM0 GUID)
├── 10_copilot_studio_pre_import_<UTC>.{png,md}   # operator-captured
├── 11_aq09_harness_readiness_<UTC>.{txt,md}
└── PREFLIGHT_SUMMARY_<UTC>.md            # one-page roll-up: all PASS/FAIL, all SHA, all paths

.planning/comms/codex_pm0_remediation_20260522/CODEX2/ROLLBACK/
└── 4A_pre_import_<UTC>/                  # per Section 6.6 + Section 7.5
    ├── PMO_v11_Tarefas_unmanaged.zip
    ├── PMO_v11_Tarefas_unmanaged.sha256.txt
    ├── PMO_v11_Tarefas_managed.zip
    ├── PMO_v11_Tarefas_managed.sha256.txt
    ├── PMO_AQ07_CopilotBinding_unmanaged.zip
    ├── PMO_AQ07_CopilotBinding_unmanaged.sha256.txt
    ├── PMO_AQ07_CopilotBinding_managed.zip
    ├── PMO_AQ07_CopilotBinding_managed.sha256.txt
    ├── manifest.md                       # Evidence Triplet for the rollback set
    └── restore_runbook.md                # exact pac import lines to recover

.planning/comms/codex_pm0_remediation_20260522/CODEX2/SHIP_ARTIFACT/
└── relocation_<UTC>.{md,png}             # per Section 7.6 — proves Solution/...zip is canonical and matches 3327BD0F…E7EB

Solution/
└── PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip   # CANONICAL SHIP ARTIFACT after Section 7.6 — SHA256 must equal 3327BD0F…E7EB
```

Each `.md` Evidence Triplet stub MUST contain:
- Timestamp BRT (matching the file's UTC stamp)
- Agent name: `Codex #2 Bravo`
- Path of the `.png` (or `.txt`/`.json` if no UI surface)
- One-line description of what was verified
- Linked source command line

---

## 9. Gate 4A ASK Draft (Section produced AFTER preflight green)

After ALL 13 evidence triplets land green (1 reconciliation `00a` + 12 preflight `00`-`11`), draft `.planning/comms/codex_pm0_remediation_20260522/CODEX2/GATE_4A_ASK_DRAFT_<UTC>.md` with this exact shape:

```markdown
# Gate 4A — Solution Import — ASK FOR OWNER APPROVAL

| Field | Value |
|---|---|
| Gate | 4A — Import only (no publish; publish = Gate 4B; cleanup = Gate 4C) |
| Package path | Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip (canonical ship path; relocated from `CODEX2/PACKAGE/package/...zip` per Section 7.6) |
| Package SHA256 | 3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB |
| Environment | ColOfertasBrasilPro · e2d10003-4d8e-e007-9d63-76d5fe89ef56 |
| Auth | Existing device-code profile COLQA0424 (verified at step 00) |
| Preflight | All 13 evidence triplets PASS (1 reconciliation + 12 preflight) — see PREFLIGHT_SUMMARY_<UTC>.md |
| Canonical artifact relocation | PASS (Section 7.6 evidence: CODEX2/SHIP_ARTIFACT/relocation_<UTC>.md) |
| Rollback artifact path | .planning/comms/codex_pm0_remediation_20260522/CODEX2/ROLLBACK/4A_pre_import_<UTC>/ |
| Rollback verification | R1 PASS · R2 PASS · R3 PASS · R4 PASS (per Section 6.6.4) |
| Restore runbook | `<rollback_path>/restore_runbook.md` |
| Operation type | Tenant write (solution import only — does NOT publish customizations) |

## Exact command to be executed upon approval

```powershell
pac solution import `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --path "Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip" `
  --activate-plugins
```

NOTE — `--publish-changes` is intentionally OMITTED. Publish is Gate 4B (separate ASK).

## Rollback
Per the Universal Pre-Write Rollback Rule (Section 6.6), the pre-import tenant state is captured at `<rollback_path>/`. To roll back, follow `<rollback_path>/restore_runbook.md` — re-import the captured ZIPs in the order specified there. The pre-3.16 baseline `PMO_v11_Tarefas_3_15_1` from `CURRENT_BASELINE.md` may be substituted if the captured ZIPs are themselves compromised.

## Risk if not approved
PM0 functional fix remains uninstalled; AQ-09 A1 failure mode remains live.
```

---

## 10. Trail Document Updates (mandatory per Continuous Documentation Update Rule)

After preflight is complete, update:

1. `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` — append entry with timestamp, Codex #2 agent name, summary of preflight outcome, links to all 12 evidence files.
2. `.planning/comms/codex_pm0_remediation_20260522/DOC_UPDATES_LOG.md` — log this prompt's execution and the trail file edits.
3. `.planning/comms/codex_pm0_remediation_20260522/EVIDENCE_LOG.md` — register all 12 evidence triplets.
4. `.planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md`:
   - §7 Divergence Map — mark Q4 RESOLVED → 3 gates (Codex #1) per owner adjudication 2026-05-22 18:50 BRT.
   - §1 Question Summary Table — annotate Q4 row with owner ratification.
   - Refresh `Last updated:` line.

---

## 11. Halt Conditions

STOP and return to owner WITHOUT progressing if any of the following occurs:

- Auth verify (step 0) fails or surfaces a different env/user than pinned values.
- Any read returns 401/403/404 unexpectedly (could indicate tenant drift since runbook).
- Solution list (step 1) shows different solution unique names or unexpected solutions.
- Connection list (step 2) shows different connection IDs than runbook.
- AQ-08 verifier (step 7) FAILs.
- Strict consistency (step 8) SHA256 does not match `3327BD0F…E7EB`.
- AQ-09 harness readiness (step 11) shows ID mismatch between harness and packaged components.
- Pre-Gate-4A rollback artifact set (Section 7.5) is missing or incomplete, OR any of R1-R4 (per Section 6.6.4) fails. No Gate 4A ASK may be drafted until the rollback artifact set is GREEN.
- Canonical artifact relocation (Section 7.6) fails any of: source SHA mismatch before copy, destination SHA mismatch after copy, source file missing, or destination file at unexpected SHA (neither `3327BD0F…E7EB` nor `4280EC92…EDD15`).
- **Section 6.7 token acquisition fails:** all three candidates (Az CLI, MSAL.PS, Xrm.Tooling) returned errors; record each AAD error code in the halt evidence WITHOUT any partial token.
- **Section 6.7 token leak:** transcript or evidence file contains `Bearer eyJ` or `accessToken` after scrub-verification; this is a halt regardless of preflight progress.
- **Section 6.7 missing dependency:** none of Az CLI / MSAL.PS / Xrm.Tooling is installed; owner approval required before installing.
- Any forbidden verb (per Section 5 table) was about to run.
- Any operation might mutate tenant state.

In a halt, write a `PREFLIGHT_HALT_<UTC>.md` summary with the reason, the step that halted, the commands that ran successfully before the halt, and a recommendation for the owner.

---

## 12. Acceptance Criteria (your output is accepted only if all are TRUE)

- [ ] All 9 mandatory references read (per Section 2); references logged at top of orchestrator script.
- [ ] Pre-Step A SHA reconciliation complete (6 UPDATE + 1 APPEND files), with `00a_sha_reconciliation_<UTC>.{md,png}` evidence triplet.
- [ ] Access check-in entry written in `AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` BEFORE step 0.
- [ ] Script(s) authored, PSScriptAnalyzer-clean, idempotent, halt-on-error, no tenant writes.
- [ ] All 12 preflight steps (0-11) executed; 12 Evidence Triplets present and valid (timestamp BRT + agent name + screenshot/file). Total artifacts = 13 (1 reconciliation + 12 preflight).
- [ ] Pre-Gate-4A rollback artifact set captured at `CODEX2/ROLLBACK/4A_pre_import_<UTC>/` with 4 ZIPs + 4 SHA256 files + `manifest.md` + `restore_runbook.md`; R1-R4 (Section 6.6.4) all PASS.
- [ ] Canonical artifact relocation (Section 7.6) complete: `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` SHA256 = `3327BD0F…E7EB`; evidence at `CODEX2/SHIP_ARTIFACT/relocation_<UTC>.md`.
- [ ] `PREFLIGHT_SUMMARY_<UTC>.md` written with PASS/FAIL roll-up.
- [ ] `GATE_4A_ASK_DRAFT_<UTC>.md` written using exact shape in Section 9.
- [ ] Trail docs (Section 10) updated; Q4 marked RESOLVED in consolidated divergence map.
- [ ] No tenant write executed.
- [ ] Final hand-off message lists exact paths of all artifacts produced (use Section 13 manifest shape).

---

## 13. Output Manifest (return this at the end)

When done (or halted), reply with:

```
## Codex #2 Gate 4 Preflight — Output Manifest

Status: GREEN | HALTED | FAILED
Started: <BRT>
Ended: <BRT>
Duration: <minutes>

Scripts authored:
- scripts/<file>.ps1 (lines, purpose)
- ...

Evidence Triplets (13 expected — 1 reconciliation + 12 preflight):
- 00a_sha_reconciliation_<UTC>.{md,png}: PASS|FAIL|SKIP — <one-line>
- 00_auth_verify_<UTC>.{json,txt,md}: PASS|FAIL|SKIP — <one-line>
- ... [00-11, all 12 preflight steps]

Pre-Gate-4A Rollback Artifact Set (per Section 6.6 + 7.5):
- Path: .planning/comms/codex_pm0_remediation_20260522/CODEX2/ROLLBACK/4A_pre_import_<UTC>/
- Solutions captured: PMO_v11_Tarefas (managed + unmanaged), PMO_AQ07_CopilotBinding (managed + unmanaged)
- ZIP count: <n>/4 expected
- SHA256 file count: <n>/4 expected
- manifest.md: PRESENT|MISSING
- restore_runbook.md: PRESENT|MISSING
- R1-R4 verification: PASS|FAIL (per check)

Canonical Artifact Relocation (per Section 7.6):
- Outcome: COPIED | ALREADY_AT_TARGET | FAILED
- Source: .planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip — SHA256 <hash>
- Destination: Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip — SHA256 <hash> (must equal 3327BD0F…E7EB)
- Pre-relocation destination SHA256: <hash> (was 4280EC92…EDD15 if RELOCATION_NEEDED)
- Evidence: .planning/comms/codex_pm0_remediation_20260522/CODEX2/SHIP_ARTIFACT/relocation_<UTC>.md

Trail updates:
- INVESTIGATION_LOG.md (entry timestamp)
- DOC_UPDATES_LOG.md (entry timestamp)
- EVIDENCE_LOG.md (entry timestamp)
- OPEN_QUESTIONS_CONSOLIDATED_20260522.md (Q4 RESOLVED, last-updated bumped)

Gate 4A ASK draft: .planning/comms/codex_pm0_remediation_20260522/CODEX2/GATE_4A_ASK_DRAFT_<UTC>.md

Outstanding for owner:
- Gate 4A approval (the import command in the draft)
- Anything that halted (reference PREFLIGHT_HALT_<UTC>.md if applicable)

Halt conditions hit: <list or "none">
```

### 13.1 Post-execution peer review by Codex #1 (mandatory before owner sees the manifest)

After this Output Manifest is complete and BEFORE handing it back to owner, request Codex #1 to perform a single-pass sanity review of every artifact produced. Codex #1 reviews only — it does NOT execute, modify, or re-author any artifact. The review covers:

- Every Evidence Triplet under `CODEX2/PREFLIGHT/`, `CODEX2/ROLLBACK/4A_pre_import_<UTC>/`, and `CODEX2/SHIP_ARTIFACT/` has a BRT timestamp, agent name `Codex #2 Bravo`, and a resolvable file path.
- Every `.json` evidence file parses without error; every `.md` stub references files that exist on disk.
- The corrected SHA `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` appears in each of the 6 UPDATE files from §9 and in `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` (Section 7.6 destination).
- The old SHA `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15` is still present in each of the 7 LEAVE files from §6.5.3 (forensic anchor intact).
- Rollback artifact set contains exactly 4 ZIPs + 4 `.sha256.txt` + `manifest.md` + `restore_runbook.md`; each ZIP's recorded hash matches `Get-FileHash` of the actual file.
- The Gate 4A ASK draft references `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` as the import path and omits `--publish-changes`.
- No tenant write was executed (transcript free of import/publish/delete verbs).

Codex #1 writes its verdict to `.planning/comms/codex_pm0_remediation_20260522/CODEX1/PEER_REVIEW/<UTC>_gate4a_preflight_review.md` containing one of:
- **PASS** — all checks green; Codex #2 may forward the manifest to owner.
- **FAIL** — itemized findings (which check, which file, what is wrong). Codex #2 corrects the flagged items and requests a fresh review. Owner does NOT see the manifest until Codex #1 signs off PASS.

Codex #1 does not run any tenant command, does not modify any output file, and does not author any new evidence. Review-only, read-only.

---

## END OF PROMPT

Tenant write authorization in this turn: **NOT GRANTED**. Read-only and local-script only.
