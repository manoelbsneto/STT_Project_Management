# Caderno de Homologacao PMO - 2026-05-13

Status geral: NO-SHIP para release completa ate fechar os testes pendentes abaixo.

## Atualizacao Executiva - 2026-05-13 17:35 BRT

| Campo | Valor |
|---|---|
| Status executivo | NO-SHIP |
| Risco atual | High |
| Projeto QA ativo | `QA Robust 20260513 F` |
| ProjectID | `PRJ-274E5ACC` |
| Item SharePoint do projeto | `33` |
| Tarefa QA ativa | `Validar status choice 3.4` |
| Item SharePoint da tarefa | `13` |
| Ultimo resultado comprovado | `CMD-14 ExcluirTarefa positive soft-delete runtime = PASS` |
| Bloqueador principal | `BLK-AT-001 AtualizarTarefa skip semantics` |

### Resumo Do Bloqueador Principal

| Blocker ID | Componente | Codigo | Sintoma | Causa | Status |
|---|---|---|---|---|---|
| `BLK-AT-001` | `AtualizarTarefa` topic + `PMO_PA_AtualizarTarefa` flow | `FlowActionBadGateway`, `NoResponse` | Falha quando usuario responde `nao` para campos opcionais | O topico instrui `nao` como manter valor atual, mas o flow envia `nao` para campos SharePoint como `DataFim` e `Responsavel` | Fix obrigatorio antes de release |

### Evidencia Runtime Mais Recente

| Evidence ID | Teste | Resultado | Observacao |
|---|---|---|---|
| `E-140` | `CMD-11 CriarTarefa` | PASS | Criou tarefa `13` em `Tarefas` vinculada ao `ProjectID=PRJ-274E5ACC` |
| `E-141` | `CMD-12 ListarTarefas` | PASS | Listou tarefa `13`, status inicial `Pendente`, prioridade `Alta` |
| `E-142` | `CMD-13A AtualizarTarefa com nao` | FAIL | Gerou `FlowActionBadGateway` porque `nao` foi enviado como valor real |
| `E-143` | `CMD-13B AtualizarTarefa com valores explicitos` | PASS | Atualizou tarefa `13` para `Em Andamento`, horas realizadas `18`, responsavel `mbenicios@minsait.com`, prazo `2026-06-30`, prioridade `Alta` |
| `E-145` | `CMD-13C AtualizarTarefa para Concluida` | PASS | Atualizou tarefa `13` para `Concluida`; projeto recalculado com `Percentual=100%`, `Total=1`, `Concluidas=1`, `Abertas=0`, `Atrasadas=0` |
| `E-146` | `CMD-14 ExcluirTarefa positive soft-delete` | PASS | Bot removeu tarefa `13` do projeto ativo `QA Robust 20260513 F` e informou que o registro SharePoint sera mantido para auditoria |

### Proxima Sequencia Obrigatoria

| Ordem | Test ID | Comando | Resultado Esperado |
|---:|---|---|---|
| 1 | `CMD-12` | `listar tarefas QA Robust 20260513 F` | Tarefa `13` nao aparece na lista ativa |
| 2 | `SP-AUDIT` | Consulta read-only do item `13` em `Tarefas` | Item fisico existe com `Deleted=true`, motivo, timestamp e usuario |
| 3 | `CMD-09` | `pedir decisao` com aprovador invalido `UPN ?` | Bot rejeita UPN invalido sem `FlowActionInternalServerError` |

Fonte de verdade usada neste caderno:
- SharePoint XML real: `.planning/comms/sharepoint_schema_xml_20260513/`
- Inventario real dos flows: `.planning/comms/adaptive_cards_flow_inventory_20260513/flow_inventory.json`
- PRD: `PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md`
- Runbook: `deploy/MASTER_RUNBOOK/MASTER_RUNBOOK.md`

## Evidencia Base Capturada

| Item | Status | Evidencia |
|---|---|---|
| XML real das listas SharePoint | DONE | `.planning/comms/sharepoint_schema_xml_20260513/inventory.json` |
| Flows Adaptive/Planner inventariados | DONE | `.planning/comms/adaptive_cards_flow_inventory_20260513/flow_inventory.json` |
| Canal Teams temporario de testes | DONE | Group `96c5b0c4-46cc-46cd-8695-50451db74994`, Channel `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` |
| Projeto piloto | DONE | `QA Robust 20260513 F`, `ProjectID=PRJ-274E5ACC` |
| Import solution 3.4 | DONE | `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (24).xml`: solution `PMO_v11_Tarefas`, version `3.4`, status `Procesado`, workflows activated `Procesado` |

## Comandos Copilot - Homologacao

