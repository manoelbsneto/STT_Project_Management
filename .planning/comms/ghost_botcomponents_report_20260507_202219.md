# Ghost Bot Component Discovery

Date: 2026-05-07 20:22:19
Environment: e2d10003-4d8e-e007-9d63-76d5fe89ef56
Name filter: pmo_AssistentePMO
Status: Skipped
Exit code: 

## Files

| Artifact | Path |
|---|---|
| FetchXML | $fetchPath |
| Stdout | $stdoutPath |
| Stderr | $stderrPath |

## Safety

This script is read-only. It only creates FetchXML, executes a Dataverse fetch when pac is available, and writes evidence files.
It does not delete, deactivate, update, or publish any Dataverse component.

## Human/Admin Gate

Any deletion of orphaned otcomponent rows requires explicit Human/Admin approval after reviewing the stdout evidence.
