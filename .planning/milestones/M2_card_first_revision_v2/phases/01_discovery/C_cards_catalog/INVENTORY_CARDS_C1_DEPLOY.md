# C.1 Inventory Cards - deploy/cards/

## Overview
This document contains the inventory for the `deploy/cards/` directory scanned during M2 Phase 1 - Discovery (Track C.1).

### Cards Catalog

1. **AlertaCritico.json**
   - **Size**: 1457 bytes
   - **Operation**: AlertaCritico
   - **Usage Status**: orphan
   - **Quality**: complete
   - **Fields**: None
   - **Actions**: Action.OpenUrl

2. **AtualizarStatusCard.json**
   - **Size**: 2811 bytes
   - **Operation**: AtualizarStatus
   - **Usage Status**: in_use
   - **Quality**: complete
   - **Fields**: statusRAG, percentual, resumo, risco, bloqueio, proximaAcao
   - **Actions**: submitStatusUpdate, cancelStatusUpdate

3. **AtualizarStatusSingleBoxReviewCard.json**
   - **Size**: 3230 bytes
   - **Operation**: AtualizarStatusReview
   - **Usage Status**: in_use
   - **Quality**: complete
   - **Fields**: None
   - **Actions**: confirmStatusUpdate, submitStatusUpdate, cancelStatusUpdate

4. **AtualizarTarefaCard.json**
   - **Size**: 3679 bytes
   - **Operation**: AtualizarTarefa
   - **Usage Status**: in_use
   - **Quality**: complete
   - **Fields**: taskTitle, taskStatus, responsibleUpn, dueDate, priority, actualHours, updateNotes
   - **Actions**: submitUpdateTask, cancelTaskEdit, requestTaskUpdate

5. **CheckInDiario.json**
   - **Size**: 2339 bytes
   - **Operation**: CheckInDiario
   - **Usage Status**: orphan
   - **Quality**: complete
   - **Fields**: statusRAG, resumo, percentual, risco, bloqueio, proximaAcao
   - **Actions**: submitCheckIn

6. **CriarTarefaCard.json**
   - **Size**: 3342 bytes
   - **Operation**: CriarTarefa
   - **Usage Status**: in_use
   - **Quality**: complete
   - **Fields**: taskTitle, taskDescription, responsibleUpn, dueDate, priority, plannerBucketName, estimatedHours
   - **Actions**: submitCreateTask, cancelTaskEdit

7. **DecisaoBoard.json**
   - **Size**: 2090 bytes
   - **Operation**: PedirDecisao
   - **Usage Status**: in_use
   - **Quality**: complete
   - **Fields**: justificativa
   - **Actions**: approveDecision, rejectDecision, deferDecision

8. **EscalacaoRisco.json**
   - **Size**: 1721 bytes
   - **Operation**: EscalarRisco
   - **Usage Status**: in_use
   - **Quality**: complete
   - **Fields**: None
   - **Actions**: OpenUrl

9. **ListarTarefasProjetoCard.json**
   - **Size**: 3463 bytes
   - **Operation**: ListarTarefas
   - **Usage Status**: in_use
   - **Quality**: complete
   - **Fields**: taskId
   - **Actions**: createTaskFromProject, editTask, markTaskInProgress, markTaskDone, requestTaskUpdate

10. **ResumoDiarioBoard.json**
    - **Size**: 2764 bytes
    - **Operation**: ResumoDiario
    - **Usage Status**: orphan
    - **Quality**: complete
    - **Fields**: None
    - **Actions**: OpenUrl

11. **ResumoExecutivoPortfolio.json**
    - **Size**: 3676 bytes
    - **Operation**: ResumoExecutivoPortfolio
    - **Usage Status**: in_use
    - **Quality**: complete
    - **Fields**: None
    - **Actions**: viewRedProjects, viewWithoutUpdate, requestPmUpdate, viewProjectDetails, refreshPortfolio

12. **ResumoSemanal.json**
    - **Size**: 2055 bytes
    - **Operation**: ResumoSemanal
    - **Usage Status**: orphan
    - **Quality**: complete
    - **Fields**: None
    - **Actions**: OpenUrl
