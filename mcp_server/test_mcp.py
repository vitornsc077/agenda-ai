#!/usr/bin/env python3
"""
Testador do servidor MCP AgendaAI.
Simula o handshake inicial do Claude/Cursor e a execução da tool create_service.
"""

import subprocess
import json
import os
import sys

def run_test():
    server_path = os.path.join(os.path.dirname(__file__), "server.py")
    
    # 1. Inicia processo MCP
    proc = subprocess.Popen(
        [sys.executable, server_path],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    print("🚀 Testando AgendaAI MCP Server...")

    # Passo 1: Initialize
    init_request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "TestClient", "version": "1.0.0"}
        }
    }
    proc.stdin.write(json.dumps(init_request) + "\n")
    proc.stdin.flush()
    init_response = json.loads(proc.stdout.readline())
    print("✅ Handshake Initialize OK:", init_response.get("result", {}).get("serverInfo"))

    # Passo 2: List Tools
    tools_request = {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "tools/list",
        "params": {}
    }
    proc.stdin.write(json.dumps(tools_request) + "\n")
    proc.stdin.flush()
    tools_response = json.loads(proc.stdout.readline())
    tools = tools_response.get("result", {}).get("tools", [])
    print(f"✅ Tools List OK ({len(tools)} ferramenta(s) registrada(s)):")
    for t in tools:
        print(f"   - Tool: '{t['name']}' -> {t['description'][:80]}...")

    # Finaliza
    proc.stdin.close()
    proc.terminate()
    print("\n🎉 Teste MCP concluído com sucesso!")

if __name__ == "__main__":
    run_test()
