# PMO Intelligent Hub — M365 Standard-Only MVP

## Vision
Eliminar a fricção de status reporting para projetos de tecnologia, oferecendo atualização por linguagem natural (voz/texto) via Copilot Studio, com dados centralizados em SharePoint e visibilidade executiva em tempo real via Teams.

## Solução Arquitetural
**D + B** — SharePoint Hub (dados) + Copilot Studio Agent (interface conversacional) + Power Automate Standard (orquestração) + Planner Basic (execução operacional)

## Source of Truth
- PRD oficial: `PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md`
- Nota arquitetural: 94/100
- Solução visual: `solucao_b_revisada.html`

## Endpoints Oficiais
- **Teams Channel:** `Projetos_Tranformação_Digital` (GroupID: 96c5b0c4-46cc-46cd-8695-50451db74994)
- **Teams Channel URL:** `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920`
- **SharePoint Site:** `Grp_T_DN_Transformacao_Digital` (indra365.sharepoint.com)
- **SharePoint URL:** `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/SitePages/Home.aspx`
- **Tenant ID:** 7808e005-1489-4374-954b-d3b08f193920
- **Power Platform Environment:** `ColOfertasBrasilPro`
- **Power Platform Environment ID:** e2d10003-4d8e-e007-9d63-76d5fe89ef56
- **Power Platform Environment URL:** https://colofertasbrasilpro.crm4.dynamics.com/

## Restrições Mandatórias
- ❌ No Microsoft Graph direto
- ❌ No HTTP with Microsoft Entra ID
- ❌ No conectores Premium
- ❌ No Dataverse, Planner Premium, Project for the Web
- ❌ No Entra app registration, ClientId, certificate auth, service principal, or custom app auth for provisioning
- ✅ Apenas Standard Connectors
- ✅ Planner Standard connector permitido
- ✅ Todas as fases Power Platform / Power Automate / Copilot devem usar sempre `ColOfertasBrasilPro`; não usar Default environment
- ✅ SharePoint provisioning via Windows PowerShell 5.1 + `SharePointPnPPowerShellOnline 3.29.2101.0` + `Connect-PnPOnline -Url $SiteUrl -UseWebLogin`
- ✅ Login and provisioning command must run in the same Windows PowerShell process; see `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
- ✅ Tenant command execution runbook obrigatório antes de qualquer ação em SharePoint/Power Automate/PAC: `.planning/TENANT_COMMAND_RUNBOOK.md`

## Agentes do Projeto
| Role | Agent | Responsabilidade |
|------|-------|------------------|
| Principal Solutions Architect | Opus 4.6 | Arquitetura, PRD, decisões, revisão |
| Deployment Engineer + QA + Troubleshooting | Codex 1 (5.5 high thinking) | Deploy, testes, resolução de problemas |
| Sub-Agent 1 | Codex Sub-1 | SharePoint provisioning (listas, views, índices) |
| Sub-Agent 2 | Codex Sub-2 | Power Automate flows (criação e teste) |
| Sub-Agent 3 | Codex Sub-3 | Copilot Studio (topics, entities, publicação) |

## Framework
GSD (Get Shit Done) v1.39.1 — Spec-Driven Development

## Handoff Protocol
- Every Codex final response after execution must include a ready-to-send OPUS handoff prompt link when control is expected to return to OPUS-ARCH.
- Current OPUS handoff prompt: `.planning/comms/OPUS_HANDOFF_TENANT_RUNBOOK.md`
- Handoff prompts must preserve gate status, evidence logs, next phase, next owner, and any mandatory tenant access constraints.
