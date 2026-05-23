# PMO Intelligent Hub — Product Requirements Document (PRD) v2.0
## Milestone 2 (M2) Final State Architecture

Last updated: 2026-05-22 20:15:00 BRT | Gemini Lead | Draft M2 Final PRD

---

## 1. Executive Summary: The M1 → M2 Evolution

The **PMO Intelligent Hub (PMO Hub)** is an enterprise status reporting and project management automation system designed to minimize friction for Project Managers (PMs), establish real-time executive visibility, and automate risk escalation within the Microsoft 365 ecosystem.

### The Problem with M1 (Chat-First)
Milestone 1 (M1) utilized a **chat-first, conversational agent model** where the user interacted with Copilot Studio via open-ended natural language, and the bot collected inputs step-by-step or tried to parse bulk text. This approach suffered from several fatal operational issues:
- **High Friction**: PMs had to write extensive freeform text, leading to unstructured and inconsistent data in SharePoint.
- **Content Filtering Risks**: Freeform input regularly triggered standard AI safety content filtering, blocking legitimate project status updates.
- **Data Validation Failures**: Date formats, project IDs, and status strings were often parsed incorrectly by the LLM, leading to database schema mismatches in SharePoint.
- **State Tracking Issues**: The conversational flow was highly fragile. If a user was interrupted, the bot session timed out, and the progress was lost.

### The Solution in M2 (Hybrid Card-First)
To resolve these issues, Milestone 2 (M2) implements a **Hybrid Card-First Architecture** (formally approved under `ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md`). Under this hybrid paradigm:
- **Trigger**: The user initiates a request (e.g., in natural language or via command like "Atualizar Status").
- **UI Presentation**: Instead of asking follow-up questions, the bot immediately renders a structured **Microsoft Adaptive Card (v1.5)** in the Teams channel.
- **Structured Inputs**: The user inputs data through clean dropdowns, date pickers, and text inputs with predefined character validation.
- **Direct Submission**: The Adaptive Card submits the form payload directly to underlying **Power Automate Cloud Flows** (Standard-only) using standard schema variables.
- **Key Business Benefits**: Reduces time-to-report from ~35 min/day to **< 1 min/day**, achieves **100% structured data validation**, and **completely eliminates chat-based ContentFiltered errors** for structured operations.

---

## 2. Architectural Decisions

The architectural design of the PMO Hub M2 release is governed by the following core Architectural Decision Records (ADRs):

### ADR_AQ08: Hybrid Card-First Migration
- **Context**: The high error rate in conversational parsing required a robust alternative.
- **Decision**: Migrate the 5 high-frequency status-reporting topics to an Adaptive Card-first model. Use Adaptive Cards version 1.5 to support modern layout constraints and rich dynamic data binding.
- **Status**: **Approved & Implemented**

### ADR-001: Standard-Only Connectors
- **Context**: Licensing constraints prohibit Premium power platform or Power Automate connectors.
- **Decision**: Restrict all data operations to standard SharePoint, Planner, and Office 365 Users connectors. No HTTP with Entra ID, Premium Dataverse, or third-party Premium triggers allowed.
- **Status**: **Enforced**

### ADR-002: ASCII-Safe User-Facing Strings
- **Context**: Character encoding bugs in Teams and SharePoint can lead to UI rendering corruptions.
- **Decision**: Enforce strictly standard US-ASCII strings for all application-facing labels, choice variables, and dropdown keys inside card schemas (e.g., using `Em Andamento` instead of `Em Andamento`, `Implantacao` instead of `Implantação`).
- **Status**: **Enforced**

### ADR-003: Double-Buffered SharePoint Schema
- **Context**: Schema drift can break active flow inputs.
- **Decision**: Maintain a strict lock on SharePoint lists schemas, with all updates applied programmatically via verified provisioning scripts.
- **Status**: **Enforced**

---

## 3. In-Scope Topics + Their Workflows + SharePoint Lists

The M2 release implements **5 target card-first topics**. These topics handle the most critical PMO transactions:

### 3.1. Topic: `AtualizarStatus`
- **Purpose**: Fast status reporting for active projects.
- **Workflow ID**: `1721e0a3-a250-f111-bec7-000d3abc5cc6`
- **Power Automate Action**: `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus`
- **SharePoint List**: `PMO_StatusReport`
- **Card Schema**: `AtualizarStatusCard_v316.json`
- **Expected Fields**: Project ID, Status color (Red/Yellow/Green), Report Date, Key Highlights, Next Steps.

### 3.2. Topic: `AtualizarTarefa`
- **Purpose**: Update progress of an assigned project task.
- **Workflow ID**: `7c6300c2-a250-f111-bec7-000d3abc5cc6`
- **Power Automate Action**: `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa`
- **SharePoint List**: `PMO_Tasks`
- **Card Schema**: `AtualizarTarefaCard.json`
- **Expected Fields**: Task ID, Progress %, Status (Not Started, In Progress, Blocked, Completed), Actual Finish Date, Comments.

### 3.3. Topic: `CriarTarefa`
- **Purpose**: Spawn a new task within a project.
- **Workflow ID**: `7f662db7-a250-f111-bec7-000d3abc5cc6`
- **Power Automate Action**: `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa`
- **SharePoint List**: `PMO_Tasks`
- **Card Schema**: `CriarTarefaCard.json`
- **Expected Fields**: Project ID, Task Title, Assignee Email, Due Date, Priority (Low, Medium, High, Critical).

