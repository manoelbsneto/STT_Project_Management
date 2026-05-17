# Manual Operacional PMO

Status: rascunho operacional
Ambiente: ColOfertasBrasilPro
Bot: Assistente PMO Clean
SharePoint: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital

## Objetivo

Este manual orienta PMs, PMO e aprovadores no uso do Assistente PMO para criar projetos, atualizar status, consultar portfolio, registrar riscos/bloqueios e solicitar decisoes do board.

## Regras de uso

- Use pt-BR em mensagens naturais.
- Para entradas por voz ou texto longo, prefira o formato `Campo=valor` separado por virgulas.
- Todo comando de gravacao exige confirmacao antes da execucao.
- Respostas aceitas para confirmar: `sim`, `s`, `yes`, `confirmo`.
- Respostas aceitas para cancelar: qualquer outra resposta clara de negativa, por exemplo `nao` ou `cancelar`.

## Regras obrigatorias para agentes

- Todo novo agente ou novo chat deve ler `.planning/GOLDEN_RULES.md`, `.planning/CURRENT_BASELINE.md` e `.planning/AGENT_CHECKIN_REGISTRY.md` antes de alterar codigo, deploy, importacao, publicacao, tenant ou decisao de release.
- Trabalho que altera comportamento PMO deve ler este manual antes de iniciar.
- Diligencia de ship e SEV-0. O padrao e NO-SHIP ate existir evidencia estatica e runtime do artefato atual.
- Comportamento de Power Platform, Copilot Studio, Power Automate, Dataverse, SharePoint, Teams, Graph, Entra e Microsoft 365 CLI deve ser validado por documentacao oficial Microsoft e evidencia do tenant.
- Nenhum agente pode importar, publicar, fazer deploy, commit, deletar, alterar portal/runtime ou escrever em producao sem aprovacao explicita por escrito do dono do projeto no chat atual.
- Edicoes locais, preparo local de pacote e testes locais sao permitidos; importacao em producao e validacao runtime ficam sob responsabilidade do dono do projeto salvo delegacao explicita por escrito.
- Nao declarar ship com evidencia ausente ou antiga, flow/topic ID obsoleto, ghost component pendente, placeholder, caminho de escrita confirm-only, risco de perda de dados, teste falho, ou texto app-facing nao ASCII onde ASCII e requerido.

## Topicos do bot

| Topico | Objetivo | Exemplo de entrada |
|---|---|---|
| CriarProjeto | Criar um projeto na lista `Projetos` | `criar projeto: NomeProjeto=Projeto Alpha, PM=usuario@empresa.com, Prazo=30/06/2026, Prioridade=Alta` |
| CriarTarefa | Criar uma tarefa na lista `Tarefas` vinculada a um projeto existente | `criar tarefa: projeto=Projeto Alpha, titulo=Validar kickoff, responsavel=usuario@empresa.com, prazo=30/06/2026, prioridade=Media` |
| Gerar_Multiplos_Projetos | Criar projetos em lote e tarefas iniciais por indice | `gerar multiplos projetos` seguido do bloco estruturado |
| AtualizarStatus | Enviar atualizacao de status do projeto | `Atualizar status: Projeto=Projeto Alpha, Verde, Resumo=sem desvios, Risco=nao, Acao=manter plano, Percentual=35` |
| ConsultarPortfolio | Ver resumo RAG do portfolio ativo | `como esta o portfolio` |
| ConsultarProjeto | Consultar detalhes de um projeto | `consultar projeto` |
| RegistrarRisco | Registrar risco aberto em `Riscos e Bloqueios` | `registrar risco` |
| RegistrarBloqueio | Registrar bloqueio aberto em `Riscos e Bloqueios` | `registrar bloqueio` |
| PedirDecisao | Solicitar decisao do board em `Decisoes do Board` | `preciso de uma decisao` |
| ListarTarefas | Listar tarefas de um projeto quando disponivel no bot publicado | `listar tarefas do projeto` |
| ExcluirProjeto | Remover projeto por soft-delete quando v1.14 estiver publicado | `excluir projeto: projeto=Projeto Alpha, motivo=registro criado por engano` |
| ExcluirTarefa | Remover uma linha de tarefa por soft-delete quando v1.14 estiver publicado | `excluir tarefa: projeto=Projeto Alpha, tarefa=Tarefa 123, motivo=linha incorreta` |

