---
name: query-cqrs
description: Criar, revisar ou orientar queries no padrão CQRS de leitura no FGR-Ops. Usar quando o pedido envolver interfaces `*Query`, arquivos `*.query.ts`, use cases de leitura (`find-*`), projeções/DTOs para consumo da API/front, paginação/filtros/agregações e separação entre leitura (query) e escrita (repository/comando).
---

# Query CQRS

## Overview

Aplicar o padrão de consultas de leitura desacopladas dos comandos, usando Prisma para leitura otimizada retornando DTOs/projeções adequadas à API do FGR-Ops.

## Guidelines

- Usar Query para leitura/projeção performática; usar Repository/entidade para fluxos de comando (escrever/validar invariantes).
- Definir interfaces de query em `core` (`execute(...) => Promise<Result<DTO>>`).
- Implementar a adapter query em `apps/api` (usando Prisma Client fortemente tipado) retornando o DTO.
- Manter use case de leitura fino: apenas orquestra, chama a query abstrata, mapeia falhas e aplica formatação se for do domínio.
- Não carregar instâncias ricas de Aggregate Roots do Prisma apenas para consultar dados listados.
- DTO de query não pode estender classe de entidade; deve usar `select` de campos do Prisma para performance.

## Workflow

1. Identificar se trata-se de caso de leitura (query CQRS) ou comando de transação rica (repository).
2. Definir contrato da query (`FindXxxQuery`) e DTO de saída nas pastas de Core API.
3. Implementar lógica da query no adapter Prisma do app Nest, montando joins e `select`.
4. Usar a query interface no use case de leitura do Core.
5. Validar formato final que a API devolve ao front.

## References

Consultar `references/query-cqrs-pattern.md` para exemplos reais e definições estruturais.
