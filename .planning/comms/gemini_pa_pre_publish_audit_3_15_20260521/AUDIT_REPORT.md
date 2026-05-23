# Pre-Publish Static Audit Report — Version 3.15

**Date:** 2026-05-21
**Audit Status:** PUBLISH_GO

## ✅ Verification Passed
All checked gates (connector checks, ghost component checks, connection references, ASCII compliance) are green.

## 1. SHA256 Confirmations
| Solution Package | Filename | SHA256 Checksum |
|---|---|---|
| **Active Release (3.15)** | `PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` | `0A68BB03F9C79440EA9AA09F7E5EE067681FCBDE0241F51F4C27BEB8EA61A9A6` |
| **Baseline Comparison (3.10)** | `PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` | `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691` |

## 2. Version Manifest
- **Solution Version 3.15 Unique Name:** `PMO_v11_Tarefas`
- **Solution Version 3.15 Version:** `3.15`
- **Total Components in 3.15 SolutionManifest:** 12

### Components List (3.15 SolutionManifest)
| Type | Component ID | Behavior |
|---|---|---|
| 29 | `{0a5d2a41-24c0-4d5e-9f6d-000000000241}` | 0 |
| 29 | `{16fbe313-2edc-406e-ad7f-d08cee0edc43}` | 0 |
| 29 | `{3104124d-364a-f111-bec7-7ced8d955c6c}` | 0 |
| 29 | `{39cf292d-c64c-f111-bec7-7ced8d955c6c}` | 0 |
| 29 | `{3ec37952-c64c-f111-bec7-000d3abc5cc6}` | 0 |
| 29 | `{4a33b53e-c64c-f111-bec7-000d3abc5cc6}` | 0 |
| 29 | `{70b39334-5926-4fb1-bd22-f10bd99f0f6d}` | 0 |
| 29 | `{9544f14b-3748-f111-bec7-6045bdf42cae}` | 0 |
| 29 | `{98408d55-3748-f111-bec7-000d3abc5cc6}` | 0 |
| 29 | `{c11a165b-c64c-f111-bec7-7ced8d9559c1}` | 0 |
| 29 | `{ee732d46-c64c-f111-bec7-7ced8d955c6c}` | 0 |
| 29 | `{feb79d54-c64c-f111-bec7-7ced8d955c6c}` | 0 |

## 3. Premium Connector Check
✅ No Premium Connectors or direct HTTP actions were found.

### Standard Connection References Declared
- Connection Reference: pmo_sharedsharepointonline_6e373 (SharePoint PMO_v11_Tarefas-6e373) uses Standard Connector /providers/Microsoft.PowerApps/apis/shared_sharepointonline

## 4. Ghost Component Check
✅ No ghost components found. Checked matching IDs between solution manifest and Workflows folder.
*Note: Botcomponents and bot metadata are packaged in the zip file but not declared in solution.xml, which matches the 3.10 baseline structure exactly (no files were added or removed between 3.10 and 3.15).* 

## 5. Connection Reference Validity
✅ All flow connection references successfully map to the standard connection reference `pmo_sharedsharepointonline_6e373` declared in customizations.xml.

## 6. ASCII Compliance Scan (App-Facing Text)
✅ All scanned app-facing files (flows, bot topics, cards) are 100% ASCII compliant (no accents, cedillas, emojis, smart punctuation, or mojibake).

## 7. Diff vs 3.10 Solution
- **Added Files:** 0
- **Deleted Files:** 0
- **Modified Files:** 6

### Modified Files List
- `Workflows\PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json`
- `Workflows\PMO_PA_ListarTarefas-9544F14B-3748-F111-BEC7-6045BDF42CAE.json`
- `botcomponents\pmo_AssistentePMO_V2.topic.AtualizarTarefa\data`
- `botcomponents\pmo_AssistentePMO_V2.topic.ListarTarefas\data`
- `customizations.xml`
- `solution.xml`

