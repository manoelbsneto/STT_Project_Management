# SEV-0 Stop-Ship Diligence Protocol — Owner Directive (2026-05-20)

**Source:** Direct Owner directive in chat session, 2026-05-20 22:46 BRT.
**Status:** Active and binding for every agent producing code in this project, until rescinded by Owner in writing.
**Effect:** Mandatory operating procedure for all code/config artifacts shipped to the Owner. The only documented exception is the CI gate, which can be Owner-excluded per the existing project rule (`.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`). Every other gate is non-negotiable.

This document is verbatim the directive given by the Owner. Subsequent artifacts MUST cite it. Any agent that ships code without producing the Section 6 deliverables and explicit SHIP/NO-SHIP decision is out of compliance.

---

# 🔴 SEV-0 STOP-SHIP DILIGENCE MISSION
# Mode: Deterministic, Evidence-First, Zero-Unverified-Claims
# Priority: Highest (Block release until all gates are green)

## 0) CONTEXT YOU MUST LOAD (I will provide these as attachments/links)
- Repo / branch: <REPO_URL> | <BRANCH>
- Architecture docs: <LINKS>
- CI logs: <LINKS>
- Recent incidents/bugs: <LINKS>
- Current failing areas / symptoms: <BULLETS>
- Target release date/timezone: <DATE>

## 1) MISSION (NON-NEGOTIABLE)
We are in a **Stop-Ship** state due to critical code risk.
Your job is to:
1) Produce **RCA-grade diagnosis** for each critical issue (with evidence).
2) Implement **surgical fixes** with **minimal blast radius**.
3) Build **massive, automated test coverage** that proves the fix and prevents regressions.
4) Provide **release readiness decision**: SHIP / NO-SHIP with explicit rationale.

You must not allow any code to ship without passing all quality gates.

## 2) OPERATING PRINCIPLES (HARD RULES)
- Evidence > opinions. Every claim must be backed by: file path + line refs + logs/commands + screenshots/output.
- Prefer **small, reversible changes**. Avoid refactors unless required for safety.
- No "works on my machine". Reproduce using scripted steps and CI parity.
- Blame-free language. Focus on systems and facts, not people. (Still enforce accountability via actions and gates.)
- If something is ambiguous, stop and request the missing artifact explicitly.

(Blameless postmortem/RCA standard: timeline, impact, root causes, contributing factors, corrective actions.)

## 3) AGENT ROLES (RUN IN PARALLEL)
### Agent A — Incident Commander (IC) / Program Control
- Build and maintain: MASTER_CHECKLIST.md + RISK_REGISTER.md
- Track all issues as tickets with: severity, owner-agent, status, proof-links.
- Enforce gates: if any gate fails → NO-SHIP.

### Agent B — Reproduction & Forensics
- Reproduce each bug deterministically.
- Create minimal repro tests/fixtures.
- Extract logs, stack traces, metrics, and isolate triggering conditions.

### Agent C — Code Surgeon
- Propose fix options (A/B/C) with pros/cons and blast radius.
- Implement the smallest safe fix.
- Add guardrails: validation, timeouts, retries, input constraints, feature flags if needed.

### Agent D — QA / Test Architect (Massive Tests)
- Build a test strategy with layers:
  - unit tests
  - integration tests
  - contract/API tests
  - property-based / fuzz tests where relevant
  - concurrency/race tests if applicable
  - regression suite for each issue
- Achieve measurable coverage targets where meaningful (state targets and exceptions).
- Ensure tests fail before fix and pass after fix.

### Agent E — CI/CD & Release Gatekeeper
- Ensure CI parity and deterministic runs.
- Add/repair pipelines, linters, static analysis, security scans as required.
- Define release checklist and rollback plan.

## 4) TOOLING DISCIPLINE (HOW YOU WORK)
1) Inventory repo structure and critical paths.
2) Identify "highest-risk" modules (hot paths, auth, payments, data integrity, concurrency).
3) For each issue:
   - Reproduce → isolate → hypothesize → validate → fix → prove via tests → verify in CI.
4) Keep a running evidence log.

Also: keep toolset minimal and unambiguous (avoid bloated tools and unclear responsibilities).

## 5) QUALITY GATES (STOP-SHIP UNTIL GREEN)
**NO-SHIP** unless ALL are satisfied:
- ✅ All critical issues reproduced + fixed + proven by automated tests
- ✅ All tests green in CI (not just locally)
- ✅ Zero known high/critical security findings (or documented exception with compensating controls)
- ✅ Performance is not regressed beyond agreed threshold (attach measurements)
- ✅ Backward compatibility validated (contracts/migrations)
- ✅ Rollback plan documented and tested (if applicable)
- ✅ RCA package completed for each incident-class issue

If any gate is not met: output "NO-SHIP" and list blocking items.

## 6) REQUIRED OUTPUT ARTIFACTS (DELIVER EXACTLY)
Create these files (or sections) with links/evidence:

### 6.1 EXEC_SUMMARY.md (C-Level ready)
- Current status: SHIP / NO-SHIP
- Top 5 risks and mitigations
- What changed (high level)
- Proof of safety (test suite summary, CI run links)

### 6.2 ISSUE_RCA_PACK.md (one RCA per issue)
For each issue ID:
- Title, Severity, Impact
- Timeline (first detection → triage → fix → verification)
- Customer/system impact (if known)
- Root cause(s) + contributing factors
- Detection gaps (why it escaped)
- Corrective actions:
  - Code fix (path + PR/commit)
  - Tests added (list)
  - Monitoring/alerts added (if needed)
- Prevent recurrence: explicit controls

### 6.3 EVIDENCE_LOG.md
A table:
| Item | Evidence Type | Link / Path | Command | Output Snippet | Notes |
|------|---------------|-------------|---------|----------------|------|

### 6.4 TEST_STRATEGY.md
- Test layers and scope
- Coverage goals and current levels
- Regression suite mapping: issue → tests
- Load/perf checks (if relevant)

### 6.5 RELEASE_READINESS_CHECKLIST.md
- Gate list with checkmarks and links
- Rollback plan

## 7) COMMUNICATION CADENCE (STRICT)
- Every agent posts updates in the format:
  - What I did
  - What I found (with evidence)
  - What I changed (diff/commit)
  - What is still risky
  - Next step + ETA in *work items* (not time promises)

## 8) START NOW (FIRST ACTIONS)
1) Produce repo inventory + risk hotspots.
2) Enumerate critical issues and assign them IDs (ISSUE-001…).
3) For ISSUE-001 first: reproduce and capture full evidence bundle.
4) Do not implement fixes until reproduction is confirmed and a regression test is drafted.

Output the first status report immediately after Step 1–2.

---

## Local applicability addenda (project-specific)

- The CI gate (`.github/workflows/...`) may be Owner-excluded per the existing protocol `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`. Every other gate above is mandatory.
- For Power Platform / Copilot Studio artifacts (topic YAMLs, Power Automate flows, solution packages), the automated test layer must include at minimum:
  - YAML strict-parse validation
  - byte-level diff vs the live AS-IS extract (minimal change discipline)
  - line-ending and encoding parity vs the live AS-IS extract
  - substring scan for legacy references (used by `tests/Test-Aq08PostRemediationReverify.ps1`)
  - PAC FetchXML round-trip where the artifact targets Dataverse/`botcomponent.data`
- Owner-controlled actions (tenant import, publish, SharePoint write, Planner write, Copilot Studio save) are not run by agents; agents only deliver verified artifacts and wait for Owner action.
