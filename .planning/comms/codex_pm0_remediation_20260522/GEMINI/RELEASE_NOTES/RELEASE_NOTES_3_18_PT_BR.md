# Notas de Lançamento (Release Notes) — Versão 3.18

Last updated: 2026-05-23 17:42:00 BRT | Sub G2B acting as Δ G1B | Updated solution version to 3.18.

---

## 1. Cabeçalho de Lançamento (Release Header)

- **Versão da Solução**: 3.18.0.0
- **Data de Lançamento**: 23 de maio de 2026
- **Ambiente de Destino**: `ColOfertasBrasilPro` (ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- **Status do Lançamento (Ship Status)**: PENDING (Waiting for Owner Gate 9 Decision in active thread)

---

## 2. Destaques (Highlights)

A **Versão 3.18** representa um salto qualitativo fundamental na governança e estabilidade do **PMO Intelligent Hub**. O foco principal desta release é a migração completa do núcleo de transações frequentes para um modelo **híbrido baseado em cartões adaptativos (Card-First)**, resolvendo gargalos críticos de experiência do usuário e segurança de dados da versão 3.15.1.

### Principais Destaques:
- **Migração Card-First**: Substituição do diálogo livre em texto por formulários estruturados em Microsoft Adaptive Cards v1.5.
- **Implementação Robusta do Backend**: Totalmente integrada a fluxos do Power Automate Standard com validação prévia de variáveis.
- **Eliminação de Filtros de Segurança (Content Filter)**: O uso de campos estruturados e strings US-ASCII elimina completamente os falsos positivos de segurança que bloqueavam PMs.
- **Total Conformidade com Licenciamento**: Solução construída de forma estrita com conectores standard (SharePoint Online, Planner Standard), sem custos de licenciamento premium.

---

## 3. Novidades (What's New)

Esta release introduz funcionalidades refinadas para as cinco transações principais do PMO Hub:

1. **Atualizacao de Status Executivo (`AtualizarStatus`)**: Envio simplificado de relatórios semafóricos (Verde/Amarelo/Vermelho) e destaques de projetos, com escrita automática no SharePoint.
2. **Atualizacao de Tarefas (`AtualizarTarefa`)**: Atualização granular de progresso percentual (0 a 100) e status operacional de tarefas do portfólio.
3. **Criacao de Tarefas (`CriarTarefa`)**: Permite que PMs deleguem e criem novas tarefas informando responsável (e-mail), vencimento e prioridade crítica.
4. **Listagem de Tarefas Dinâmica (`ListarTarefas`)**: Retorna um sumário condensado (FactSet) contendo o status de todas as tarefas de um projeto diretamente na tela de conversa.
5. **Dashboard de Portfolio Executivo (`ConsultarPortfolio`)**: Agrega as métricas de saúde financeira, atrasos de tarefas e volumetria geral do portfólio.

---

## 4. Correções de Defeitos (Defects Fixed)

Esta release corrige falhas graves observadas na versão anterior em relação à integridade de fluxo e parsing de dados:

- **Total de Defeitos Corrigidos**: 18 defeitos resolvidos (7 de severidade SEV-0 e 11 de severidade HIGH)
- **Mitigação de Drifts**: Correção nos esquemas e variáveis de entrada dos fluxos Power Automate para garantir mapeamento preciso com as tabelas SharePoint.
- **Tratamento de Codificação**: Implantação estrita de strings ASCII-safe para prevenir falhas de serialização JSON no Teams.

---

## 5. Limitações Conhecidas (Known Limitations)

- **Débito de Tópicos Legados**: Sete tópicos secundários (`ConsultarProjeto`, `PedirDecisaoBot`, `RegistrarBloqueioBot`, `RegistrarRiscoBot`, `AlertaCritico`, `CheckInDiario`, `ResumoSemanal`) continuam operando em modo textual chat-first. O risco de ativamento do filtro de segurança (Content Filter) nesses fluxos é aceito temporariamente como débito técnico a ser quitado na release Wave 2.
- **Planner Basic**: A leitura de indicadores de planos Planner está limitada às capacidades básicas do conector nativo (Standard), sem suporte a recursos avançados do Project Premium.

---

## 6. Compatibilidade (Compatibility)

- **Restrições de Ambiente**: Deploy homologado estritamente no ambiente corporativo `ColOfertasBrasilPro`.
- **Restrição de Conectores**: Standard-Only. É expressamente proibido o uso de conectores Premium, barramentos de API ou customizações Azure sem aprovação prévia.

---

## 7. Caminho de Atualização (Upgrade Path)

Para realizar o deploy e atualização da solução:

1. Acesse o terminal autenticado e execute a importação da solução Dataverse consolidada:
   ```powershell
   pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path 'Solution/PMO_v11_Tarefas_3_18_PM0_FUNCTIONAL_FIX.zip' --publish-changes
   # Verified SHA256 Checksum: <<TODO_BACKFILL: sha256_rebuild_3_18 (depends on: Codex2_repackage_3_18)>> (SHA pending 3.18 rebuild)
   ```
2. Após o término da importação, verifique a publicação das alterações no portal de soluções.

---

## 8. Caminho de Rollback (Rollback Path)

Caso seja detectada qualquer instabilidade severa ou regressão não passível de correção imediata, execute o procedimento de rollback para a versão estável anterior (3.10):

```powershell
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path 'Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip' --publish-changes
```
*Prerequisito*: Confirme se o hash SHA256 do arquivo corresponde a `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`.

---

## 9. Referências de Análise

- **Relatório de Causa Raiz (RCA)**: [RCA_PM0_FLOWS_20260522.md](file:///d:/VMs/Projetos/STT_Project_Management/.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md)
- **Plano de Remediação**: [REMEDIATION_PLAN.md](file:///d:/VMs/Projetos/STT_Project_Management/.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md)
- **Decisão Arquitetural**: [ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md](file:///d:/VMs/Projetos/STT_Project_Management/.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md)
