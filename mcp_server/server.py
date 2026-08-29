#!/usr/bin/env python3
"""
AgendaAI MCP Server (Model Context Protocol)
Permite que assistentes de IA (Claude, Cursor, Windsurf, LangChain, etc.)
interajam com o sistema de agendamentos AgendaAI via MCP.

Tool implementada:
- create_service: Cadastra um novo serviço no AgendaAI utilizando o token de API do usuário.
"""

import sys
import json
import os
import urllib.request
import urllib.error

# Configurações padrão
DEFAULT_BASE_URL = os.environ.get("AGENDA_AI_BASE_URL", "https://agenda-ai-okr3.onrender.com")
DEFAULT_API_TOKEN = os.environ.get("AGENDA_AI_API_TOKEN", "")

def create_service_api(name: str, duration_minutes: int = 30, price_reais: float = 0.0, description: str = "", active: bool = True, api_token: str = None, base_url: str = None) -> dict:
    """
    Realiza a requisição HTTP POST para a API do AgendaAI para cadastrar um novo serviço.
    """
    token = api_token or DEFAULT_API_TOKEN
    if not token:
        return {
            "success": False,
            "error": "Token de autenticação não fornecido.",
            "message": "Você precisa fornecer o 'api_token' no argumento ou definir a variável de ambiente AGENDA_AI_API_TOKEN no seu assistente MCP."
        }

    url = f"{base_url or DEFAULT_BASE_URL}".rstrip("/") + "/api/v1/services"

    payload = {
        "name": name,
        "duration_minutes": duration_minutes,
        "price_reais": price_reais,
        "description": description,
        "active": active
    }

    data = json.dumps(payload).encode("utf-8")
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": f"Bearer {token}"
    }

    req = urllib.request.Request(url, data=data, headers=headers, method="POST")

    try:
        with urllib.request.urlopen(req, timeout=15) as response:
            res_body = json.loads(response.read().decode("utf-8"))
            return {
                "success": True,
                "data": res_body
            }
    except urllib.error.HTTPError as e:
        try:
            error_body = json.loads(e.read().decode("utf-8"))
        except Exception:
            error_body = {"error": str(e)}

        return {
            "success": False,
            "status_code": e.code,
            "error_body": error_body,
            "message": f"Erro HTTP {e.code}: {error_body.get('message', error_body.get('error', 'Falha na requisição'))}"
        }
    except Exception as e:
        return {
            "success": False,
            "message": f"Erro de conexão com o AgendaAI: {str(e)}"
        }

# Definição das ferramentas (MCP Tools)
TOOLS = [
    {
        "name": "create_service",
        "description": "Cadastra um novo serviço no sistema de agendamento online AgendaAI. O serviço ficará imediatamente disponível para os clientes agendarem horários na página pública da empresa.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "name": {
                    "type": "string",
                    "description": "Nome do serviço a ser cadastrado (ex: 'Corte Degradê Premium', 'Barboterapia com Toalha Quente', 'Consulta Terapia')."
                },
                "duration_minutes": {
                    "type": "integer",
                    "description": "Duração do atendimento em minutos (ex: 15, 30, 45, 60, 90). Padrão: 30 minutos.",
                    "default": 30
                },
                "price_reais": {
                    "type": "number",
                    "description": "Valor do serviço em Reais (R$) (ex: 45.00, 80.50). Pode ser 0 para serviços gratuitos.",
                    "default": 0.0
                },
                "description": {
                    "type": "string",
                    "description": "Descrição dos procedimentos inclusos para os clientes lerem na página de agendamento.",
                    "default": ""
                },
                "active": {
                    "type": "boolean",
                    "description": "Indica se o serviço já deve entrar ativo para receber agendamentos online. Padrão: true.",
                    "default": True
                },
                "api_token": {
                    "type": "string",
                    "description": "Token de API do usuário no AgendaAI (opcional se a variável AGENDA_AI_API_TOKEN já estiver configurada no ambiente)."
                }
            },
            "required": ["name"]
        }
    }
]

