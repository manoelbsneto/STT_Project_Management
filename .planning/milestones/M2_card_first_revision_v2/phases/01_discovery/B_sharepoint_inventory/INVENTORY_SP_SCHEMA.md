# Track B.1 - SharePoint Schema Inventory

Source: read-only PnP PowerShell against https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital.

## Projetos

- Visible fields: 50
- Required fields: Title, ProjectID, NomeProjeto, PM, StatusRAG
- Views: 6 (Todos los elementos, Board RAG, Gallery, Todos, Projetos CrÃ­ticos, Projetos Críticos)

### Choice Fields
| Internal name | Title | Choices |
|---|---|---|
| StatusRAG | StatusRAG | Verde, Amarelo, Vermelho |
| Unidade | Unidade | TI, Digital, Dados, Infra, Seguranca |
| Prioridade | Prioridade | Alta, Media, Baixa |
| PlannerSyncStatus | PlannerSyncStatus | OK, Erro, Pendente |

### Lookup Fields
| Internal name | Title | Type | Target list | Target field |
|---|---|---|---|---|
| PM | PM | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Sponsor | Sponsor | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Author | Creado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Editor | Modificado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| ItemChildCount | Número secundario de elemento | Lookup |  | ItemChildCount |
| FolderChildCount | Recuento secundario de carpetas | Lookup |  | FolderChildCount |
| _ComplianceFlags | Configuración de la etiqueta | Lookup |  | ComplianceFlags |
| _ComplianceTag | Etiqueta de retención | Lookup |  | ComplianceTag |
| _ComplianceTagWrittenTime | Etiqueta de retención aplicada | Lookup |  | ComplianceTagWrittenTime |
| _ComplianceTagUserId | Usuario que ha aplicado la etiqueta: | Lookup |  | ComplianceTagUserId |
| AppAuthor | Aplicación creada por | Lookup | AppPrincipals | Title |
| AppEditor | Aplicación modificada por | Lookup | AppPrincipals | Title |

### Calculated Fields
None detected.

## Tarefas

- Visible fields: 41
- Required fields: Title, ProjectID, Status
- Views: 4 (Todos los elementos, Por Projeto, Kanban, Breakdown Completo)

### Choice Fields
| Internal name | Title | Choices |
|---|---|---|
| Status | Status | Pendente, Em Andamento, ConcluÃ­da, Cancelada, Testes, Piloto e Implantacao, Concluido, Cancelado |
| Prioridade | Prioridade | Baixa, MÃ©dia, Alta, CrÃ­tica |
| PlannerSyncStatus | Planner Sync Status | Pendente, OK, Erro, Ignorado |

### Lookup Fields
| Internal name | Title | Type | Target list | Target field |
|---|---|---|---|---|
| Author | Creado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Editor | Modificado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| ItemChildCount | Número secundario de elemento | Lookup |  | ItemChildCount |
| FolderChildCount | Recuento secundario de carpetas | Lookup |  | FolderChildCount |
| _ComplianceFlags | Configuración de la etiqueta | Lookup |  | ComplianceFlags |
| _ComplianceTag | Etiqueta de retención | Lookup |  | ComplianceTag |
| _ComplianceTagWrittenTime | Etiqueta de retención aplicada | Lookup |  | ComplianceTagWrittenTime |
| _ComplianceTagUserId | Usuario que ha aplicado la etiqueta: | Lookup |  | ComplianceTagUserId |
| AppAuthor | Aplicación creada por | Lookup | AppPrincipals | Title |
| AppEditor | Aplicación modificada por | Lookup | AppPrincipals | Title |

### Calculated Fields
None detected.

## Status Diario

- Visible fields: 41
- Required fields: Title, StatusID, ProjectID, DataRegistro, RAG, Resumo, OrigemEntrada
- Views: 2 (Todos los elementos, Por Projeto)

### Choice Fields
| Internal name | Title | Choices |
|---|---|---|
| RAG | RAG | Verde, Amarelo, Vermelho |
| OrigemEntrada | OrigemEntrada | AdaptiveCard, CopilotStudio, FormsFallback, ManualPMO, ImportacaoInicial |