## Fluxo operacional por topico

### CriarProjeto

1. Envie os campos principais em uma unica mensagem quando possivel.
2. O Plano A e preencher/revisar um Adaptive Card.
3. O Plano B e enviar texto multilinha ou Speech-to-Text achatado.
4. O bot valida campos ausentes e pergunta somente o que faltar.
5. O bot mostra um resumo e pede confirmacao.
6. Ao confirmar, o fluxo cria item somente em `Projetos`.
7. O retorno esperado inclui codigo `ProjectID` e ID SharePoint do projeto.

Campos esperados:

| Campo | Regra |
|---|---|
| NomeProjeto | Nome curto e claro do projeto |
| PM | UPN/email do PM. Nome exibido so deve ser aceito se resolver uma pessoa unica. |
| Prazo | `dd/MM/aaaa` somente |
| Prioridade | `Baixa`, `Media`, `Alta` ou `Critica` |
| StatusRAG | `Verde`, `Amarelo` ou `Vermelho`; padrao `Verde` |
| Percentual | 0 a 100; padrao 0 |
| Ativo | `true` por padrao |

Observacoes:

- `ProjectID` e sempre definido pelo sistema. Se o usuario informar `ProjectID: sistema define automaticamente`, o texto deve ser aceito, mas o valor deve ser ignorado como input gravavel.
- `Created` e campo de sistema do SharePoint. Pode aparecer no texto para contexto/auditoria, mas nao deve ser sobrescrito pelo flow.
- Frases como `criar tarefa`, `nova tarefa` ou `adicionar tarefa` nao devem cair em `CriarProjeto`.

### CriarTarefa

1. O usuario informa um projeto existente e os dados da tarefa.
2. O Plano A e preencher/revisar um Adaptive Card.
3. O Plano B e enviar texto multilinha ou Speech-to-Text achatado.
4. O flow resolve `NomeProjeto` ou `ProjectID` contra `Projetos` ativo e `Deleted=false`.
5. Ao confirmar, o fluxo cria item somente em `Tarefas`.
6. O retorno esperado inclui ID SharePoint da tarefa e `ProjectID` vinculado.

Campos esperados:

| Campo | Regra |
|---|---|
| Projeto | NomeProjeto ou ProjectID existente em `Projetos` |
| Titulo | Nome curto e claro da tarefa |
| Responsavel | UPN/email do responsavel |
| Prazo | `dd/MM/aaaa` somente |
| Horas | Numero opcional |
| Prioridade | `Baixa`, `Media`, `Alta` ou `Critica`; padrao `Media` |
| Status | Padrao `Pendente` |

Regras obrigatorias:

- `CriarTarefa` nunca deve criar ou atualizar item em `Projetos`.
- Projeto inexistente, inativo ou deletado retorna erro de negocio e nao grava.
- Tarefa criada deve nascer com `Deleted=false`.

### Gerar_Multiplos_Projetos

Use quando precisar criar varios projetos e tarefas iniciais no mesmo comando.

Plano A:

1. O usuario inicia `gerar multiplos projetos`.
2. O bot abre Adaptive Card para preenchimento/revisao.
3. O card mostra quantidade de projetos, tarefas, duplicados e falhas de validacao.
4. Somente o botao de confirmacao grava no SharePoint.

Plano B:

O usuario pode colar texto multilinha ou usar Speech-to-Text. O parser deve aceitar:

```text
Criar projetos:
Nome_Projeto1: Teste Projetos multilinhas 1
Nome_Projeto2: Teste Projetos multilinhas 2
Nome_Projeto3: Teste Projetos multilinhas 3
ProjectID: sistema define automaticamente
PM: Benicio De Souza Filho, Manoel
Prioridade: Alta
StatusRAG: Verde
Percentual: 0
Ativo: true

Created: 2026-05-12
Criar Tarefas:
Tarefa1: Validar kickoff
Tarefa2: Preparar cronograma
Tarefa3: Confirmar sponsor
```

