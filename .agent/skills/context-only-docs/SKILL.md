---
name: context-only-docs
description: "Instrução de contexto fundamental: Utilize esta skill para lembrar que o repositório 'FGR-Ops-Requisitos' é usado EXCLUSIVAMENTE para documentação (PRD, SPEC) e arquitetura. NENHUM CÓDIGO FONTE DE PRODUTO DEVE SER IMPLEMENTADO AQUI."
---

# Contexto: Repositório Apenas de Documentação

## O que você precisa saber

**Aviso crítico:** Este repositório (`FGR-Ops-Requisitos`) é dedicado **restrita e exclusivamente** à especificação e documentação do sistema FGR-Ops.

Não se desenvolve aqui a aplicação de produto. Não espere nem crie ficheiros de código de produto (por exemplo `*.ts`, `*.prisma`, `*.tsx`, controllers, casos de uso, componentes de UI do cliente web) neste repositório.

## Propostas de mudança em `docs/changes/`

As mudanças de documentação usam pastas versionadas **`docs/changes/<nome-kebab>/`** com `proposal.md`, `design.md` e `tasks.md` (ver [docs/changes/README.md](../../../docs/changes/README.md)).

- **`proposal.md`** — O quê e porquê: resumo; REQ novos, alterados ou removidos; riscos e ambiguidades.
- **`design.md`** — Como: ficheiros alvo em `docs/PRD/*.md` e `docs/SPEC/*.md`, ligações cruzadas planeadas.
- **`tasks.md`** — Checklist `- [ ]` / `- [x]` com **apenas** tarefas de documentação (sem implementação de código).

Ao editar, a matriz global em **`docs/traceability.md`** é entrega **obrigatória** quando PRD/SPEC da mudança estão estáveis. Ao concluir, seguir o skill **docs-audit-consistency** (`.cursor/skills/docs-audit-consistency/SKILL.md`) e correr `python .cursor/skills/docs-audit-consistency/scripts/check_consistency.py`.

## Skills no repositório

Skills táticas de código (`controller`, `prisma`, `use-case`, etc.) servem apenas como **referência arquitetural** para redigir SPEC/PRD — não para implementar código *neste* repo.

**Resumo:** Atue como **analista de requisitos / arquiteto de software** em Markdown. O encadeamento formal é **PRD ↔ SPEC ↔ `docs/traceability.md`**, com validação pelo skill e script acima.
