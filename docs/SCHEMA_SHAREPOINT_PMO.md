# Mapeamento Funcional e Técnico do SharePoint PMO

Este documento descreve formalmente o schema, as restrições e os tipos de dados exatos configurados no provisionamento oficial das listas SharePoint utilizadas no PMO Intelligent Hub. Serve como base de contrato técnico e referência para integrações de API, scripts e rotinas do Power Automate.

**Repositório Base de Verdade**: `deploy/SP_Provisioning.ps1` e `deploy/Add-LogicalDeleteFields.ps1`

---

## 0. Premissa Operacional de Leitura de Schema

As validacoes programaticas de schema devem usar comandos read-only do PnP PowerShell, como `Get-PnPList`, `Get-PnPField` e `Get-PnPListItem`. Esses comandos consultam metadados e amostras das listas sem alterar dados, colunas, permissoes ou configuracao.

No ambiente local `dataops-lab`, os scripts historicamente usam `Connect-PnPOnline -UseWebLogin`. Esse modo e aceitavel para execucao local assistida quando a sessao Microsoft 365 ja esta autenticada/cacheada. Se o token expirar, o PnP pode abrir uma janela interativa de login/MFA e bloquear a execucao ate acao humana. Por isso, agentes autonomos nao devem tratar `UseWebLogin` como mecanismo headless confiavel.

Para este projeto, consultas SharePoint feitas por agente devem permanecer restritas a leitura, produzir evidencia em `.planning/comms`, e qualquer execucao que solicite login interativo deve ser interrompida e devolvida ao owner. Imports, publish, deploy, alteracoes de listas, alteracoes de fluxos e writes em producao continuam exclusivos do owner.

---

## 1. Projetos

Representa a espinha dorsal do portfólio de projetos ativos no PMO.

| Display Name | Internal Name (Obrigatório em APIs) | Tipo SharePoint | Obrigatório | Detalhes e Valores Permitidos |
| :--- | :--- | :--- | :---: | :--- |
| **ProjectID** | `ProjectID` | Text | **Sim** | Chave principal de negócio. Indexado. |
| **Nome** | `NomeProjeto` | Text | **Sim** | - |
| **PM** | `PM` | User (Person) | **Sim** | Resolve via Claims do Entra ID. Indexado. |
| **Sponsor** | `Sponsor` | User (Person) | Não | Resolve via Claims do Entra ID. Indexado. |
| **StatusRAG** | `StatusRAG` | Choice | **Sim** | `Verde`, `Amarelo`, `Vermelho` (Indexado) |
| **Percentual** | `Percentual` | Number | Não | - |
| **DataAlvo** | `DataAlvo` | DateTime | Não | Formato DateOnly (apenas Data). |
| **UltimaAtualizacao**| `UltimaAtualizacao` | DateTime | Não | Indexado. |
| **Ativo** | `Ativo` | Boolean | Não | Indexado. |
| **Unidade** | `Unidade` | Choice | Não | `TI`, `Digital`, `Dados`, `Infra`, `Seguranca` |
| **Prioridade** | `Prioridade` | Choice | Não | `Alta`, `Media`, `Baixa`, `Critica` |
| **PlannerGroupId** | `PlannerGroupId` | Text | Não | - |
| **PlannerPlanId** | `PlannerPlanId` | Text | Não | - |
| **LinkPlanner** | `LinkPlanner` | URL | Não | - |
| **TarefasTotal** | `TarefasTotal` | Number | Não | - |
| **TarefasAbertas** | `TarefasAbertas` | Number | Não | - |
| **TarefasConcluidas**| `TarefasConcluidas` | Number | Não | - |
| **TarefasAtrasadas** | `TarefasAtrasadas` | Number | Não | - |
| **PlannerLastSyncAt**| `PlannerLastSyncAt` | DateTime | Não | - |
| **PlannerSyncStatus**| `PlannerSyncStatus` | Choice | Não | `OK`, `Erro`, `Pendente` |
| **ResumoExecutivo** | `ResumoExecutivo` | Note (Multi) | Não | - |
| **DiasSemUpdate** | `DiasSemUpdate` | Number | Não | - |

*(Campos de Auditoria e Remoção Lógica)*
| Display Name | Internal Name | Tipo SharePoint | Obrigatório | Detalhes |
| :--- | :--- | :--- | :---: | :--- |
| **Deleted** | `Deleted` | Boolean | Não | Default: `0` (`false`). Indexado. |
| **DeletedAt** | `DeletedAt` | DateTime | Não | - |
| **DeletedReason** | `DeletedReason` | Note (Multi) | Não | - |
| **DeletedByUPN** | `DeletedByUPN` | Text | Não | - |

