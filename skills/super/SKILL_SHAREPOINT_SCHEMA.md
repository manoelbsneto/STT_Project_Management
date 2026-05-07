# Skill — SharePoint Schema and Data Layer Audit

Use this skill when analyzing SharePoint list dependencies for the vacation-management solution.

## Objective
Ensure lists, columns, internal names, data types, permissions and lookup logic match Copilot Studio and Power Automate.

## Required Checks
For each SharePoint reference found:
- Site URL
- List name
- List ID if present
- Column display name
- Column internal name if visible
- Data type
- Required vs optional
- Person column handling
- Choice column handling
- Date column handling
- Number column handling
- Text email vs Person email mismatch
- Filter query correctness
- Permissions required
- Whether list/schema evidence exists locally

## Common Failure Patterns
- Display name differs from internal name.
- Person column is treated as text.
- Text email column is treated as Person.
- Choice column value does not match actual choices.
- Date column receives ambiguous locale string.
- Flow filters by wrong field name.
- Flow uses hardcoded list/site instead of environment variable.
- Employee email does not match UPN.
- Manager email is blank or not resolvable.
- Balance list has no matching row.
- User lacks permissions.

## Recommended MVP Lists

### Colaboradores / Employees
| Column | Type | Notes |
|---|---|---|
| Title | Text | Employee display name |
| Email | Text or Person | Must match logged-in user |
| Gestor_Email | Text or Person | Manager email |
| Ativo | Yes/No | Recommended |

### Saldo_Ferias / Vacation Balance
| Column | Type | Notes |
|---|---|---|
| ColaboradorEmail | Text or Person | Must match employee |
| SaldoDisponivel | Number | Available days |
| AnoReferencia | Number | Recommended |
| UltimaAtualizacao | DateTime | Recommended |

### Solicitacoes_Ferias / Vacation Requests
| Column | Type | Notes |
|---|---|---|
| Title | Text | Request title |
| ColaboradorEmail | Text or Person | Requester |
| GestorEmail | Text or Person | Approver |
| DataInicio | Date | Start date |
| DataFim | Date | End date |
| DiasSolicitados | Number | Requested days |
| Status | Choice | Draft/Pending/Approved/Rejected/Cancelled |
| Comentario | Multiline text | Optional |
| ApprovalId | Text | Optional |
