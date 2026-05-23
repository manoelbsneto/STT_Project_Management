# AGENTS.md — Configuração do Ambiente de Desenvolvimento

> **Propósito:** Este arquivo contém instruções e contexto para agentes de código (AIs) trabalharem neste projeto, especialmente no GitHub Codespaces via iPad ou celular (VS Code para Web).

---

## Configuração Atual do Projeto

| Componente | Tecnologia | Versão |
|---|---|---|
| Backend / CLI | Python | ≥3.12 |
| Frontend / Servidor Web | Node.js | ≥18.0.0 (LTS) |
| PMO Cockpit (Web App) | Express.js / Vanilla JS | — |
| AI Assistants | Aider, GitHub Copilot, Codex | — |

---

## Desenvolvimento Remoto (iPad / Celular)

### 1. Como Acessar o Codespace

1. No **iPad** ou **celular**, abra o navegador e acesse:
   `https://github.com/codespaces`
2. Selecione o codespace deste repositório e clique em **"Open in Visual Studio Code for Web"** (icone de navegador).
3. Pronto! Você terá o VS Code completo no navegador, com terminal integrado e extensões.

### 2. Iniciar o Servidor PMO Cockpit Pesquisa no Celular

Após o codespace estar aberto, abra o terminal (`Ctrl+``) e execute:

```bash
cd Web_MD_Viewer
npm start
```

O GitHub Codespaces irá automaticamente encaminhar a porta `7777` (padrão do cockpit). Clique no link que aparecer no painel **PORTS** ou use a URL pública gerada pelo Codespaces.

---

## Segredos (Secrets) Obrigatórios

> ⚠️ **ATENÇÃO:** Nunca comite chaves de API no repositório. Use os **Secrets do GitHub Codespaces** listados abaixo.

### Onde Configurar

1. No GitHub, vá em: **Settings → Secrets and Variables → Codespaces**
2. Clique em **"New repository secret"** e adicione os seguintes secrets:

| Nome do Secret | O que é | Onde Pegar | Obrigatório? |
|---|---|---|---|
| `GITHUB_TOKEN` | Token de autenticação do GitHub (Copilot + CLI) | [GitHub Settings → Developer Settings → Tokens](https://github.com/settings/tokens) | **SIM** |
| `GITHUB_USER` | Seu nome de usuário do GitHub | GitHub Profile | **SIM** |
| `OPENAI_API_KEY` | Chave de API da OpenAI | [OpenAI Platform](https://platform.openai.com/api-keys) | **SIM** (para Aider + Codex) |
| `AIDER_MODEL` | Modelo principal do Aider (ex: `gpt-4o`) | Definido por você | Opcional (padrão: `gpt-4o`) |
| `AIDER_WEAK_MODEL` | Modelo "barato" para tarefas simples | Definido por você | Opcional (padrão: `gpt-4o-mini`) |
| `GOOGLE_CLOUD_PROJECT` | ID do projeto no Google Cloud | [Google Cloud Console](https://console.cloud.google.com) | Se usar Gemini/Vertex |
| `GOOGLE_CLOUD_LOCATION` | Região do Google Cloud (ex: `global`) | Google Cloud Console | Se usar Gemini/Vertex |
| `GOOGLE_GENAI_USE_VERTEXAI` | Flag para usar Vertex AI | `True` ou `False` | Se usar Gemini/Vertex |

### Como os Secrets Funcionam no Codespaces

No arquivo [`.devcontainer/devcontainer.json`](./.devcontainer/devcontainer.json), os secrets são referenciados como variáveis de ambiente:

```json
"remoteEnv": {
  "OPENAI_API_KEY": "${{ secrets.OPENAI_API_KEY }}",
  "AIDER_MODEL": "${{ secrets.AIDER_MODEL }}",
  ...
}
```

Isso faz com que, ao abrir o codespace, as chaves já estejam disponíveis no ambiente (como no `.env`), sem precisar configurar manualmente.

---

## Uso do Aider no Codespaces

O **Aider** foi projetado para trabalhar com o Git. Quando dentro de um codespace:

```bash
# O terminal no VS Code for Web já terá o Git configurado.
aider --model gpt-4o
```

Se o `OPENAI_API_KEY` estiver nos secrets do Codespaces, o Aider funcionará automaticamente, permitindo que você edite código, envie prompts de arquitetura e analise logs via chat diretamente do iPad.

---

## Comandos Úteis

| Comando | Descrição |
|---|---|
| `pip install -e .` | Instala o pacote Python localmente |
| `cd Web_MD_Viewer && npm start` | Inicia o servidor do PMO Cockpit |
| `aider --model gpt-4o` | Inicia o Aider com o modelo principal |
| `gh auth status` | Verifica se o GitHub CLI está autenticado |

---

## Notas de Segurança

- O arquivo local `.env` está no `.gitignore` e NUNCA deve ser comitado.
- Se precisar de uma nova chave de API, gere uma nova no painel do provedor e atualize o secret no GitHub (não no `.env` do codespace).
- O GitHub automaticamente revoga tokens expostos publicamente, mas o ideal é prevenir commits acidentais usando o `.gitignore`.