### 3.4. Topic: `ListarTarefas`
- **Purpose**: Render a structured list of tasks associated with a specific Project ID.
- **Workflow ID**: `e0e3c6b0-a250-f111-bec7-000d3abc5cc6`
- **Power Automate Action**: `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas`
- **SharePoint List**: `PMO_Tasks`
- **Card Schema**: `ListarTarefasCard_v316.json`
- **Expected Fields**: Project ID input in chat -> Bot responds with list of tasks inside a beautiful read-only dynamic FactSet.

### 3.5. Topic: `ConsultarPortfolio`
- **Purpose**: Display executive KPI portfolio dashboard.
- **Workflow ID**: `8333bd91-a250-f111-bec7-000d3abc5cc6`
- **Power Automate Action**: `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio`
- **SharePoint List**: `PMO_Projects` & `PMO_StatusReport`
- **Card Schema**: `ResumoExecutivoPortfolioCard_v316.json`
- **Expected Fields**: Aggregated stats: Total active projects, status counts (Green/Yellow/Red), overall portfolio budget variance, and critical risk flags.

---

## 4. Out-of-Scope (Backlog Wave 2 Debt)

As part of the hybrid migration strategy defined in `ADR_AQ08`, to guarantee release timelines, **7 legacy topics** remain in their legacy **chat-first (text-only)** state. These items are officially accepted as backlog debt and will be migrated to the card-first pattern in the **BACKLOG-PM0-LEGACY-MIGRATION-WAVE2** cycle:

1. `ConsultarProjeto` (Text-based summary of project metadata)
2. `PedirDecisaoBot` (Register a decision request via chat)
3. `RegistrarBloqueioBot` (Escalate a task block via chat)
4. `RegistrarRiscoBot` (Log a new project risk via chat)
5. `AlertaCritico` (Automated notification trigger)
6. `CheckInDiario` (Teams daily check-in sequence)
7. `ResumoSemanal` (Teams weekly summarization report)

---

## 5. Functional Definition of Done (DoD)

To prevent premature shipping of incomplete flows, the PMO Intelligent Hub establishes a **Functional Definition of Done (DoD)**. No workflow or card is considered completed until it satisfies all 5 conditions:

1. **Successful Execution**: The flow must run end-to-end with no run-time failures (`Status = Succeeded` in Power Automate run history).
2. **Data Commitment**: The flow must accurately commit or retrieve real records to/from the target SharePoint list.
3. **Card Rendering**: The Microsoft Teams Adaptive Card must render perfectly in the Teams desktop and mobile client without syntax, truncation, or overflow errors.
4. **Zero Safety Blocks**: The transactional data must not trigger standard Microsoft safety content filters (ContentFiltered errors).
5. **Verified Evidence**: The execution must be backed by structural and visual logs containing screenshots and JSON payloads saved in the project's evidence registry.

---

## 6. Quality Gates

All releases are subjected to three mandatory Quality Gates:

### 6.1. Evidence Triplet Gate
Every milestone completion, test run, or deploy claim must produce a logged "Triplet" including:
1. **Screenshot**: Renders or runtime outcome images saved in the evidence folder.
2. **Timestamp**: The exact BRT execution date and time.
3. **Agent Attestation**: The identity of the agent responsible for verification (Gemini Lead, Gemini sub-1, or Gemini sub-2).

### 6.2. Structural Verifier Gate
- **Card Size Check**: All Adaptive Card JSON payloads must measure strictly under **27KB** to guarantee mobile client processing.
- **ASCII Validator**: All dynamic and static labels in user-facing card inputs must consist exclusively of ASCII-safe characters (no smart quotes, accents, emojis, or non-ASCII characters).

### 6.3. Functional Verifier Gate
- **Regression Suite**: Execution of the 12-scenario standard smoke suite (`AQ-09 Smoke Suite`) to verify legacy compatibility and new card-first execution paths.

---

## 7. Operational Constraints

- **Execution Environment**: All solutions, workflows, and configurations must reside exclusively in the `ColOfertasBrasilPro` environment (ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`).
- **No-Premium Rule**: Direct HTTP actions, Premium triggers, and custom assemblies are strictly prohibited to comply with the standard-only licensing scope.
- **Approval Protocol**: Manoel Benicio is the sole authorized owner. No package can be pushed to staging/production without written sign-off in the thread.

---

## 8. References

- **ADR Baseline**: [ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md](file:///d:/VMs/Projetos/STT_Project_Management/.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md)
- **Remediation Directives**: [REMEDIATION_PLAN.md](file:///d:/VMs/Projetos/STT_Project_Management/.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md)
- **Root Cause Analysis**: [RCA_PM0_FLOWS_20260522.md](file:///d:/VMs/Projetos/STT_Project_Management/.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md)
- **Executive Summary**: [EXECUTIVE_SUMMARY.md](file:///d:/VMs/Projetos/STT_Project_Management/.planning/comms/codex_pm0_audit_20260522/EXECUTIVE_SUMMARY.md)
- **Microsoft Learn Sources**: [PRD Citations](file:///d:/VMs/Projetos/STT_Project_Management/.planning/comms/codex_pm0_remediation_20260522/GEMINI/PRD/ms_learn_citations.md)