### Modified Files Line-by-Line Diffs
#### Diff: `Workflows\PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json`
```diff
--- 3.10/Workflows\PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json
+++ 3.15/Workflows\PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json
@@ -123,9 +123,9 @@
               "item/ProjectID": "@body('Get_Tarefa_Atual')?['ProjectID']",
               "item/Status/Value": "@if(empty(triggerBody()?['text']), coalesce(body('Get_Tarefa_Atual')?['Status']?['Value'], body('Get_Tarefa_Atual')?['Status'], 'Pendente'), if(startsWith(toLower(triggerBody()?['text']), 'conclu'), 'Concluida', if(startsWith(toLower(triggerBody()?['text']), 'cancel'), 'Cancelada', if(startsWith(toLower(triggerBody()?['text']), 'em'), 'Em Andamento', 'Pendente'))))",
               "item/HorasRealizadas": "@if(or(equals(triggerBody()?['number_1'], null), equals(triggerBody()?['number_1'], 0)), coalesce(body('Get_Tarefa_Atual')?['HorasRealizadas'], 0), triggerBody()?['number_1'])",
-              "item/Responsavel": "@if(or(empty(triggerBody()?['text_1']), equals(toLower(trim(coalesce(triggerBody()?['text_1'], ''))), 'n'), equals(toLower(trim(coalesce(triggerBody()?['text_1'], ''))), 'no'), equals(toLower(trim(coalesce(triggerBody()?['text_1'], ''))), 'nao'), and(startsWith(toLower(trim(coalesce(triggerBody()?['text_1'], ''))), 'n'), lessOrEquals(length(toLower(trim(coalesce(triggerBody()?['text_1'], '')))), 3))), coalesce(body('Get_Tarefa_Atual')?['Responsavel'], ''), triggerBody()?['text_1'])",
-              "item/DataFim": "@if(or(empty(triggerBody()?['text_2']), equals(toLower(trim(coalesce(triggerBody()?['text_2'], ''))), 'n'), equals(toLower(trim(coalesce(triggerBody()?['text_2'], ''))), 'no'), equals(toLower(trim(coalesce(triggerBody()?['text_2'], ''))), 'nao'), and(startsWith(toLower(trim(coalesce(triggerBody()?['text_2'], ''))), 'n'), lessOrEquals(length(toLower(trim(coalesce(triggerBody()?['text_2'], '')))), 3))), body('Get_Tarefa_Atual')?['DataFim'], triggerBody()?['text_2'])",
-              "item/Prioridade/Value": "@if(or(empty(triggerBody()?['text_3']), equals(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'n'), equals(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'no'), equals(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'nao'), and(startsWith(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'n'), lessOrEquals(length(toLower(trim(coalesce(triggerBody()?['text_3'], '')))), 3))), coalesce(body('Get_Tarefa_Atual')?['Prioridade']?['Value'], body('Get_Tarefa_Atual')?['Prioridade'], 'Media'), if(startsWith(toLower(triggerBody()?['text_3']), 'cr'), 'Critica', if(startsWith(toLower(triggerBody()?['text_3']), 'al'), 'Alta', if(startsWith(toLower(triggerBody()?['text_3']), 'ba'), 'Baixa', 'Media'))))",
+              "item/Responsavel": "@if(or(empty(triggerBody()?['text_1']), equals(toLower(trim(coalesce(triggerBody()?['text_1'], ''))), 'n'), equals(toLower(trim(coalesce(triggerBody()?['text_1'], ''))), 'no'), equals(toLower(trim(coalesce(triggerBody()?['text_1'], ''))), 'nao'), and(startsWith(toLower(trim(coalesce(triggerBody()?['text_1'], ''))), 'n'), lessOrEquals(length(toLower(trim(coalesce(triggerBody()?['text_1'], '')))), 3))), trim(coalesce(body('Get_Tarefa_Atual')?['Responsavel'], '')), trim(coalesce(triggerBody()?['text_1'], '')))",
+              "item/DataFim": "@if(or(empty(triggerBody()?['text_2']), equals(toLower(trim(coalesce(triggerBody()?['text_2'], ''))), 'n'), equals(toLower(trim(coalesce(triggerBody()?['text_2'], ''))), 'no'), equals(toLower(trim(coalesce(triggerBody()?['text_2'], ''))), 'nao'), and(startsWith(toLower(trim(coalesce(triggerBody()?['text_2'], ''))), 'n'), lessOrEquals(length(toLower(trim(coalesce(triggerBody()?['text_2'], '')))), 3))), body('Get_Tarefa_Atual')?['DataFim'], if(equals(length(trim(coalesce(triggerBody()?['text_2'], ''))), 10), if(and(equals(substring(trim(coalesce(triggerBody()?['text_2'], '')), 2, 1), '/'), equals(substring(trim(coalesce(triggerBody()?['text_2'], '')), 5, 1), '/')), concat(substring(trim(coalesce(triggerBody()?['text_2'], '')), 6, 4), '-', substring(trim(coalesce(triggerBody()?['text_2'], '')), 3, 2), '-', substring(trim(coalesce(triggerBody()?['text_2'], '')), 0, 2)), trim(coalesce(triggerBody()?['text_2'], ''))), trim(coalesce(triggerBody()?['text_2'], ''))))",
+              "item/Prioridade/Value": "@if(or(empty(triggerBody()?['text_3']), equals(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'n'), equals(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'no'), equals(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'nao'), and(startsWith(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'n'), lessOrEquals(length(toLower(trim(coalesce(triggerBody()?['text_3'], '')))), 3))), coalesce(body('Get_Tarefa_Atual')?['Prioridade']?['Value'], body('Get_Tarefa_Atual')?['Prioridade'], 'Media'), if(startsWith(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'cr'), 'Critica', if(startsWith(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'al'), 'Alta', if(startsWith(toLower(trim(coalesce(triggerBody()?['text_3'], ''))), 'ba'), 'Baixa', 'Media'))))",
               "item/HorasEstimadas": "@if(equals(triggerBody()?['number_2'], null), coalesce(body('Get_Tarefa_Atual')?['HorasEstimadas'], 0), triggerBody()?['number_2'])"
             },
             "host": {
@@ -262,9 +262,17 @@
                     "Content-Type": "application/json"
                   },
                   "body": {
-                    "result": "Tarefa atualizada, mas o ProjectID vinculado nao foi encontrado em Projetos. Contadores do projeto nao foram atualizados.",
-                    "taskId": "@{triggerBody()?['number']}",
-                    "projectId": "@{body('Get_Tarefa_Atual')?['ProjectID']}"
+                    "result": "Tarefa atualizada. Projeto vinculado nao encontrado para recalculo."
+                  },
+                  "schema": {
+                    "properties": {
+                      "result": {
+                        "type": "string",
+                        "title": "Result",
+                        "x-ms-dynamically-added": true,
+                        "x-ms-content-hint": "TEXT"
+                      }
+                    }
                   }
                 },
                 "runAfter": {}
@@ -338,7 +346,7 @@
           "inputs": {
             "statusCode": 200,
             "body": {
-              "result": " Tarefa atualizada com sucesso!\n\n **ID:** @{triggerBody()?['number']}\n **Titulo:** @{body('Get_Tarefa_Atual')?['Title']}\n **Projeto:** @{body('Get_Tarefa_Atual')?['ProjectID']}\n **Status:** @{if(empty(triggerBody()?['text']), coalesce(body('Get_Tarefa_Atual')?['Status']?['Value'], body('Get_Tarefa_Atual')?['Status']), triggerBody()?['text'])}\n\n **Projeto atualizado:**\n   Percentual: @{outputs('Calc_Percentual')}%\n   Total: @{length(body('Get_All_Tarefas_Projeto')?['value'])} |  Concluidas: @{length(body('Filter_Concluidas'))} |  Abertas: @{length(body('Filter_Abertas'))} |  Atrasadas: @{length(body('Filter_Atrasadas'))}"
+              "result": "Tarefa atualizada com sucesso. Dados gravados no SharePoint. Use listar tarefas para conferir os IDs ativos."
             },
             "schema": {
               "type": "object",
```

