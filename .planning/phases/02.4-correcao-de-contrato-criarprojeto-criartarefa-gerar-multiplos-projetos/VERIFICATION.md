# Phase 2.4 Plan Verification

**Date:** 2026-05-11
**Verifier:** gsd-plan-checker + Codex integration
**Initial Verdict:** BLOCK
**Current Verdict:** FLAG - planning artifacts created; implementation still blocked until local tests/package exist.

## Initial Blockers From Checker

1. No formal `PLAN.md` existed for phase 2.4.
2. `CriarProjeto` and `CriarTarefa` contracts were not yet formalized.
3. `Gerar_Multiplos_Projetos` needed explicit preview/confirmation, idempotency, limits, and partial-result rules.
4. Adaptive Cards needed explicit card/schema/fallback rules.
5. PROD gates needed explicit no-import/no-publish/no-write controls.

## Resolution In This Planning Pass

- `PLAN.md` created.
- `02-04-CONTEXT.md` created.
- `02-04-RESEARCH.md` created with official Microsoft sources.
- PRD updated with REQ-14, REQ-15, REQ-16.
- Manual updated with `CriarProjeto`, `CriarTarefa`, and `Gerar_Multiplos_Projetos`.
- Requirements updated.
- Roadmap updated.
- Phase artifacts moved to the canonical GSD directory:
  `.planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos`.
- `gsd-tools init plan-phase 2.4` now detects `has_context=true`, `has_research=true`, `has_plans=true`, and `plan_count=1`.
- `PLAN.md` declares `requirements_addressed: REQ-14, REQ-15, REQ-16`.
- `.planning/SKILLS_MAP.md` maps the required project skills for Copilot Studio, Power Automate, SharePoint, Adaptive Card UX, and executive UX.

## Remaining Flags Before Execution

- Local tests still need to be created.
- Local package 2.4 still needs to be created.
- Existing old tests that require `CriarTarefa` -> `Projetos` must be replaced or split.
- `Tarefas` live schema must be confirmed read-only before final field mapping.
- Adaptive Card payload size and Teams Desktop/Mobile behavior must be checked during runtime validation after owner import/publish.
- `gsd-tools init plan-phase 2.4` currently reports `phase_req_ids=null` for the decimal phase even though `.planning/ROADMAP.md` lists REQ-14/REQ-15/REQ-16; manual coverage is declared in `PLAN.md` until the parser is adjusted or this phase is promoted to a non-decimal slot.

## Execution Gate

Implementation may proceed locally only if:

- No PROD changes are attempted.
- Tests are written before package changes where practical.
- Package is based on 2.3 baseline.
- All changes preserve `ExcluirTarefa` 2.3 project-scope guard.

## Release Gate

Release remains NO-SHIP until:

- Static gates pass on 2.4 package.
- Owner imports/publishes 2.4.
- Runtime smoke proves:
  - `CriarProjeto` creates only `Projetos`.
  - `CriarTarefa` creates only `Tarefas`.
  - `Gerar_Multiplos_Projetos` respects Adaptive Card confirmation and batch limits.
  - `ExcluirTarefa` positive deletion works against real created tasks.
