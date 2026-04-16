# Requisitos não funcionais

Esta seção consolida os requisitos de arquitetura, segurança e plataforma que sustentam o MVP do FGR-OPS para operação multi-tenant, uso em campo e longevidade técnica.

## Plataforma e stack base

### `REQ-NFR-001` Monorepo e arquitetura tática

O produto deve ser implementado num monorepo em `Turborepo`, separando frontends, domínios core puros em `packages/` e adaptadores em `apps/`, sob uma abordagem de arquitetura tática alinhada a Domain-Driven Design.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)

### `REQ-NFR-002` Interface mobile-first em PWA

O acesso operacional de campo deve privilegiar um `Progressive Web App` responsivo construído em `React 19` com build tool `Vite`, design system `Tailwind CSS` + `shadcn/ui` e Service Worker via `vite-plugin-pwa` (Workbox), com usabilidade mobile-first e base para funcionamento resiliente em cenários de conectividade instável (DEC-021). A aplicação é entregue como export estático (SPA) servido diretamente pelo IIS em Windows Server (DEC-022). Packages compartilhados (`packages/types`, `packages/schemas`, `packages/api-client`, `packages/domain`) preparam a reutilização de lógica e tipos para o futuro aplicativo mobile em `React Native` (Expo), cuja implementação fica prevista para fase posterior (DEC-023).

-> SPEC: [../SPEC/00-visao-arquitetura.md#visao-geral](../SPEC/00-visao-arquitetura.md#visao-geral)
-> SPEC: [../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline](../SPEC/06-definicoes-complementares.md#estrategia-pwa-offline)
-> SPEC: [../SPEC/07-design-ui-logica.md](../SPEC/07-design-ui-logica.md)

### `REQ-NFR-003` Backend orientado a domínio com autenticação JWT

O backend deve ser fornecido por um serviço `NestJS`, preservando separação entre use cases de domínio e detalhes de framework, com autenticação baseada em `JWT`.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)

### `REQ-NFR-004` Persistência relacional multi-tenant

O sistema deve utilizar modelo relacional em `SQL Server` com `Prisma`, garantindo isolamento lógico multi-tenant automatizado e rastreabilidade consistente dos recursos operacionais.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)
-> SPEC: [../SPEC/02-modelo-dados.md#relacionamentos-e-regras-de-integridade](../SPEC/02-modelo-dados.md#relacionamentos-e-regras-de-integridade)

## Segurança de autenticação

### `REQ-NFR-005` Política de tokens JWT

O sistema deve aplicar autenticação por `JSON Web Tokens` com sessão curta no access token, renovação controlada por refresh token rotativo e capacidade de invalidação imediata em casos de logout ou uso suspeito.

- `Access Token`: expiração de 15 minutos.
- `Refresh Token`: TTL de 7 dias.
- Rotacao de refresh token a cada uso.
- Invalidação imediata de tokens via blacklist em `Redis`.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)

### `REQ-NFR-006` Rate limiting para autenticação e criação de demandas

O sistema deve impor limites de requisição para mitigar força bruta, abuso e negação de serviço nos endpoints mais sensíveis.

- Limite de 5 requisições por minuto em `/auth/login`.
- Limite de 20 requisições por minuto em `POST /demandas` e `POST /demandas/bulk`.
- Violações devem retornar `HTTP 429` com bloqueio temporário de 15 minutos para IP ou usuário.

-> SPEC: [../SPEC/00-visao-arquitetura.md#arquitetura-plataforma](../SPEC/00-visao-arquitetura.md#arquitetura-plataforma)

### `REQ-NFR-007` Política de autenticação segmentada por perfil

A política de autenticação é segmentada por perfil, equilibrando usabilidade operacional em campo e segurança corporativa nos perfis de retaguarda (DEC-004).

**Perfis de Campo** (`Empreiteiro`, `Operador`):
- Autenticação simplificada via `Usuario + PIN numérico` no app mobile.
- Controles compensatórios obrigatórios: lockout progressivo, resposta não enumerável, trilha auditável e sessão curta.

**Perfis Administrativos / Suporte** (demais perfis com credencial própria):
- Mínimo de 8 caracteres.
- Inclusão obrigatória de letras maiúsculas, minúsculas, números e caracteres especiais.
- Bloqueio de reutilização das últimas 3 palavras-passe.

-> SPEC: [../SPEC/00-visao-arquitetura.md#politica-autenticacao-senha](../SPEC/00-visao-arquitetura.md#politica-autenticacao-senha)