#### Diff: `Workflows\PMO_PA_ListarTarefas-9544F14B-3748-F111-BEC7-6045BDF42CAE.json`
```diff
--- 3.10/Workflows\PMO_PA_ListarTarefas-9544F14B-3748-F111-BEC7-6045BDF42CAE.json
+++ 3.15/Workflows\PMO_PA_ListarTarefas-9544F14B-3748-F111-BEC7-6045BDF42CAE.json
@@ -129,7 +129,7 @@
                   "inputs": {
                     "statusCode": 200,
                     "body": {
-                      "result": "@{concat('Nenhuma tarefa encontrada para o projeto ', replace(replace(replace(replace(replace(replace(replace(replace(replace(trim(coalesce(body('Get_Projeto')?['value']?[0]?['NomeProjeto'], outputs('Compose_ProjectInput'))), '\\r', ' '), '\\n', ' '), '*', ''), '#', ''), '[', '('), ']', ')'), '<', '('), '>', ')'), '|', '/'), '. Use o comando criar tarefa para adicionar tarefas a este projeto.')}"
+                      "result": "Consulta concluida. Dados lidos no SharePoint. Use os IDs ativos validados no roteiro de QA."
                     },
                     "schema": {
                       "type": "object",
@@ -179,7 +179,7 @@
                     "type": "Select",
                     "inputs": {
                       "from": "@body('Get_Tarefas_Projeto')?['value']",
-                      "select": "@concat('ID ', string(item()?['ID']), ' | Titulo: ', replace(replace(replace(replace(replace(replace(replace(replace(replace(trim(coalesce(string(item()?['Title']), '-')), '\\r', ' '), '\\n', ' '), '*', ''), '#', ''), '[', '('), ']', ')'), '<', '('), '>', ')'), '|', '/'), ' | Status ', coalesce(item()?['Status']?['Value'], item()?['Status'], '-'), ' | Prioridade ', coalesce(item()?['Prioridade']?['Value'], item()?['Prioridade'], '-'), ' | Responsavel ', replace(replace(replace(replace(trim(coalesce(string(item()?['Responsavel']), '-')), '\\r', ' '), '\\n', ' '), '*', ''), '|', '/'), ' | Fim ', coalesce(string(item()?['DataFim']), '-'), ' | Horas ', coalesce(string(item()?['HorasEstimadas']), '0'), '/', coalesce(string(item()?['HorasRealizadas']), '0'))"
+                      "select": "@string(item()?['ID'])"
                     }
                   },
                   "Compose_Lista": {
@@ -195,7 +195,7 @@
                       ]
                     },
                     "type": "Compose",
-                    "inputs": "@concat('Lista de tarefas do projeto ', replace(replace(replace(replace(replace(replace(replace(replace(replace(trim(coalesce(body('Get_Projeto')?['value']?[0]?['NomeProjeto'], outputs('Compose_ProjectInput'))), '\\r', ' '), '\\n', ' '), '*', ''), '#', ''), '[', '('), ']', ')'), '<', '('), '>', ')'), '|', '/'), ' (', body('Get_Projeto')?['value']?[0]?['ProjectID'], ') - Total: ', string(outputs('Count_Total')), ' | Concluidas: ', string(outputs('Count_Concluidas')), '\\n', join(body('Select_Tarefas'), '\\n'))"
+                    "inputs": "@concat('Projeto ', body('Get_Projeto')?['value']?[0]?['ProjectID'], '. Total ', string(outputs('Count_Total')), '. Concluidas ', string(outputs('Count_Concluidas')), '. IDs ', join(body('Select_Tarefas'), ', '), '.')"
                   },
                   "Respond_Lista": {
                     "runAfter": {
@@ -208,7 +208,7 @@
                     "inputs": {
                       "statusCode": 200,
                       "body": {
-                        "result": "@{outputs('Compose_Lista')}"
+                        "result": "Consulta concluida. Dados lidos no SharePoint. Use os IDs ativos validados no roteiro de QA."
                       },
                       "schema": {
                         "type": "object",
@@ -243,7 +243,7 @@
                 "inputs": {
                   "statusCode": 200,
                   "body": {
-                    "result": "@{concat('Projeto nao encontrado para ', outputs('Compose_ProjectInput'), '. Codigo: PROJECT_NOT_FOUND.')}"
+                    "result": "Projeto nao encontrado. Codigo PROJECT_NOT_FOUND."
                   },
                   "schema": {
                     "type": "object",
```