def handle_tool_call(tool_name: str, arguments: dict) -> dict:
    if tool_name != "create_service":
        return {
            "content": [
                {
                    "type": "text",
                    "text": f"Ferramenta desconhecida: '{tool_name}'. Ferramentas disponíveis: ['create_service']."
                }
            ],
            "isError": True
        }

    name = arguments.get("name")
    duration = int(arguments.get("duration_minutes", 30))
    price = float(arguments.get("price_reais", 0.0))
    description = arguments.get("description", "")
    active = bool(arguments.get("active", True))
    api_token = arguments.get("api_token")

    result = create_service_api(
        name=name,
        duration_minutes=duration,
        price_reais=price,
        description=description,
        active=active,
        api_token=api_token
    )

    if result["success"]:
        res_data = result["data"]
        service_info = res_data.get("service", {})
        public_url = res_data.get("public_booking_url", "")

        formatted_msg = (
            f"✅ **Serviço Criado com Sucesso no AgendaAI!**\n\n"
            f"- **Nome:** {service_info.get('name')}\n"
            f"- **Preço:** {service_info.get('price_formatted')}\n"
            f"- **Duração:** {service_info.get('duration_minutes')} minutos\n"
            f"- **Status:** {'🟢 Ativo para agendamentos online' if service_info.get('active') else '⚪ Inativo'}\n"
            f"- **Descrição:** {service_info.get('description') or 'Sem descrição'}\n"
            f"- **ID no Sistema:** `{service_info.get('id')}`\n\n"
            f"🔗 **Link Direto de Agendamento do Serviço:**\n{public_url}"
        )

        return {
            "content": [
                {
                    "type": "text",
                    "text": formatted_msg
                }
            ]
        }
    else:
        error_msg = f"❌ **Erro ao cadastrar serviço no AgendaAI:**\n{result.get('message')}"
        if "error_body" in result and "errors" in result["error_body"]:
            for err in result["error_body"]["errors"]:
                error_msg += f"\n- {err}"

        return {
            "content": [
                {
                    "type": "text",
                    "text": error_msg
                }
            ],
            "isError": True
        }

def run_stdio_server():
    """
    Executa o protocolo MCP sobre canais padrão stdin/stdout (JSON-RPC 2.0).
    Compatível com Claude Desktop, Antigravity IDE, Cursor e Windsurf.
    """
    sys.stderr.write("🚀 Servidor MCP AgendaAI iniciado em modo stdio (JSON-RPC 2.0)\n")
    sys.stderr.flush()

    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break

            line = line.strip()
            if not line:
                continue

            message = json.loads(line)
            method = message.get("method")
            msg_id = message.get("id")
            params = message.get("params", {})

            if method == "initialize":
                response = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": {
                        "protocolVersion": "2024-11-05",
                        "serverInfo": {
                            "name": "agenda-ai-mcp",
                            "version": "1.0.0"
                        },
                        "capabilities": {
                            "tools": {}
                        }
                    }
                }
                sys.stdout.write(json.dumps(response) + "\n")
                sys.stdout.flush()

            elif method == "notifications/initialized":
                # Confirmação do handshake MCP
                pass

            elif method == "ping":
                response = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": {}
                }
                sys.stdout.write(json.dumps(response) + "\n")
                sys.stdout.flush()

            elif method == "tools/list":
                response = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": {
                        "tools": TOOLS
                    }
                }
                sys.stdout.write(json.dumps(response) + "\n")
                sys.stdout.flush()

            elif method == "tools/call":
                tool_name = params.get("name")
                arguments = params.get("arguments", {})
                tool_result = handle_tool_call(tool_name, arguments)

                response = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": tool_result
                }
                sys.stdout.write(json.dumps(response) + "\n")
                sys.stdout.flush()

            else:
                if msg_id is not None:
                    response = {
                        "jsonrpc": "2.0",
                        "id": msg_id,
                        "error": {
                            "code": -32601,
                            "message": f"Método não encontrado: '{method}'"
                        }
                    }
                    sys.stdout.write(json.dumps(response) + "\n")
                    sys.stdout.flush()

        except Exception as e:
            sys.stderr.write(f"Erro no loop MCP: {str(e)}\n")
            sys.stderr.flush()

if __name__ == "__main__":
    run_stdio_server()
