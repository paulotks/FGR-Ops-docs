---
description: Escaneia documentos em busca de segredos, credenciais ou PII antes de edições
---

# /secret-scanner — Workflow de Detecção de Segredos

Equivalente ao hook `PreToolUse` (`doc-secret-scanner.sh`) do Claude Code.
Executar **antes de editar** documentos que possam conter dados sensíveis de exemplo.

## Passos

// turbo
1. Executar o scanner automatizado:
   ```bash
   bash .agent/workflows/scripts/doc-secret-scanner.sh
   ```
2. Analisar a saída:
   - **exit 2 (BLOCKED):** NÃO prosseguir com a edição. Substituir dados reais por sintéticos
   - **WARNING (e-mail pessoal):** confirmar que é dado sintético antes de continuar
   - **OK (exit 0):** prosseguir com a edição normalmente
3. Registrar no `MEMORY/inbox.md` se algum arquivo foi bloqueado por conter PII/segredos

## Padrões Detectados

- API Keys (OpenAI `sk-...`, AWS `AKIA...`, GitHub `ghp_...`, Stripe `pk_live_...`)
- JWTs reais (`eyJ...header.payload.signature`)
- Connection strings com credenciais (SQL Server, MongoDB, PostgreSQL)
- CPFs reais (formato `NNN.NNN.NNN-NN`)
- E-mails pessoais (gmail, hotmail, yahoo, outlook) — **warning apenas**
- Caminhos de rede internos (`\\server\share`)
