# Contexto Completo do Problema

Temos um bot chamado "Assistente PMO V2" no Microsoft Copilot Studio. Ele gerencia projetos PMO com tópicos como CriarTarefa, AtualizarStatus, ConsultarPortfolio, RegistrarRisco e PedirDecisao. Cada tópico tem trigger phrases e invoca Power Automate flows para gravar dados no SharePoint.

## O Bug: Cold Start na Primeira Mensagem

Toda vez que uma sessão nova é iniciada no bot, a PRIMEIRA mensagem do usuário falha no reconhecimento de intenção e cai no tópico Fallback genérico ("Não entendi bem..."). A SEGUNDA mensagem idêntica funciona perfeitamente — parsing, confirmação, invocação do flow e gravação no SharePoint.

Teste real de 2026-05-10:
- 1ª tentativa: "criar tarefa: titulo=Teste Fix Codex, responsavel=Manoel Benicio, prazo=2026/05/31, horas=4, prioridade=Alta" → FALHOU (Fallback)
- 2ª tentativa: mesma frase → SUCESSO

A documentação Microsoft confirma que isso é cold start do NLU — o modelo de reconhecimento de intenção não está carregado na 1ª mensagem.

## Solução Planejada: 2 Arquivos YAML

Para mitigar o cold start, criamos dois arquivos YAML para deploy no Copilot Studio:

### Arquivo 1: `deploy/copilot/ConversationStart_Warmup.yaml`
- **PROPÓSITO**: Tópico de boas-vindas que envia uma mensagem ao usuário quando a sessão inicia, ANTES do usuário digitar qualquer coisa. Isso dá tempo ao NLU para inicializar.
- **ONDE APLICAR NO COPILOT STUDIO**: Tópico de sistema "Greeting" (aba Personalizado). NÃO no LowConfidence.
- **COMO APLICAR**: Abrir o tópico Greeting → Code Editor (</>) → substituir YAML → salvar

### Arquivo 2: `deploy/copilot/Fallback_SmartRedirect.yaml`
- **PROPÓSITO**: Rede de segurança. Se mesmo com o Greeting o NLU falhar na 1ª mensagem, este Fallback detecta padrões conhecidos ("criar tarefa", "atualizar status", etc.) no texto do usuário via regex e redireciona para o tópico correto em vez de mostrar erro genérico.
- **ONDE APLICAR NO COPILOT STUDIO**: Tópico de sistema "LowConfidence" (aba Sistema). Este é o Fallback do bot.
- **COMO APLICAR**: Abrir o tópico LowConfidence → Code Editor (</>) → substituir YAML → salvar

## O Problema Atual: 2 Erros PowerFx no Fallback

O arquivo `ConversationStart_Warmup.yaml` é simples e não tem erros.

O arquivo `Fallback_SmartRedirect.yaml` foi colado no tópico LowConfidence via Code Editor, mas o Topic Checker do Copilot Studio retornou **2 erros do tipo "PowerFxError"** na seção "Condição". O YAML não pode ser publicado até esses erros serem corrigidos.

Os erros aparecem visualmente nas branches de condição que usam `IsMatch()` com regex. Não tenho detalhes exatos de qual condição — só sei que são 2 erros PowerFxError em nós de Condição.

## Arquivo de Referência que FUNCIONA Sem Erros

O arquivo `deploy/CriarTarefa_topic_VALIDATED.yaml` já está publicado e funcionando no mesmo bot. Ele usa `IsMatch()` e `Match()` com `MatchOptions.IgnoreCase` e patterns regex complexos como:
```
=IsMatch(Topic.RawInput, "criar\\s+(?:tarefa|projeto)\\s*:\\s*(?:t.tulo\\s*=\\s*)?(?<v>[^,\\r\\n]+)", MatchOptions.IgnoreCase)
```
Este pattern funciona sem erro no PowerFx do Copilot Studio.

## Suspeitos Mais Prováveis

O regex do `detect_atualizar_status` na linha 66 do Fallback contém `check[- ]?in` — o character class `[- ]` (hyphen + space) pode ser inválido no PowerFx. Mas pode haver outros erros que não identifiquei.

## O Que Preciso

1. Abra `deploy/copilot/Fallback_SmartRedirect.yaml` e revise TODAS as 5 expressões `condition: =IsMatch(...)` 
2. Compare cada uma com a sintaxe do `deploy/CriarTarefa_topic_VALIDATED.yaml` que funciona
3. Identifique e corrija os 2 erros PowerFxError
4. Corrija o arquivo `deploy/copilot/Fallback_SmartRedirect.yaml` diretamente
5. NÃO altere a estrutura YAML (BeginDialog, ConditionGroup, OnUnknownIntent, etc.) — apenas corrija as expressões PowerFx nas condições
6. Se tiver dúvida sobre alguma sintaxe, erre para o lado conservador — use patterns mais simples que certamente funcionam no PowerFx

## Estrutura do Bot no Copilot Studio

Tópicos personalizados (10):
- AtualizarStatus, AtualizarTarefa, ConsultarPortfolio, ConsultarProjeto, CriarTarefa, Greeting, ListarTarefas, PedirDecisao, RegistrarBloqueio, RegistrarRisco

Tópicos de sistema (2):
- LowConfidence (Fallback)
- SeHouverErro (OnError)

Os nomes de dialog usados no BeginDialog do Fallback são:
- template-content.topic.CriarTarefa
- template-content.topic.AtualizarStatus
- template-content.topic.ConsultarPortfolio
- template-content.topic.RegistrarRisco
- template-content.topic.PedirDecisao

Esses prefixos precisam ser validados — se o bot usar outro schema prefix, os redirects falharão silenciosamente (sem erro PowerFx, mas sem funcionar).
