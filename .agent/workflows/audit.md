---
description: Auditoria completa de consistência documental — verifica PRD ↔ SPEC ↔ traceability.md
---

# /audit — Workflow de Auditoria Documental

Equivalente ao hook `PostToolUse` + skill `doc-audit` do Claude Code.

## Passos

1. Ler a skill `doc-audit` (`.agent/skills/doc-audit/SKILL.md`) e executar o protocolo completo
2. Executar o validador de rastreabilidade automatizado:
   ```bash
   bash .agent/workflows/scripts/traceability-validator.sh
   ```
3. Consolidar findings em ordem de severidade: CRITICAL → WARNING → INFO
4. Se houver findings CRITICAL: corrigi-los antes de marcar qualquer mudança como estável
5. Registrar resultado em `MEMORY/inbox.md` se houver warnings/criticals pendentes
