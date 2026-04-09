# Propostas de mudança de requisitos (`docs/changes/`)

Este diretório agrupa **propostas só em Markdown** para alterar PRD, SPEC e rastreio. Cada mudança ativa vive numa subpasta com nome **kebab-case** (ex.: `onboarding-notificacoes`).

## Estrutura por mudança

| Caminho | Função |
|---------|--------|
| `docs/changes/<nome>/proposal.md` | O quê e porquê: resumo; REQ novos, alterados ou removidos (IDs canónicos: FUNC, NFR, ACE, RBAC, JOR, etc.); riscos e ambiguidades. |
| `docs/changes/<nome>/design.md` | Como: ficheiros alvo em `docs/PRD/*.md` e `docs/SPEC/*.md`, ligações cruzadas planeadas; referência a `docs/audit/decisions-log.md` se houver decisão (DEC). |
| `docs/changes/<nome>/tasks.md` | Checklist `- [ ]` / `- [x]` com **apenas** tarefas de documentação (sem implementação de código). |

O `<nome>` deve ser único entre pastas ativas (não arquivadas). Antes de criar IDs novos, alinhar com [PRD/_index.md](../PRD/_index.md), [SPEC/_index.md](../SPEC/_index.md) e com `REQ-` em `docs/PRD/` e `docs/SPEC/` para não duplicar prefixos ou números.

## Ciclo de trabalho

1. **Propor**: criar `docs/changes/<nome>/` com `proposal.md`, `design.md` e `tasks.md` preenchidos conforme o inventário de requisitos.
2. **Aplicar**: percorrer `tasks.md`; editar só sob `docs/` (PRD, SPEC, [traceability.md](../traceability.md), auditoria quando aplicável); no fim da sessão ou ao concluir tarefas, seguir o skill **docs-audit-consistency** e executar `python .cursor/skills/docs-audit-consistency/scripts/check_consistency.py`.
3. **Arquivar**: com `tasks.md` concluído (ou aviso explícito) e verificação de consistência sem erros bloqueantes (ou aviso), mover a pasta inteira para **`docs/changes/archive/YYYY-MM-DD-<nome>/`** (data do arquivo no prefixo).

Pastas em `docs/changes/archive/` são histórico; não contam como mudanças "ativas" ao listar propostas em curso.

## Matriz global

Após PRD/SPEC estáveis para a mudança, as tarefas devem incluir atualizar [traceability.md](../traceability.md) (nova linha ou ajuste de células) no **mesmo formato** da tabela existente, incluindo padrões tipo `REQ-XXX-*` quando for um grupo.

## Relação com o resto da documentação

- Convenções gerais de PRD/SPEC e matriz: [README.md](../README.md).
- Requisitos de contexto só em documentação: skill **context-only-docs** em `.agent/skills/`.
- Auditoria e checagens cruzadas: skill **docs-audit-consistency** em `.cursor/skills/docs-audit-consistency/`.
