# AUTH_RESOLUTION_TRAIL - PM0 3.20 Canonical Full Validate V2

- Agent: Codex #2 Lead
- Mission ID: PM0-3_20-CANONICAL-FULL-VALIDATE-V2
- Timestamp: 2026-05-24 11:01:24 BRT
- Mode: local/read-only tenant validation; no import/publish/write executed.

## Summary

Auth was not declared blocked. The required reading proof was completed first, then A.1-A.11 was exercised until a working path was found. A.4 resolved PAC auth by creating a local profile for tenant 7808e005-1489-4374-954b-d3b08f193920 and environment https://colofertasbrasilpro.crm4.dynamics.com/.

## Auth Paths

| Path | Result | Evidence |
|---|---|---|
| A.1 Windows PowerShell 5.1 pac auth list/env who | Initial profile existed, but env who failed with AADSTS70043; pac auth list --json unsupported | evidence/auth_paths/A01_pac_auth_list_winps51.{txt,json,png} |
| A.2 Select existing profile then pac org who | Failed/auth-blocked on existing expired profile | evidence/auth_paths/A02_pac_auth_select_profile1.{txt,json,png} |
| A.3 pac auth create --deviceCode | Timed out / interactive path | evidence/auth_paths/A03_pac_auth_create_devicecode.{txt,json,png} |
| A.4 pac auth create tenant plus URL | PASS - authenticated mbenicios@minsait.com, connected to ColOfertasBrasilPro, profile created | evidence/auth_paths/A04_pac_auth_create_tenant_url.{txt,json,png} |
| A.5 az login tenant fallback | Failed/auth-blocked, not needed after A.4 | evidence/auth_paths/A05_az_login_tenant_then_pac.{txt,json,png} |
| A.6 Personal guest pattern probe | Captured local Azure account/tenant evidence; not needed after A.4 | evidence/auth_paths/A06_personal_guest_pattern_probe.{txt,json,png} |
| A.7 Microsoft.PowerApps.PowerShell Get-Flow | PASS - module returned PM0 flows; showed AtualizarStatus Enabled=False | evidence/auth_paths/A07_powerapps_module_getflow.{txt,json,png} |
| A.8 Microsoft.PowerApps.Administration.PowerShell | Partial PASS - admin app query worked; one environment cmdlet unavailable | evidence/auth_paths/A08_powerapps_admin_module.{txt,json,png} |
| A.9 PAC MCP probe | Root pac mcp path failed; local guide indicates pac copilot mcp --run is the relevant command, not needed after A.4 | evidence/auth_paths/A09_pac_mcp.{txt,json,png} |
| A.10 Auth cache discovery | Captured PAC token/profile cache locations | evidence/auth_paths/A10_auth_cache_probe.{txt,json,png} |
| A.11 External references | Checked Microsoft Learn and GitHub references; compatible guidance supports profile recreation/device code for expired refresh token/auth profile issues | evidence/A11_external_auth_references.{txt,json,png} |

## External Reference Notes

Microsoft Learn pac auth documents pac auth create, --environment, --deviceCode, pac auth list, and pac auth select. Microsoft identity guidance for AADSTS70043 aligns with expired/invalid refresh token due to sign-in frequency or token invalidation. The compatible action applied here was A.4 local auth profile recreation.

## Fallback B Paths

B.1-B.4 were not needed because PAC runtime access was restored by A.4. No HOLD was declared for auth.
