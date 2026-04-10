---
description: Valida rastreabilidade bidirecional após edições em docs/PRD/ ou docs/SPEC/
---

# /traceability-check — Workflow de Validação de Rastreabilidade

Equivalente ao hook `PostToolUse` (`traceability-validator.sh`) do Claude Code.
Executar **após qualquer edição** em arquivos de `docs/PRD/` ou `docs/SPEC/`.

## Passos

// turbo
1. Executar o validador automatizado:
   ```bash
   bash .agent/workflows/scripts/traceability-validator.sh
   ```
2. Analisar a saída:
   - **ERRORS > 0:** corrigir inconsistências antes de continuar (REQ-IDs órfãos, `Rastreio PRD:` ausente, links quebrados)
   - **WARNINGS > 0:** documentar em `MEMORY/inbox.md` se intencional
   - **OK:** prosseguir normalmente
3. Se `docs/traceability.md` não foi atualizado junto com PRD/SPEC, atualizá-lo agora
