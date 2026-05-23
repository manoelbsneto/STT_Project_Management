# PMO Intelligent Hub — M2 Hybrid Card-First Architecture Diagram

Last updated: 2026-05-22 20:15:00 BRT | Gemini Lead | Architectural Diagram

---

This diagram shows the transactional and reporting integration flows of the PMO Intelligent Hub v2.0 (Milestone 2).

```mermaid
graph TD
    %% User and Interface
    subgraph MS_TEAMS_CLIENT [Microsoft Teams Client]
        PM[Project Manager / User]
        UC[Adaptive Card Form v1.5]
    end

    %% Agent and Messaging
    subgraph COPILOT_STUDIO [Copilot Studio Bot]
        CS[pmo_AssistentePMO_V2]
        T1[AtualizarStatus Topic]
        T2[AtualizarTarefa Topic]
        T3[CriarTarefa Topic]
        T4[ListarTarefas Topic]
        T5[ConsultarPortfolio Topic]
    end

    %% Automation Layer (Standard Only)
    subgraph POWER_AUTOMATE [Power Automate Cloud Flows]
        PA1[PM0_PA_Card_AtualizarStatus]
        PA2[PM0_PA_Card_AtualizarTarefa]
        PA3[PM0_PA_Card_CriarTarefa]
        PA4[PM0_PA_Card_ListarTarefas]
        PA5[PM0_PA_Card_ResumoExecutivoPortfolio]
    end

    %% Storage Layer
    subgraph SHAREPOINT_ONLINE [SharePoint Online Hub]
        SP1[(PMO_StatusReport List)]
        SP2[(PMO_Tasks List)]
        SP3[(PMO_Projects List)]
    end

    %% Flow Steps
    PM -->|1. Type Natural Language / Command| CS
    CS -->|2. Direct Trigger| T1 & T2 & T3 & T4 & T5
    T1 & T2 & T3 & T4 & T5 -->|3. Render Card Schema| UC
    PM -->|4. Input ASCII-Safe Form Data & Submit| UC
    UC -->|5. Submit JSON Payload| PA1 & PA2 & PA3 & PA4 & PA5
    
    %% Storage Operations
    PA1 -->|6. Commit Status Report| SP1
    PA2 -->|6. Update Task Status| SP2
    PA3 -->|6. Insert New Task| SP2
    PA4 -->|6. Query Task List| SP2
    PA5 -->|6. Query Projects & Aggregates| SP3
    
    %% Return Data Flow
    SP2 -.->|7. Read Tasks| PA4
    SP3 -.->|7. Read Aggregates| PA5
    PA4 -.->|8. Return FactSet JSON| UC
    PA5 -.->|8. Return Dashboard Card| UC
```

### Flow Descriptions
1. **Trigger Phase**: The user interacts with `pmo_AssistentePMO_V2` in Teams via text (e.g., "Atualizar Status").
2. **Card Rendering Phase**: Instead of initiating a multi-step conversation, the Bot returns an ASCII-safe Microsoft Adaptive Card v1.5 with input forms.
3. **Form Submission**: The user fills out the form in the card and clicks the submit button. This passes structured JSON directly to the Power Automate cloud flow.
4. **Data Commitment**: The cloud flow validates inputs, maps parameters, and writes/queries the SharePoint Online list using standard connectors.
5. **Close Loop**: The flow returns verification or dynamic data, rendering a refreshed confirmation view on the Adaptive Card.
