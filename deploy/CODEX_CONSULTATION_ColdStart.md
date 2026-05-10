Temos um problema de cold start confirmado no bot Assistente PMO V2 (Copilot Studio). Toda vez que uma sessão nova é iniciada, a primeira mensagem do usuário falha no reconhecimento de intenção e cai no Fallback Topic ("Não entendi bem..."). A segunda mensagem idêntica funciona perfeitamente.

Exemplo real do teste de hoje (2026-05-10):
- 1ª tentativa: "criar tarefa: titulo=Teste Fix Codex, responsavel=Manoel Benicio, prazo=2026/05/31, horas=4, prioridade=Alta" → FALHOU (Fallback)
- 2ª tentativa: mesma frase → SUCESSO (parseou campos, confirmou, invocou flow, criou projeto)

A documentação Microsoft confirma que isso é cold start do NLU — o modelo de reconhecimento não está carregado na 1ª mensagem da sessão.

Preciso que você:

1. Analise o arquivo `deploy/CriarTarefa_topic_VALIDATED.yaml` (nosso tópico validado e funcionando)

2. Crie dois novos arquivos YAML no diretório `deploy/copilot/`:
   - `ConversationStart_Warmup.yaml` — Tópico de boas-vindas que força o NLU a inicializar antes do primeiro comando real do usuário
   - `Fallback_SmartRedirect.yaml` — Tópico Fallback inteligente que detecta padrões ("criar tarefa", "atualizar status", "consultar portfolio", "registrar risco", "solicitar decisao") no texto não reconhecido e redireciona para o tópico correto em vez de mostrar erro genérico

3. Garanta que o Fallback redirect NÃO cause loops infinitos e NÃO interfira com os outros tópicos existentes

4. Documente no header de cada YAML o propósito e como fazer deploy no Copilot Studio

O formato YAML deve seguir o padrão AdaptiveDialog do Copilot Studio, igual ao CriarTarefa_topic_VALIDATED.yaml.
