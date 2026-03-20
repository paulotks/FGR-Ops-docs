# Requisitos nao funcionais

Esta secao consolida os requisitos de arquitetura, seguranca e plataforma que sustentam o MVP do FGR-OPS para operacao multi-tenant, uso em campo e longevidade tecnica.

## Plataforma e stack base

### `REQ-NFR-001` Monorepo e arquitetura tatica

O produto deve ser implementado num monorepo em `Turborepo`, separando frontends, dominios core puros em `packages/` e adaptadores em `apps/`, sob uma abordagem de arquitetura tatica alinhada a Domain-Driven Design.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)

### `REQ-NFR-002` Interface mobile-first em PWA

O acesso operacional de campo deve privilegiar um `Progressive Web App` responsivo em `Next.js`, com usabilidade mobile-first e base para funcionamento resiliente em cenarios de conectividade instavel.

-> SPEC: [../SPEC/00-visao-arquitetura.md#visao-geral](../SPEC/00-visao-arquitetura.md#visao-geral)
-> SPEC: [../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline](../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline)

### `REQ-NFR-003` Backend orientado a dominio com autenticacao JWT

O backend deve ser fornecido por um servico `NestJS`, preservando separacao entre use cases de dominio e detalhes de framework, com autenticacao baseada em `JWT`.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)

### `REQ-NFR-004` Persistencia relacional multi-tenant

O sistema deve utilizar modelo relacional em `SQL Server` com `Prisma`, garantindo isolamento logico multi-tenant automatizado e rastreabilidade consistente dos recursos operacionais.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)
-> SPEC: [../SPEC/02-modelo-dados.md#relacionamentos-e-regras-de-integridade](../SPEC/02-modelo-dados.md#relacionamentos-e-regras-de-integridade)

## Seguranca de autenticacao

### `REQ-NFR-005` Politica de tokens JWT

O sistema deve aplicar autenticacao por `JSON Web Tokens` com sessao curta no access token, renovacao controlada por refresh token rotativo e capacidade de invalidacao imediata em casos de logout ou uso suspeito.

- `Access Token`: expiracao de 15 minutos.
- `Refresh Token`: TTL de 7 dias.
- Rotacao de refresh token a cada uso.
- Invalidacao imediata de tokens via blacklist em `Redis`.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)

### `REQ-NFR-006` Rate limiting para autenticacao e criacao de demandas

O sistema deve impor limites de requisicao para mitigar forca bruta, abuso e negacao de servico nos endpoints mais sensiveis.

- Limite de 5 requisicoes por minuto em `/auth/login`.
- Limite de 20 requisicoes por minuto em `POST /demandas` e `POST /demandas/bulk`.
- Violacoes devem retornar `HTTP 429` com bloqueio temporario de 15 minutos para IP ou utilizador.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)

### `REQ-NFR-007` Politica de palavra-passe

Todos os perfis com credencial propria devem obedecer a uma politica minima de palavra-passe, com composicao forte e prevencao de reutilizacao recente.

- Minimo de 8 caracteres.
- Inclusao obrigatoria de letras maiusculas, minusculas, numeros e caracteres especiais.
- Bloqueio de reutilizacao das ultimas 3 palavras-passe.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)
