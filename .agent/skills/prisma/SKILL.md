---
name: prisma
description: "Criar, revisar ou orientar a camada Prisma do backend no padrão FGR-Ops. Usar quando o pedido envolver schema Prisma (`schema.prisma`, `models/*.prisma`), migrações SQL no SQL Server, geração de client, seeds e adapters `*.prisma.ts`."
---

# Prisma

## Overview

Aplicar o padrão Prisma do FGR-Ops com foco em banco SQL Server. Envolve modelagem limpa, gestão de migrations, seeds e adapters Repository/Query.

## Guidelines

- Agrupar modelos lógicos no `schema.prisma` da pasta base ou usar plugins de multi-schema se aplicável no monorepo.
- Mapear convenções do FGR-Ops: nomes de tabelas, relacionamentos (Cuidado com N:N no SQL Server) usando `@map` e `@@map`.
- Tipar as implementações `*.prisma.ts` extraindo os types gerados do PrismaClient.
- O Isolamento multi-tenant (Obra) deve ser garantido por middleware, mas refletido fortemente nas queries do Prisma Client (`where: { obraId }`).
- Implementar `toDomain` que extrai as Props a partir do Json gerado do Prisma.
- Tratar Unique Constraints com `Result.fail`.

## Workflow

1. Avaliar modelo lógico da feature.
2. Escrever model no `schema.prisma`.
3. Validar se relation fields funcionam bem pro SQL Server (tipos `Int`, `String` nativos, `DateTime`).
4. `npx prisma migrate dev` para testar localmente.
5. Criar/atualizar o Adapter do Repositório ou da Query que implementa a Interface.
6. Tipar rigorosamente as Props vindas do `fromDomain()`.

## References

Consultar `references/prisma-pattern.md` para checklist de pitfalls com Prisma e SQL Server.
