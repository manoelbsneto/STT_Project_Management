# Mitigation Plan - PM0 Card-First Incident

Last updated: 2026-05-22 15:32 BRT | Codex #1 | Owner decision matrix and containment plan written.

## Current Containment State

The PM0 card-first lane is STOP-SHIP. Codex #1 performed no tenant write. Bravo read-only evidence shows the PM0 workflow bindings are active in `ColOfertasBrasilPro`, the bot is published/synchronized, and local/live audited workflow clientdata is semantically aligned for the five PM0 flows.

## Containment Options

| Option | Action | Time estimate | Risk | Reversibility | Dependencies |
|---|---|---:|---|---|---|
| ROLLBACK | Return live path to the documented 3.10 baseline and verify M1 behavior. | About 15-60 min after approval and operator readiness | Reintroduces M1 scope; M2 card-first improvements unavailable | High if import/re-publish path succeeds and evidence saved | Owner approval; rollback package; authenticated operator; import/publish evidence |
| FIX-AND-SHIP | Keep PM0 active but block release until all response, input, and runtime gates pass. | Engineering estimate remains 20-30h until re-estimated from implementation detail | Broken PM0 exposure remains if users reach it before fix | Medium | Owner accepts wait; implementation and test lane |
| HYBRID | Contain PM0 routes now by rollback or topic disable, keep local PM0 remediation in progress, re-ship only after runtime gates. | Containment same day plus remediation sprint | Two operating states to track | High for containment; medium for future re-ship | Owner chooses emergency switch; clear comms; approved write path |

## Recommended Path

Recommend `HYBRID` with immediate owner-approved containment of the broken PM0 user path, preferring rollback to the documented 3.10 baseline when the owner needs a working live tenant now. Alpha and Bravo show this is not a single stale audit row: the audited PM0 release scope has zero `REAL` workflows, missing input propagation on four required paths, and a runtime A1 failure already observed. Structural drift evidence says the broken audited PM0 definitions are not merely a local-only mismatch.

## Live Tenant Emergency Switches

Any item in this section is a tenant write and requires explicit owner approval in the active thread first.

| Switch | Use when | Evidence after action |
|---|---|---|
| Import/publish rollback package | Owner wants known M1 path restored. | Import output, bot publish/sync output, AQ-09 rollback smoke. |
| Disable affected PM0 topic/action exposure | Rollback is delayed but PM0 routes must stop reaching broken path. | Topic/action inventory diff, runtime negative/legacy route proof. |
| Feature-flag via route gating if an existing approved switch exists | Existing project switch can keep PM0 hidden without broad rollback. | Switch state, route evidence, smoke transcript. |
| No write, user comms only | Owner accepts temporary exposure while remediation is prepared. | User notice, NO-SHIP status, monitoring cadence. |

## User Communication Plan

1. Notify active PMO testers/users that PM0 card-first task flow results are under stop-ship after a runtime failure on 2026-05-22.
2. State whether the live path is rollback, temporarily disabled, or under observation.
3. Avoid saying routing PASS means task-flow function PASS.
4. Provide the next evidence checkpoint: containment proof first, then remediation runtime proof.

## Monitoring Controls Until Remediation

| Control | Cadence | Evidence |
|---|---|---|
| FlowRun status watch for PM0 flow IDs | Each containment/remediation test window | Dataverse/PAC read output with run time, workflow, status, errors where available |
| Bot publish/sync status | After approved publish/rollback | Bot current row output |
| AQ-08 structural route drift | Keep existing drift monitor labeled structural | Existing AQ-08 evidence folder |
| AQ-09 runtime smoke | After containment and each candidate re-ship | Transcript, run output, expected/observed result |
| Placeholder response scan | Every PM0 artifact build | `rg`/automated verifier result |

Microsoft Learn monitoring basis: flow runs, triggers, actions, status, and errors are part of the Power Automate monitoring surface: `https://learn.microsoft.com/en-us/power-automate/guidance/coding-guidelines/monitoring-and-alerting`.

## Rollback Procedure

### Prerequisites

1. Written owner approval in active thread.
2. Confirm target environment is `ColOfertasBrasilPro` / `e2d10003-4d8e-e007-9d63-76d5fe89ef56`.
3. Confirm rollback package exists:

```powershell
Get-FileHash 'Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip' -Algorithm SHA256
```

Expected SHA256:

```text
37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691
```

4. Confirm PAC authentication and environment:

```powershell
pac auth list
pac env who
```

Expected dry-run evidence is an authenticated operator on `ColOfertasBrasilPro`, not Default environment.

### Approved write command

Microsoft Learn documents `pac solution import` for Dataverse solution import. The exact package/import flags must follow project packaging evidence and operator review before execution.

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path 'Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip' --publish-changes
```

Do not run that command without owner approval. If the operator chooses a different project-approved import flag set, store the exact command and output.

### Post-rollback evidence

1. Save import output and timestamp.
2. Verify bot publish/synchronization state if publish is part of rollback.
3. Re-run structural route/binding inventory to show PM0 exposure state after rollback.
4. Run the approved M1/AQ-09 smoke path and store transcript/run evidence.
5. Update `.planning/CURRENT_BASELINE.md`, status docs, risk register, and investigation log with exact rollback result.

## Decision Matrix

| Criterion | ROLLBACK | FIX-AND-SHIP | HYBRID |
|---|---|---|---|
| Restores working path fastest | Strong | Weak | Strong if containment chosen immediately |
| Keeps M2 card-first improvements live | Weak | Strong after fix | Moderate |
| Reduces user exposure now | Strong | Weak unless separate disable used | Strong |
| Engineering effort before next functional proof | Low | High | Medium |
| Evidence burden | Rollback smoke | Full PM0 remediation suite | Containment smoke plus remediation suite |
| Recommended | Acceptable | Not recommended as sole immediate response | Recommended |

## Owner Decisions Required

1. Choose containment: `ROLLBACK`, `FIX-AND-SHIP`, or `HYBRID`.
2. If containment requires a tenant write, authorize the exact operation in-thread: rollback import, topic/action disable, or approved switch.
3. Choose whether write-path PM0 flows remain in release scope during remediation or are deferred until read-path proof is complete.
4. Approve the revised DoD and gate rule that structural AQ-08 evidence alone cannot produce functional DONE/PUBLISH wording.

