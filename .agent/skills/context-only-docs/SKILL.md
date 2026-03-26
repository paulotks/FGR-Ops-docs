---
name: context-only-docs
description: "Instrução de contexto fundamental: Utilize esta skill para lembrar que o repositório 'FGR-Ops-Requisitos' é usado EXCLUSIVAMENTE para documentação (PRD, SPEC) e arquitetura. NENHUM CÓDIGO FONTE DE PRODUTO DEVE SER IMPLEMENTADO AQUI."
---

# Contexto: Repositório Apenas de Documentação

## O que você precisa saber

**Aviso crítico:** Este repositório (`FGR-Ops-Requisitos`) é dedicado **restrita e exclusivamente** à especificação e documentação do sistema FGR-Ops.

Não se desenvolve aqui a aplicação de produto. Não espere nem crie ficheiros de código de produto (por exemplo `*.ts`, `*.prisma`, `*.tsx`, controllers, casos de uso, componentes de UI do cliente web) neste repositório.

## Propostas de mudança em `docs/changes/`

O fluxo **OpsX** neste repo usa pastas versionadas **`docs/changes/<nome-kebab>/`** com `proposal.md`, `design.md` e `tasks.md` (ver [docs/changes/README.md](../../../docs/changes/README.md)). **Não** há CLI OpenSpec nem pasta `openspec/`.

1. **`/opsx:propose`**
   - Gera ou atualiza o pacote da mudança sob `docs/changes/<nome>/`.
   - O `tasks.md` deste repositório deve conter **apenas** tarefas de documentação (PRD, SPEC, matriz, auditoria). Não listar implementação de código de produto como trabalho a executar *aqui*.

2. **`/opsx:apply`**
   - Executar **somente** o que atualiza documentação: ficheiros sob `docs/` (PRD, SPEC, **`docs/traceability.md`**, `docs/audit/` quando aplicável) e o checklist em `docs/changes/<nome>/tasks.md`.
   - A matriz global em **`docs/traceability.md`** é entrega **obrigatória** quando PRD/SPEC da mudança estão estáveis — novas linhas ou células no **mesmo formato** da tabela existente.
   - Ao final da sessão ou ao concluir as tarefas: seguir o skill **docs-audit-consistency** (`.cursor/skills/docs-audit-consistency/SKILL.md`) e correr `python .cursor/skills/docs-audit-consistency/scripts/check_consistency.py`.

3. **Outras skills no repositório**
   - Skills táticas de código (`controller`, `prisma`, `use-case`, etc.), se existirem na base de conhecimento, servem apenas como **referência arquitetural** para redigir SPEC/PRD — não para implementar código *neste* repo.

**Resumo:** Atue como **analista de requisitos / arquiteto de software** em Markdown. O encadeamento formal é **PRD ↔ SPEC ↔ `docs/traceability.md`**, com validação pelo skill e script acima.
