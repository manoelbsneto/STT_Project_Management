# DO NOT EXECUTE WITHOUT OWNER APPROVAL
# Staged rollback script for hotfix 3.15.1.
# Default state is confirmation-only: the rollback import block is commented out.
# PAC CLI 2.6.4 does not expose a solution import --dry-run option.

$ErrorActionPreference = "Stop"

Write-Host "Confirm PAC authentication context before any rollback decision."
pac auth list
pac env who

Write-Host "Dry-run only. Rollback import remains commented until Owner approval."
Write-Host "Owner must uncomment every line in the import block to execute rollback."

# Owner-executed rollback import block. Keep commented until rollback is approved.
# pac solution import `
#   --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
#   --path "D:\VMs\Projetos\STT_Project_Management\Solution\PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip" `
#   --force-overwrite `
#   --activate-plugins `
#   --publish-changes
