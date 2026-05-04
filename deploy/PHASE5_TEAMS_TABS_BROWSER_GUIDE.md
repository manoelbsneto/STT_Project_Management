# Phase 5 — Teams Integration: Browser Step-by-Step Guide

## Objective

Add 3 SharePoint list view tabs to the Teams channel **Projetos_Tranformação_Digital** so that the executive board and project managers can see live PMO data directly in Teams without opening SharePoint.

## Prerequisites

- [x] G1 PASSED — SharePoint lists and views exist
- [x] SharePoint views verified: `g5_sharepoint_views_20260503_142829.json`
- User must be a **member or owner** of the Teams group `Projetos_Tranformação_Digital`
- Browser: Microsoft Edge or Chrome (latest)

## Environment

| Parameter | Value |
|-----------|-------|
| Teams Group ID | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| Teams Channel | `Projetos_Tranformação_Digital` |
| Tenant ID | `7808e005-1489-4374-954b-d3b08f193920` |
| SharePoint Site | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital` |

## Tabs to Create

| # | Tab Name | Source List | Source View | SharePoint URL |
|---|----------|------------|-------------|----------------|
| 1 | Portfólio Executivo | Projetos | Board RAG | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos/Board%20RAG.aspx` |
| 2 | Projetos Críticos | Projetos | Projetos Críticos | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos/Projetos%20Crticos1.aspx` |
| 3 | Decisões Pendentes | Decisoes do Board | Pendentes | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Decisoes%20do%20Board/Pendentes.aspx` |

---

## Step-by-Step Instructions

### STEP 1 — Open Teams Web

1. Open browser and navigate to: `https://teams.microsoft.com`
2. Log in with your Microsoft 365 account (complete MFA if prompted)
3. Wait for Teams to fully load

### STEP 2 — Navigate to the Channel

1. In the left sidebar, find the team that contains the channel **Projetos_Tranformação_Digital**
2. Click on the team name to expand it
3. Click on the channel **Projetos_Tranformação_Digital**
4. You should now see the channel conversation view

### STEP 3 — Add Tab 1: "Portfólio Executivo"

1. At the top of the channel, next to existing tabs (Posts, Files, etc.), click the **+** (plus) button to add a new tab
2. In the "Add a tab" dialog, search for **SharePoint**
3. Select the **SharePoint** app (icon is the green SharePoint logo)
4. A configuration dialog will appear. You may see options like:
   - "Add an existing SharePoint page or list as a tab"
   - If prompted to select a site, choose: **Grp_T_DN_Transformacao_Digital**
5. Select the **Projetos** list
6. Select the **Board RAG** view
   - If the view picker doesn't appear, you can paste the URL directly:
     ```
     https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos/Board%20RAG.aspx
     ```
7. Set the tab name to: **Portfólio Executivo**
8. Check the option "Post to the channel about this tab" (optional, recommended)
9. Click **Save** or **Add**
10. Verify the tab appears at the top of the channel and loads the Board RAG view with projects grouped by StatusRAG (Verde/Amarelo/Vermelho)

### STEP 4 — Add Tab 2: "Projetos Críticos"

1. Click the **+** button again at the top of the channel
2. Search and select **SharePoint**
3. Select site **Grp_T_DN_Transformacao_Digital**
4. Select the **Projetos** list
5. Select the **Projetos Críticos** view
   - Direct URL if needed:
     ```
     https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos/Projetos%20Crticos1.aspx
     ```
6. Set the tab name to: **Projetos Críticos**
7. Click **Save** or **Add**
8. Verify the tab loads and shows only projects where StatusRAG = Vermelho

### STEP 5 — Add Tab 3: "Decisões Pendentes"

1. Click the **+** button again at the top of the channel
2. Search and select **SharePoint**
3. Select site **Grp_T_DN_Transformacao_Digital**
4. Select the **Decisoes do Board** list
5. Select the **Pendentes** view
   - Direct URL if needed:
     ```
     https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Decisoes%20do%20Board/Pendentes.aspx
     ```
6. Set the tab name to: **Decisões Pendentes**
7. Click **Save** or **Add**
8. Verify the tab loads and shows only decisions where StatusDecisao = Pendente

### STEP 6 — Verify All 3 Tabs

1. After adding all 3 tabs, you should see them at the top of the channel:
   - `Posts` | `Files` | **`Portfólio Executivo`** | **`Projetos Críticos`** | **`Decisões Pendentes`**
2. Click each tab and verify it loads the correct SharePoint list view
3. Verify data is live and reflects current SharePoint content

### STEP 7 — Take Evidence Screenshots

For each tab, take a screenshot showing:
1. The tab name visible at the top of the channel
2. The SharePoint list content rendered inside Teams
3. Save screenshots as:
   - `g5_tab_portfolio_executivo.png`
   - `g5_tab_projetos_criticos.png`
   - `g5_tab_decisoes_pendentes.png`
4. Save to `.planning/comms/` directory

### STEP 8 — Update Project Controls

After all tabs are verified, update:

1. **GATE_STATUS.md** — Mark G5 as ✅ PASSED with evidence references
2. **ROADMAP.md** — Mark Phase 5 as ✅ DONE
3. **STATE.md** — Update current phase to Phase 6
4. **SUB1_SP_LOG.md** — Add entry for tab creation
5. **CODEX_LEAD_LOG.md** — Add G5 completion entry
6. Create **OPUS_HANDOFF_G5.md** with summary and evidence

---

## Troubleshooting

### SharePoint app not appearing in tab picker
- Ensure the SharePoint app is installed for the team
- Try searching "SharePoint" or "Website" in the tab picker
- If SharePoint doesn't appear, use "Website" tab and paste the URL directly

### "You don't have access" error
- The logged-in user must be a member of the Teams group
- The user must also have access to the SharePoint site

### View shows empty data
- This is normal if the view filter doesn't match any current items
- For "Projetos Críticos": there may be no Vermelho projects currently
- The tab will populate when matching data exists

### Tab added but shows wrong view
- Click the dropdown arrow on the tab name → "Settings"
- Change the URL to the correct view URL from the table above

---

## Acceptance Criteria

- [ ] Tab "Portfólio Executivo" visible and loads Board RAG view
- [ ] Tab "Projetos Críticos" visible and loads filtered Vermelho view
- [ ] Tab "Decisões Pendentes" visible and loads filtered Pendente view
- [ ] Screenshots captured for all 3 tabs
- [ ] GATE_STATUS.md updated to G5 PASSED
- [ ] ROADMAP.md updated to Phase 5 DONE
