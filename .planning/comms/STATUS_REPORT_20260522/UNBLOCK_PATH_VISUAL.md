# 🔓 UNBLOCK PATH — Caminho Atual

**Status:** 🔴 **NO-SHIP após AQ-09 A1 FAIL** | **Próximo gate:** Owner containment decision | **SHIP target:** blocked
Last updated: 2026-05-22 15:37 BRT | Codex #1 | Old same-day ship path marked superseded after PM0 merge.
**Atualizado:** 2026-05-22 15:37 BRT

---

## ✅ JÁ COMPLETO

```
✅ DONE — 5 UI edits Copilot Studio (~08:00-08:15 BRT)
✅ DONE — Solution 3.15.1 import
✅ DONE — Bot publish
✅ DONE — AQ-08 reverify T+5min PASS
✅ DONE — AQ-08 reverify T+1h PASS
✅ DONE — Drift fingerprint RCA (false-positive identified)
```

---

## 🔴 PRÓXIMOS PASSOS

1. Owner escolhe `ROLLBACK`, `FIX-AND-SHIP` ou `HYBRID` usando o mitigation plan.
2. Se houver escrita no tenant, owner autoriza a operação exata em-thread.
3. Time executa contenção ou remediation local.
4. Runtime bot evidence e AQ-09 voltam a ser gate somente após a escolha aprovada.

The original same-day path below is superseded by the A1 failure and retained only as incident context.

```
┌────────────────────────────────────────────────────────────────────────────┐
│                      🚀 PATH TO PRODUCTION SHIP                             │
└────────────────────────────────────────────────────────────────────────────┘

   ┌──────────────────────────────────────────┐
   │  STEP 1 │ AQ-09 RUNTIME SMOKE (~2h)      │ ⬅ AÇÃO MANUAL OWNER
   ├─────────┴──────────────────────────────────
   │
   │  📍 onde:  Teams → bot Assistente PMO V2
   │  📋 runbook: .planning/comms/aq09_smoke_runbook_20260520/
   │  👤 who:   Owner (chat) + Codex 5.5 (validation)
   │  🧪 12 cenários runtime: criar/atualizar/listar/consultar/etc.
   │
   ▼
   ┌──────────────────────────────────────────┐
   │  STEP 2 │ DRIFT T+6H (passivo)           │ ⬅ AGENTE BACKGROUND
   ├─────────┴──────────────────────────────────
   │
   │  ⏰ scheduled: 2026-05-22 14:23 BRT
   │  🔧 process:   PID 44496 já dispatched
   │  📂 output:    drift_monitoring_20260522_0816/T+6h/
   │
   ▼
   ┌──────────────────────────────────────────┐
   │  STEP 3 │ XPIA HARNESS (30min)           │ ⬅ AGENTE
   ├─────────┴──────────────────────────────────
   │
   │  🛡 harness:  xpia_01_verify_20260520/
   │  👤 who:    Opus 4.7 #2
   │  🎯 gate:   ZERO ContentFiltered nos 5 in-scope (Section A)
   │             Section B (7 legacy) accepted as backlog debt
   │
   ▼
   ┌──────────────────────────────────────────┐
   │  STEP 4 │ SHIP DECISION (30min)          │ ⬅ AÇÃO MANUAL OWNER
   ├─────────┴──────────────────────────────────
   │
   │  📊 review: Owner + Opus 4.7
   │  ✍ decision: SHIP / NO-SHIP / Rollback
   │  🚀 if SHIP: production publish (se houver diferença env vs prod)
   │  🔄 if rollback: Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip (15min)
   │
   ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                            🎉 PRODUCTION LIVE 🎉                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 📅 Cronograma proposto: 22/05 13:30 → 17:00

| Horário | Atividade | Duração | Agente |
|---|---|---:|---|
| **13:30** | 🔴 Owner inicia cenário 1 AQ-09 smoke | 10min | Owner |
| **13:40→15:30** | 🔴 Cenários 2-12 AQ-09 + validação | 1h50 | Owner + Codex |
| **14:23** | 🤖 Drift Monitor T+6h auto-trigger | passivo | CODEX-PA |
| **15:30** | 🤖 Opus #2 inicia XPIA harness | 30min | Opus #2 |
| **16:00** | 🔴 Owner revisa evidências agregadas | 30min | Owner + Opus 4.7 |
| **16:30** | 🔴 SHIP decision + production publish | 30min | Owner |
| **17:00** | 🎉 **PRODUÇÃO LIVE** ou rollback | — | — |

> **Total Owner ativo:** ~2h30min
> **Total wall-clock:** ~3h30min

---

## 🚦 SEMÁFORO DE STATUS

| Etapa | Status | Próxima ação |
|---|---|---|
| 5 UI edits | ✅ DONE | — |
| Solution import + publish | ✅ DONE | — |
| AQ-08 reverify T+5min/T+1h | ✅ PASS | — |
| Drift T+6h | ⏳ SCHEDULED | aguarda 14:23 BRT |
| AQ-09 runtime smoke | 🔴 A1 FAILED | Retest after containment/remediation |
| XPIA Section A | 🟡 WAITING | aguarda AQ-09 |
| SHIP decision | 🟡 BLOCKED | aguarda XPIA |

---

## 🔥 SE ALGO QUEBRAR

| Falha em | Plano B | Tempo extra |
|---|---|---|
| Drift T+6h FAIL | CODEX-PA RCA + Owner decide rollback | +1h |
| AQ-09 falha 1-2 cenários menores | Codex fix targeted + re-smoke parcial | +1h |
| AQ-09 falha 3+ ou crítico | Rollback `3.10_POST_WFSET_CLEAN.zip` | 15min |
| XPIA hit em in-scope | Opus #2 ativa fallback α/β/γ | +4h |
| XPIA hit em legacy out-of-scope | Aceito como backlog debt | 0min |

---

## 📂 ARQUIVOS RELACIONADOS

```
.planning/comms/STATUS_REPORT_20260522/
├── STATUS_REPORT_TASKS_PLANNER.csv          ← Planilha consolidada
├── STATUS_REPORT_EXECUTIVE_20260522.md      ← Status report completo
├── UNBLOCK_PATH_VISUAL.md                   ← ESTE arquivo
└── IMMEDIATE_ACTION.md                       ← Ação imediata 1 página

.planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/drift_monitoring_20260522_0816/
├── T+5min/  ✅ PASS
├── T+1h/    ✅ PASS
├── T+6h/    ⏳ scheduled 14:23
└── DRIFT_FINGERPRINT_FALSE_POSITIVE_RCA.md

.planning/comms/aq09_smoke_runbook_20260520/      ← Owner executa daqui
.planning/comms/xpia_01_verify_20260520/          ← Opus #2 roda automaticamente

Solution/
└── PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip      ← LIVE no tenant
└── PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip     ← rollback target
```

---

**🎯 OWNER: PRÓXIMO CLIQUE É ABRIR `aq09_smoke_runbook_20260520/` E COMEÇAR CENÁRIO 1.**