### Lookup Fields
| Internal name | Title | Type | Target list | Target field |
|---|---|---|---|---|
| PM | PM | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Author | Creado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Editor | Modificado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| ItemChildCount | Número secundario de elemento | Lookup |  | ItemChildCount |
| FolderChildCount | Recuento secundario de carpetas | Lookup |  | FolderChildCount |
| _ComplianceFlags | Configuración de la etiqueta | Lookup |  | ComplianceFlags |
| _ComplianceTag | Etiqueta de retención | Lookup |  | ComplianceTag |
| _ComplianceTagWrittenTime | Etiqueta de retención aplicada | Lookup |  | ComplianceTagWrittenTime |
| _ComplianceTagUserId | Usuario que ha aplicado la etiqueta: | Lookup |  | ComplianceTagUserId |
| AppAuthor | Aplicación creada por | Lookup | AppPrincipals | Title |
| AppEditor | Aplicación modificada por | Lookup | AppPrincipals | Title |

### Calculated Fields
None detected.

## Riscos e Bloqueios

- Visible fields: 41
- Required fields: Title, RiskID, ProjectID, Tipo, Severidade, Descricao, DataCriacao, StatusRisco
- Views: 2 (Todos los elementos, Abertos)

### Choice Fields
| Internal name | Title | Choices |
|---|---|---|
| Tipo | Tipo | Risco, Bloqueio |
| Severidade | Severidade | Baixa, Media, Alta, Critica |
| Impacto | Impacto | Baixo, Medio, Alto, Critico |
| Probabilidade | Probabilidade | Baixa, Media, Alta |
| StatusRisco | Status | Aberto, Em Mitigacao, Escalado, Resolvido, Aceito |

### Lookup Fields
| Internal name | Title | Type | Target list | Target field |
|---|---|---|---|---|
| Owner | Owner | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| EscaladoPara | EscaladoPara | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Author | Creado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Editor | Modificado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| ItemChildCount | Número secundario de elemento | Lookup |  | ItemChildCount |
| FolderChildCount | Recuento secundario de carpetas | Lookup |  | FolderChildCount |
| _ComplianceFlags | Configuración de la etiqueta | Lookup |  | ComplianceFlags |
| _ComplianceTag | Etiqueta de retención | Lookup |  | ComplianceTag |
| _ComplianceTagWrittenTime | Etiqueta de retención aplicada | Lookup |  | ComplianceTagWrittenTime |
| _ComplianceTagUserId | Usuario que ha aplicado la etiqueta: | Lookup |  | ComplianceTagUserId |
| AppAuthor | Aplicación creada por | Lookup | AppPrincipals | Title |
| AppEditor | Aplicación modificada por | Lookup | AppPrincipals | Title |

### Calculated Fields
None detected.

## Decisoes do Board

- Visible fields: 42
- Required fields: Title, DecisionID, ProjectID, Descricao, Solicitante, Aprovador, StatusDecisao
- Views: 2 (Todos los elementos, Pendentes)

### Choice Fields
| Internal name | Title | Choices |
|---|---|---|
| StatusDecisao | Status | Pendente, Aprovada, Rejeitada, Adiada, Cancelada |
| Impacto | Impacto | Baixo, Medio, Alto, Critico |
| ResponseSource | ResponseSource | AdaptiveCard, CopilotStudio, Manual |

### Lookup Fields
| Internal name | Title | Type | Target list | Target field |
|---|---|---|---|---|
| Solicitante | Solicitante | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Aprovador | Aprovador | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Author | Creado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| Editor | Modificado por | User | {89714468-0542-4442-85fa-6405d2939c45} |  |
| ItemChildCount | Número secundario de elemento | Lookup |  | ItemChildCount |
| FolderChildCount | Recuento secundario de carpetas | Lookup |  | FolderChildCount |
| _ComplianceFlags | Configuración de la etiqueta | Lookup |  | ComplianceFlags |
| _ComplianceTag | Etiqueta de retención | Lookup |  | ComplianceTag |
| _ComplianceTagWrittenTime | Etiqueta de retención aplicada | Lookup |  | ComplianceTagWrittenTime |
| _ComplianceTagUserId | Usuario que ha aplicado la etiqueta: | Lookup |  | ComplianceTagUserId |
| AppAuthor | Aplicación creada por | Lookup | AppPrincipals | Title |
| AppEditor | Aplicación modificada por | Lookup | AppPrincipals | Title |

### Calculated Fields
None detected.