---

## 2. Tarefas

Controla as ações táticas. Toda tarefa deve estar vinculada a um Projeto pai.

| Display Name | Internal Name (Obrigatório em APIs) | Tipo SharePoint | Obrigatório | Detalhes e Valores Permitidos |
| :--- | :--- | :--- | :---: | :--- |
| **TaskID** | `TaskID` | Text | Não | - |
| **ProjectID** | `ProjectID` | Text | **Sim** | Chave Estrangeira do Projeto. Indexado. |
| **Status** | `Status` | Choice | **Sim** | `Pendente`, `Em Andamento`, `Concluida`, `Cancelada` (Indexado) |
| **HorasRealizadas** | `HorasRealizadas` | Number | Não | - |
| **Responsavel** | `Responsavel` | Text | Não | ATENÇÃO: Campo de Texto Livre (Não é Claim de Entra ID). |
| **DataInicio** | `DataInicio` | DateTime | Não | Formato DateOnly. |
| **DataFim** | `DataFim` | DateTime | Não | Formato DateOnly. Indexado. |
| **Prioridade** | `Prioridade` | Choice | Não | `Baixa`, `Media`, `Alta`, `Critica` (Indexado) |
| **HorasEstimadas** | `HorasEstimadas` | Number | Não | - |
| **Ativo** | `Ativo` | Boolean | Não | - |

*(Campos de Auditoria e Remoção Lógica)*
| Display Name | Internal Name | Tipo SharePoint | Obrigatório | Detalhes |
| :--- | :--- | :--- | :---: | :--- |
| **Deleted** | `Deleted` | Boolean | Não | Default: `0` (`false`). |
| **DeletedAt** | `DeletedAt` | DateTime | Não | - |
| **DeletedReason** | `DeletedReason` | Note (Multi) | Não | - |
| **DeletedByUPN** | `DeletedByUPN` | Text | Não | - |

---

## 3. Status Diario

Histórico de reports de andamento, normalmente via automação, forms ou bot.

| Display Name | Internal Name (Obrigatório em APIs) | Tipo SharePoint | Obrigatório | Detalhes e Valores Permitidos |
| :--- | :--- | :--- | :---: | :--- |
| **StatusID** | `StatusID` | Text | **Sim** | Chave principal de negócio. Indexado. |
| **ProjectID** | `ProjectID` | Text | **Sim** | Chave Estrangeira do Projeto. Indexado. |
| **DataRegistro** | `DataRegistro` | DateTime | **Sim** | Indexado. |
| **PM** | `PM` | User (Person) | Não | Resolve via Claims do Entra ID. Indexado. |
| **RAG** | `RAG` | Choice | **Sim** | `Verde`, `Amarelo`, `Vermelho` |
| **Resumo** | `Resumo` | Note (Multi) | **Sim** | - |
| **Risco** | `Risco` | Note (Multi) | Não | - |
| **Bloqueio** | `Bloqueio` | Note (Multi) | Não | - |
| **ProximaAcao** | `ProximaAcao` | Note (Multi) | Não | - |
| **Percentual** | `Percentual` | Number | Não | - |
| **OrigemEntrada** | `OrigemEntrada` | Choice | **Sim** | `AdaptiveCard`, `CopilotStudio`, `FormsFallback`, `ManualPMO`, `ImportacaoInicial` |
| **ResumoTarefas** | `ResumoTarefas` | Note (Multi) | Não | - |
| **CardVersion** | `CardVersion` | Text | Não | Utilizado pela automação de Adaptive Cards. |

*(Campos de Auditoria e Remoção Lógica)*
| Display Name | Internal Name | Tipo SharePoint | Obrigatório | Detalhes |
| :--- | :--- | :--- | :---: | :--- |
| **Deleted** | `Deleted` | Boolean | Não | Default: `0` (`false`). |
| **DeletedAt** | `DeletedAt` | DateTime | Não | - |
| **DeletedReason** | `DeletedReason` | Note (Multi) | Não | - |
| **DeletedByUPN** | `DeletedByUPN` | Text | Não | - |

---

## 4. Riscos e Bloqueios

Centralização de mitigação técnica de riscos e registro de obstáculos (bloqueios).

