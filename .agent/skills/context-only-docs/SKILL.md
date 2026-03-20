---
name: context-only-docs
description: "Instrução de contexto fundamental: Utilize esta skill para lembrar que o repositório 'FGR-Ops-Requisitos' é usado EXCLUSIVAMENTE para documentação (PRD, SPEC) e arquitetura. NENHUM CÓDIGO FONTE DEVE SER IMPLEMENTADO AQUI."
---

# Contexto: Repositório Apenas de Documentação

## O que você precisa saber

**Aviso Crítico:** Este repositório (`FGR-Ops-Requisitos`) é dedicado **restritamente e exclusivamente** à especificação e documentação do sistema FGR-Ops. 
Nós **NÃO** estamos desenvolvendo o sistema aqui. Não espere encontrar e não tente modificar/criar arquivos de código fonte (como `*.ts`, `*.prisma`, `*.tsx`, controllers, use cases, componentes React) dentro deste repositório.

## Como atuar com fluxos Openspec (opsx-propose e opsx-apply)

1. **Geração de Tasks (`tasks.md`)**:
   - As tarefas geradas durante uma proposta de mudança (`/opsx-propose`) podem até listar o checklist de implementação técnica para orientar os desenvolvedores no repositório de código futuro.
   - **Contudo**, você deve **sempre incluir tarefas explícitas para atualizar os documentos formais** do repositório (ex: `PRD-FGR-OPS.md` e `FGR-OPS-SPEC.md`).

2. **Execução de Tasks (`/opsx-apply`)**:
   - Ao executar a implementação das tasks neste repositório, você deve **APENAS** processar e completar as tarefas relacionadas à alteração e atualização dos arquivos Markdown de documentação (`PRD`, `SPEC`, `design.md`, etc.).
   - Se houver tarefas de implementação de código no `tasks.md`, você **DEVE** marcá-las como concluídas ou ignorá-las verbalmente, assumindo que serão executadas por humanos (ou por você em outro momento) no repositório de código real. Não tente executar bash scripts para gerar código aqui.

3. **Outras Skills no Repositório**:
   - Outras skills de implementação tática de código (`controller`, `prisma`, `use-case`, etc.) que existam nesta base de conhecimento servem apenas como **referência de documentação de arquitetura**. Não as use para tentar codificar dentro deste repositório.

**Resumo da diretriz:** Pense e aja como um **Analista de Requisitos / Arquiteto de Software** dentro desta pasta. Seu objetivo de entrega é sempre documentação em Markdown.
