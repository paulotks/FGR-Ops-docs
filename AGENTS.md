# AGENTS.md — FGR Ops Requisitos (Antigravity)

> **Instruções completas do projeto estão em [`CLAUDE.md`](./CLAUDE.md).**
> Leia e siga integralmente o `CLAUDE.md` antes de qualquer ação. Ele é a fonte única de verdade para regras, restrições, routing table, quality gates e persona deste projeto.

---

## Instruções Específicas do Antigravity

### Skills Disponíveis

As seguintes skills estão disponíveis em `.agent/skills/`. Consulte-as quando relevante:

| Skill | Quando Usar |
|-------|-------------|
| `context-only-docs` | Sempre — lembre que este repositório é exclusivamente para documentação |
| `doc-audit` | Ao auditar consistência PRD ↔ SPEC ↔ traceability.md |
| `spec-authoring` | Ao redigir ou atualizar seções SPEC |

### Workflows Disponíveis (Slash Commands)

Os hooks automáticos do Claude Code foram convertidos em workflows invocáveis:

| Workflow | Equivalente Claude Hook | Quando Usar |
|----------|------------------------|-------------|
| `/audit` | `doc-audit` skill + `traceability-validator.sh` | Antes de marcar qualquer mudança como estável |
| `/traceability-check` | PostToolUse hook (`traceability-validator.sh`) | Após editar qualquer arquivo em `docs/PRD/` ou `docs/SPEC/` |
| `/secret-scanner` | PreToolUse hook (`doc-secret-scanner.sh`) | Antes de editar documentos que possam conter dados sensíveis |
| `/session-end` | Stop hook (`session-end.sh`) | Ao encerrar uma sessão de trabalho significativa |

### Regras Extras para Antigravity

- **Após qualquer edição em `docs/PRD/` ou `docs/SPEC/`:** execute `/traceability-check` manualmente (substitui o hook automático do Claude)
- **Antes de editar documentos com dados de exemplo:** execute `/secret-scanner` (substitui o pre-hook do Claude)
- **Ao concluir trabalho significativo:** execute `/session-end` para atualizar `MEMORY/` (substitui o stop hook do Claude)
- **Ao iniciar qualquer sessão:** leia `MEMORY/wake-up.md` para retomar contexto

---

*Gerado em: 2026-04-10 — manter sincronizado com `CLAUDE.md`*
