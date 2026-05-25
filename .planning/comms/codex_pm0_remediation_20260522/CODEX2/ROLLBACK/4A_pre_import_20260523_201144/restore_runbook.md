# Gate 4A Restore Runbook

Recommended order: import PMO_AQ07_CopilotBinding artifacts first if dependency read-back shows AQ07 carries binding rows, then PMO_v11_Tarefas. Use only after owner approval.

~~~powershell
pac solution import ` 
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 ` 
  --path ".planning\comms\codex_pm0_remediation_20260522\CODEX2\ROLLBACK\4A_pre_import_20260523_201144\PMO_v11_Tarefas_unmanaged.zip" ` 
  --activate-plugins

pac solution import ` 
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 ` 
  --path ".planning\comms\codex_pm0_remediation_20260522\CODEX2\ROLLBACK\4A_pre_import_20260523_201144\PMO_v11_Tarefas_managed.zip" ` 
  --activate-plugins

pac solution import ` 
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 ` 
  --path ".planning\comms\codex_pm0_remediation_20260522\CODEX2\ROLLBACK\4A_pre_import_20260523_201144\PMO_AQ07_CopilotBinding_unmanaged.zip" ` 
  --activate-plugins

pac solution import ` 
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 ` 
  --path ".planning\comms\codex_pm0_remediation_20260522\CODEX2\ROLLBACK\4A_pre_import_20260523_201144\PMO_AQ07_CopilotBinding_managed.zip" ` 
  --activate-plugins
~~~