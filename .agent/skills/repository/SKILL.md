---
name: repository
description: "Criar, revisar ou orientar contratos e implementações de repositório no padrão FGR-Ops. Usar quando o pedido envolver arquivos `*.repository.ts`, operações de persistência de entidades (create/update/findById/findAll/delete), adaptação de infraestrutura do Prisma para contratos de core, tratamento de erros com `Result` e mapeamentos `toDomain/fromDomain`."
---

# Repository

## Overview

Aplicar o padrão de repositório para escrita e leitura de entidades de domínio com contratos no `core` e implementação desacoplada em infraestrutura.

## Guidelines

- Definir contrato em `packages/[modulo]/core/src/**/provider/*.repository.ts`.
- Reutilizar bases de shared quando aplicável (`CrudRepository`, `CreateRepository`, etc.).
- Implementar em adapter de infraestrutura (ex.: `apps/api/src/**/*.prisma.ts`) retornando `Result`.
- Mapear domínio explicitamente:
  - `toDomain`: payload do banco -> entidade.
  - `fromDomain`: entidade -> payload de persistência.
- Tratar falhas com `Result.fail(...)` e não vazar exceção no fluxo normal.
- Manter separação CQRS:
  - Repository para comando/escrita e leitura orientada a entidade.
  - Query para leitura/projeção DTO via CQRS.

## Workflow

1. Confirmar agregados/entidades cobertos pelo repositório.
2. Definir/ajustar contrato no core com métodos mínimos necessários.
3. Implementar adapter de infraestrutura respeitando o contrato e usando Prisma.
4. Implementar mapeamento `toDomain`/`fromDomain` interagindo com Types gerados pelo Prisma.
5. Garantir consistência transacional para operações compostas com Prisma Transactions.
6. Criar/ajustar mocks in-memory para testes de use case no core.

## References

Consultar `references/repository-pattern.md` para contratos, exemplos de implementação e checklist.
