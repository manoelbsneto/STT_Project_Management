# Solution 2.7 Local Gates - Batch Topic No-Flow Preview

## Package

- Path: `Solution/PMO_v11_Tarefas_2_7_BATCH_TOPIC_NO_FLOW_PREVIEW.zip`
- Version: `2.7`
- SHA256: `16F5AEABD7E03370B3D45EFDC68EE445B9790CFF1DD99FC0C241161F39E8586A`
- Size: `74629` bytes

## Runtime RCA

Version 2.6 reached the `Gerar_Multiplos_Projetos` topic and displayed the preview/no-write marker, but confirmation failed with:

`flowNotFound The flow with id 0a5d2a42-24c0-4d5e-9f6d-000000000241 was not found in the bot definition`

Read-only SharePoint verification found zero matching `Projetos` rows for `Teste Batch Preview 2.6 A/B` and zero matching `Tarefas` rows for `Kickoff preview` or `Planejamento preview`.

## Fix

Because the current release intent is preview/no-write, the safest correction is to remove `InvokeFlowAction` from the `Gerar_Multiplos_Projetos` topic and return the deterministic no-write response directly from the topic after confirmation.

This avoids any dependency on a bot flow binding while preserving the batch UX marker and the no-write guarantee.

## Local Gates

All gates below passed locally:

- `Test-GerarMultiplosProjetosDefinition.ps1`
- `Test-SolutionZipP24Contracts.ps1`
- `Test-SolutionZipP0Contracts.ps1`
- `Test-ExcluirSoftDeleteCapability.ps1`
- `Test-CriarTarefaCreatesTarefas.ps1`
- `Test-PMOFlowStopShipAudit.ps1`
- `git diff --check`

The batch gate now explicitly verifies:

- no `InvokeFlowAction` in `Gerar_Multiplos_Projetos` topic
- no `flowId: 0a5d2a42-24c0-4d5e-9f6d-000000000241` in the preview topic
- direct `BATCH_PREVIEW_ONLY_NO_WRITE` response
- no `Create_Projeto_Batch_SharePoint`
- no `Create_Tarefa_Batch_SharePoint`
- no hidden confirmed write branch