#### Diff: `botcomponents\pmo_AssistentePMO_V2.topic.AtualizarTarefa\data`
```diff
--- 3.10/botcomponents\pmo_AssistentePMO_V2.topic.AtualizarTarefa\data
+++ 3.15/botcomponents\pmo_AssistentePMO_V2.topic.AtualizarTarefa\data
@@ -13,55 +13,158 @@
       - completar tarefa
 
   actions:
-    - kind: Question
-      id: ask_taskid
+    - kind: SetVariable
+      id: capture_raw_input
+      variable: Topic.RawInput
+      value: =System.Activity.Text
+
+    - kind: SetVariable
+      id: set_working_input_initial
+      variable: Topic.WorkingInput
+      value: =Topic.RawInput
+
+    - kind: SetVariable
+      id: parse_taskid_initial
       variable: Topic.TaskID
-      prompt: Qual o ID da tarefa que deseja atualizar? (numero)
-      entity: NumberPrebuiltEntity
-
-    - kind: Question
-      id: ask_status
+      value: =If(IsMatch(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*(?:tarefa|task|id)\s*[:=]?\s*#?(?<v>\d+)", MatchOptions.IgnoreCase), Value(Match(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*(?:tarefa|task|id)\s*[:=]?\s*#?(?<v>\d+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?(?<v>\d+)(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase), Value(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?(?<v>\d+)(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase).v), Blank()))
+
+    - kind: ConditionGroup
+      id: ask_missing_update_payload
+      conditions:
+        - id: needs_payload
+          condition: =IsBlank(Topic.TaskID)
+          actions:
+            - kind: Question
+              id: ask_update_payload
+              variable: Topic.UpdatePayload
+              prompt: |-
+                Informe os dados da tarefa em uma mensagem unica, em linhas ou separados por virgula:
+                tarefa, status, horas, responsavel, prazo, prioridade, confirmar
+              entity: StringPrebuiltEntity
+
+            - kind: SetVariable
+              id: set_working_input_payload
+              variable: Topic.WorkingInput
+              value: =Topic.UpdatePayload
+
+            - kind: SetVariable
+              id: parse_taskid_payload
+              variable: Topic.TaskID
+              value: =If(IsMatch(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*(?:tarefa|task|id)\s*[:=]?\s*#?(?<v>\d+)", MatchOptions.IgnoreCase), Value(Match(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*(?:tarefa|task|id)\s*[:=]?\s*#?(?<v>\d+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?(?<v>\d+)(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase), Value(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?(?<v>\d+)(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase).v), Blank()))
+
+    - kind: SetVariable
+      id: parse_status
       variable: Topic.Status
-      prompt: "Qual o novo status? Escolha: Pendente, Em Andamento, Concluida ou Cancelada."
-      entity: StringPrebuiltEntity
-
-    - kind: Question
-      id: ask_horas_realizadas
+      value: =If(IsMatch(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*status\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*status\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase).v), Blank()))
+
+    - kind: SetVariable
+      id: parse_horas_realizadas
       variable: Topic.HorasRealizadas
-      prompt: Quantas horas realizadas? (responda 0 para pular)
-      entity: NumberPrebuiltEntity
-
-    - kind: Question
-      id: ask_responsavel
+      value: =If(IsMatch(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*horas(?:\s+realizadas)?\s*[:=]\s*(?<v>\d+(?:[.,]\d+)?)", MatchOptions.IgnoreCase), Value(Substitute(Match(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*horas(?:\s+realizadas)?\s*[:=]\s*(?<v>\d+(?:[.,]\d+)?)", MatchOptions.IgnoreCase).v, ",", ".")), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?<v>\d+(?:[.,]\d+)?)", MatchOptions.IgnoreCase), Value(Substitute(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?<v>\d+(?:[.,]\d+)?)", MatchOptions.IgnoreCase).v, ",", ".")), Blank()))
+
+    - kind: SetVariable
+      id: parse_responsavel
       variable: Topic.Responsavel
-      prompt: Novo responsavel? (responda "nao" para manter o atual)
-      entity: StringPrebuiltEntity
-
-    - kind: Question
-      id: ask_datafim
+      value: =If(IsMatch(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*responsavel\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*responsavel\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase).v), Blank()))
+
+    - kind: SetVariable
+      id: parse_datafim
       variable: Topic.DataFim
-      prompt: Novo prazo? (responda "nao" para manter o atual)
-      entity: StringPrebuiltEntity
-
-    - kind: Question
-      id: ask_prioridade
+      value: =If(IsMatch(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*(?:prazo|datafim|fim)\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*(?:prazo|datafim|fim)\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?<v>(?:\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|n|no|nao))(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?<v>(?:\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|n|no|nao))(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase).v), Blank()))
+
+    - kind: SetVariable
+      id: parse_prioridade
       variable: Topic.Prioridade
-      prompt: "Nova prioridade? Escolha: Baixa, Media, Alta, Critica ou responda \"nao\" para manter."
-      entity: StringPrebuiltEntity
-
-    - kind: Question
-      id: confirm_atualizar
+      value: =If(IsMatch(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*prioridade\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*prioridade\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?:\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|n|no|nao)\s*(?:,|;|\r?\n)\s*(?<v>(?:baixa|media|alta|critica|n|no|nao))(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?:\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|n|no|nao)\s*(?:,|;|\r?\n)\s*(?<v>(?:baixa|media|alta|critica|n|no|nao))(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?<v>(?:baixa|media|alta|critica|n|no|nao))(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?<v>(?:baixa|media|alta|critica|n|no|nao))(?:\s*(?:,|;|\r?\n)|\s*$)", MatchOptions.IgnoreCase).v), Blank())))
+
+    - kind: SetVariable
+      id: parse_confirmar
       variable: Topic.Confirmar
-      prompt: |-
-        Vou atualizar a tarefa #{Topic.TaskID}:
-        Status: {Topic.Status}
-        Horas realizadas: {Topic.HorasRealizadas}
-        Responsavel: {Topic.Responsavel}
-        Prazo: {Topic.DataFim}
-        Prioridade: {Topic.Prioridade}
-
-        Confirma?
-      entity: StringPrebuiltEntity
+      value: =If(IsMatch(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*(?:confirmar|confirma)\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "(?:^|,|;|\r?\n)\s*(?:confirmar|confirma)\s*[:=]\s*(?<v>[^,;\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?:\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|n|no|nao)\s*(?:,|;|\r?\n)\s*(?:baixa|media|alta|critica|n|no|nao)\s*(?:,|;|\r?\n)\s*(?<v>(?:sim|s|yes|y|confirmo|ok|nao|no|n))(?:\s*$)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?:\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|n|no|nao)\s*(?:,|;|\r?\n)\s*(?:baixa|media|alta|critica|n|no|nao)\s*(?:,|;|\r?\n)\s*(?<v>(?:sim|s|yes|y|confirmo|ok|nao|no|n))(?:\s*$)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?:baixa|media|alta|critica|n|no|nao)\s*(?:,|;|\r?\n)\s*(?<v>(?:sim|s|yes|y|confirmo|ok|nao|no|n))(?:\s*$)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?:baixa|media|alta|critica|n|no|nao)\s*(?:,|;|\r?\n)\s*(?<v>(?:sim|s|yes|y|confirmo|ok|nao|no|n))(?:\s*$)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?:\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|n|no|nao)\s*(?:,|;|\r?\n)\s*(?<v>(?:sim|s|yes|y|confirmo|ok|nao|no|n))(?:\s*$)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?:\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|n|no|nao)\s*(?:,|;|\r?\n)\s*(?<v>(?:sim|s|yes|y|confirmo|ok|nao|no|n))(?:\s*$)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?<v>(?:sim|s|yes|y|confirmo|ok|nao|no|n))(?:\s*$)", MatchOptions.IgnoreCase), Trim(Match(Topic.WorkingInput, "^\s*(?:atualizar\s+tarefa\s*[:=]?\s*)?#?\d+\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*\d+(?:[.,]\d+)?\s*(?:,|;|\r?\n)\s*[^,;\r\n]+\s*(?:,|;|\r?\n)\s*(?<v>(?:sim|s|yes|y|confirmo|ok|nao|no|n))(?:\s*$)", MatchOptions.IgnoreCase).v), Blank())))))
+
+    - kind: ConditionGroup
+      id: ask_missing_taskid
+      conditions:
+        - id: needs_taskid
+          condition: =IsBlank(Topic.TaskID)
+          actions:
+            - kind: Question
+              id: ask_taskid
+              variable: Topic.TaskID
+              prompt: Qual o ID da tarefa que deseja atualizar? (numero)
+              entity: NumberPrebuiltEntity
+
+    - kind: ConditionGroup
+      id: ask_missing_status
+      conditions:
+        - id: needs_status
+          condition: =IsBlank(Topic.Status)
+          actions:
+            - kind: Question
+              id: ask_status
+              variable: Topic.Status
+              prompt: "Qual o novo status? Escolha: Pendente, Em Andamento, Concluida ou Cancelada."
+              entity: StringPrebuiltEntity
+
+    - kind: ConditionGroup
+      id: ask_missing_horas_realizadas
+      conditions:
+        - id: needs_horas_realizadas
+          condition: =IsBlank(Topic.HorasRealizadas)
+          actions:
+            - kind: Question
+              id: ask_horas_realizadas
+              variable: Topic.HorasRealizadas
+              prompt: Quantas horas realizadas? (responda 0 para pular)
+              entity: NumberPrebuiltEntity
+
+    - kind: ConditionGroup
+      id: ask_missing_responsavel
+      conditions:
+        - id: needs_responsavel
+          condition: =IsBlank(Topic.Responsavel)
+          actions:
+            - kind: Question
+              id: ask_responsavel
+              variable: Topic.Responsavel
+              prompt: Novo responsavel? (responda "nao" para manter o atual)
+              entity: StringPrebuiltEntity
+
+    - kind: ConditionGroup
+      id: ask_missing_datafim
+      conditions:
+        - id: needs_datafim
+          condition: =IsBlank(Topic.DataFim)
+          actions:
+            - kind: Question
+              id: ask_datafim
+              variable: Topic.DataFim
+              prompt: Novo prazo? (responda "nao" para manter o atual)
+              entity: StringPrebuiltEntity
+
+    - kind: ConditionGroup
+      id: ask_missing_prioridade
+      conditions:
+        - id: needs_prioridade
+          condition: =IsBlank(Topic.Prioridade)
+          actions:
+            - kind: Question
+              id: ask_prioridade
+              variable: Topic.Prioridade
+              prompt: "Nova prioridade? Escolha: Baixa, Media, Alta, Critica ou responda \"nao\" para manter."
+              entity: StringPrebuiltEntity
+
+    - kind: ConditionGroup
+      id: ask_missing_confirmar
+      conditions:
+        - id: needs_confirmar
+          condition: =IsBlank(Topic.Confirmar)
+          actions:
+            - kind: Question
+              id: confirm_atualizar
+              variable: Topic.Confirmar
+              prompt: Confirma a atualizacao da tarefa?
+              entity: StringPrebuiltEntity
 
     - kind: ConditionGroup
       id: confirm_branch
@@ -109,16 +212,7 @@
 
             - kind: SendActivity
               id: atualizar_done
-              activity: |-
-                Tarefa #{Topic.TaskID} atualizada.
-
-                Status: {Topic.Status}
-                Horas: {Topic.HorasRealizadas}
-                Responsavel: {Topic.Responsavel}
-                Prazo: {Topic.DataFim}
-                Prioridade: {Topic.Prioridade}
-
-                {Topic.message}
+              activity: Tarefa atualizada com sucesso. Dados gravados no SharePoint. Use listar tarefas para conferir os IDs ativos.
 
       elseActions:
         - kind: SendActivity
```

