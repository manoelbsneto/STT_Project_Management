# FAQ — Perguntas Frequentes do Assistente PMO v3.16

Last updated: 2026-05-22 20:35:00 BRT | Gemini sub-2 | FAQ Drafted

---

## 1. Dúvidas Gerais e Funcionalidades

### Q01: O que mudou do Assistente PMO antigo para a versão 3.16?
Na versão antiga, o Assistente tentava interpretar mensagens longas em texto livre, o que causava atrasos de processamento, falhas de leitura e erros de segurança. Na versão 3.16, implantamos uma interface baseada em formulários visuais chamados **Microsoft Adaptive Cards**, que garantem 100% de estabilidade de dados e preenchimento em segundos.

### Q02: Como faço para abrir o Assistente PMO no Teams?
Basta abrir o canal oficial `Projetos_Transformacao_Digital` e iniciar uma conversa digitando qualquer palavra ou os comandos listados no cheat sheet, como `Atualizar Status` ou `Listar Tarefas`.

### Q03: As novas telas funcionam em celulares e tablets?
Sim, o Teams renderiza os cartões adaptativos nativamente em todas as plataformas compatíveis (Teams Mobile para Android e iOS, iPadOS, macOS e navegadores da Web).

### Q04: Por que o robô não responde a perguntas complexas em linguagem natural?
Para assegurar a integridade dos dados operacionais gravados no SharePoint da organização, priorizamos comandos rápidos estruturados nesta release. As conversações abertas e consultas corporativas mais abrangentes serão expandidas nas próximas fases.

### Q05: Há custos adicionais de licenças para utilizar o novo Assistente?
Não. A solução foi projetada sob uma diretriz estrita de **conectores Standard (Standard-Only)** da Microsoft Power Platform, garantindo custo de licenciamento adicional de zero reais para o nosso orçamento corporativo.

---

## 2. Preenchimento de Dados e Validações

### Q06: Posso usar letras acentuadas (como á, õ, ç) nos campos do cartão?
Recomendamos fortemente preencher os dados utilizando caracteres padrão US-ASCII (sem acentuações ou símbolos especiais). Isso previne distorções visuais ou falhas de serialização no banco de dados e no Teams.

### Q07: Qual é o tamanho máximo de texto nos campos de Destaque ou Comentários?
O limite de tamanho recomendado para textos livres é de **500 caracteres** para garantir que o processamento do cartão de resposta permaneça rápido e abaixo dos limites corporativos do Teams.

### Q08: Como o Assistente valida a atribuição de responsáveis por tarefas?
O Assistente realiza uma verificação direta no banco de dados SharePoint baseada no e-mail UPN da organização. Certifique-se de digitar o e-mail completo do responsável (exemplo: `usuario@stt.com`) para evitar falhas de gravação.

### Q09: O que acontece se eu digitar um ID de Projeto inválido?
O Assistente retornará uma mensagem de erro indicando que o projeto não foi localizado em nossa base oficial. Utilize a função de listagem para validar os códigos corretos.

### Q10: Como as tarefas criadas pelo Assistente se integram ao Planner?
Os fluxos automatizados em segundo plano utilizam conexões padrão para sincronizar indicadores e tarefas básicas entre o site SharePoint e os planos de projeto consolidados, garantindo sincronismo.

---

## 3. Tratamento de Erros e Suporte Técnico

### Q11: O que devo fazer se receber o erro "FlowActionBadGateway"?
Este é um erro transient do ecossistema Microsoft Teams/SharePoint. Aguarde um ou dois minutos e repita o envio. Caso a falha persista após 3 tentativas, entre em contato com o suporte.

### Q12: O que é o erro "ContentFiltered" e como posso evitá-lo?
Este erro ocorre quando o filtro automático de segurança da organização identifica linguagem inadequada ou fora dos padrões. Preencher os dados estritamente dentro dos formulários estruturados dos cartões evita esse bloqueio automático.

### Q13: Qual é o SLA de atendimento para problemas com o Assistente PMO?
Problemas classificados como prioritários (bloqueio total de relatórios de status) têm tempo de resposta inicial de **15 minutos** e resolução média em até **2 horas**.

### Q14: Como posso reportar bugs ou solicitar novas funcionalidades?
Envie um e-mail descrevendo a ocorrência para `t1-pmo@stt.com` ou publique diretamente no canal do Teams `Suporte_Assistente_PMO`.

### Q15: Caso a solução inteira fique fora do ar, qual é o plano de contingência?
Nosso time de operações dispõe de um mecanismo de Rollback homologado de 15 minutos para retornar à solução estável anterior (Versão 3.10), garantindo a continuidade das reportações operacionais em qualquer cenário de emergência.