| ID | Tema | Comando/Teste | Status Atual | Proxima acao | Criterio de aceite |
|---|---|---|---|---|---|
| CMD-01 | CriarProjeto guiado | `novo projeto` + respostas por prompt | PASS | Manter como regressao | Cria somente `Projetos`, sem ContentFiltered, sem duplicidade |
| CMD-02 | CriarProjeto one-shot | `criar projeto: NomeProjeto=..., PM=..., Prazo=dd/MM/yyyy, Prioridade=Alta` | PASS | Manter como regressao | Roteia para `CriarProjeto`; cria `Projetos`; confirma `ProjectID` |
| CMD-03 | CriarProjeto duplicado | repetir nome existente | PASS | Manter como regressao | Nao cria item duplicado ativo |
| CMD-04 | CriarProjeto data invalida | `Prazo=yyyy-MM-dd` | PASS | Manter como regressao | Rejeita formato e nao grava SharePoint |
| CMD-05 | ConsultarProjeto | `consultar projeto QA Robust 20260513 F` | PASS com hardening | Fix futuro: capturar nome inline sem segundo prompt | Retorna dados reais de `Projetos` e riscos abertos |
| CMD-06 | RegistrarRisco | `registrar risco` | PASS | Manter como regressao | Cria item `Tipo=Risco`, `StatusRisco=Aberto`, `Deleted=false` |
| CMD-07 | RegistrarBloqueio | `registrar bloqueio` | PASS | Manter como regressao | Cria item `Tipo=Bloqueio`, `StatusRisco=Aberto`, `Deleted=false` |
| CMD-08 | PedirDecisao valido | `solicitar decisao` + UPN valido | PASS | Manter como regressao | Cria `Decisoes do Board`, `StatusDecisao=Pendente` |
| CMD-09 | PedirDecisao UPN invalido | aprovador `UPN ?` | IMPORTED 3.4 / RUNTIME PENDING | Owner publish 3.4, depois retestar | Bot deve rejeitar UPN invalido sem FlowActionInternalServerError |
| CMD-10 | AtualizarStatus multilinha | `atualizar status` + resumo multilinha | PARTIAL | Fix obrigatorio para extrair campos estruturados ou aceitar criterio reduzido | `Resumo` multilinha preservado; `Risco`, `Bloqueio`, `ProximaAcao`, `Percentual` devem preencher quando informados |
| CMD-11 | CriarTarefa | `criar tarefa` | IMPORTED 3.4 / RUNTIME PENDING | Owner publish 3.4, depois retestar | Cria somente `Tarefas`; `Status=Pendente`; vincula `ProjectID` ativo |
| CMD-12 | ListarTarefas | `listar tarefas QA Robust 20260513 F` | PENDING | Testar apos CMD-11 | Lista tarefas do projeto, ignora deleted/inativo |
| CMD-13A | AtualizarTarefa com campos opcionais pulados | `atualizar tarefa` com `nao` nos campos opcionais | FAIL / BLOCKER | Corrigir `BLK-AT-001` | `nao` deve preservar valores atuais e nao gerar `FlowActionBadGateway` |
| CMD-13B | AtualizarTarefa com valores explicitos | `atualizar tarefa` com `13`, `Em Andamento`, `18`, `mbenicios@minsait.com`, `2026-06-30`, `Alta`, `sim` | PASS | Manter como workaround ate fix | Atualiza somente tarefa alvo para `Em Andamento` |
| CMD-13C | AtualizarTarefa para concluida | `atualizar tarefa` com `13`, `Concluida`, `18`, `mbenicios@minsait.com`, `2026-06-30`, `Alta`, `sim` | PASS | Manter como regressao com workaround | Atualizou tarefa `13` para `Concluida` e recalculou contadores |
| CMD-14 | ExcluirTarefa | `excluir tarefa projeto=QA Robust 20260513 F, tarefa=13, motivo=homologacao 3.4 task lifecycle` | PASS runtime | Verificar lista ativa e auditoria SharePoint | Soft delete remove da lista ativa e mantem registro fisico para auditoria |
| CMD-15 | ConsultarPortfolio | `consultar portfolio` | NEED CURRENT RECHECK | Rodar leitura atual | Totais batem com SharePoint ativo/non-deleted |

## Adaptive Cards - Homologacao

| ID | Flow/Card | Status Atual | Proxima acao | Criterio de aceite |
|---|---|---|---|---|
| CARD-01 | `PMO_PA_RegistrarDecisaoBoard` | READY/RUNTIME OBSERVED | Usar card no canal temporario: aprovar, rejeitar, adiar | Atualiza `StatusDecisao`, `Resposta`, `Justificativa`, `DataResposta`, `ResponseSource=AdaptiveCard`, `CardVersion` |
| CARD-02 | `PMO_PA_CheckInOnDemand` | READY | Acionar card e submeter check-in | Cria `Status Diario` com `OrigemEntrada=AdaptiveCard`, preenche RAG/resumo/risco/bloqueio/proximaAcao/percentual e atualiza `Projetos` |
| CARD-03 | `PMO_PA_ProcessarRespostaCheckIn` | BLOCKED | Flow esta `Stopped`; definir se volta a ser canonico ou se `CheckInOnDemand` substitui | Flow habilitado/canonico com run verde ou decisao formal de substituicao |
| CARD-04 | `PMO_PA_EnviarCheckInDiario` | READY BUT DEPENDS CARD-03 | Validar envio recorrente e submit real | Card chega no canal/chat e resposta grava SharePoint |
| CARD-05 | `PMO_PA_AlertaProjetoVermelho` | OPEN | Criar condicao controlada `StatusRAG=Vermelho` | Card no canal temporario, sem duplicidade, dados batem com projeto |
| CARD-06 | `PMO_PA_EscalarRiscoCritico` | READY | Criar/usar risco severidade Critica | Posta alerta; non-critical nao deve escalar |
| CARD-07 | `PMO_PA_ResumoDiarioBoard` | OPEN | Capturar run/manual seguro | Card mostra totais RAG, sem update, decisoes pendentes |
| CARD-08 | `PMO_PA_ResumoSemanal` | OPEN | Capturar run/manual seguro | Card semanal renderiza e dados batem com SharePoint |

