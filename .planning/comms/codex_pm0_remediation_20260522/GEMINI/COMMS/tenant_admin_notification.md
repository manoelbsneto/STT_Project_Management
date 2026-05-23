# Notificação para Administração do Tenant (M365 Admin) — Release PMO Hub 3.16

Last updated: 2026-05-22 17:18:30 BRT | Gemini sub-2 | Backfilled COM-03 solution component inventory.

---

**Para**: Equipe de Administração do Microsoft 365 / Power Platform Admin  
**De**: Liderança de Arquitetura do PMO Intelligent Hub  
**Assunto**: Implantação e Volumetria de Recursos da Solução `pmo_AssistentePMO_V2` (Release 3.16)

Prezados Administradores,

Comunicamos que a solução de gerenciamento de projetos corporativa **`pmo_AssistentePMO_V2`** está programada para atualização para a **versão 3.16.0.0** no ambiente oficial `ColOfertasBrasilPro`. Solicitamos atenção especial quanto às alterações de infraestrutura e volumetria detalhadas a seguir para garantir o monitoramento adequado de nosso tenant corporativo.

---

## 1. Escopo das Alterações da Solução

A release 3.16.0.0 altera o paradigma de tráfego de dados de diálogo livre para **Microsoft Adaptive Cards (v1.5)**. Esta alteração impactará os seguintes componentes da solução:
- **Novos Componentes**: Inclusão de 5 fluxos automatizados nomeados no padrão `PM0_PA_Card_*` no Power Automate, que atuarão como receptores diretos dos payloads estruturados gerados pelos cartões do Teams.
  **75 componentes corporativos totais**, incluindo:
    - **5 Fluxos (Workflows) PM0 Card-First**: `PM0_PA_Card_AtualizarStatus`, `PM0_PA_Card_AtualizarTarefa`, `PM0_PA_Card_CriarTarefa`, `PM0_PA_Card_ListarTarefas`, `PM0_PA_Card_ResumoExecutivoPortfolio` (todos operando em Power Automate Standard-only).
    - **12 Fluxos (Workflows) Legados/Auxiliares**: Mantidos temporariamente para retrocompatibilidade no canal corporativo.
    - **5 Ações de Chatbot (Botcomponents Actions)**: Vinculadas às ações de cartões dinâmicos Teams.
    - **15 Tópicos de Conversa (Botcomponents Topics)**: Tópicos conversacionais card-first homologados e tratamento de exceções.
    - **38 Componentes Adicionais**: Customizações, mapeamentos do Dataverse, arquivos XML de solução e definições gerais de chatbot.
- **Sem Conectores Premium**: Reiteramos que esta solução permanece classificada como **Standard-Only**, dependendo estritamente de conectores nativos de SharePoint Online, Planner Standard e Office 365 Users, respeitando as políticas de DLP vigentes no ambiente `ColOfertasBrasilPro`.

---

## 2. Volumetria e Padrões de Tráfego Esperados

Com a transição para formulários interativos estruturados, prevemos as seguintes alterações no comportamento e tráfego de rede no Teams e SharePoint:

1. **Volume de Adaptive Cards no Teams**:
   - *Padrão de Execução*: Cada interação de atualização gerará o render de um cartão adaptativo do tipo formulário de entrada.
   - *Estimativa de Tráfego*: Aproximadamente **80 a 120 mensagens de cartões/dia** no canal `Projetos_Transformacao_Digital` durante janelas de reporte executivo.
   - *Limites de Payload*: Todos os cartões adaptativos foram otimizados e medem estritamente **abaixo de 27KB** (tamanho máximo de segurança), garantindo renderização rápida em redes móveis sem risco de estouro de limites do Teams.

2. **Taxa de Escrita no SharePoint (Write Rate)**:
   - *Comportamento*: O Power Automate passará a gravar diretamente nas tabelas `PMO_StatusReport` e `PMO_Tasks` usando o conector Standard SharePoint Online.
   - *Média de Gravações*: Estimada em **60 a 90 commits/dia**, com picos concentrados entre as 16:00 e 18:00 BRT. Este volume está amplamente abaixo das cotas de limites e throttling padrões da API do SharePoint Online.

---

## 3. Diretrizes de Segurança e DLP

- **Segurança de Entrada**: Todas as entradas do formulário são ASCII-safe e validadas contra esquemas de tipo estrito antes de qualquer commit na base SharePoint, prevenindo falhas de injeção ou corrupções de dados.
- **Políticas de Prevenção de Perda de Dados (DLP)**: Os conectores utilizados estão em conformidade com as regras vigentes do tenant corporativo, operando integralmente na categoria corporativa ("Business"), isolada de conectores pessoais ou de terceiros.

Agradecemos a atenção de todos e nos colocamos à disposição para quaisquer esclarecimentos.

Atenciosamente,

**PMO Intelligent Hub Team**  
*STT Project Management*
