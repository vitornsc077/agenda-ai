# 🤖 AgendaAI MCP Server (Python)

Servidor oficial do protocolo **MCP (Model Context Protocol)** para integração direta entre assistentes de Inteligência Artificial (Claude Desktop, Cursor, Windsurf, Antigravity IDE, LangChain) e a sua plataforma de agendamentos **AgendaAI**.

---

## 🛠️ Ferramenta Disponível (*Tool*)

### `create_service`
Cadastra um novo serviço no seu estabelecimento, configurando nome, duração, preço, descrição e status de ativação. O serviço fica imediatamente disponível para agendamentos online na sua página pública.

#### Parâmetros:
| Parâmetro | Tipo | Obrigatório | Padrão | Descrição |
|---|---|---|---|---|
| `name` | `string` | **Sim** | - | Nome do serviço (ex: *"Corte Degradê Premium"*) |
| `duration_minutes` | `integer` | Não | `30` | Duração em minutos (ex: `15`, `30`, `45`, `60`) |
| `price_reais` | `number` | Não | `0.0` | Preço em Reais (R$) (ex: `45.00`, `80.00`) |
| `description` | `string` | Não | `""` | Descrição dos procedimentos inclusos |
| `active` | `boolean` | Não | `true` | Se o serviço já entra ativo na página pública |
| `api_token` | `string` | Não | *env* | Token de autenticação (opcional se definido em `AGENDA_AI_API_TOKEN`) |

---

## 🔑 Como Obter seu Token de API

1. Acesse o painel administrativo do seu AgendaAI: **`https://agenda-ai-okr3.onrender.com/session/new`**
2. No menu lateral, clique em **"API & Integração MCP"** (ou acesse diretamente `/admin/api_token`).
3. Copie o seu **Token Pessoal**.

---

## 🚀 Como Configurar no Claude Desktop

Adicione ao seu arquivo de configuração `claude_desktop_config.json`:

- **MacOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux:** `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "agenda-ai": {
      "command": "python3",
      "args": ["/caminho/completo/para/agenda-ai/mcp_server/server.py"],
      "env": {
        "AGENDA_AI_API_TOKEN": "SEU_TOKEN_AQUI",
        "AGENDA_AI_BASE_URL": "https://agenda-ai-okr3.onrender.com"
      }
    }
  }
}
```

---

## 💡 Exemplos de Prompts para o Assistente de IA

Uma vez conectado, você pode pedir ao Claude/Cursor:

- *"Cadastre um novo serviço de 'Barboterapia com Toalha Quente' por R$ 50,00 e duração de 40 minutos."*
- *"Crie o serviço 'Design de Sobrancelha' com valor de R$ 35,00 e duração de 20 minutos no meu AgendaAI."*
- *"Adicione o serviço 'Limpeza de Pele Profunda' com valor de R$ 120,00 e 60 minutos."*

---

## 🧪 Como Testar Manualmente

Você pode rodar o script de teste incluído:

```bash
python3 mcp_server/test_mcp.py
```