## Planner / Kanban

| ID | Tema | Status Atual | Proxima acao | Criterio de aceite |
|---|---|---|---|---|
| PLN-01 | `PMO_PA_SyncPlannerStats_Standard` | OPEN | Confirmar Planner connection ID e preencher piloto com `PlannerGroupId`/`PlannerPlanId` | Flow usa Planner Standard `List tasks`; atualiza metricas em `Projetos` |
| PLN-02 | CriarProjeto/CriarTarefa escreve Planner | OUT OF SCOPE NOW | Nao implementar sem mudanca PRD/runbook | SharePoint continua fonte de verdade; Planner apenas metric sync |

## Fixes Obrigatorios Antes de Release Completa

| Fix | Motivo | Evidencia |
|---|---|---|
| `PedirDecisao` validar UPN/email antes do flow | Evitar `FlowActionInternalServerError` para entrada invalida | Teste com `UPN ?` falhou no runtime |
| `AtualizarStatus` extrair multiline para campos estruturados ou ajustar criterio formal | STT/Plan B ainda parcial | `Status Diario` preservou `Resumo`, mas `Risco/Bloqueio/ProximaAcao` ficaram null |
| `CriarTarefa` reconciliar `Status` com choice real | XML real mostra choices `Pendente`, `Em Andamento`, `Concluida`, `Cancelada`; `Aberta` nao e choice valido | `.planning/comms/sharepoint_schema_xml_20260513/Tarefas/fields_summary.csv` |
| Decidir flow canonico de check-in card | `PMO_PA_ProcessarRespostaCheckIn` esta stopped, mas PRD/runbook citam ele | `.planning/comms/adaptive_cards_flow_inventory_20260513/flow_inventory.json` |

## Sequencia Recomendada de Fechamento

1. Fechar regressao dos comandos ja aprovados: CMD-01 a CMD-08, CMD-15.
2. Corrigir e retestar CMD-09, CMD-10 e CMD-11.
3. Fechar CRUD de tarefas: CMD-11 a CMD-14.
4. Fechar Adaptive Cards: CARD-01, CARD-02, CARD-05, CARD-06, CARD-07, CARD-08.
5. Resolver decisao CARD-03/CARD-04.
6. Fechar Planner sync: PLN-01.

## Fila Imediata Pos-Import 3.4

Import analisado:
- Log: `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (24).xml`
- Resultado: solution `PMO_v11_Tarefas`, version `3.4`, status `Procesado`.
- Observacao: `0x80045042` apareceu em workflows com status `Procesado` e texto `The original workflow definition has been deactivated and replaced`; como houve ativacao posterior `Procesado`, isto nao foi classificado como blocker de import.

Comandos prioritarios no Copilot Studio:

| Ordem | ID | Comando | Resultado esperado |
|---|---|---|---|
| 1 | CMD-11 | `criar tarefa: projeto=QA Robust 20260513 F, tarefa=Validar status choice 3.4, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Alta` | Cria uma tarefa em `Tarefas` com `Status=Pendente`; nao cria projeto novo |
| 2 | CMD-09 | `solicitar decisao` com aprovador `UPN ?` | Rejeita UPN invalido com mensagem controlada; sem `FlowActionInternalServerError`; nao cria decisao |
| 3 | CMD-08 | `solicitar decisao` com aprovador `mbenicios@minsait.com` | Cria decisao `Pendente` e posta card no Teams |
| 4 | CMD-12 | `listar tarefas QA Robust 20260513 F` | Lista tarefas ativas/non-deleted do projeto e inclui `Validar status choice 3.4` |
| 5 | CMD-13 | `atualizar tarefa Validar status choice 3.4 para Em Andamento` | Atualiza somente a tarefa alvo para `Em Andamento` |
| 6 | CMD-13 | `atualizar tarefa Validar status choice 3.4 para Concluida` | Atualiza somente a tarefa alvo para `Concluida` |
| 7 | CMD-14 | `excluir tarefa Validar status choice 3.4 motivo homologacao 3.4` | Soft delete: item permanece na lista com `Deleted=true` e motivo |
| 8 | CMD-12 | `listar tarefas QA Robust 20260513 F` | Nao deve listar a tarefa excluida logicamente |
| 9 | CMD-15 | `consultar portfolio` | Totais devem bater com SharePoint ativo/non-deleted |
| 10 | CMD-10 | `atualizar status` com texto multilinha estruturado | Ainda e blocker conhecido se `Risco/Bloqueio/ProximaAcao/Percentual` ficarem vazios |
