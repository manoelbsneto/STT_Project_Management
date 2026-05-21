# Inventory - Quota Risks

**Agent:** CODEX-1-SUB-C  
**Generated:** 2026-05-20T20:39:27-03:00  
**Scope:** M2 Phase 1 Track H.1  
**Tenant:** ColOfertasBrasilPro

## Summary

Quota risk is **Low** for the M2 pilot. The expected production volume is roughly 50 PMO operations/day, which is far below the documented per-connection and per-day limits for SharePoint, Teams, Planner, Power Virtual Agents, and Power Automate seeded usage.

The practical risk is retry amplification: a broken Teams route, SharePoint schema mismatch, or Planner mapping error can cause repeated retries and consume more connector calls than normal operation. That is a runtime reliability risk, not a baseline quota bottleneck.

## Connector Matrix

| Connector | Standard limit | Estimated M2 calls/day | Risk | Mitigation |
|---|---:|---:|---|---|
| SharePoint Standard | 600 API calls/connection/60s; 1000 MB/connection/60s; list view threshold 5000 items | ~300 | Low | Use indexed ProjectID/Deleted filters; avoid broad unfiltered Get items. |
| Microsoft Teams Standard | 100 API calls/connection/60s; Flow bot/adaptive-card non-GET operations 25/connection/300s | ~150 | Low | Keep DM/channel sends sequential; avoid bulk card broadcasts. |
| Planner Standard | 100 API calls/connection/60s; trigger poll 1/360s; basic plans only | ~90 | Low | Keep Planner operations limited to create/update/list task paths; persist sync state in SharePoint. |
| Power Virtual Agents / Copilot Studio | PVA connector 100 API calls/connection/60s; flow calls count as Power Platform requests | ~50 | Low | Keep one final action call per topic after collection/confirmation. |
| Power Automate / Power Platform requests | Office 365 seeded users: 6000 requests/user/24h official; transition: 10000/cloud flow; 100000 requests/5min ceiling | ~1500 | Low | Monitor request reports after publish; consider Process license only if actual usage grows materially. |

## Sources

- Microsoft Learn, Power Platform request limits and allocations: https://learn.microsoft.com/en-us/power-platform/admin/api-request-limits-allocations
- Microsoft Learn, SharePoint connector: https://learn.microsoft.com/en-us/connectors/sharepointonline/
- Microsoft Learn, Teams connector: https://learn.microsoft.com/en-us/connectors/teams/
- Microsoft Learn, Planner connector: https://learn.microsoft.com/en-gb/connectors/planner/
- Microsoft Learn, Power Virtual Agents connector: https://learn.microsoft.com/nb-no/connectors/powervirtualagents/
- Microsoft Learn, SharePoint list view threshold: https://learn.microsoft.com/en-us/troubleshoot/sharepoint/lists-and-libraries/items-exceeds-list-view-threshold

## Notes

- Current Track D flow inventory shows legacy flows use SharePoint heavily; PM0 target flows add Teams card posts and Planner operations for task flows.
- The 5000-item SharePoint list view threshold is a scale/design constraint. It is not an immediate blocker, but M2 should use indexed list queries before data grows.
- No tenant writes or runtime tests were performed for this analysis.
