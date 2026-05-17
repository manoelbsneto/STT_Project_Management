# Field Mapping

- SharePoint list: `Tarefas`
- All existing Planner mapping fields from AQ-03:
  - PlannerTaskId
  - PlannerBucketId
  - PlannerSyncStatus
  - PlannerLastSyncAt
  - PlannerSyncError
- Required mapping behavior:
  - never trust client-submitted `plannerTaskId`
  - resolve PlannerTaskId server-side from SharePoint item
  - explicitly write Title, ProjectID, and Status when creating a SharePoint item
  - explicitly write all 5 Planner sync fields when creating a SharePoint item
  - sanitize PlannerSyncError
  - map card status values to live SharePoint choices
  - map bucket status to canonical bucket IDs from AQ-04
  - explicitly map task updates to buckets (Pendente, Em Andamento, Testes, Piloto e Implantacao, Concluido, Cancelado)
  - explicitly map new task selected bucket to SharePoint Status, defaulting to Pendente if unmapped
  - preserve legacy SharePoint Status choices while using the canonical AQ-07 set for new writes: Pendente, Em Andamento, Testes, Piloto e Implantacao, Concluido, Cancelado
