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

## Topicos do bot

| Topico | Objetivo | Exemplo de entrada |
|---|---|---|
| CriarTarefa | Criar projeto/tarefa na lista `Projetos` | `Criar tarefa: Titulo=Projeto Alpha, Responsavel=usuario@empresa.com, Prazo=30/06/2026, Horas=100, Prioridade=Alta` |
| AtualizarStatus | Enviar atualizacao de status do projeto | `Atualizar status: Projeto=Projeto Alpha, Verde, Resumo=sem desvios, Risco=nao, Acao=manter plano, Percentual=35` |
| ConsultarPortfolio | Ver resumo RAG do portfolio ativo | `como esta o portfolio` |
| ConsultarProjeto | Consultar detalhes de um projeto | `consultar projeto` |
| RegistrarRisco | Registrar risco aberto em `Riscos e Bloqueios` | `registrar risco` |
| RegistrarBloqueio | Registrar bloqueio aberto em `Riscos e Bloqueios` | `registrar bloqueio` |
| PedirDecisao | Solicitar decisao do board em `Decisoes do Board` | `preciso de uma decisao` |
| ListarTarefas | Listar tarefas de um projeto quando disponivel no bot publicado | `listar tarefas do projeto` |

## Fluxo operacional por topico

### CriarTarefa

1. Envie os campos principais em uma unica mensagem quando possivel.
2. O bot valida campos ausentes e pergunta somente o que faltar.
3. O bot mostra um resumo e pede confirmacao.
4. Ao responder `sim`, o fluxo cria item em `Projetos`.
5. O retorno esperado inclui codigo `ProjectID`.

Campos esperados:

| Campo | Regra |
|---|---|
| Titulo | Nome curto e claro do projeto/tarefa |
| Responsavel | UPN/email do PM |
| Prazo | `dd/MM/yyyy` ou ISO |
| Horas | Numero |
| Prioridade | `Baixa`, `Media`, `Alta` ou `Critica` |

### AtualizarStatus

Use texto longo ou voz com estes campos:

```text
Atualizar status: Projeto=Projeto Alpha, Verde, Resumo=entrega em dia, Risco=nao, Acao=seguir plano, Percentual=40
```

O bot deve capturar o texto completo, extrair campos conhecidos e perguntar somente os ausentes.

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
| CriarTarefa confirma mas nao cria item | V3 ainda esta stub ou falha no SharePoint Create item | Verificar run history do fluxo e item em `Projetos` |
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
- V3 CriarTarefa gravar em `Projetos` com controle de duplicidade.
- Confirmacao por `sim/s/yes/confirmo` estar publicada e testada.
- Ghost bot components estarem limpos ou formalmente aceitos pelo responsavel.
- Evidencias runtime estarem anexadas ao pacote de release.