Regra de pareamento:

- `Nome_Projeto1` recebe `Tarefa1`.
- `Nome_Projeto2` recebe `Tarefa2`.
- `Nome_Projeto3` recebe `Tarefa3`.
- Limite inicial do pacote 2.4: ate 10 projetos e 10 tarefas no modo simples por indice.

Resultado esperado:

- Criar N itens em `Projetos`.
- Criar tarefas correspondentes em `Tarefas` usando o `ProjectID` gerado para cada projeto.
- Retornar resultado por linha com status, ProjectID, ID SharePoint do projeto e ID SharePoint da tarefa quando houver.
- Sucesso parcial deve ser explicito; falha em uma linha nao pode ser escondida como sucesso total.

### AtualizarStatus

Use texto longo ou voz com estes campos:

```text
Atualizar status: Projeto=Projeto Alpha, Verde, Resumo=entrega em dia, Risco=nao, Acao=seguir plano, Percentual=40
```

O bot deve capturar o texto completo, extrair campos conhecidos e perguntar somente os ausentes.

### ExcluirProjeto / ExcluirTarefa (v1.14 pendente)

Status: pendente/em progresso. Use somente depois que a versao v1.14 estiver importada, publicada e validada.

Regras esperadas:

- Nao excluir fisicamente linhas do SharePoint por padrao.
- Exigir correspondencia exata do projeto ou da tarefa antes da confirmacao.
- Exigir confirmacao explicita antes da remocao logica.
- Gravar `Deleted=true`, `DeletedAt`, `DeletedReason` e `DeletedByUPN`.
- Remover itens marcados como deletados das consultas ativas do PMO.

Mensagens de teste para release:

| Cenario | Mensagem | Resultado esperado |
|---|---|---|
| Excluir projeto | `excluir projeto: projeto=Projeto Smoke v113 Cancel, motivo=registro criado por engano no smoke` depois `sim` | Linha permanece no SharePoint com `Deleted=true`, campos de auditoria preenchidos e projeto fora das consultas ativas. |
| Cancelar exclusao de projeto | `excluir projeto: projeto=Projeto Smoke v113 Cancel, motivo=teste de cancelamento` depois `nao` | Nenhuma alteracao de delete; item continua ativo com `Deleted=false`. |
| Excluir tarefa especifica | `excluir tarefa: projeto=Projeto Smoke v113 Cancel, tarefa=<id ou titulo da tarefa>, motivo=linha incorreta` depois `sim` | Somente a tarefa alvo fica com `Deleted=true`; demais tarefas do projeto continuam ativas. |

### ConsultarPortfolio

Entrada recomendada:

```text
como esta o portfolio
```

Retorno esperado:

```text
Portfolio PMO: <total> projetos ativos. Verde: <n> | Amarelo: <n> | Vermelho: <n>. Projetos sem atualizacao (>24h): <n>.
```

### ConsultarProjeto

Entrada recomendada:

```text
consultar projeto
```

Informe o nome do projeto quando o bot perguntar. O retorno esperado inclui RAG, percentual, data alvo, PM, ultima atualizacao e quantidade de riscos abertos.

### RegistrarRisco

Campos:

| Campo | Regra |
|---|---|
| Projeto | Nome do projeto em `Projetos` |
| Descricao | Texto objetivo do risco |
| Severidade | `Baixa`, `Media`, `Alta` ou `Critica` |

Se a severidade for `Critica`, o fluxo de escalacao critica pode ser acionado automaticamente por evento do SharePoint.

### RegistrarBloqueio

Campos:

| Campo | Regra |
|---|---|
| Projeto | Nome do projeto em `Projetos` |
| Descricao | Texto objetivo do bloqueio |
| Impacto | `Baixo`, `Medio`, `Alto` ou `Critico` |

O item gravado usa `Tipo=Bloqueio` e `StatusRisco=Aberto`.

