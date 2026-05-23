# 🎯 AÇÃO IMEDIATA — O QUE FAZER AGORA

Last updated: 2026-05-22 15:37 BRT | Codex #1 | Stale continue-smoke sequencing removed after PM0 merge.
**Atualizado:** 2026-05-22 15:37 BRT
**Você está em:** NO-SHIP após AQ-09 A1 FAIL; RCA/remediation/mitigation pack pronto

---

## ✅ JÁ FEITO (não precisa fazer mais)

- 5 UI edits no Copilot Studio ✅
- Solution 3.15.1 importada e publicada ✅
- AQ-08 verifier T+5min PASS ✅
- AQ-08 verifier T+1h PASS ✅

---

## 🔴 FAÇA AGORA — 1 decisão

### **ESCOLHA A CONTENÇÃO PM0**

**RCA:** `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md`
**Remediation:** `.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md`
**Mitigation:** `.planning/comms/codex_pm0_audit_20260522/MITIGATION_PLAN.md`
**Escolhas:** `ROLLBACK`, `FIX-AND-SHIP`, `HYBRID`

```
1. Leia o executive summary e a mitigation matrix.
2. Escolha a contenção.
3. Autorize em-thread qualquer escrita exata no tenant, se necessário.
4. Só retome AQ-09 completo depois da contenção/remediação aprovada.
```

---

## ⏳ EM PARALELO

AQ-08 structural drift evidence can continue to be collected, but it is not a substitute for PM0 functional remediation/runtime proof. XPIA and full AQ-09 continuation wait for the containment path selected now.

---

## 🚨 DEPOIS DA DECISÃO

Execute only the approved path. A rollback/disable action needs tenant-write approval first; a fix-and-ship path needs the remediation tests and runtime proof before SHIP language returns.

---

## 📞 SE ALGO DER ERRADO

| Problema | Solução | Tempo |
|---|---|---|
| Cenário AQ-09 falha individual | Codex faz fix targeted | +1h |
| Múltiplos cenários falham | Rollback para `3.10_POST_WFSET_CLEAN.zip` | 15min |
| XPIA hit em in-scope | Opus #2 ativa fallback α/β/γ | +4h |

---

## 📂 LINKS RÁPIDOS

- **Runbook AQ-09:** `.planning/comms/aq09_smoke_runbook_20260520/`
- **Status report completo:** `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_EXECUTIVE_20260522.md`
- **Caminho visual:** `.planning/comms/STATUS_REPORT_20260522/UNBLOCK_PATH_VISUAL.md`
- **Planilha CSV:** `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_TASKS_PLANNER.csv`

---

## ✋ LEMBRETE GOLDEN RULE (recém-adicionada)

Toda task / test / verifier / smoke / decisão **DEVE atualizar imediatamente** os documentos de status. Não acumule. Os agentes lerão a doc, e doc desatualizada vira retrabalho — exatamente o problema que aconteceu agora.

**Documentos a manter sempre live:**
- `.planning/STATE.md`
- `.planning/CURRENT_BASELINE.md`
- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `.planning/START_HERE_CURRENT_STATUS.md`
- `.planning/stop_ship/MASTER_CHECKLIST.md`
- `.planning/milestones/M2.../STATE.md`
- Status reports ativos
