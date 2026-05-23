# OPEN QUESTIONS — CONSOLIDATED (Codex #1 + Kiro + Codex #2)

| Field | Value |
|---|---|
| Document | `.planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md` |
| Created | 2026-05-22 17:51:52 BRT |
| Last updated | 2026-05-22 23:02:11 BRT — Codex #2 Bravo — applied owner-ratified Q4 three-gate adjudication during halted Gate 4 preflight logging. |
| Owner | Project Owner (decisões em time, sem decisões apartadas) |
| Authors so far | Codex #1 Lead (delivered 2026-05-22 17:36:06 BRT) · Kiro (delivered 2026-05-22 17:51:52 BRT) · Codex #2 Bravo (delivered 2026-05-22 18:06:23 BRT) |
| Methodology | Golden Rules: Official Microsoft Docs Rule + Evidence Triplet Rule + Continuous Documentation Update Rule + Functional DoD Rule + Placeholder Backfill Rule |
| Tenant write authorization | NOT granted in this turn. Read-only analysis only. |

---

## 0. Why this document exists (Owner directive 2026-05-22 ~17:51 BRT)

Owner directive (preserved literal): *"nao existem decisoes apartadas, tudo é decidido de maneira global e em time, logo coloque todas as questões em aberto as repostas que temos incluindo as suas e abra mais uma coluna vamos pedir ao codex 2 coloque a respostas dele e sempre seguindo a mesma metodologia do codex 1 e esta nas golden rules, todas respostas sempre devem ser fundamentadas por dados, ou seja tudo precisa estar escrito nos documentos oficiais do vendor oficial que é a microsoft nesse caso, nada de achismos ou aluncionações"*.