### PedirDecisao

Campos:

| Campo | Regra |
|---|---|
| Projeto | Nome do projeto em `Projetos` |
| Descricao | Decisao necessaria |
| Impacto | `Baixo`, `Medio`, `Alto` ou `Critico` |
| Prazo | Data limite |
| Aprovador | UPN/email do aprovador |

O item gravado em `Decisoes do Board` inicia como `StatusDecisao=Pendente`.

## Arquitetura operacional

```text
Usuario Teams
  -> Copilot Studio: Assistente PMO Clean
    -> Topico reconhecido
      -> Coleta/parse de campos
      -> Confirmacao obrigatoria
      -> Power Automate com trigger Copilot
        -> SharePoint Standard connector
          -> Listas PMO
        -> Resposta para Copilot
  -> Usuario recebe confirmacao ou erro
```

Listas principais:

| Lista | Uso |
|---|---|
| Projetos | Projetos ativos, RAG, PM, prazo, percentual |
| Riscos e Bloqueios | Riscos e bloqueios por projeto |
| Decisoes do Board | Solicitacoes de decisao e aprovacao |
| Status Diario | Atualizacoes periodicas quando aplicavel |

## Troubleshooting

| Sintoma | Causa provavel | Acao recomendada |
|---|---|---|
| Bot diz que fluxo nao foi encontrado | Topico aponta para flowId antigo ou flowId placeholder | Opus deve rebinder o topico no Copilot Studio e publicar |
| CriarProjeto confirma mas nao cria item | Flow falhou no SharePoint Create item | Verificar run history do fluxo e item em `Projetos` |
| CriarTarefa criou projeto por engano | Contrato antigo/ambiguidade de topico ainda publicado | Bloquear release; `CriarTarefa` deve gravar somente em `Tarefas` e frases de projeto devem ir para `CriarProjeto` |
| Gerar_Multiplos_Projetos cria parcialmente | Uma linha falhou validacao ou escrita | Consultar resultado por linha, corrigir dados e reprocessar somente itens pendentes |
| Pessoa PM nao grava | UPN invalido ou campo Person sem Claims | Usar email corporativo e verificar `PM/Claims` |
| Data nao filtra duplicado | Filtro usando igualdade em DateTime | Usar intervalo do dia com `ge` e `lt` |
| `sim` nao confirma por voz | Confirmacao ainda usa BooleanPrebuiltEntity no bot publicado | Publicar versao com StringPrebuiltEntity |
| Portfolio retorna vazio | `Ativo` nao marcado ou fluxo sem permissao na lista | Validar itens ativos e conexao SharePoint |
| Projeto nao encontrado | Nome nao bate com `NomeProjeto` | Consultar grafia no SharePoint |
| Fluxo falha por expressao | Uso de funcao nao suportada no tenant | Remover `padLeft` e usar expressao validada |

## Evidencia para release

Cada topico precisa de:

| Evidencia | Responsavel |
|---|---|
| Screenshot do topico vinculado ao fluxo correto | Opus |
| Publish do bot com sucesso | Opus |
| Chat de teste com entrada e confirmacao | Opus |
| Run URL verde no Power Automate | Opus |
| Item criado/consultado no SharePoint quando aplicavel | Opus |
| Resultado dos testes estaticos no repo | Codex |

## Criterio de ship

O sistema permanece NO-SHIP ate:

- Todos os topicos PRD estarem funcionais.
- Nenhum topico de escrita ficar em modo confirm-only.
- `CriarProjeto` gravar em `Projetos` com controle de duplicidade.
- `CriarTarefa` gravar somente em `Tarefas` e nunca em `Projetos`.
- `Gerar_Multiplos_Projetos` validar lote por Adaptive Card antes de qualquer escrita e suportar texto multilinha/STT como fallback.
- Confirmacao por `sim/s/yes/confirmo` estar publicada e testada.
- Ghost bot components estarem limpos ou formalmente aceitos pelo responsavel.
- Evidencias runtime estarem anexadas ao pacote de release.
