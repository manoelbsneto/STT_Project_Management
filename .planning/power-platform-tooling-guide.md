# Power Platform CLI (PAC) — Tooling Ecosystem Guide

> **Purpose**: Complete reference for all available tools, extensions, and integrations that support native Power Platform CLI (`pac`) operations — solution import, export, pack, unpack, move, and all other native functions.
>
> **Audience**: Developers, DevOps engineers, AI agents, and architects working with Power Platform / Power Automate / Dataverse.
>
> **Last Updated**: May 2026

---

## Table of Contents

1. [Overview](#1-overview)
2. [Official VS Code Extension (VSIX)](#2-official-vs-code-extension-vsix)
3. [Official PAC MCP Server](#3-official-pac-mcp-server)
4. [Community MCP Servers (GitHub)](#4-community-mcp-servers-github)
5. [GitHub Actions for CI/CD](#5-github-actions-for-cicd)
6. [Full PAC CLI Command Reference](#6-full-pac-cli-command-reference)
7. [Decision Matrix — Which Tool to Use](#7-decision-matrix--which-tool-to-use)
8. [Installation Checklist](#8-installation-checklist)
9. [References & Links](#9-references--links)

---

## 1. Overview

The **Power Platform CLI** (`pac`) is Microsoft's official command-line tool for professional developers and ISVs working with the Power Platform ecosystem. It provides native commands for:

- **Solution lifecycle management** (export, import, pack, unpack, clone, publish)
- **Environment management** (list, select, create, copy, backup, restore)
- **Authentication** (create, list, select, delete profiles)
- **Dataverse operations** (data import/export, table management)
- **Power Pages** (download, upload, preview sites)
- **Code components (PCF)** (create, build, push, debug)
- **Power Automate flows** (within solutions)

The PAC CLI can be consumed through multiple channels:

| Channel | Type | Best For |
|---------|------|----------|
| **Power Platform Tools** (VSIX) | VS Code Extension | Day-to-day development |
| **PAC MCP Server** (built-in) | Model Context Protocol | AI-assisted operations |
| **Community MCP Servers** | Open-source MCP | Extended Dataverse/flow queries |
| **GitHub Actions** | CI/CD Automation | Pipelines, ALM automation |
| **Standalone CLI** | .NET Tool / MSI | Scripts, automation outside VS Code |

---

## 2. Official VS Code Extension (VSIX)

### 2.1 Identity

| Field | Value |
|-------|-------|
| **Name** | Power Platform Tools |
| **Publisher** | Microsoft |
| **Marketplace** | [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.powerplatform-vscode) |
| **Extension ID** | `microsoft-IsvExpTools.powerplatform-vscode` |
| **Type** | VSIX (VS Code Extension) |
| **License** | Proprietary (Microsoft) |
| **Bundled CLI** | PAC CLI (latest stable) |

### 2.2 Installation

**Method 1 — VS Code Marketplace (Recommended)**
```
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search: "Power Platform Tools"
4. Click Install on the Microsoft-published extension
5. Reload VS Code
```

**Method 2 — Command Line**
```bash
code --install-extension microsoft-IsvExpTools.powerplatform-vscode
```

**Method 3 — Standalone CLI (without VS Code)**
```bash
# Via .NET Tool (cross-platform)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Via Windows MSI
# Download from https://aka.ms/PowerAppsCLI
```

### 2.3 Features Provided

| Feature | Description |
|---------|-------------|
| **Integrated PAC CLI** | Full `pac` CLI available in VS Code terminal |
| **Auth Panel** | Visual UI in Activity Bar to create/select/manage auth profiles |
| **Environment Browser** | Browse environments, view solutions, copy env details (URL, IDs) |
| **Solution Explorer** | View installed solutions, components, and dependencies |
| **Power Pages Actions Hub** | Download, upload, preview Power Pages sites |
| **Liquid IntelliSense** | Autocompletion and diagnostics for Liquid templates |
| **YAML IntelliSense** | Autocompletion for Power Platform YAML config files |
| **Copilot Chat** | `@powerpages` chat participant for JS, Liquid, Web API |
| **CodeQL Security** | Built-in security screening for Power Pages |
| **Debugging** | Server logic debugging with mock data support |

### 2.4 Post-Installation Setup

```bash
# 1. Create an authentication profile
pac auth create --environment https://your-org.crm.dynamics.com/

# 2. Verify connection
pac auth list

# 3. List environments
pac env list

# 4. Test solution operations
pac solution list
```

---

## 3. Official PAC MCP Server

### 3.1 What Is It?

The Power Platform CLI includes a **built-in MCP (Model Context Protocol) server** that exposes all PAC CLI capabilities as tools for AI models. This allows AI assistants (GitHub Copilot, Claude, etc.) to execute Power Platform operations via natural language.

### 3.2 Requirements

- PAC CLI installed (via VSIX or standalone .NET tool)
- MCP-compatible client (VS Code with MCP support, Claude Desktop, etc.)

### 3.3 How to Start

```bash
# Start the built-in MCP server
pac copilot mcp --run
```

### 3.4 MCP Client Configuration

Add the following to your MCP client configuration file (e.g., `mcp.json`, `settings.json`, or `claude_desktop_config.json`):

**Option A — Using `dnx` (recommended for VS Code)**
```json
{
  "servers": {
    "pac-mcp": {
      "type": "stdio",
      "command": "dnx",
      "args": [
        "Microsoft.PowerApps.CLI.Tool",
        "--yes",
        "copilot",
        "mcp",
        "--run"
      ]
    }
  }
}
```

**Option B — Direct path to pac-mcp executable**
```json
{
  "servers": {
    "pac-mcp": {
      "type": "stdio",
      "command": "C:/Users/<USERNAME>/.dotnet/tools/pac-mcp.exe",
      "args": []
    }
  }
}
```

> [!NOTE]
> The `pac-mcp.exe` is typically installed at `~/.dotnet/tools/pac-mcp.exe` when you install the CLI via `dotnet tool install --global Microsoft.PowerApps.CLI.Tool`.

### 3.5 Supported MCP Operations

Once configured, the MCP server exposes tools for:

| Category | Operations |
|----------|------------|
| **Solution** | export, import, list, pack, unpack, clone, publish, delete |
| **Environment** | list, select, create, copy, backup, restore |
| **Auth** | create, list, select, delete, clear |
| **Dataverse** | data export, data import, table operations |
| **Power Pages** | download, upload, preview |
| **PCF** | init, build, push |

### 3.6 Example Natural Language Prompts

Once the MCP is connected, you can instruct your AI assistant with:

```
"Export the solution named 'AgentificacaoOfertas' as unmanaged to ./exports/"
"Import the solution from ./exports/AgentificacaoOfertas.zip with publish changes"
"List all solutions in my current environment"
"Switch to the production environment"
"Unpack the solution zip into ./src/ for source control"
```

---

## 4. Community MCP Servers (GitHub)

### 4.1 michsob/powerplatform-mcp

| Field | Value |
|-------|-------|
| **Repository** | [github.com/michsob/powerplatform-mcp](https://github.com/michsob/powerplatform-mcp) |
| **Language** | TypeScript / Node.js |
| **Focus** | Querying and configuring Power Platform / Dataverse environments |
| **License** | Open Source |

**Capabilities:**
- Multiple environment support
- Entity metadata browsing
- Plugin and workflow queries
- Flow management
- Solution component inspection
- Environment configuration

**Installation:**
```bash
git clone https://github.com/michsob/powerplatform-mcp.git
cd powerplatform-mcp
npm install
npm run build
```

**MCP Config:**
```json
{
  "servers": {
    "powerplatform-mcp": {
      "type": "stdio",
      "command": "node",
      "args": ["path/to/powerplatform-mcp/dist/index.js"]
    }
  }
}
```

---

### 4.2 Cliveo/Power-Platform-MCP

| Field | Value |
|-------|-------|
| **Repository** | [github.com/Cliveo/Power-Platform-MCP](https://github.com/Cliveo/Power-Platform-MCP) |
| **Language** | C# / .NET |
| **Focus** | Dataverse + Power Automate integration with AI agents |
| **License** | Open Source |

**Capabilities:**
- Dataverse CRUD operations
- Power Automate flow management
- Integration with GitHub Copilot
- Environment management
- Solution operations

**Installation:**
```bash
git clone https://github.com/Cliveo/Power-Platform-MCP.git
cd Power-Platform-MCP
dotnet build
dotnet run
```

---

### 4.3 Comparison — Official vs Community

| Feature | PAC MCP (Official) | michsob/powerplatform-mcp | Cliveo/Power-Platform-MCP |
|---------|-------------------|--------------------------|--------------------------|
| Solution import/export | ✅ Full support | ⚠️ Partial (query only) | ✅ Supported |
| Environment management | ✅ Full support | ✅ Multi-env | ✅ Supported |
| Dataverse metadata | ✅ Basic | ✅ Deep (entities, plugins) | ✅ CRUD |
| Power Automate flows | ✅ Via solution | ✅ Query/manage | ✅ Full |
| Auth integration | ✅ PAC auth profiles | ✅ Own auth | ✅ Own auth |
| Maintained by | Microsoft | Community | Community |
| Stability | Production-grade | Beta | Beta |

---

## 5. GitHub Actions for CI/CD

### 5.1 Official Repository

| Field | Value |
|-------|-------|
| **Repository** | [github.com/microsoft/powerplatform-actions](https://github.com/microsoft/powerplatform-actions) |
| **Marketplace** | [GitHub Marketplace — Power Platform Actions](https://github.com/marketplace/actions/powerplatform-actions) |
| **Maintained by** | Microsoft |
| **Auth** | Service Principal (App ID, Tenant ID, Client Secret) |

### 5.2 Available Actions

| Action | Purpose |
|--------|---------|
| `actions-install@v1` | Install Power Platform tools in runner |
| `export-solution@v1` | Export solution from environment |
| `import-solution@v1` | Import solution into environment |
| `unpack-solution@v1` | Unpack `.zip` → XML source files |
| `pack-solution@v1` | Pack source files → `.zip` |
| `publish-solution@v1` | Publish all customizations |
| `delete-solution@v1` | Delete solution from environment |
| `check-solution@v1` | Run solution checker |
| `deploy-package@v1` | Deploy Package Deployer package |
| `set-solution-version@v1` | Set solution version number |
| `clone-solution@v1` | Clone solution for patching |
| `create-environment@v1` | Create new environment |
| `delete-environment@v1` | Delete environment |
| `copy-environment@v1` | Copy environment |
| `backup-environment@v1` | Backup environment |
| `restore-environment@v1` | Restore environment from backup |

### 5.3 Authentication Setup

```bash
# 1. Create an App Registration in Azure AD
# 2. Assign it as an Application User in your Power Platform environments
# 3. Store credentials as GitHub Secrets:
#    - CLIENT_ID (Application/Client ID)
#    - TENANT_ID (Azure AD Tenant ID)
#    - CLIENT_SECRET (Client Secret value)
```

### 5.4 Complete Workflow Example — Export → Commit → Import

```yaml
name: Power Platform ALM Pipeline

on:
  workflow_dispatch:
    inputs:
      solution_name:
        description: 'Solution name to export'
        required: true
        default: 'AgentificacaoOfertas'

env:
  DEV_ENV_URL: 'https://your-dev.crm.dynamics.com'
  PROD_ENV_URL: 'https://your-prod.crm.dynamics.com'

jobs:
  # ═══ JOB 1: Export from DEV ═══
  export-from-dev:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Power Platform Tools
        uses: microsoft/powerplatform-actions/actions-install@v1

      - name: Export Unmanaged Solution
        uses: microsoft/powerplatform-actions/export-solution@v1
        with:
          environment-url: ${{ env.DEV_ENV_URL }}
          app-id: ${{ secrets.CLIENT_ID }}
          tenant-id: ${{ secrets.TENANT_ID }}
          client-secret: ${{ secrets.CLIENT_SECRET }}
          solution-name: ${{ github.event.inputs.solution_name }}
          solution-output-file: out/solutions/${{ github.event.inputs.solution_name }}.zip
          managed: false

      - name: Export Managed Solution
        uses: microsoft/powerplatform-actions/export-solution@v1
        with:
          environment-url: ${{ env.DEV_ENV_URL }}
          app-id: ${{ secrets.CLIENT_ID }}
          tenant-id: ${{ secrets.TENANT_ID }}
          client-secret: ${{ secrets.CLIENT_SECRET }}
          solution-name: ${{ github.event.inputs.solution_name }}
          solution-output-file: out/solutions/${{ github.event.inputs.solution_name }}_managed.zip
          managed: true

      - name: Unpack Solution for Source Control
        uses: microsoft/powerplatform-actions/unpack-solution@v1
        with:
          solution-file: out/solutions/${{ github.event.inputs.solution_name }}.zip
          solution-folder: out/solutions/${{ github.event.inputs.solution_name }}/
          solution-type: 'Unmanaged'
          overwrite-files: true

      - name: Commit Solution to Repository
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add -A
          git commit -m "chore: export ${{ github.event.inputs.solution_name }} [skip ci]"
          git push

  # ═══ JOB 2: Import to PROD ═══
  import-to-prod:
    runs-on: windows-latest
    needs: export-from-dev
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Install Power Platform Tools
        uses: microsoft/powerplatform-actions/actions-install@v1

      - name: Import Managed Solution
        uses: microsoft/powerplatform-actions/import-solution@v1
        with:
          environment-url: ${{ env.PROD_ENV_URL }}
          app-id: ${{ secrets.CLIENT_ID }}
          tenant-id: ${{ secrets.TENANT_ID }}
          client-secret: ${{ secrets.CLIENT_SECRET }}
          solution-file: out/solutions/${{ github.event.inputs.solution_name }}_managed.zip
          force-overwrite: true
          publish-changes: true
          run-asynchronously: true
```

---

## 6. Full PAC CLI Command Reference

### 6.1 Solution Commands

```bash
# ─── LIST ───
pac solution list                              # List all solutions in environment

# ─── EXPORT ───
pac solution export \
  --name "SolutionName" \
  --path ./exports/Solution.zip \
  --managed false \
  --async

# ─── IMPORT ───
pac solution import \
  --path ./exports/Solution.zip \
  --publish-changes \
  --force-overwrite \
  --async

# ─── PACK (source → zip) ───
pac solution pack \
  --folder ./src/SolutionName/ \
  --zipfile ./exports/Solution.zip \
  --packagetype Unmanaged

# ─── UNPACK (zip → source) ───
pac solution unpack \
  --zipfile ./exports/Solution.zip \
  --folder ./src/SolutionName/ \
  --packagetype Unmanaged \
  --allowWrite true

# ─── CLONE ───
pac solution clone \
  --name "SolutionName" \
  --outputDirectory ./cloned/

# ─── PUBLISH ───
pac solution publish

# ─── DELETE ───
pac solution delete --solution-name "SolutionName"

# ─── VERSION ───
pac solution version --strategy solution \
  --solutionPath ./src/SolutionName/
```

### 6.2 Authentication Commands

```bash
# Create auth profile (browser login)
pac auth create --environment https://your-org.crm.dynamics.com/

# Create auth with Service Principal
pac auth create \
  --environment https://your-org.crm.dynamics.com/ \
  --applicationId <APP_ID> \
  --clientSecret <SECRET> \
  --tenant <TENANT_ID>

# List profiles
pac auth list

# Select profile
pac auth select --index 1

# Delete profile
pac auth delete --index 1

# Clear all
pac auth clear
```

### 6.3 Environment Commands

```bash
pac env list                          # List all environments
pac env select --environment <URL>    # Select active environment
pac env create --name "Dev" --type Developer
pac env copy --source <URL> --target <URL>
pac env backup --environment <URL>
pac env restore --source <URL> --target <URL>
pac env delete --environment <URL>
```

### 6.4 Data Commands (Windows Only)

```bash
pac data export \
  --schemaFile ./schema.xml \
  --dataFile ./data.zip \
  --overwrite

pac data import \
  --data ./data.zip
```

### 6.5 Power Pages Commands

```bash
pac pages download \
  --path ./pages/ \
  --webSiteId <SITE_ID>

pac pages upload \
  --path ./pages/

pac pages preview
```

### 6.6 PCF (Code Components) Commands

```bash
pac pcf init --namespace MyNamespace --name MyComponent --template field
pac pcf build
pac pcf push --publisher-prefix myprefix
```

### 6.7 Copilot / MCP Commands

```bash
pac copilot mcp --run              # Start MCP server
pac copilot mcp --list-tools       # List available MCP tools
```

---

## 7. Decision Matrix — Which Tool to Use

| Use Case | Recommended Tool | Why |
|----------|-----------------|-----|
| **Interactive dev in VS Code** | Power Platform Tools VSIX | Full CLI + visual panels + IntelliSense |
| **AI-assisted operations** | PAC MCP Server (official) | Natural language → pac commands |
| **Deep Dataverse exploration** | michsob/powerplatform-mcp | Rich metadata, entity, plugin queries |
| **Power Automate + AI agents** | Cliveo/Power-Platform-MCP | Flow management + Copilot integration |
| **CI/CD pipelines** | GitHub Actions (`powerplatform-actions`) | Automated ALM, no human interaction |
| **Shell scripts / automation** | Standalone PAC CLI (.NET Tool) | Cross-platform, scriptable |
| **Quick one-off operations** | PAC CLI in terminal | Fastest for ad-hoc commands |

---

## 8. Installation Checklist

```
[ ] 1. Install .NET 6+ SDK (required for PAC CLI)
        → https://dotnet.microsoft.com/download

[ ] 2. Install PAC CLI globally
        → dotnet tool install --global Microsoft.PowerApps.CLI.Tool

[ ] 3. Verify installation
        → pac --version

[ ] 4. Install Power Platform Tools VSIX in VS Code
        → Extensions → Search "Power Platform Tools" → Install

[ ] 5. Create first auth profile
        → pac auth create --environment https://your-org.crm.dynamics.com/

[ ] 6. Verify connection
        → pac env list
        → pac solution list

[ ] 7. (Optional) Configure PAC MCP Server
        → Add pac-mcp config to your MCP client settings

[ ] 8. (Optional) Set up GitHub Actions
        → Store CLIENT_ID, TENANT_ID, CLIENT_SECRET as GitHub Secrets
        → Create .github/workflows/power-platform.yml

[ ] 9. (Optional) Clone community MCP servers
        → git clone https://github.com/michsob/powerplatform-mcp.git
        → git clone https://github.com/Cliveo/Power-Platform-MCP.git
```

---

## 9. References & Links

### Official Microsoft Resources

| Resource | URL |
|----------|-----|
| PAC CLI Documentation | https://learn.microsoft.com/power-platform/developer/cli/introduction |
| Power Platform Tools VSIX | https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.powerplatform-vscode |
| PAC Solution Commands | https://learn.microsoft.com/power-platform/developer/cli/reference/solution |
| PAC Auth Commands | https://learn.microsoft.com/power-platform/developer/cli/reference/auth |
| PAC Environment Commands | https://learn.microsoft.com/power-platform/developer/cli/reference/environment |
| GitHub Actions Docs | https://learn.microsoft.com/power-platform/alm/devops-github-actions |
| GitHub Actions Repo | https://github.com/microsoft/powerplatform-actions |

### Community MCP Servers

| Resource | URL |
|----------|-----|
| michsob/powerplatform-mcp | https://github.com/michsob/powerplatform-mcp |
| Cliveo/Power-Platform-MCP | https://github.com/Cliveo/Power-Platform-MCP |

### Related Tools

| Resource | URL |
|----------|-----|
| .NET SDK Download | https://dotnet.microsoft.com/download |
| Azure AD App Registration | https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps |
| Power Platform Admin Center | https://admin.powerplatform.microsoft.com |

---

> **Document Version**: 1.0 · May 2026
>
> **Author**: AI-assisted technical documentation
>
> **Distribution**: Approved for sharing with developers and AI agents