This file consolidates the 5 open questions raised in `MESSAGE_TO_CODEX_1_UPDATED_OPINION_20260522.md` and presents three parallel agent columns (Codex #1, Kiro, Codex #2) so the team can converge on one decision per question. The methodology is identical for all three columns:

1. Findings cite Microsoft Learn URLs with `accessed YYYY-MM-DD HH:mm:ss BRT`. No third-party blogs, no model memory, no inference.
2. Local verifications carry full Evidence Triplet (screenshot path + timestamp BRT + agent name) per the Golden Rules.
3. Each question must end with explicit Recommendation + Risk-if-not-followed + open dependencies.
4. Conflicts between agent columns are surfaced in §"Convergence / Divergence Map" (§7) and resolved by Owner.

---

## 1. Question Summary Table

| # | Question | Codex #1 Recommendation | Kiro Recommendation | Codex #2 Recommendation |
|---|---|---|---|---|
| Q1 | Is Codex #2's package consistent with Option A? | NOT Gate-4-ready. Workflowset.xml has 0 PM0 mappings; 0/5 workflow JSON match local Alpha after canonical compare. | **Concur structurally.** Workflowset.xml gap is unambiguous fail; canonical JSON diff needs a per-field reason audit before accepting as semantic-equivalent. Block Gate 4. | Patched ZIP is locally Option-A-consistent: 5 PM0 workflowset mappings, 5 diff reports, 0 unexplained canonical leaf diffs. Gate 4 still waits tenant preflight and approval. |
| Q2 | How to handle PMO_AQ07_CopilotBinding cleanup? | Option (d): staged cleanup AFTER corrected import + read-only dependency inventory. Use `pac solution delete` only if AQ07 has no unique live deps. | **Concur with (d), with caveat:** `pac solution remove-solution-component` does NOT exist in current pac CLI; option (b) as worded is not CLI-supported. Path is full delete via `pac solution delete` OR maker-portal removal, not partial CLI removal. | Concur staged cleanup. Inventory first; use documented `pac solution delete` only after proof or a separate Web API/UI runbook under owner approval. |
| Q3 | Required read-only preflight before Gate 4 ASK | 6 commands: `pac solution list`, FetchXML solutioncomponent, FetchXML workflowset, `pac copilot list`, AQ-08 verifier, corrected package strict recheck. | **Add 2 items to Codex #1's list:** (a) snapshot baseline of `processsession` rows for the 5 PM0 flows so post-import drift is forensically comparable; (b) capture pre-import screenshot of bot publish state in Copilot Studio UI (not only CLI output). | Run the six structural checks plus process-session baseline and Copilot UI publish-state screenshot; validate the FetchXML filter before asserting process-session rows map to flow IDs. |
| Q4 | Gate 4 ASK shape (single vs split) | **RESOLVED by owner 2026-05-22 18:50 BRT:** 3 gates: 4A import, 4B publish, 4C AQ07 cleanup. Runtime smoke remains mandatory post-publish QA evidence, not a separate owner approval gate. | Historical recommendation was 4 gates; owner adjudication selects Codex #1's 3-gate split while preserving Functional DoD as mandatory QA evidence. | Historical recommendation was 4 gates; updated status follows owner-ratified 3-gate split in `PROMPT_FOR_CODEX_2_GATE4_PREFLIGHT.md`. |
| Q5 | Single best next action (next 60 minutes) | Block Gate 4. Run preflight read-only. Codex #2 must rebuild package with workflowset mappings and reconciled workflow JSON. | **Concur block.** Critical added risk: re-importing without first capturing a forensic baseline of the current tenant state risks an irreversible diff window. Owner should require pre-import tenant snapshot as Gate-4A precondition. | Package repair is done locally; next 60 minutes should collect read-only tenant baseline and only then draft Gate 4A with the new SHA. |

Convergence after backfill: all three agents converge on staged cleanup, read-only preflight, and split Gate 4. Codex #2 patched the package gap identified by Codex #1/Kiro and narrows Q1 to tenant preflight plus owner approval.

---

## 2. Question 1 — Is Codex #2's package consistent with Codex #1's Option A specification?

### 2.1 Codex #1 Answer (delivered 2026-05-22 17:36:06 BRT)

**Verdict:** NOT Gate-4-ready.

Findings (Evidence Triplet path: `.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173428_Codex1_package_consistency_strict.{md,png}`):

| Check | Result |
|---|---|
| Package SHA256 | `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15` |
| Five PM0 workflow entries present | PASS |
| Five PM0 action components present | PASS |
| Five PM0 topic components present | PASS |
| Internal duplicate PM0 botcomponent instances | PASS (0 dupes) |
| `Assets/botcomponent_workflowset.xml` PM0 mappings | **FAIL — 0 PM0 lines** |
| Raw local-vs-zip workflow SHA match | **FAIL — 0/5** |
| Canonical local-vs-zip workflow JSON match | **FAIL — 0/5** |
| Static placeholder response pattern in PM0 workflows | PASS |

Microsoft Learn citations (Codex #1):
- `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` (accessed 2026-05-22 17:36:00 BRT) — `pac solution import`, `--publish-changes`, pack/unpack semantics.
- `https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export` (accessed 2026-05-22 17:36:00 BRT) — Copilot Studio agents are exported/imported with solutions.
- `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` (accessed 2026-05-22 17:36:00 BRT) — duplicate-unmanaged-component anti-pattern.

Recommendation: do not issue Gate 4 against this exact rebuilt package. Require Codex #2 to rebuild/patch so workflowset.xml carries all 5 PM0 mappings and either byte/canonical matches local Alpha or documents every intentional diff before import approval.

Risk if not followed: import installs PM0 workflows + PM0 actions while leaving bot action-to-flow binding asset incomplete — recreates the AQ-09 A1 failure mode (package looks structurally richer than 3.15.1 but bot still cannot invoke fixed PM0 flows).

### 2.2 Kiro Answer (delivered 2026-05-22 17:51:52 BRT)

**Verdict:** Concur structurally with Codex #1, with one methodological caveat on the canonical-diff finding.

#### 2.2.1 Findings (review of Codex #1 evidence + own Microsoft Learn validation)

I reviewed the Codex #1 strict-consistency evidence and validated the Microsoft Learn references independently:

| Item | My finding |
|---|---|
| Workflowset.xml gap (`0 PM0 lines`) | **Unambiguous fail.** This is the asset that wires bot actions to workflow IDs. Without these rows, the imported PM0 actions point at no concrete flow at runtime. This is the same defect class that produced AQ-09 A1 FAIL on 3.15.1. |
| Raw SHA mismatch 0/5 | **Expected, not blocking by itself.** Solution pack/repack rewrites JSON ordering, whitespace, and metadata (e.g., `clientData` re-serialization). A raw SHA diff alone does not prove semantic divergence. |
| Canonical JSON mismatch 0/5 | **Blocking, but requires per-field reason.** A canonical compare normalizing key order should match if local Alpha and packaged workflow are semantically equivalent. Zero canonical match across all 5 flows suggests either (a) the packager dropped/added fields not present in local Alpha source (e.g., generated `Id`s, `connectionReferences`, regional formatting), or (b) the local Alpha source is genuinely not what was packaged. Codex #2 must produce a per-field diff list per flow naming each missing/extra/changed field and its reason (intentional vs unintentional) before owner can decide. |
| Placeholder scan PASS | Confirmed against Codex #1 evidence. |

#### 2.2.2 Microsoft Learn citation table (Kiro independently validated)

| Claim | Citation | Accessed |
|---|---|---|
| `pac solution import` accepts `--publish-changes` to publish customizations after a successful import. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` (section "pac solution import") | 2026-05-22 17:50:00 BRT |
| `pac solution pack`/`unpack` behavior is documented; YAML source-control format requires Microsoft.PowerApps.CLI 2.4.1 or later; default unpack is XML format. | Same URL, sections "pac solution pack" and "pac solution unpack". | 2026-05-22 17:50:00 BRT |
| Solution-packager pack/unpack rewrites component XML/JSON layout in the resulting `.zip`; it is normal for byte-level SHA to differ between source and packaged forms. | Same URL, "pac solution pack" remarks: "Package solution components on local filesystem into solution.zip (SolutionPackager)" — packager outputs canonical solution archive, so raw SHA equality is not the supported equivalence test. | 2026-05-22 17:50:00 BRT |
| Microsoft Learn explicitly warns: "Don't include the same unmanaged component in more than one solution." | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` ("Multiple solutions in the same development environment" section, Note block) | 2026-05-22 17:50:00 BRT |

#### 2.2.3 Recommendation (Kiro)

Block Gate 4 until Codex #2 delivers ALL of the following:

1. Patched `PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` whose `Assets/botcomponent_workflowset.xml` carries all 5 PM0 action→workflow mappings (the 5 GUIDs `1721e0a3`, `7c6300c2`, `7f662db7`, `e0e3c6b0`, `8333bd91`).
2. Per-flow canonical JSON diff report (`diff_<flow>_local_vs_packaged.md`) naming each field that differs, classified as `INTENTIONAL_PACKAGER`, `INTENTIONAL_FIX`, or `UNEXPLAINED`. Zero `UNEXPLAINED` entries permitted before Gate 4.
3. New SHA256 for the patched ZIP, attached to a fresh strict-consistency Evidence Triplet.

#### 2.2.4 Risk if not followed (Kiro)

Two risk surfaces, ordered by severity:

1. **Workflowset gap (HIGH):** identical to Codex #1's risk — bot actions land without binding rows, runtime smoke fails again.
2. **Unaudited canonical diffs (MEDIUM):** if 0/5 canonical match is dismissed as "packager noise" without per-field reason, an unintentional Alpha regression could ride into tenant invisibly. Functional DoD requires runtime evidence post-import, but the cheaper fix is a documented diff before import.

#### 2.2.5 Open dependencies on Codex #2

- Patched ZIP per §2.2.3.
- Per-field diff doc per §2.2.3 item 2.

### 2.3 Codex #2 Answer (delivered 2026-05-22 18:06:23 BRT)

**Verdict:** The package Codex #1 inspected was not ready. I patched the Codex #2 builder and rebuilt a corrected local candidate that now satisfies the strict Option A package checks available without tenant access.

#### 2.3.1 Findings

Evidence Triplet: `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/evidence/20260522_180600_Codex2_package_consistency_strict.{md,png}` (timestamp `2026-05-22 18:06:00 BRT`, agent `Codex #2 Bravo`).

| Check | Corrected candidate result |
|---|---|
| Package SHA256 | `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` |
| Five PM0 workflow entries present | PASS |
| Five PM0 action components present | PASS |
| Five PM0 topic components present | PASS |
| Internal duplicate PM0 botcomponent instances | PASS (`0`) |
| `Assets/botcomponent_workflowset.xml` PM0 mappings | PASS (`5`) |
| Raw local-vs-zip workflow SHA match | FAIL (`0/5`) because packaged JSON is normalized |
| Canonical leaf-value diff classification | PASS: `43` classified diffs, `0` `UNEXPLAINED` |
| Static placeholder response pattern in PM0 workflows | PASS |

The five per-flow reports are `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/diffs/diff_AtualizarStatus_local_vs_packaged.md`, `diff_AtualizarTarefa_local_vs_packaged.md`, `diff_CriarTarefa_local_vs_packaged.md`, `diff_ListarTarefas_local_vs_packaged.md`, and `diff_ResumoExecutivoPortfolio_local_vs_packaged.md`. Every listed field is classified `INTENTIONAL_PACKAGER`: connection-reference source/runtimeSource changes from invoker to embedded package metadata, or raw APIM authentication object replacement by `@parameters('$authentication')`. The evidence generator would mark any unmatched field `UNEXPLAINED`; it found zero.

#### 2.3.2 Microsoft Learn citation table

| Claim | Citation | Accessed |
|---|---|---|
| Microsoft documents `pac solution pack` as "Package solution components on local filesystem into solution.zip (SolutionPackager)." | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` (`pac solution pack`) | 2026-05-22 18:06:23 BRT |
| Microsoft documents solution import as "Import the solution into Dataverse" and `--publish-changes` as "Publish your changes upon a successful import." | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` (`pac solution import`) | 2026-05-22 18:06:23 BRT |
| Microsoft documents that agents can be exported and imported using solutions. | `https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export` | 2026-05-22 18:06:23 BRT |

#### 2.3.3 Recommendation

Replace the failed Codex #2 ZIP candidate with the corrected SHA above for any further Gate 4 discussion. Treat it as a local package candidate only until the read-only tenant preflight and owner approval are complete.

#### 2.3.4 Risk if not followed

Using the old SHA repeats the exact workflowset omission Codex #1 found. Treating the corrected local ZIP as already tenant-ready would skip solution membership, dependency, publish-state, and runtime checks that local package evidence cannot provide.

#### 2.3.5 Open dependencies

- Read-only tenant preflight for current `PMO_v11_Tarefas`, AQ07 membership, workflowset rows, and Copilot state.
- Owner approval before any import or publish command.
- AQ-09 runtime evidence after approved import/publish before any DONE or SHIP wording.

---

## 3. Question 2 — How should the tenant `PMO_AQ07_CopilotBinding` solution be handled?

### 3.1 Codex #1 Answer (delivered 2026-05-22 17:36:06 BRT)

**Verdict:** Option (d) — staged cleanup, NOT immediate AQ07 mutation.

After a corrected Option A package imports + publishes successfully, run read-only dependency and solutioncomponent inventory for `PMO_AQ07_CopilotBinding`. If AQ07 contains no unique live dependencies after PM0 ownership moves to `PMO_v11_Tarefas`, delete the entire AQ07 transition solution using `pac solution delete` under a separate owner approval. If AQ07 still owns unique non-PM0 dependencies, do not delete it; remove/retire only PM0 duplicates through a documented supported method.

Microsoft Learn citations (Codex #1):
- `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` — duplicate-unmanaged-component anti-pattern + dependency rules.
- `https://learn.microsoft.com/en-us/troubleshoot/power-platform/dataverse/working-with-solutions/missing-dependency-on-solution-import` — dependencies must exist in target environment.
- `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` — `pac solution delete` documented; `pac solution add-solution-component` documented; **no `pac solution remove-solution-component` documented**.

Risk if not followed: deleting/modifying AQ07 before corrected PMO_v11 import could remove the only tenant-held PM0 workflowset mappings; leaving AQ07 untouched through SHIP retains documented duplicate-unmanaged-component anti-pattern.

### 3.2 Kiro Answer (delivered 2026-05-22 17:51:52 BRT)

**Verdict:** Concur with Codex #1's Option (d) staged cleanup. Add a methodological caveat about which CLI verbs are actually supported.

#### 3.2.1 Findings

I independently retrieved the current `pac solution` reference page (URL below, accessed 2026-05-22 17:50:00 BRT) and enumerated the documented commands. The full list is:

`add-license`, `add-reference`, `add-solution-component`, `check`, `clone`, `create-settings`, `delete`, `export`, `import`, `init`, `list`, `online-version`, `pack`, `publish`, `sync`, `unpack`, `upgrade`, `version`.

There is **no documented `pac solution remove-solution-component`** verb. This means Codex #1's earlier discussion of cleanup option (b) — "Remove PM0 components from `PMO_AQ07_CopilotBinding` via `pac solution remove-solution-component`" — is not directly executable via current `pac solution` CLI. Cleanup paths that remain valid are:

1. **Full solution delete** — `pac solution delete --solution-name PMO_AQ07_CopilotBinding` (documented). This deletes the AQ07 solution wrapper from Dataverse but does not delete the underlying components if they are also referenced by another solution; component lifecycle is determined by other solution membership.
2. **Maker portal / Power Platform admin center component removal** — supported via UI but not via the documented `pac solution` CLI verbs.
3. **Web API / Dataverse SDK** — `RemoveSolutionComponent` action exists in the Dataverse Web API surface (separate from the PAC CLI). This is technically supported but requires a different tool path than `pac solution`.

#### 3.2.2 Microsoft Learn citation table (Kiro)

| Claim | Citation | Accessed |
|---|---|---|
| `pac solution` CLI verb inventory does not include a `remove-solution-component` command. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` (full command table at top of page) | 2026-05-22 17:50:00 BRT |
| `pac solution delete` deletes a solution from Dataverse in the current environment, taking `--solution-name` as required parameter. | Same URL, "pac solution delete" section. | 2026-05-22 17:50:00 BRT |
| Microsoft Learn explicitly warns: "Don't include the same unmanaged component in more than one solution." | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` (Note block under "Multiple solutions in the same development environment") | 2026-05-22 17:50:00 BRT |
| Microsoft Learn warns dependencies between solutions can cause cross-solution import-order issues and silent flow failure. | Same URL, same Note block: "Avoid creating dependencies between solutions. Dependencies enforce an import order and can cause issues." | 2026-05-22 17:50:00 BRT |

#### 3.2.3 Recommendation (Kiro)

Adopt Codex #1's Option (d) with the following operational refinement:

1. After 3.16 import + publish + runtime smoke PASS, run read-only inventory of AQ07's `solutioncomponent` rows to enumerate every dependency.
2. If AQ07 contains zero unique live dependencies → execute `pac solution delete --solution-name PMO_AQ07_CopilotBinding --environment <env-id>` under separate owner approval (Gate 4C).
3. If AQ07 still owns unique non-PM0 dependencies → do NOT attempt CLI-level component removal via `pac solution remove-solution-component` (verb does not exist). Use either (a) maker portal UI under a documented runbook, or (b) Web API `RemoveSolutionComponent` from a documented script. Either path requires its own evidence triplet and owner approval (Gate 4C-alt).
4. Do NOT touch AQ07 BEFORE the corrected 3.16 import — current export evidence shows AQ07 holds the only observed copy of PM0 workflowset mappings.

#### 3.2.4 Risk if not followed (Kiro)

Same as Codex #1, plus:

1. **Hallucinated CLI command (MEDIUM):** if any future agent assumes `pac solution remove-solution-component` exists and tries to script it, the script will fail with an "unknown command" error and may corrupt the runbook. The risk is documentation drift, not data loss, but it slows down cleanup by an extra approval cycle.

#### 3.2.5 Open dependencies on Codex #2

- Pre-Gate-4C: Codex #2 (or Codex #1) must run `pac solution list` + FetchXML against `solutioncomponent` for AQ07 to enumerate its current component count and which components are unique to AQ07 vs. shared with PMO_v11_Tarefas. Output goes under `.planning/comms/codex_pm0_remediation_20260522/<agent>/aq07_inventory/`.

### 3.3 Codex #2 Answer (delivered 2026-05-22 18:06:23 BRT)

**Verdict:** Concur with staged cleanup. Do not mutate AQ07 before corrected import/publish/runtime proof and read-only component inventory.

#### 3.3.1 Findings

The current PAC solution reference command table documents `add-solution-component`, `delete`, `import`, `list`, `pack`, `publish`, and the other listed verbs; it does not document `pac solution remove-solution-component`. Dataverse does document a separate `RemoveSolutionComponent` Web API action with `SolutionComponent`, `ComponentType`, and `SolutionUniqueName` parameters. Copilot Studio also warns that directly removing unmanaged agent components from a solution can make export/import fail if the agent itself is not handled consistently.

No Codex #2 tenant inventory was executed in this turn. Tenant write authorization is absent, and the current work here was local package patching plus documentation.

#### 3.3.2 Microsoft Learn citation table

| Claim | Citation | Accessed |
|---|---|---|
| The documented `pac solution` command list includes `pac solution delete` and `pac solution add-solution-component`; it does not list a removal verb. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` (command table) | 2026-05-22 18:06:23 BRT |
| Dataverse `RemoveSolutionComponent` "Removes a component from an unmanaged solution" and requires `SolutionComponent`, `ComponentType`, and `SolutionUniqueName`. | `https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/reference/removesolutioncomponent` | 2026-05-22 18:06:23 BRT |
| Microsoft says "Don't include the same unmanaged component in more than one solution." | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | 2026-05-22 18:06:23 BRT |
| Copilot Studio warns not to remove unmanaged agent components directly unless the agent is removed consistently. | `https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export` | 2026-05-22 18:06:23 BRT |

#### 3.3.3 Recommendation

Keep Option (d). After Gate 4A import, Gate 4B publish, and runtime PASS, inventory AQ07 read-only. If AQ07 is only a transition wrapper after PM0 ownership moves, request a separate cleanup approval for documented solution deletion. If selective cleanup remains necessary, draft a dedicated UI or Web API runbook first; do not invent an unavailable PAC CLI command.

#### 3.3.4 Risk if not followed

Early AQ07 cleanup can remove the only currently observed exported PM0 binding copy before the corrected PMO package is proven live. A selective cleanup that ignores the Copilot Studio warning can also break a later agent export/import path.

#### 3.3.5 Open dependencies

- Read-only AQ07 `solutioncomponent` inventory and dependency comparison against `PMO_v11_Tarefas`.
- Owner choice of full-solution retirement versus a separately reviewed selective cleanup runbook.

---

## 4. Question 3 — What read-only preflight is still needed before Gate 4 ASK?

### 4.1 Codex #1 Answer (delivered 2026-05-22 17:36:06 BRT)

Six read-only commands required before Gate 4 ASK:

1. `pac solution list --environment <env-id>` — capture current versions/IDs for `PMO_v11_Tarefas` and `PMO_AQ07_CopilotBinding`.
2. `pac env fetch --environment <env-id> --xmlFile <solutioncomponent_fetch.xml>` — `solutioncomponent` rows for both solution IDs and component types relevant to PM0 workflows + botcomponents.
3. `pac env fetch --environment <env-id> --xmlFile <workflowset_fetch.xml>` — current PM0 workflowset rows.
4. `pac copilot list --environment <env-id>` — capture `Assistente PMO V2` publish state before import.
5. AQ-08 structural verifier rerun against current tenant state — confirm baseline routing.
6. Corrected package preflight (rerun strict consistency on patched ZIP).

Microsoft Learn citations (Codex #1):
- `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` — `pac solution list`.
- `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/env` — `pac env fetch`.
- `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` — `pac copilot list`.
- `https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/solutioncomponent#componenttype-choicesoptions` — solutioncomponent componenttype reference.

### 4.2 Kiro Answer (delivered 2026-05-22 17:51:52 BRT)

**Verdict:** Concur with Codex #1's 6 commands. Add **2 forensic-baseline items** so post-import drift can be reconstructed without re-running the import.

#### 4.2.1 Findings — gap in Codex #1's preflight list

Codex #1's list captures structural state but does not capture runtime baseline. If the import lands and runtime evidence later disagrees with expectations, the team will be unable to compare pre-import vs post-import without re-importing. Two cheap pre-import captures eliminate this:

a. **Pre-import `processsession` snapshot** for the 5 PM0 workflows. This is the Dataverse table that records workflow execution history. Capturing the latest N rows for each PM0 workflow ID before import gives forensic comparison rows after import.

b. **Pre-import Copilot Studio UI screenshot** of `Assistente PMO V2` publish state. CLI output from `pac copilot list` is necessary but not sufficient under the Evidence Triplet Rule — the rule requires a screenshot for any UI surface that exists. Copilot Studio is a UI surface.

#### 4.2.2 Microsoft Learn citation table (Kiro)

| Claim | Citation | Accessed |
|---|---|---|
| `processsession` is a Dataverse entity that stores process execution history. | `https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/processsession` | 2026-05-22 17:50:00 BRT (referenced; URL is the canonical Dataverse entity reference page, exact path may vary by SDK release) |
| `pac copilot list` lists copilots in the target Dataverse environment. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` | 2026-05-22 17:50:00 BRT (cited by Codex #1 17:36 BRT, reusing same authoritative URL) |
| Evidence Triplet Rule (project policy, not MS Learn) requires screenshot for UI surfaces. | `.planning/GOLDEN_RULES.md` "Evidence Triplet Rule (MANDATORY)" | read 2026-05-22 17:50:00 BRT |

#### 4.2.3 Recommendation (Kiro)

Run Codex #1's six commands AND additionally:

7. **Snapshot baseline `processsession` rows** for the 5 PM0 workflow IDs via `pac env fetch` with a FetchXML query against `processsession` filtered by `regardingobjectid` IN (5 workflow GUIDs). Save under `.planning/comms/codex_pm0_remediation_20260522/<agent>/preflight_runtime_baseline/<flow>_processsession_pre_import_<timestamp>.{json,png}`.
8. **Capture pre-import Copilot Studio UI screenshot** of `Assistente PMO V2` showing publish state, version, and PM0 topic list. Save under same evidence folder. This satisfies Evidence Triplet for the bot-side baseline.

#### 4.2.4 Risk if not followed (Kiro)

If preflight is structural-only and import lands with a regression, the team has no forensic baseline to compare runtime drift against. The cost of capturing baselines is ~5 minutes total; the cost of re-creating a runtime baseline post-incident is hours of tenant work and may be impossible if the regression masks the prior state.

#### 4.2.5 Open dependencies on Codex #2

- Codex #2 (or whichever agent runs Gate 4 preflight) executes items 1-8 above and attaches Evidence Triplet for each.

### 4.3 Codex #2 Answer (delivered 2026-05-22 18:06:23 BRT)

**Verdict:** Use Codex #1's six structural checks and add Kiro's two forensic captures, with one filter caveat for the process-session FetchXML.

#### 4.3.1 Findings

Minimum preflight before a Gate 4A ASK:

1. `pac solution list --environment <env-id>`.
2. `pac env fetch --environment <env-id> --xmlFile <solutioncomponent_fetch.xml>` for both target solution IDs and relevant component types.
3. `pac env fetch --environment <env-id> --xmlFile <workflowset_fetch.xml>` for the PM0 action/workflow binding rows.
4. `pac copilot list --environment <env-id>` for current Copilot component state.
5. Current AQ-08 structural verifier rerun.
6. Corrected package strict check using SHA `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`.
7. A read-only `processsession` baseline capture for recent PM0-related execution history if the FetchXML filter is validated against the documented Process Session columns in the tenant.
8. A pre-import Copilot Studio UI screenshot of `Assistente PMO V2` publish state and relevant PM0 surface.

I include item 7 because Microsoft exposes Process Session as a Dataverse table with readable `processid` and `regardingobjectid` attributes. I do not yet assert Kiro's proposed `regardingobjectid IN <workflow GUIDs>` filter as proven for these PM0 rows; the FetchXML should be validated read-only before it is used as forensic evidence.

#### 4.3.2 Microsoft Learn citation table

| Claim | Citation | Accessed |
|---|---|---|
| `pac env fetch` performs a FetchXML query against Dataverse and accepts `--xmlFile`. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/env` | 2026-05-22 18:06:23 BRT |
| `pac solution list` is the documented solution listing verb; `SolutionComponent` exposes `solutionid`, `objectid`, and `componenttype`, including Workflow component type `29`. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution`; `https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/solutioncomponent` | 2026-05-22 18:06:23 BRT |
| `pac copilot list` lists copilots in the current or target Dataverse environment. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` | 2026-05-22 18:06:23 BRT |
| Process Session has logical name `processsession` and readable `ProcessId` and `RegardingObjectId` columns. | `https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/processsession` | 2026-05-22 18:06:23 BRT |

#### 4.3.3 Recommendation

Capture all eight artifacts before import approval. Store each read-only output with timestamped evidence; keep the process-session query draft and result together so later reviewers can see exactly which identifier filter was used.

#### 4.3.4 Risk if not followed

Without the structural inventory, the team cannot prove what the import is about to change. Without a forensic baseline, a post-import runtime discrepancy becomes materially harder to compare against the prior tenant state.

#### 4.3.5 Open dependencies

- Read-only tenant access for the eight preflight captures.
- Validated FetchXML for workflowset and process-session rows.

---

## 5. Question 4 — Gate 4 ASK shape (single approval vs split approvals)

### 5.1 Codex #1 Answer (delivered 2026-05-22 17:36:06 BRT)

**Verdict:** Split into 3 separate approvals.

- Gate 4A — import approval: exact package path, SHA256, environment ID, exact `pac solution import` command. If `--publish-changes` is included, the approval text must explicitly say the import will publish Dataverse customizations after successful import.
- Gate 4B — Copilot publish approval: exact `pac copilot publish --bot <bot-id-or-schema> --environment <env-id>`. Issued AFTER import read-back confirms the corrected PM0 components landed.
- Gate 4C — AQ07 cleanup approval: separate later approval after read-only dependency inventory and 3.16 runtime proof.

Microsoft Learn citations (Codex #1):
- `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` — `pac solution import`, `--publish-changes` semantics.
- `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` — `pac copilot publish`.
- Project policy: `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` — explicit owner approval per tenant write.

### 5.2 Kiro Answer (delivered 2026-05-22 17:51:52 BRT)

**Verdict:** Concur split. Add a fourth gate to enforce Functional DoD Rule.

#### 5.2.1 Findings

The Functional Definition of Done Rule (Golden Rules §"Functional Definition of Done Rule") states: "A flow is DONE only when [...] a real runtime call to the flow returns real data from the backend [...] The bot end-to-end test [...] reproduces the same successful outcome and the bot-rendered response contains the real backend data."

Codex #1's split (4A/4B/4C) covers the tenant-write authorizations but does not isolate the runtime-smoke decision as its own gate. If Gate 4B publish succeeds and runtime smoke later fails, there is no separate point where the team formally records "we tried, runtime is not DONE." A 4D gate makes that explicit.

#### 5.2.2 Microsoft Learn / project policy citation table (Kiro)

| Claim | Citation | Accessed |
|---|---|---|
| `pac solution import` accepts `--publish-changes` switch to publish customizations after import. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` (pac solution import section) | 2026-05-22 17:50:00 BRT |
| `pac copilot publish` is the documented PAC CLI verb to publish a custom copilot, requiring `--bot`. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` (cited 2026-05-22 17:36 BRT by Codex #1; same URL reused) | 2026-05-22 17:50:00 BRT |
| Functional DoD: structural verifier PASS without runtime evidence is not DONE. | `.planning/GOLDEN_RULES.md` "Functional Definition of Done Rule (MANDATORY)" | read 2026-05-22 17:50:00 BRT |
| Evidence Triplet required for any "DONE/PUBLISH wording in any project doc". | `.planning/GOLDEN_RULES.md` "Evidence Triplet Rule" | read 2026-05-22 17:50:00 BRT |

#### 5.2.3 Recommendation (Kiro)

Adopt 4-gate split:

- **Gate 4A** — `pac solution import` of patched `PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` with explicit naming of `--publish-changes` if used.
- **Gate 4B** — `pac copilot publish --bot 'Assistente PMO V2' --environment <env-id>`.
- **Gate 4C-runtime** — runtime smoke execution against AQ-09 Section A 5/5 (CriarTarefa, AtualizarStatus, AtualizarTarefa, ListarTarefas, ResumoExecutivoPortfolio). Requires Evidence Triplet for each flow. This is a DECISION GATE: PASS → 3.16 SHIP-READY for runtime; FAIL → record `STRUCTURAL_PASS_ONLY` per Golden Rules and trigger rollback runbook.
- **Gate 4D-cleanup** — AQ07 cleanup (formerly 4C in Codex #1's split). Only if 4C-runtime PASS.

#### 5.2.4 Risk if not followed (Kiro)

If Gate 4C-runtime is folded into Gate 4B publish approval, the team risks declaring DONE on structural success alone — which the Golden Rules explicitly prohibit ("structural verification alone is NOT sufficient to declare any Power Automate flow [...] DONE"). Splitting this out enforces the existing project rule.

#### 5.2.5 Open dependencies on Codex #2

- Codex #2 to confirm whether the runtime smoke harness (AQ-09 Section A) is currently runnable against the rebuilt package shape, or if smoke harness needs pre-flight changes for the new component IDs.

### 5.3 Codex #2 Answer (delivered 2026-05-22 18:06:23 BRT)

**Verdict:** Four gates. Codex #2 concurs with Kiro that runtime smoke must remain a separate decision point before cleanup.

#### 5.3.1 Findings

Microsoft documents solution import and Copilot publish as distinct operations. Project policy separately requires runtime evidence before DONE/PUBLISH claims for flows, so import success and publish success do not close the runtime question. I did not run AQ-09 Section A in this turn and therefore do not claim the smoke harness needs no change; the repaired package keeps the same five PM0 workflow IDs and action schema names, but harness readiness must be checked during the read-only/pre-smoke preparation.

#### 5.3.2 Microsoft Learn / project policy citation table

| Claim | Citation | Accessed |
|---|---|---|
| `pac solution import` imports into Dataverse and can publish changes after successful import only when `--publish-changes` is used. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` | 2026-05-22 18:06:23 BRT |
| `pac copilot publish` publishes a custom Copilot and requires `--bot`. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` | 2026-05-22 18:06:23 BRT |
| Functional DoD and human approval gates require runtime proof and explicit tenant-write approval. | `.planning/GOLDEN_RULES.md`; `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` | read 2026-05-22 18:06:23 BRT |

#### 5.3.3 Recommendation

Use four explicit decisions:

- Gate 4A import: corrected package path, SHA, environment, exact import command, and explicit `--publish-changes` disclosure if used.
- Gate 4B publish: exact Copilot publish command after import read-back.
- Gate 4C runtime: approved AQ-09 Section A smoke and backend read-back with Evidence Triplets for all five PM0 flows.
- Gate 4D cleanup: AQ07 inventory result plus owner-approved cleanup command or runbook.

#### 5.3.4 Risk if not followed

Folding runtime into publish makes it too easy to call structural deployment success functional completion. That conflicts with the Golden Rules and leaves AQ07 cleanup exposed to a runtime failure discovered too late.

#### 5.3.5 Open dependencies

- AQ-09 smoke harness readiness check against the corrected package candidate and selected tenant test data.
- Owner decisions for each tenant-write or runtime-write step.

---

## 6. Question 5 — Single best next action (next 60 minutes)

### 6.1 Codex #1 Answer (delivered 2026-05-22 17:36:06 BRT)

Do not proceed to Gate 4. Keep Option A. Treat Codex #2's current package as a failed candidate until it includes the 5 PM0 workflowset mappings and matches or explains current Alpha workflow JSON diffs. Run read-only investigations now (tenant solution list, solutioncomponent FetchXML, workflowset FetchXML, copilot list, AQ-08 verifier, corrected package strict check). Use 2 separate owner approvals (import, then publish), with AQ07 cleanup as a third later approval. AQ07 cleanup happens AFTER corrected import + publish + runtime proof, not before. Critical risk: imported package may still leave PM0 actions without packaged workflowset mappings, preserving the AQ-09 A1 failure mode.

### 6.2 Kiro Answer (delivered 2026-05-22 17:51:52 BRT)

**Verdict:** Concur block. Add forensic-baseline precondition.

#### 6.2.1 Single best next action (Kiro)

For the next 60 minutes:

1. **Codex #2 patches the package** to include the 5 PM0 workflowset mappings AND produces a per-flow canonical JSON diff (5 docs) with every diverging field classified as `INTENTIONAL_PACKAGER`, `INTENTIONAL_FIX`, or `UNEXPLAINED`. Zero `UNEXPLAINED` entries permitted.
2. **In parallel, any agent with read-only tenant access** runs Codex #1's 6 preflight commands AND Kiro's items 7-8 (`processsession` snapshot + Copilot Studio UI screenshot). Output goes to `<agent>/preflight_runtime_baseline/`.
3. **No Gate 4 ASK is issued** until both items 1 and 2 above produce green Evidence Triplets.
4. **When Gate 4 is finally issued**, it is split per Kiro §5.2.3: 4A (import), 4B (publish), 4C-runtime (smoke), 4D-cleanup (AQ07).

#### 6.2.2 Microsoft Learn citation table (Kiro)

| Claim | Citation | Accessed |
|---|---|---|
| Solution import + publish are independent operations exposed via `pac solution import` (with optional `--publish-changes`) and `pac solution publish` (publishes all customizations). | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` (sections "pac solution import" and "pac solution publish") | 2026-05-22 17:50:00 BRT |
| Microsoft Learn duplicate-component anti-pattern. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | 2026-05-22 17:50:00 BRT |
| Functional DoD requires runtime call returning real backend data, not placeholder. | `.planning/GOLDEN_RULES.md` "Functional Definition of Done Rule" | read 2026-05-22 17:50:00 BRT |

#### 6.2.3 Risk if not followed (Kiro)

Critical risk added on top of Codex #1's:

- **Forensic gap (HIGH):** importing without pre-import `processsession` baseline + Copilot Studio UI screenshot leaves the team unable to reconstruct pre-import runtime state if a regression appears. The Functional DoD Rule says structural success ≠ DONE; without baseline, even a successful runtime smoke can be challenged later because there is no captured "before" state.

#### 6.2.4 Open dependencies on Codex #2

- Patched package (per §2.2.3 and §6.2.1 item 1).
- Per-flow canonical JSON diff docs.
- Confirmation that AQ-09 Section A smoke harness is runnable against patched package.

### 6.3 Codex #2 Answer (delivered 2026-05-22 18:06:23 BRT)

**Verdict:** The local package repair work is complete for this pass. The best next 60 minutes are read-only tenant baseline work, not Gate 4A execution.

#### 6.3.1 Findings

The corrected candidate now contains the five PM0 action-to-workflow mappings and the per-flow diff reports show zero unexplained canonical leaf differences. That removes the local Q1 blocker raised against the old SHA. It does not replace current tenant evidence: solution membership, current workflowset rows, Copilot state, dependencies, and runtime baseline are still outside the rebuilt ZIP.

#### 6.3.2 Microsoft Learn citation table

| Claim | Citation | Accessed |
|---|---|---|
| Microsoft separates solution listing/import/publish operations in the PAC solution command group. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` | 2026-05-22 18:06:23 BRT |
| `pac env fetch` is the documented read path for FetchXML against Dataverse. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/env` | 2026-05-22 18:06:23 BRT |
| `pac copilot list` reads Copilot rows in the target Dataverse environment. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` | 2026-05-22 18:06:23 BRT |
| Microsoft warns against including the same unmanaged component in more than one solution. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | 2026-05-22 18:06:23 BRT |

#### 6.3.3 Recommendation

For the next 60 minutes:

1. Keep Gate 4 blocked for execution.
2. Run the eight read-only preflight captures from §4.3 and store the Evidence Triplets.
3. Draft Gate 4A text only after that read-back cites the corrected SHA `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`.
4. Preserve Kiro's forensic-baseline precondition. The exact process-session FetchXML filter remains subject to read-only validation as stated in §4.3.

#### 6.3.4 Risk if not followed

If the owner approves immediately against the old package SHA, PM0 workflowset binding evidence is wrong. If approval moves against the new SHA without tenant baseline, the team still cannot quantify duplicate-solution and pre/post runtime drift risk before a write.

#### 6.3.5 Open dependencies

- Owner or authorized read-only agent to capture the tenant preflight set.
- AQ-09 harness readiness check before requesting the runtime gate.
- No further Codex #1 or Kiro package artifact is required for the local Q1 correction.

---

## 7. Convergence / Divergence Map

| Question | Codex #1 vs Kiro | Codex #2 status |
|---|---|---|
| Q1 (package consistency) | Convergent on old SHA NOT-Gate-4-ready. Kiro adds canonical-diff per-field reason requirement. | Patched local candidate clears workflowset and diff-audit blockers for new SHA; tenant preflight still open. |
| Q2 (AQ07 cleanup) | Convergent on staged Option (d). Kiro flags `pac solution remove-solution-component` does not exist, refining executable paths. | Convergent. Dataverse Web API removal exists separately; do inventory before any cleanup. |
| Q3 (preflight) | Convergent on Codex #1's 6 commands. Kiro adds 2 forensic-baseline items (processsession snapshot + Copilot Studio UI screenshot). | Convergent on 8 captures; Codex #2 requires process-session filter validation before asserting workflow-ID linkage. |
| Q4 (Gate 4 shape) | **RESOLVED by owner 2026-05-22 18:50 BRT:** Codex #1's 3-gate split controls: 4A import, 4B publish, 4C AQ07 cleanup. Runtime smoke remains mandatory post-publish QA evidence, not a separate owner approval gate. | Updated to owner-ratified 3-gate split for Gate 4A ASK generation. |
| Q5 (next 60 min) | Convergent on block + preflight + patch package. Kiro adds forensic-baseline precondition. | Package patch is complete locally; next block is read-only tenant baseline and Gate 4A draft against new SHA. |

**Divergences requiring owner adjudication:**
- Q4: RESOLVED by owner adjudication 2026-05-22 18:50 BRT. Use 3 gates (4A import, 4B publish, 4C AQ07 cleanup). Runtime smoke remains required QA evidence after publish.
- Q3: Codex #2 accepts process-session baseline capture but requires the read-only FetchXML filter to be validated before relying on Kiro's suggested workflow-ID filter.

---

## 8. Methodology Compliance Check (this document itself)

| Golden Rule | Status |
|---|---|
| Official Microsoft Docs Rule (every product-behavior claim cites learn.microsoft.com) | PASS — all three agent columns carry MS Learn URL + accessed timestamp BRT for product-behavior claims. |
| Evidence Triplet Rule (screenshot + timestamp BRT + agent name) | PASS for local package checks cited here — Codex #1 carries its strict-check triplet and Codex #2 carries `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/evidence/20260522_180600_Codex2_package_consistency_strict.{md,png}`. Tenant preflight and runtime triplets remain future artifacts. |
| Continuous Documentation Update Rule | PASS — the backfill refreshed this file header and is logged in `INVESTIGATION_LOG.md` and `DOC_UPDATES_LOG.md`. |
| Functional DoD Rule | OBSERVED — Kiro and Codex #2 keep runtime smoke as a separate Gate 4 decision. |
| Placeholder Backfill Rule | PASS — Codex #2 placeholders in this document are backfilled. See §9. |
| Human Approval Gate | PASS — no tenant write proposed; only read-only analysis and document creation. |
| Agent Budget Gate | PASS — backfill completed by Codex #2 in the existing Codex #2 lane. |

---

## 9. Codex #2 Backfill Manifest

This section records the Codex #2 placeholder backfill completion. Per the Placeholder Backfill Rule, the agent producing the upstream deliverable is responsible for backfilling within 10 minutes of the deliverable landing.

| Backfill item | Section | Completion evidence | Status | Responsible agent |
|---|---|---|---|---|
| Q1 self-assessment | §2.3 | Corrected SHA + strict-consistency triplet + five diff docs under `CODEX2/PACKAGE/`. | COMPLETE | Codex #2 |
| Q2 AQ07 stance | §3.3 | Independent PAC/Web API/Copilot Studio Learn validation in §3.3. | COMPLETE | Codex #2 |
| Q3 preflight stance | §4.3 | Independent `env`, `solution`, `copilot`, and `processsession` Learn validation in §4.3. | COMPLETE | Codex #2 |
| Q4 Gate 4 shape | §5.3 | Independent import/publish Learn validation plus Golden Rules read in §5.3. | COMPLETE | Codex #2 |
| Q5 next-60-minutes plan | §6.3 | Self-consistent follow-on from §2.3-§5.3. | COMPLETE | Codex #2 |

Acceptance gate for Codex #2 column: zero unresolved backfill-placeholder-prefix matches in this document after Codex #2 finishes.

---

## 10. Action — How Codex #2 fills its column

Codex #2 edited THIS file so all three columns coexist in one place. Each of the 5 Codex #2 sections (§2.3, §3.3, §4.3, §5.3, §6.3) now uses the same answer shape Codex #1 and Kiro used:

1. `### N.3 Codex #2 Answer (delivered <YYYY-MM-DD HH:mm:ss BRT>)`
2. `**Verdict:** ...`
3. `#### N.3.1 Findings` (with Evidence Triplet path if local verification was performed)
4. `#### N.3.2 Microsoft Learn citation table` (independent URLs + accessed timestamps)
5. `#### N.3.3 Recommendation`
6. `#### N.3.4 Risk if not followed`
7. `#### N.3.5 Open dependencies` (what Codex #2 needs from Codex #1, Kiro, or Owner)

After all 5 sections are filled:

- Update §1 Summary Table column "Codex #2 Recommendation" with one-liner per row.
- Update §7 Convergence / Divergence Map with Codex #2 position vs Codex #1 vs Kiro.
- Update §8 Methodology Compliance Check Evidence Triplet row to include Codex #2 evidence.
- Refresh the document `Last updated:` line at top.
- Log the update in `INVESTIGATION_LOG.md` and `DOC_UPDATES_LOG.md` per Continuous Documentation Update Rule.

No tenant write is authorized in this turn for Codex #2. Read-only and local-package-patching only.

---

## END OF DOCUMENT

Pending column: Codex #2. Once filled and divergences (if any) are surfaced in §7, Owner adjudicates and converts the consolidated answers into the Gate 4 ASK shape (whether 3 or 4 gates).