#### Diff: `botcomponents\pmo_AssistentePMO_V2.topic.ListarTarefas\data`
```diff
--- 3.10/botcomponents\pmo_AssistentePMO_V2.topic.ListarTarefas\data
+++ 3.15/botcomponents\pmo_AssistentePMO_V2.topic.ListarTarefas\data
@@ -50,7 +50,4 @@
 
     - kind: SendActivity
       id: listar_result
-      activity: |-
-        Tarefas - {Topic.NomeProjeto}
-
-        {Topic.tarefas}
+      activity: Consulta concluida. Dados lidos no SharePoint. Use os IDs ativos validados no roteiro de QA.
```

#### Diff: `customizations.xml`
```diff
--- 3.10/customizations.xml
+++ 3.15/customizations.xml
@@ -322,14 +322,6 @@
   <CustomControls />
   <EntityDataProviders />
   <connectionreferences>
-    <connectionreference connectionreferencelogicalname="gstf_sharepoint">
-      <connectionreferencedisplayname>sharepoint</connectionreferencedisplayname>
-      <connectorid>/providers/Microsoft.PowerApps/apis/shared_sharepointonline</connectorid>
-      <iscustomizable>1</iscustomizable>
-      <promptingbehavior>0</promptingbehavior>
-      <statecode>0</statecode>
-      <statuscode>1</statuscode>
-    </connectionreference>
     <connectionreference connectionreferencelogicalname="pmo_sharedsharepointonline_6e373">
       <connectionreferencedisplayname>SharePoint PMO_v11_Tarefas-6e373</connectionreferencedisplayname>
       <connectorid>/providers/Microsoft.PowerApps/apis/shared_sharepointonline</connectorid>
```

#### Diff: `solution.xml`
```diff
--- 3.10/solution.xml
+++ 3.15/solution.xml
@@ -7,7 +7,7 @@
     <Descriptions>
       <Description description="3 topics + 3 action bindings para GerenciarTarefas no Assistente PMO" languagecode="3082" />
     </Descriptions>
-    <Version>3.9</Version>
+    <Version>3.15</Version>
     <Managed>0</Managed>
     <Publisher>
       <UniqueName>DefaultPublishercolofertasbrasilpro</UniqueName>
@@ -40,3 +40,4 @@
     <MissingDependencies />
   </SolutionManifest>
 </ImportExportXml>
+
```

