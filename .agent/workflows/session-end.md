---
description: Atualiza MEMORY/ com o estado da sessão ao encerrar trabalho significativo
---

# /session-end — Workflow de Encerramento de Sessão

Equivalente ao hook `Stop` (`session-end.sh`) do Claude Code.
Executar **ao concluir trabalho significativo** em uma sessão.

## Passos

// turbo
1. Executar o script de encerramento:
   ```bash
   bash .agent/workflows/scripts/session-end.sh
   ```
2. Verificar a saída:
   - `wake-up.md` atualizado? → OK
   - `journal.md` atualizado? → OK
   - Alerta de `traceability.md` pendente? → Executar `/audit` antes de encerrar
3. Se o script detectou TBD/TODO em `docs/`, revisar `MEMORY/inbox.md` e priorizar para próxima sessão
4. Anotar manualmente em `MEMORY/journal.md` quaisquer decisões táticas importantes tomadas na sessão que os scripts não capturam automaticamente
