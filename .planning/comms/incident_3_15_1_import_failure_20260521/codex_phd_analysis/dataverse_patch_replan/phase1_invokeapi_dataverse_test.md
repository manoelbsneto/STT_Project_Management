# Phase 1 InvokeApi Dataverse Test

Status: `FAIL - STOP`

Date: `2026-05-21` BRT  
Environment: `ColOfertasBrasilPro`  
Environment URL: `https://colofertasbrasilpro.crm4.dynamics.com/`

## Gate Purpose

This phase tests only whether the runbook-approved PowerApps PowerShell `InvokeApi` path can call the Dataverse Web API row route needed for `botcomponent.data`.

Runbook basis:

- PowerApps PowerShell + `InvokeApi` is the documented tenant access path for this mission: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 143-180 and lines 224-294.
- Forbidden alternate auth remains blocking: `.planning/TENANT_COMMAND_RUNBOOK.md` lines 30-38 and `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` lines 34-47.
- The fallback rule from the dispatch is enforced: stop if `InvokeApi` does not support the Dataverse `botcomponents` route.

Microsoft Learn basis for the endpoint under test:

- Dataverse Web API `botcomponent` entity set path is `[organization URI]/api/data/v9.2/botcomponents`; the entity type lists `GET` and `PATCH` among supported operations and `data` as an `Edm.String` property: <https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/reference/botcomponent?view=dataverse-latest>
- The `botcomponent` table reference documents `GET /botcomponents(botcomponentid)` for retrieve and `PATCH /botcomponents(botcomponentid)` for update: <https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/botcomponent>
- Dataverse Web API update guidance documents row updates with `PATCH [Organization URI]/api/data/v9.2/<entityset>(<id>)`: <https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/update-delete-entities-using-web-api>

The failure below is therefore not a claim that the Dataverse Web API route is invalid. It is a runtime proof that the mission's approved `InvokeApi` session did not acquire the required token for that Dataverse resource.

## Test Command

Windows PowerShell 5.1 process:

```powershell
$route = "https://colofertasbrasilpro.crm4.dynamics.com/api/data/v9.2/botcomponents(ec4416d0-0744-4e8c-b937-aae4ad9c605b)?`$select=botcomponentid,name,schemaname,data,statecode,statuscode,modifiedon"
InvokeApi -Method GET -Route $route -ThrowOnFailure
```

The same process used the Phase 0 runbook imports and `Add-PowerAppsAccount -Endpoint prod`. `Get-Command InvokeApi -Syntax` returned:

```text
InvokeApi [-Method] <string> [-Route] <string> [[-Body] <Object>] [[-ApiVersion] <string>] [-ThrowOnFailure] [<CommonParameters>]
```

## Runtime Result

Result: `FAIL`

Exception summary:

```text
ExceptionType: System.Management.Automation.MethodInvocationException
FullyQualifiedErrorId: MsalServiceException,Await-Task
Message: AADSTS65002: Consent between first party application '689e5960-2e49-4505-98d8-369236220fc6' and first party resource '797f4846-ba00-4fd7-ba43-dac1f8f63013' must be configured via preauthorization - applications owned and operated by Microsoft must get approval from the API owner before requesting tokens for that API.
Timestamp from error: 2026-05-22 02:39:32Z
```

Observed stack path:

```text
Get-JwtToken
Invoke-Request
InvokeApi
```

The stack path was inside the imported `Microsoft.PowerApps.Administration.PowerShell` auth/rest modules after the direct Dataverse route was passed to `InvokeApi`.

## Gate Decision

Phase 1 gate result: `FAIL`.

Execution stops here:

- No Dataverse `PATCH` was attempted.
- No five-topic drift check was started.
- No backup snapshot was taken because the approved read route failed before the backup gate.
- No alternate auth method was attempted.
- No device code, MSAL.PS, ClientId, app registration, service principal, certificate auth, Graph direct, HTTP Premium connector, or `Connect-PnPOnline -Interactive` was used.

## Owner Escalation

Runbook-compliant next-path assessment:

1. `.planning/TENANT_COMMAND_RUNBOOK.md` section 6, lines 224-294, documents `InvokeApi -Method PATCH` for a `Microsoft.ProcessSimple` flow endpoint, not for direct Dataverse `botcomponents`.
2. That ProcessSimple example is not a substitute route for the five `botcomponent.data` row updates approved in this mission.
3. The owner must choose a documented path before retrying the patch mission:
   - update the project runbook with an approved Dataverse access method for `botcomponents.data`, or
   - redirect the hotfix back to the already documented Copilot Studio authoring/export/import path described by the incident replan.

Explicit owner question:

> `InvokeApi` failed the Dataverse `botcomponents` GET gate with `AADSTS65002` under the exact runbook modules and `Add-PowerAppsAccount -Endpoint prod` path. Should this mission stop pending a runbook update for an approved Dataverse access route, or should the hotfix return to the Copilot Studio authoring/export/import path?
