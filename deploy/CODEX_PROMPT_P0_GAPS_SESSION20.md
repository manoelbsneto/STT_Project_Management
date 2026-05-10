# CODEX SESSION 20 — P0 GAP Closure Mission

**Data:** 2026-05-10
**Prioridade:** P0 — Ship blocker
**Escopo:** 6 GAPs pendentes (B1, B2, B3, B4, B5, B6)
**Método:** Todos programáticos (YAML para Code Editor `</>` do Copilot Studio)
**Constraint Principal:** SOMENTE usar padrões documentados na documentação oficial da Microsoft. Quando houver dúvida, consultar a documentação oficial antes de implementar.

---

## CONTEXTO OBRIGATÓRIO

### Ambiente
- **Bot:** Assistente PMO Clean (V2) — Copilot Studio
- **Environment:** `ColOfertasBrasilPro` (ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- **SharePoint Site:** `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
- **Repo:** `d:\VMs\Projetos\STT_Project_Management` | branch `main`
- **Linguagem do bot:** pt-BR
- **Modelo NLU:** GPT-4.1 (NÃO usar GPT-5 Chat)

### Regras Invioláveis
1. **Standard connectors ONLY** — Sem Premium, sem Graph API, sem HTTP with Entra ID.
2. **ASCII-Only** — Sem emoji, sem acentos, sem cedilha em texto operacional de flows/bot.
3. **Confirm-Before-Action** — Obrigatório em TODOS os tópicos de escrita (PRD §9.3).
4. **Logical Delete** — Todos os SP writes devem setar `Deleted=false` no item criado. Todas as SP reads devem filtrar `Deleted ne true`.
5. **PowerFx regex** — Somente padrões suportados pelo engine do Copilot Studio. Referência: https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-ismatch
6. **Entity types** — Usar `StringPrebuiltEntity` para texto livre, `NumberPrebuiltEntity` para números. NUNCA usar `BooleanPrebuiltEntity` (quebra STT).
7. **Confirmação** — Usar pattern `StringPrebuiltEntity` + `Or(Lower(Trim(var)) = "sim", ...)`. Referência: `deploy/CriarTarefa_topic_VALIDATED.yaml` linhas 141-159.
8. **Flow invocation** — Usar `InvokeFlowAction` com `flowId` real. Cada flow DEVE ser criado ANTES no Power Automate via Classic Designer e o `flowId` obtido da URL.

### Gold Standard — Referência Obrigatória
O arquivo `deploy/CriarTarefa_topic_VALIDATED.yaml` é o padrão validado e testado em produção. TODOS os novos tópicos devem seguir exatamente a mesma estrutura YAML, os mesmos patterns de PowerFx, e o mesmo fluxo de confirmação. Não inventar patterns novos.

### Documentação Oficial Microsoft (Consultar ANTES de implementar)
- **Power Fx IsMatch:** https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-ismatch
- **Copilot Studio YAML schema:** https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-create-edit-topics
- **Power Automate + SharePoint:** https://learn.microsoft.com/en-us/power-automate/sharepoint-overview
- **SharePoint REST API filtering:** https://learn.microsoft.com/en-us/sharepoint/dev/sp-add-ins/use-odata-query-operations-in-sharepoint-rest-requests
- **Copilot Studio variables:** https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-variables

---

## SHAREPOINT LISTS — SCHEMA COMPLETO

Os flows abaixo vão ler/escrever nestas listas. Os nomes de coluna (InternalName) são EXATOS.

### Lista 1: Projetos
| Coluna (InternalName) | Tipo | Obrigatório |
|---|---|---|
| ProjectID | Text | Sim |
| NomeProjeto | Text | Sim |
| PM | User | Sim |
| Sponsor | User | Não |
| StatusRAG | Choice (Verde/Amarelo/Vermelho) | Sim |
| Percentual | Number | Não |
| DataAlvo | DateTime (DateOnly) | Não |
| UltimaAtualizacao | DateTime | Não |
| Ativo | Boolean | Não |
| Unidade | Choice (TI/Digital/Dados/Infra/Seguranca) | Não |
| Prioridade | Choice (Alta/Media/Baixa/Critica) | Não |
| ResumoExecutivo | Note | Não |
| DiasSemUpdate | Number | Não |
| Deleted | Boolean | Não (default: false) |

### Lista 4: Riscos e Bloqueios
| Coluna (InternalName) | Tipo | Obrigatório |
|---|---|---|
| RiskID | Text | Sim |
| ProjectID | Text | Sim |
| Tipo | Choice (Risco/Bloqueio) | Sim |
| Severidade | Choice (Baixa/Media/Alta/Critica) | Sim |
| Descricao | Note | Sim |
| Impacto | Choice (Baixo/Medio/Alto/Critico) | Não |
| Probabilidade | Choice (Baixa/Media/Alta) | Não |
| Owner | User | Não |
| DataCriacao | DateTime | Sim |
| SLA | DateTime (DateOnly) | Não |
| StatusRisco | Choice (Aberto/Em Mitigacao/Escalado/Resolvido/Aceito) | Sim |
| PlanoMitigacao | Note | Não |
| EscaladoPara | User | Não |
| Deleted | Boolean | Não (default: false) |

### Lista 5: Decisoes do Board
| Coluna (InternalName) | Tipo | Obrigatório |
|---|---|---|
| DecisionID | Text | Sim |
| ProjectID | Text | Sim |
| Descricao | Note | Sim |
| Solicitante | User | Sim |
| Aprovador | User | Sim |
| Prazo | DateTime (DateOnly) | Não |
| StatusDecisao | Choice (Pendente/Aprovada/Rejeitada/Adiada/Cancelada) | Sim |
| Resposta | Note | Não |
| DataResposta | DateTime | Não |
| Impacto | Choice (Baixo/Medio/Alto/Critico) | Não |
| Justificativa | Note | Não |
| ApproverUPN | Text | Não |
| Deleted | Boolean | Não (default: false) |

### Lista 3: Status Diario
| Coluna (InternalName) | Tipo | Obrigatório |
|---|---|---|
| StatusID | Text | Sim |
| ProjectID | Text | Sim |
| DataRegistro | DateTime | Sim |
| PM | User | Não |
| RAG | Choice (Verde/Amarelo/Vermelho) | Sim |
| Resumo | Note | Sim |
| Risco | Note | Não |
| Bloqueio | Note | Não |
| ProximaAcao | Note | Não |
| Percentual | Number | Não |
| OrigemEntrada | Choice (AdaptiveCard/CopilotStudio/FormsFallback/ManualPMO/ImportacaoInicial) | Sim |
| Deleted | Boolean | Não (default: false) |

---

## GAP-B3: RegistrarRisco — Flow com SP Write

### Problema
O tópico `RegistrarRisco` no Copilot Studio pergunta os dados ao usuário e confirma, mas o flow NÃO grava no SharePoint. O redirect do Fallback funciona (testado Session 19), mas o flow é um stub.

### O que construir
Um tópico YAML completo que:
1. Captura `System.Activity.Text` no `Topic.RawInput`
2. Tenta parsear campos do texto livre via regex (mesmo pattern do CriarTarefa)
3. Pergunta campos faltantes um a um via `Question` + `StringPrebuiltEntity`
4. Exibe resumo e pede confirmação via `StringPrebuiltEntity` (pattern `sim/s/yes/confirmo`)
5. Se confirmado, invoca flow via `InvokeFlowAction`
6. O flow:
   - Recebe: `ProjectID` (text), `Descricao` (text), `Severidade` (text), `Impacto` (text)
   - Gera `RiskID` usando `GUID()` ou `concat("RSK-", formatDateTime(utcNow(), "yyyyMMddHHmmss"))`
   - Valida que o projeto existe na lista `Projetos` (filtro: `ProjectID eq '{input}' and Ativo eq 1 and Deleted ne true`)
   - Cria item na lista `Riscos e Bloqueios` com: RiskID, ProjectID, Tipo="Risco", Severidade, Descricao, Impacto, DataCriacao=utcNow(), StatusRisco="Aberto", Deleted=false
   - Retorna mensagem de sucesso ou erro

### Campos obrigatórios para o usuário
- **Projeto:** Nome do projeto (bot deve resolver para ProjectID fazendo lookup na lista Projetos)
- **Descricao:** Texto livre descrevendo o risco
- **Severidade:** Baixa, Media, Alta ou Critica

### Campos opcionais
- **Impacto:** Baixo, Medio, Alto ou Critico (default: não preenchido)

### Trigger queries recomendadas
```
registrar risco, novo risco, abrir risco, cadastrar risco, risco no projeto, risco em projeto, risco do projeto
```

### Recomendação de implementação
- **Flow:** Criar no Power Automate via Classic Designer (Standard). Trigger: "Run a flow from Copilot" (antigo "PowerVirtualAgents"). Ações: "Get items" (Projetos, filtrar por nome) → "Create item" (Riscos e Bloqueios) → "Respond to Copilot" com mensagem.
- **Topic YAML:** Seguir exatamente o pattern do `CriarTarefa_topic_VALIDATED.yaml`. Salvar como `deploy/copilot/RegistrarRisco_topic.yaml`.

---

## GAP-B4: RegistrarBloqueio — Flow com SP Write

### Problema
Mesmo que B3, mas para Bloqueios. O tópico deve gravar na MESMA lista `Riscos e Bloqueios` com `Tipo="Bloqueio"`.

### O que construir
Idêntico ao GAP-B3, mas:
- `Tipo` fixo = `"Bloqueio"` (não perguntar ao usuário)
- `RiskID` prefixo = `"BLK-"` em vez de `"RSK-"`
- Trigger queries: `registrar bloqueio, novo bloqueio, abrir bloqueio, cadastrar bloqueio, bloqueio no projeto`

### Recomendação
Pode ser o MESMO flow do RegistrarRisco com um parâmetro `Tipo` adicional, OU um flow separado. Se usar o mesmo flow, o topic passa `Tipo="Bloqueio"` no binding. Se flow separado, criar `PMO_PA_RegistrarBloqueioBot`.

Salvar YAML como: `deploy/copilot/RegistrarBloqueio_topic.yaml`

---

## GAP-B5: PedirDecisao — Flow com SP Write

### Problema
O tópico `PedirDecisao` confirma mas não grava na lista `Decisoes do Board`.

### O que construir
Um tópico YAML que:
1. Captura `System.Activity.Text`
2. Parseia campos via regex
3. Pergunta campos faltantes
4. Confirma com `StringPrebuiltEntity`
5. Invoca flow que grava no SP

### Campos obrigatórios para o usuário
- **Projeto:** Nome do projeto (resolver para ProjectID)
- **Descricao:** O que precisa ser decidido
- **Impacto:** Baixo, Medio, Alto ou Critico

### Campos opcionais
- **Prazo:** Data limite para a decisão (formato dd/mm/aaaa)

### O flow deve
- Receber: ProjectID, Descricao, Impacto, Prazo (opcional)
- Gerar `DecisionID` = `concat("DEC-", formatDateTime(utcNow(), "yyyyMMddHHmmss"))`
- Validar projeto existe
- Buscar PM do projeto para setar como `Solicitante`
- Criar item em `Decisoes do Board` com: DecisionID, ProjectID, Descricao, Solicitante=PM do projeto, StatusDecisao="Pendente", Impacto, Prazo (se fornecido), Deleted=false
- **Nota:** O campo `Aprovador` (User, Required) é um problema — o Standard connector não consegue setar User fields via flow facilmente. Recomendação: se não for possível setar Aprovador via Standard, usar `ApproverUPN` (Text) como campo alternativo e deixar `Aprovador` vazio ou pre-setado.

### Trigger queries
```
solicitar decisao, pedir decisao, registrar decisao, nova decisao, preciso de uma decisao, decisao para projeto, solicitar aprovacao, pedir aprovacao
```

Salvar YAML como: `deploy/copilot/PedirDecisao_topic.yaml`

---

## GAP-B2: ConsultarProjeto — Flow com SP Read

### Problema
O tópico `ConsultarProjeto` é um stub. Deveria consultar a lista `Projetos` pelo nome e retornar detalhes.

### O que construir
Um tópico YAML que:
1. Captura nome do projeto do `System.Activity.Text`
2. Pergunta qual projeto se não detectado
3. **NÃO precisa de confirmação** (é leitura, não escrita — PRD §9.3 só exige confirm em writes)
4. Invoca flow que busca no SP

### O flow deve
- Receber: `NomeProjeto` (text)
- Buscar na lista `Projetos`: filtro `substringof('{NomeProjeto}', NomeProjeto) and Ativo eq 1 and Deleted ne true`
- **ATENÇÃO:** Verificar na documentação oficial do SharePoint REST API se `substringof` é suportado pelo conector "Get items" do Power Automate Standard. Se não, usar filtro exato: `NomeProjeto eq '{NomeProjeto}' and Ativo eq 1 and Deleted ne true`. Referência: https://learn.microsoft.com/en-us/sharepoint/dev/sp-add-ins/use-odata-query-operations-in-sharepoint-rest-requests
- Se encontrou: retornar string formatada com ProjectID, NomeProjeto, PM, StatusRAG, Percentual, DataAlvo, Prioridade, UltimaAtualizacao
- Contar riscos abertos: "Get items" de `Riscos e Bloqueios` com filtro `ProjectID eq '{ProjectID}' and Tipo eq 'Risco' and StatusRisco eq 'Aberto' and Deleted ne true`
- Se não encontrou: retornar mensagem "Projeto nao encontrado."

### Trigger queries
```
consultar projeto, ver projeto, detalhes do projeto, status do projeto, como esta o projeto
```

Salvar YAML como: `deploy/copilot/ConsultarProjeto_topic.yaml`

---

## GAP-B1: ConsultarPortfolio — Validar/Rebuild Flow com SP Read

### Problema
O tópico `ConsultarPortfolio` existe e o redirect funciona (testado Session 19), mas a resposta parece ser texto template, não dados reais do SharePoint. Pode ser que o flow faça query real mas formate mal, ou que seja stub.

### O que construir
Validar se o flow atual (`ConsultarPortfolio`) faz queries reais. Se stub, reconstruir:

### O flow deve
- **NÃO receber parâmetros** (portfolio é overview geral)
- Fazer 4 queries "Get items" na lista `Projetos`:
  1. `Ativo eq 1 and StatusRAG eq 'Verde' and Deleted ne true` → contar resultados
  2. `Ativo eq 1 and StatusRAG eq 'Amarelo' and Deleted ne true` → contar resultados
  3. `Ativo eq 1 and StatusRAG eq 'Vermelho' and Deleted ne true` → contar resultados
  4. `Ativo eq 1 and Deleted ne true` → contar total
- Montar string de resposta: `"Portfolio PMO:\n Verde: {count1} projetos\n Amarelo: {count2} projetos\n Vermelho: {count3} projetos\n Total: {count4} projetos ativos"`
- Retornar via "Respond to Copilot"

### ATENÇÃO
- Para contar resultados de "Get items", usar a expressão `length(body('Get_items')?['value'])` no Power Automate. Referência: https://learn.microsoft.com/en-us/power-automate/use-expressions-in-conditions
- O conector SharePoint "Get items" Standard suporta OData filter. Consultar: https://learn.microsoft.com/en-us/connectors/sharepointonline/#get-items

### Trigger queries
```
consultar portfolio, ver portfolio, portfolio pmo, resumo do portfolio, resumo portfolio, como esta o portfolio, dashboard, visao geral
```

Salvar YAML como: `deploy/copilot/ConsultarPortfolio_topic.yaml`

---

## GAP-B6: AtualizarStatus — Redesign para STT Long-Text

### Problema
O tópico `AtualizarStatus` pede cada campo individualmente (campo a campo), o que é incompatível com input de voz (STT). Deveria aceitar uma mensagem longa e parsear os campos.

### O que construir
Redesign do tópico seguindo o MESMO pattern do CriarTarefa:
1. Captura `System.Activity.Text` em `Topic.RawInput`
2. Parseia via regex:
   - `projeto` ou `project` → `Topic.Projeto`
   - `status` ou `rag` → `Topic.RAG`
   - `resumo` → `Topic.Resumo`
   - `percentual` ou `percent` → `Topic.Percentual`
   - `risco` → `Topic.Risco`
   - `bloqueio` → `Topic.Bloqueio`
   - `proxima acao` ou `proximo passo` → `Topic.ProximaAcao`
3. Pergunta campos faltantes (apenas obrigatórios: Projeto, RAG, Resumo)
4. Confirma (StringPrebuiltEntity pattern)
5. Invoca flow

### O flow deve
- Receber: NomeProjeto (text), RAG (text), Resumo (text), Percentual (number, opcional), Risco (text, opcional), Bloqueio (text, opcional), ProximaAcao (text, opcional)
- Buscar ProjectID na lista `Projetos` pelo nome
- Gerar StatusID = `concat("STU-", formatDateTime(utcNow(), "yyyyMMddHHmmss"))`
- Criar item em `Status Diario`: StatusID, ProjectID, DataRegistro=utcNow(), RAG, Resumo, Percentual, Risco, Bloqueio, ProximaAcao, OrigemEntrada="CopilotStudio", Deleted=false
- Atualizar o projeto na lista `Projetos`: StatusRAG=RAG, Percentual, UltimaAtualizacao=utcNow()
- Retornar mensagem de sucesso

### Regex patterns recomendados (validados no engine)
```
projeto\s*[:=]\s*(?<v>[^,\r\n]+)
status\s*[:=]\s*(?<v>[^,\r\n]+)
resumo\s*[:=]\s*(?<v>[^,\r\n]+)
percentual\s*[:=]\s*(?<v>\d+(?:[.,]\d+)?)
risco\s*[:=]\s*(?<v>[^,\r\n]+)
bloqueio\s*[:=]\s*(?<v>[^,\r\n]+)
proxima\s+acao\s*[:=]\s*(?<v>[^,\r\n]+)
```

### Trigger queries
```
atualizar status, update status, check-in, checkin, status do projeto, reportar status, enviar status, fazer checkin
```

Salvar YAML como: `deploy/copilot/AtualizarStatus_topic.yaml`

---

## ENTREGÁVEIS ESPERADOS

Para CADA GAP (B1-B6), entregar:

1. **YAML do tópico** em `deploy/copilot/{NomeTopic}_topic.yaml`
   - Seguindo EXATAMENTE o pattern do `CriarTarefa_topic_VALIDATED.yaml`
   - Com triggerQueries em pt-BR
   - Com confirmação via StringPrebuiltEntity (para topics de escrita)
   - SEM BooleanPrebuiltEntity
   - SEM emoji/acentos no texto operacional

2. **Instruções do flow** em `deploy/copilot/{NomeTopic}_FLOW_INSTRUCTIONS.md`
   - Step-by-step para criar o flow no Power Automate Classic Designer
   - Quais ações usar (Get items, Create item, Update item, etc.)
   - Quais filtros OData aplicar
   - Como montar a string de resposta
   - Input/output schema do "Respond to Copilot"

3. **Nota:** NÃO tentar criar o flow via PowerShell/API (já tentamos na Session 17 e deu timeout). O flow será criado manualmente via Classic Designer pelo usuário. O YAML será colado no Code Editor (`</>`) do Copilot Studio.

---

## ORDEM DE EXECUÇÃO

1. **GAP-B3** — RegistrarRisco (escrita, mais crítico)
2. **GAP-B4** — RegistrarBloqueio (mesma lista que B3, pode reaproveitar)
3. **GAP-B5** — PedirDecisao (escrita em lista diferente)
4. **GAP-B2** — ConsultarProjeto (leitura com lookup)
5. **GAP-B1** — ConsultarPortfolio (leitura com aggregation)
6. **GAP-B6** — AtualizarStatus (redesign de topic existente)

---

## VALIDAÇÃO

Após criar cada YAML:
1. Verificar que NÃO contém `BooleanPrebuiltEntity`
2. Verificar que todas as condições usam `=Or(...)` ou `=IsBlank(...)` (patterns validados)
3. Verificar que regex usa apenas `.`, `\s`, `\d`, `(?<v>...)`, `[^,\r\n]`, `[:=]` (patterns validados no engine)
4. Verificar que NÃO usa `[- ]` ou character classes com hífen (causa PowerFxError)
5. Verificar que texto operacional é ASCII-only
6. Verificar que `flowId` está como placeholder `REPLACE_WITH_ACTUAL_FLOW_ID` (será preenchido após criar o flow)

---

## REFERÊNCIAS NO REPOSITÓRIO

| Arquivo | Propósito |
|---|---|
| `deploy/CriarTarefa_topic_VALIDATED.yaml` | Gold standard — padrão de topic YAML validado |
| `deploy/copilot/Fallback_SmartRedirect.yaml` | Fallback com redirect para estes tópicos |
| `deploy/copilot/ConversationStart_Warmup.yaml` | Greeting warm-up |
| `deploy/SP_Provisioning.ps1` | Schema completo das 5 listas SP |
| `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md` | Plano geral com contexto |
| `.planning/stop_ship/MASTER_CHECKLIST.md` | Checklist atualizado |

---

*Fim do prompt. Codex deve entregar 6 YAMLs + 6 instruções de flow, todos validados contra o gold standard e documentação oficial Microsoft.*