| Display Name | Internal Name (Obrigatório em APIs) | Tipo SharePoint | Obrigatório | Detalhes e Valores Permitidos |
| :--- | :--- | :--- | :---: | :--- |
| **RiskID** | `RiskID` | Text | **Sim** | Chave principal de negócio. Indexado. |
| **ProjectID** | `ProjectID` | Text | **Sim** | Chave Estrangeira do Projeto. Indexado. |
| **Tipo** | `Tipo` | Choice | **Sim** | `Risco`, `Bloqueio` |
| **Severidade** | `Severidade` | Choice | **Sim** | `Baixa`, `Media`, `Alta`, `Critica` (Indexado) |
| **Descricao** | `Descricao` | Note (Multi) | **Sim** | - |
| **Impacto** | `Impacto` | Choice | Não | `Baixo`, `Medio`, `Alto`, `Critico` |
| **Probabilidade** | `Probabilidade` | Choice | Não | `Baixa`, `Media`, `Alta` |
| **Owner** | `Owner` | User (Person) | Não | Resolve via Claims do Entra ID. |
| **DataCriacao** | `DataCriacao` | DateTime | **Sim** | - |
| **SLA** | `SLA` | DateTime | Não | Formato DateOnly. |
| **Status** | `StatusRisco` | Choice | **Sim** | `Aberto`, `Em Mitigacao`, `Escalado`, `Resolvido`, `Aceito` (Indexado) |
| **PlanoMitigacao**| `PlanoMitigacao` | Note (Multi) | Não | - |
| **EscaladoPara** | `EscaladoPara` | User (Person) | Não | Resolve via Claims do Entra ID. |

*(Campos de Auditoria e Remoção Lógica)*
| Display Name | Internal Name | Tipo SharePoint | Obrigatório | Detalhes |
| :--- | :--- | :--- | :---: | :--- |
| **Deleted** | `Deleted` | Boolean | Não | Default: `0` (`false`). |
| **DeletedAt** | `DeletedAt` | DateTime | Não | - |
| **DeletedReason** | `DeletedReason` | Note (Multi) | Não | - |
| **DeletedByUPN** | `DeletedByUPN` | Text | Não | - |

---

## 5. Decisões do Board

Controle formal de processos decisórios escalados para instâncias superiores.

| Display Name | Internal Name (Obrigatório em APIs) | Tipo SharePoint | Obrigatório | Detalhes e Valores Permitidos |
| :--- | :--- | :--- | :---: | :--- |
| **DecisionID** | `DecisionID` | Text | **Sim** | Chave principal de negócio. Indexado. |
| **ProjectID** | `ProjectID` | Text | **Sim** | Chave Estrangeira do Projeto. Indexado. |
| **Descricao** | `Descricao` | Note (Multi) | **Sim** | - |
| **Solicitante** | `Solicitante` | User (Person) | **Sim** | Resolve via Claims do Entra ID. |
| **Aprovador** | `Aprovador` | User (Person) | **Sim** | Resolve via Claims do Entra ID. |
| **Prazo** | `Prazo` | DateTime | Não | Formato DateOnly. |
| **Status** | `StatusDecisao` | Choice | **Sim** | `Pendente`, `Aprovada`, `Rejeitada`, `Adiada`, `Cancelada` (Indexado) |
| **Resposta** | `Resposta` | Note (Multi) | Não | - |
| **DataResposta** | `DataResposta` | DateTime | Não | - |
| **Impacto** | `Impacto` | Choice | Não | `Baixo`, `Medio`, `Alto`, `Critico` |
| **Justificativa** | `Justificativa` | Note (Multi) | Não | - |
| **ApproverUPN** | `ApproverUPN` | Text | Não | - |
| **CardVersion** | `CardVersion` | Text | Não | Utilizado pela automação de Adaptive Cards. |
| **ResponseSource**| `ResponseSource` | Choice | Não | `AdaptiveCard`, `CopilotStudio`, `Manual` |

*(Campos de Auditoria e Remoção Lógica)*
| Display Name | Internal Name | Tipo SharePoint | Obrigatório | Detalhes |
| :--- | :--- | :--- | :---: | :--- |
| **Deleted** | `Deleted` | Boolean | Não | Default: `0` (`false`). |
| **DeletedAt** | `DeletedAt` | DateTime | Não | - |
| **DeletedReason** | `DeletedReason` | Note (Multi) | Não | - |
| **DeletedByUPN** | `DeletedByUPN` | Text | Não | - |
