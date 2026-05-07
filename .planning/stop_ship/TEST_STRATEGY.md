# TEST STRATEGY

## Scope

Six PMO flows plus clean Copilot bot invocation.

## Flow Regression Matrix

| Flow | Test Type | Inputs / Preconditions | Pass Criteria | Negative Case |
|---|---|---|---|---|
| PMO_PA_CriarTarefa | Direct manual flow test | nomeProjeto/titulo=`Agente Qualificacao de Ofertas`; prazo=`30/06/2026`; horas=`336`; prioridade=`Alta` | Returns success or duplicate message; no failed action | Invalid date rejected through controlled response |
| PMO_PA_ListarTarefas | Direct manual flow test | text=`<existing ProjectID>` | Returns formatted task list or explicit no-task message | Unknown ProjectID returns no-task response, not exception |
| PMO_PA_AtualizarTarefa | Direct manual flow test | Existing Tarefas item ID | Updates task and project counters | Task ProjectID missing in Projetos does not crash |
| PMO_PA_CheckInOnDemand | Direct manual flow test | Existing ProjectID and Teams channel access | Posts adaptive card and returns Response_OK after submit | Unknown ProjectID returns controlled failure |
| PMO_PA_RegistrarDecisaoBoard | SharePoint-trigger integration | Create item in Decisoes do Board | Posts Teams decision card and updates response after submit | Missing approver/project handled |
| PMO_PA_EscalarRiscoCritico | SharePoint-trigger integration | Create critical item in Riscos e Bloqueios | Posts Teams escalation and sends email | Missing project/sponsor handled |
| Assistente PMO Clean | Copilot integration | `criar tarefa...` then confirm | Calls clean flow action without FlowNotFound | Low confidence and flow error paths controlled |

## Automation Status

No full CI automation currently exists for Power Automate runtime execution in this workspace. Until a scripted Power Platform test harness is added, release must remain NO-SHIP unless manual evidence is captured for every flow.

