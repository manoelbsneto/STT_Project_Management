# T0_RELEASE_NOTES_ALIGNMENT_DIFF

Last updated: 2026-05-23 17:42:00 BRT | Sub G2B acting as Δ G1B | Aligned release notes versions to 3.18.

---

This document summarizes changes made to release notes (PT-BR & EN) to align them with the v3.18 re-versioning target approved by Owner.

## Changes:

1. **Solution Version Bump**:
   - Replaced all references to `3.16` with `3.18` in release headers, upgrade paths, titles, and comments.
   - Solution Version changed from `3.16.0.0` to `3.18.0.0`.
   - Upgrade package path updated to `'Solution/PMO_v11_Tarefas_3_18_PM0_FUNCTIONAL_FIX.zip'`.

2. **SHA Verification Placeholder**:
   - The previous candidate SHA256 (`3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`) has been removed as a static hash since version 3.18 will be repackaged by Codex #2.
   - Replaced with the mandatory backfill placeholder: `<<TODO_BACKFILL: sha256_rebuild_3_18 (depends on: Codex2_repackage_3_18)>>` (SHA pending 3.18 rebuild).

3. **Release Date Bump**:
   - Bumped release date to May 23, 2026 (23 de maio de 2026).
