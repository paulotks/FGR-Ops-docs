
# Claude Code Elite — Cheat Sheet

> Referência rápida do pipeline neuro-simbólico: regras simbólicas (CLAUDE.md, hooks, skills) + raciocínio neural (Claude).

## Comandos de Terminal

| Comando | O que faz |
|---------|-----------|
| `claude` | Inicia Claude Code no diretório atual |
| `claude --model claude-opus-4-6` | Usa modelo específico |
| `claude --no-tools` | Modo somente texto (sem ferramentas) |
| `claude --print "prompt"` | Resposta direta sem modo interativo |

## Atalhos no Terminal Interativo

| Atalho | Ação |
|--------|------|
| `/exit` | Encerra a sessão |
| `/clear` | Limpa o contexto da conversa |
| `/reset` | Reinicia (relê CLAUDE.md) |
| `/mcp` | Lista servidores MCP ativos |
| `Ctrl+C` | Interrumpe tarefa em andamento |
| `Ctrl+D` | Sai do Claude Code |
| `↑ / ↓` | Navega histórico de prompts |

## Configuração `.claude/settings.json`

```json
{
  "model": "claude-sonnet-4-6",
  "mcpServers": {
    "meu-mcp": {
      "command": "node",
      "args": ["./mcp-server/dist/index.js"]
    }
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/secret-scanner.sh"}]
      }
    ],
    "Stop": [
      {
        "hooks": [{"type": "command", "command": "bash .claude/hooks/session-end.sh"}]
      }
    ]
  }
}
```

## Estrutura CLAUDE.md Rápida

```markdown
# PROJECT: Nome

## STACK
- Backend: Node.js + TypeScript
- DB: PostgreSQL

## ARCHITECTURE RULES
- Regra 1
- Regra 2

## ROUTING TABLE
| Trigger | Action |
|---------|--------|
| Situação | O que fazer |

## QUALITY GATES
□ Verificação 1
□ Verificação 2

## FORBIDDEN
- NEVER fazer X
```

## Memória Persistente — Arquivos Chave

| Arquivo | O que guarda | Atualizar quando |
|---------|-------------|-----------------|
| `wake-up.md` | Estado atual do projeto | Ao final de cada sessão |
| `journal/YYYY-MM-DD.md` | O que foi feito hoje | Diariamente |
| `decisions/` | Decisões arquiteturais | Toda decisão importante |
| `inbox/` | Tasks para próxima sessão | Quando surgir nova task |

## Prompts Essenciais

```
# Início de sessão
"Leia o CLAUDE.md e wake-up.md. Resume o estado do projeto 
e o que precisa ser feito hoje."

# Checkpoint no meio do trabalho  
"Faça um checkpoint: o que já foi feito, o que está em andamento, o que falta."

# Decisão arquitetural
"Documente esta decisão em decisions/YYYY-MM-DD-[slug].md com contexto e alternativas."

# Fim de sessão
"Antes de terminar: atualize wake-up.md com o estado atual
e escreva um journal entry para hoje."

# Quando Claude ignorar regra
"Você violou a regra [X] do CLAUDE.md. Corrija a implementação."

# Para code review
"Revise o código que você escreveu hoje contra as regras do CLAUDE.md. 
Liste qualquer violação encontrada."
```

## Hooks — Exit Codes

| Exit code | Significado |
|-----------|-------------|
| `0` | Hook passa, Claude continua |
| `1` | Erro genérico (não bloqueia) |
| `2` | **Bloqueia** Claude (use para gates críticos) |

## MCP — Usando as Ferramentas

```
# Verificar MCPs disponíveis
/mcp

# Usar ferramenta de um MCP (Claude faz automaticamente se você pedir)
"Use a ferramenta get_schema do MCP database-inspector para mostrar 
a estrutura da tabela users."

# Listar ferramentas disponíveis de um MCP específico
/mcp list database-inspector
```

## Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| Claude não leu o CLAUDE.md | `/reset` ou reabra o Claude Code |
| Hook não está rodando | Verifique permissões: `chmod +x .claude/hooks/*.sh` |
| MCP não aparece em `/mcp` | Verifique se o path no settings.json está correto e `dist/index.js` existe |
| Claude usando `any` em TypeScript | Adicione ao FORBIDDEN do CLAUDE.md + reforce no prompt |
| Resposta cortada | Prompt: "Continue de onde parou" |
| Contexto longo demais | `/clear` e resuma o estado em um novo prompt conciso |
