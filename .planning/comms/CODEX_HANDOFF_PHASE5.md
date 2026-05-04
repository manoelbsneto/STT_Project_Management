# CODEX Handoff — Phase 5: Teams Integration via Browser

Copy/paste to Opus 4.6:

```text
You are OPUS-EXEC for PMO Intelligent Hub MVP.

Task: Complete Phase 5 — Teams Integration by adding 3 SharePoint tabs to the Teams channel via browser.

Context:
- G0 PASSED. G1 PASSED. G2 CONDITIONAL. G3 PASSED. G4 PASSED.
- Phase 5 is BLOCKED on Graph API auth (device-code timeout). Browser-based execution is approved.
- All SharePoint views exist and are verified.
- The user is logged in and available for any MFA prompts.

Detailed step-by-step guide: deploy/PHASE5_TEAMS_TABS_BROWSER_GUIDE.md

---

SUMMARY OF TASKS:

1. Open https://teams.microsoft.com in browser
2. Navigate to channel "Projetos_Tranformação_Digital"
3. Add 3 SharePoint tabs using the + button:

   Tab 1: "Portfólio Executivo"
   → SharePoint list: Projetos → View: Board RAG
   → URL: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos/Board%20RAG.aspx

   Tab 2: "Projetos Críticos"
   → SharePoint list: Projetos → View: Projetos Críticos
   → URL: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos/Projetos%20Crticos1.aspx

   Tab 3: "Decisões Pendentes"
   → SharePoint list: Decisoes do Board → View: Pendentes
   → URL: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Decisoes%20do%20Board/Pendentes.aspx

4. Take screenshot evidence of each tab showing data loaded in Teams
5. Save screenshots to .planning/comms/ as:
   - g5_tab_portfolio_executivo.png
   - g5_tab_projetos_criticos.png
   - g5_tab_decisoes_pendentes.png

6. Update project controls:
   - GATE_STATUS.md → G5 PASSED
   - ROADMAP.md → Phase 5 ✅ DONE
   - STATE.md → current phase = Phase 6
   - Create OPUS_HANDOFF_G5.md

Environment:
- Teams Group ID: 96c5b0c4-46cc-46cd-8695-50451db74994
- Channel: Projetos_Tranformação_Digital
- Tenant: 7808e005-1489-4374-954b-d3b08f193920
- SP Site: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
- Power Platform env: ColOfertasBrasilPro (e2d10003-4d8e-e007-9d63-76d5fe89ef56)

IMPORTANT:
- Use browser only (no CLI/API needed)
- If any auth popup appears, complete MFA immediately
- Each tab should take under 60 seconds to add
- Verify each tab loads data before moving to the next
```
