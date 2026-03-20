# Visão e arquitetura

Documento migrado a partir de `FGR-OPS-SPEC.md` (secções 1–2). Paridade com o PRD: [PRD — visão e escopo](../PRD/00-visao-escopo.md).

## 1. Visão Geral do Sistema {#visao-geral}

### Propósito, escopo e contexto de negócio {#proposito-escopo-contexto}

**Rastreio PRD:** REQ-CTX-001, REQ-CTX-002, REQ-CTX-003, REQ-OBJ-001, REQ-OBJ-003, REQ-SCO-002

O **FGR-OPS** é a plataforma de gestão operacional desenvolvida para a FGR Incorporações. A empresa opera múltiplas obras simultaneamente (atualmente 4-5) e sofre com sistemas isolados por obra, nomenclaturas inconsistentes e falta de consolidação gerencial. O propósito do sistema é unificar a operação em uma plataforma centralizada e *multi-tenant*.
O foco inicial (MVP) é restrito ao módulo **Machinery Link**, responsável por digitalizar a solicitação, despacho, execução e monitoramento de maquinários pesados nas obras.

### Princípios arquiteturais adotados {#principios-arquiteturais}

**Rastreio PRD:** REQ-OBJ-002, REQ-OBJ-004, REQ-OBJ-005, REQ-SCO-001, REQ-SCO-004, REQ-SCO-005

- **Estratégia Mobile-First**: PWA responsivo no MVP para operadores em campo utilizarem smartphones, preparando terreno para React Native na Fase 2.
- **Ecossistema unificado**: Monorepo gerenciado via Turborepo compartilhando tipos (TypeScript) entre Frontend e Backend.
- **Isolamento e Escalabilidade**: Separação clara entre o core de regras de negócio lógicas (DDD puro) e frameworks/adapters técnicos.
- **Multi-tenancy lógico**: Segregação de dados por obra no mesmo banco de dados (SQL Server), filtrado automaticamente via middleware.
- **Segurança por design**: Autenticação JWT com access token de curta expiração e refresh token rotativo. Controle de acesso granular baseado em perfis (RBAC) cobrindo transições de estado, endpoints e verbos HTTP. Rate limiting nos endpoints de autenticação e criação de demanda. Bypass de multi-tenancy para perfis cross-tenant (SuperAdmin, Board) implementado via lógica condicional no middleware, com auditoria dedicada. Política de senha aplicada a todos os perfis com credencial própria.

## 2. Arquitetura da Plataforma {#arquitetura-plataforma}

### Visão Macro {#visao-macro}

**Rastreio PRD:** REQ-OBJ-001, REQ-SCO-001

O sistema é estruturado num Monorepo (Turborepo):
- `apps/web`: Frontend em Next.js 15+ para todos os perfis.
- `apps/api`: Backend em NestJS 10+ fornecendo endpoints REST.
- `packages/[dominio]/core`: Módulos de domínio puros sem dependência de framework.
- `packages/types`, `config`, `utils`: Pacotes compartilhados.

### Decisões Arquiteturais (ADRs) {#decisoes-arquiteturais-adrs}

**Rastreio PRD:** REQ-SCO-001, REQ-OBJ-002

1. **D1: Monorepo com Turborepo**: Facilita o compartilhamento de DTOs e tipagem ponta a ponta.
2. **D2: SQL Server com Prisma ORM**: Aproveita a familiaridade da equipe com SQL Server e forte aderência typesafety do Prisma.
3. **D3: Autenticação JWT com RBAC**: Uso de Guards no NestJS para validar sessões e permissões no contexto de operações, transições e obras.
   - **Access Token**: Expiração de 15 minutos (> Decisão: 15 minutos para reduzir janela de exposição em campo). Curto o suficiente para limitar janela de abuso em caso de furto físico de smartphone.
   - **Refresh Token**: TTL de 7 dias (> Decisão: 7 dias para equilibrar UX e segurança em dispositivos compartilhados). Armazenado em cookie HttpOnly no cliente web; em SecureStorage no PWA mobile. Estratégia de rotação: ROTAÇÃO A CADA USO (> Decisão: Rotação a cada uso para detectar reuso de tokens roubados).
   - **Revogação**: Blacklist por jti em Redis (> Decisão: Blacklist por jti em Redis para invalidação imediata e stateless). Em caso de logout explícito ou detecção de uso suspeito, o token é invalidado antes da expiração natural.
   - **Rate Limiting**: Aplicado nos Guards via interceptor NestJS com limite de 5 requisições por 1 minuto (> Decisão: 5 req/min para auth e 20 req/min para criação de demandas para mitigar abusos) para endpoints de autenticação e criação de demanda.
4. **D4: Multi-tenancy Lógico**: Todo dado específico de negócio possui uma coluna `obraId`. Requisições do frontend injetam o escopo da obra via middleware para isolamento.
5. **D5: Bypass de Multi-tenancy para Perfis Cross-Tenant**: Os perfis SuperAdmin e Board requerem acesso a dados de múltiplas obras sem restrição de obraId. O middleware de injeção de obraId (D4) implementa a seguinte lógica condicional:
   - Se o token JWT decodificado contiver role: SUPER_ADMIN ou role: BOARD, o middleware não injeta obraId no contexto da requisição e repassa o payload original ao controlador.
   - O controlador, ao detectar ausência de obraId no contexto, executa a query sem filtro de tenant (acesso full-scan).
   - Para o perfil Board, o acesso irrestrito é limitado exclusivamente aos verbos HTTP GET. Qualquer verbo de escrita (POST, PUT, PATCH, DELETE) por um token BOARD retorna HTTP 403 antes de atingir o controlador, independentemente do obraId.
   - O acesso cross-tenant de SuperAdmin e Board é registrado em log de auditoria distinto (AuditLogCrossTenant) com userId, role, endpoint, obraIdAlvo (quando inferível do payload) e timestamp.

> Decisão: O modelo de bypass condicional no middleware foi preferido ao modelo de "supertenant" (tenant especial que contém todos os dados) por manter a lógica de isolamento centralizada em um único ponto da infraestrutura, reduzindo risco de vazamento por query mal construída.

### Arquitetura Tática (DDD) {#arquitetura-tatica-ddd}

**Rastreio PRD:** REQ-OBJ-001, REQ-SCO-001, REQ-SCO-002, REQ-SCO-003

Foi adotada de forma estrita a **Arquitetura Tática**:
- **Domínios e Bounded Contexts**: O módulo "Core" lida com identidade (Users, Roles, Obras). O módulo "Machinery Link" lida apenas com o ciclo operacional de equipamentos.
- **Aggregates e Entities**: `Demanda` é o Aggregate Root, compondo entidades filhas como `DemandaAcao` e amparando agrupamentos via `DemandaGrupo`. `Maquinario` e `Operador` são entidades operacionais essenciais. O cadastro de recursos abrange `Maquinario` (com atributos `placa`, `TipoMaquinario`, `Servico` vinculado e `propriedade` FGR/Terceiro) e `Ajudante` (recurso humano vinculado à obra sem credencial própria no sistema). O modelo de dados completo destas entidades está detalhado em [02-modelo-dados.md](02-modelo-dados.md).
- **Value Objects**: Atributos imutáveis e configurações de peso dinâmicos do Score (`W_adj`).
- **Domain Services**: Lógicas de negócio puras isoladas, notadamente o **Algoritmo de Priorização da Fila** (onde o check de Setor Logístico e Score é feito).
- **Repositories**: Interfaces no *Core* determinam o contrato (`IDemandaRepository`), sendo implementadas como *Prisma Adapters* na infraestrutura.
