# Visão e arquitetura

Documento migrado a partir de `FGR-OPS-SPEC.md` (seções 1–2). Paridade com o PRD: [PRD — visão e escopo](../PRD/00-visao-escopo.md).

## 1. Visão Geral do Sistema {#visao-geral}

### Propósito, escopo e contexto de negócio {#proposito-escopo-contexto}

**Rastreio PRD:** REQ-CTX-001, REQ-CTX-002, REQ-CTX-003, REQ-OBJ-001, REQ-OBJ-003, REQ-SCO-002

O **FGR-OPS** é a plataforma de gestão operacional desenvolvida para a FGR Incorporações. A empresa opera múltiplas obras simultaneamente (atualmente 4-5) e sofre com sistemas isolados por obra, nomenclaturas inconsistentes e falta de consolidação gerencial. O propósito do sistema é unificar a operação em uma plataforma centralizada e *multi-tenant*.
O foco inicial (MVP) é restrito ao módulo **Machinery Link**, responsável por digitalizar a solicitação, despacho, execução e monitoramento de maquinários pesados nas obras.

### Princípios arquiteturais adotados {#principios-arquiteturais}

**Rastreio PRD:** REQ-OBJ-002, REQ-OBJ-004, REQ-OBJ-005, REQ-SCO-001, REQ-SCO-004, REQ-SCO-005

- **Estratégia Mobile-First**: PWA responsivo no MVP para operadores em campo utilizarem smartphones; na Fase 2, evoluir para experiência móvel nativa ou shell dedicado (decisão de canal a confirmar no roadmap de produto), sem prescrever framework de UI concreto neste documento.
- **Ecossistema unificado**: Monorepo gerenciado via Turborepo compartilhando tipos (TypeScript) entre Frontend e Backend.
- **Isolamento e Escalabilidade**: Separação clara entre o core de regras de negócio lógicas (DDD puro) e frameworks/adapters técnicos.
- **Multi-tenancy lógico**: Segregação de dados por obra no mesmo banco de dados (SQL Server), filtrado automaticamente via middleware.
- **Segurança por design**: Autenticação JWT com access token de curta expiração e refresh token rotativo. Controle de acesso granular baseado em perfis (RBAC) cobrindo transições de estado, endpoints e verbos HTTP. Rate limiting nos endpoints de autenticação e criação de demanda. Bypass de multi-tenancy para perfis cross-tenant (SuperAdmin, Board) implementado via lógica condicional no middleware, com auditoria dedicada. Política de autenticação segmentada por perfil (Campo vs Administrativo) conforme D6, cobrindo palavra-passe forte, autenticação simplificada por PIN e controles compensatórios de segurança.

## 2. Arquitetura da Plataforma {#arquitetura-plataforma}

### Visão Macro {#visao-macro}

**Rastreio PRD:** REQ-OBJ-001, REQ-SCO-001, REQ-NFR-002

O sistema é estruturado num Monorepo (Turborepo):
- `apps/web`: Frontend em **Angular** (major estável **20**; baseline canónica alinhada a `REQ-NFR-002`) para todos os perfis. Validar o patch mais recente da série **20.x** no momento da implementação antes de fixar dependências de build.
- `apps/api`: Backend em NestJS 10+ fornecendo endpoints REST.
- `packages/[dominio]/core`: Módulos de domínio puros sem dependência de framework.
- `packages/types`, `config`, `utils`: Pacotes compartilhados.

### Decisões Arquiteturais (ADRs) {#decisoes-arquiteturais-adrs}

**Rastreio PRD:** REQ-SCO-001, REQ-OBJ-002, REQ-NFR-002

1. **D1: Monorepo com Turborepo**: Facilita o compartilhamento de DTOs e tipagem ponta a ponta.
2. **D2: SQL Server com Prisma ORM**: Aproveita a familiaridade da equipe com SQL Server e forte aderência typesafety do Prisma.
3. **D3: Autenticação JWT com RBAC**: Uso de Guards no NestJS para validar sessões e permissões no contexto de operações, transições e obras.
   - **Access Token**: Expiração de 15 minutos (> Decisão: 15 minutos para reduzir janela de exposição em campo). Curto o suficiente para limitar janela de abuso em caso de furto físico de smartphone.
   - **Refresh Token**: TTL de 7 dias (> Decisão: 7 dias para equilibrar UX e segurança em dispositivos compartilhados). Armazenado em cookie HttpOnly no cliente web; em SecureStorage no PWA mobile. Estratégia de rotação: ROTAÇÃO A CADA USO (> Decisão: Rotação a cada uso para detectar reuso de tokens roubados).
   - **Revogação**: Blacklist por jti em Redis (> Decisão: Blacklist por jti em Redis para invalidação imediata e stateless). Em caso de logout explícito ou detecção de uso suspeito, o token é invalidado antes da expiração natural.
   - **Rate Limiting**: Aplicado nos Guards via interceptor NestJS para mitigar força bruta, abuso e negação de serviço nos endpoints mais sensíveis. Contrato normativo conforme `REQ-NFR-006`:
     - `/auth/login` e `/auth/pin`: limite de **5 requisições por minuto** por IP ou identificador de usuário.
     - `POST /demandas` e `POST /demandas/bulk`: limite de **20 requisições por minuto** por usuário autenticado.
     - Violações retornam **`HTTP 429 Too Many Requests`** com header `Retry-After` e aplicam **bloqueio temporário de 15 minutos** ao IP ou usuário infrator.
     - (> Decisão: thresholds calibrados para o perfil de uso em obra; bloqueio de 15 min reduz risco de brute-force sem impactar operação legítima.)
4. **D4: Multi-tenancy Lógico**: Todo dado específico de negócio possui uma coluna `obraId`. Requisições do frontend injetam o escopo da obra via middleware para isolamento.
5. **D5: Bypass de Multi-tenancy para Perfis Cross-Tenant**: Os perfis SuperAdmin e Board requerem acesso a dados de múltiplas obras sem restrição de obraId. O middleware de injeção de obraId (D4) implementa a seguinte lógica condicional:
   - Se o token JWT decodificado contiver role: SUPER_ADMIN ou role: BOARD, o middleware não injeta obraId no contexto da requisição e repassa o payload original ao controlador.
   - O controlador, ao detectar ausência de obraId no contexto, executa a query sem filtro de tenant (acesso full-scan).
   - Para o perfil Board, o acesso irrestrito é limitado exclusivamente aos verbos HTTP GET. Qualquer verbo de escrita (POST, PUT, PATCH, DELETE) por um token BOARD retorna HTTP 403 antes de atingir o controlador, independentemente do obraId.
   - O acesso cross-tenant de SuperAdmin e Board é registrado em log de auditoria distinto (AuditLogCrossTenant) com userId, role, endpoint, obraIdAlvo (quando inferível do payload) e timestamp.

> Decisão: O modelo de bypass condicional no middleware foi preferido ao modelo de "supertenant" (tenant especial que contém todos os dados) por manter a lógica de isolamento centralizada em um único ponto da infraestrutura, reduzindo risco de vazamento por query mal construída.

6. **D7: Frontend web em Angular (`apps/web`)**: Cliente PWA no monorepo com **Angular** major **20** (linha estável; validar patch **20.x** ao fixar dependências). Cobre retaguarda e campo no mesmo código base web; alinhado a `REQ-NFR-002`.

### D6: Política de Autenticação e Palavra-passe - segmentação por perfil {#politica-autenticacao-senha}

   **Rastreio PRD:** REQ-NFR-007 | **Decisão de produto:** DEC-004

   A política de autenticação é segmentada em dois grupos de perfil, equilibrando usabilidade operacional em campo e segurança corporativa nos perfis de retaguarda.

   #### 6.1 Perfis de Campo (`Empreiteiro`, `Operador`) — Autenticação simplificada

   Acesso via **Usuário + PIN numérico** no app mobile (PWA).

   | Parâmetro | Valor |
   |---|---|
   | Formato do PIN | Numérico, mínimo 6 dígitos |
   | Lockout progressivo | 3 falhas → bloqueio 1 min; 5 falhas → 5 min; 10 falhas → 15 min |
   | Resposta de erro | Mensagem genérica não enumerável (não revela se o usuário existe) |
   | Trilha auditável | Registro obrigatório de cada tentativa: `userId`, `endpoint`, `resultado` (sucesso/falha), `IP`, `userAgent`, `timestamp` |
   | Sessão | Access token de 15 min (conforme D3); refresh token com TTL reduzido de 12 h para dispositivos de campo |
   | Política de troca | PIN deve ser trocado a cada 90 dias; sistema força redefinição no próximo login após expiração |
   | Armazenamento do PIN | Hash com bcrypt (cost factor ≥ 10); PIN em texto claro nunca é persistido |

   > Decisão: A autenticação simplificada por PIN foi adotada para perfis de campo por reconhecer que operadores em obra acessam o sistema em condições adversas (luvas, tela suja, pressa operacional). Controles compensatórios (lockout progressivo, sessão curta, trilha auditável) mitigam o risco de credencial fraca.

   #### 6.2 Perfis Administrativos / Suporte (`UsuarioInternoFGR`, `AdminOperacional`, `SuperAdmin`, `Board`) — Palavra-passe forte

   Acesso via **Usuário + Palavra-passe** conforme critérios mínimos de `REQ-NFR-007`.

   | Parâmetro | Valor |
   |---|---|
   | Comprimento mínimo | 8 caracteres |
   | Classes obrigatórias | Letras maiúsculas, minúsculas, números e caracteres especiais (mínimo 1 de cada) |
   | Histórico de reutilização | Bloqueio das últimas 3 palavras-passe (comparação via hash) |
   | Lockout | 5 falhas consecutivas → bloqueio temporário de 15 min por conta |
   | Resposta de erro | Mensagem genérica não enumerável |
   | Trilha auditável | Mesmo contrato da seção 6.1 |
   | Sessão | Access token de 15 min; refresh token de 7 dias (conforme D3) |
   | Política de troca | Palavra-passe deve ser redefinida a cada 180 dias; troca obrigatória no primeiro login |
   | Armazenamento | Hash com bcrypt (cost factor ≥ 10); palavra-passe em texto claro nunca é persistida |

   > Decisão: A política de palavra-passe forte para perfis administrativos segue os critérios mínimos definidos no PRD (`REQ-NFR-007`) e adiciona lockout, trilha auditável e rotação periódica como camadas complementares de segurança corporativa.

   #### 6.3 Regras transversais de autenticação

   - **Rate limiting por endpoint/perfil**: O rate limiting de D3 (5 req/min para `/auth/login`) aplica-se a ambos os grupos. Para endpoints de PIN (`/auth/pin`), aplica-se o mesmo limite de 5 req/min por IP ou identificador de dispositivo.
   - **Gestão de sessão**: Logout explícito invalida access e refresh tokens via blacklist por `jti` em Redis (conforme D3). Em dispositivos de campo, a sessão expira automaticamente após 30 min de inatividade (idle timeout), forçando re-autenticação por PIN.
   - **Auditoria de autenticação**: Todos os eventos de autenticação (login, logout, falha, lockout, troca de credencial) são registrados em tabela dedicada `AuthAuditLog` com campos: `id`, `userId`, `perfil`, `evento`, `resultado`, `ip`, `userAgent`, `timestamp`.

### Arquitetura Tática (DDD) {#arquitetura-tatica-ddd}

**Rastreio PRD:** REQ-OBJ-001, REQ-SCO-001, REQ-SCO-002, REQ-SCO-003

Foi adotada de forma estrita a **Arquitetura Tática**:
- **Domínios e Bounded Contexts**: O módulo "Core" lida com identidade (Users, Roles, Obras). O módulo "Machinery Link" lida apenas com o ciclo operacional de equipamentos.
- **Aggregates e Entities**: `Demanda` é o Aggregate Root, compondo entidades filhas como `DemandaAcao` e amparando agrupamentos via `DemandaGrupo`. `Maquinario` e `Operador` são entidades operacionais essenciais. O cadastro de recursos abrange `Maquinario` (com atributos `placa`, `TipoMaquinario`, `Servico` vinculado e `propriedade` FGR/Terceiro) e `Ajudante` (recurso humano vinculado à obra sem credencial própria no sistema). O modelo de dados completo destas entidades está detalhado em [02-modelo-dados.md](02-modelo-dados.md).
- **Value Objects**: Atributos imutáveis e configurações de peso dinâmicos do Score (`W_adj`).
- **Domain Services**: Lógicas de negócio puras isoladas, notadamente o **Algoritmo de Priorização da Fila** (onde o check de Setor Logístico e Score é feito). O algoritmo opera sobre localização declarada via **Checkpoint Manual** — mecanismo de inferência de posição sem dependência de GPS/IoT — que atribui a posição corrente da máquina com base na última conclusão de demanda. Na primeira demanda do turno, a localização parte de estado neutro (`Fora da Obra`). Este modelo assegura `REQ-OBJ-004` e `REQ-SCO-004` sem hardware de rastreamento, mantendo a eficiência da frota fundada em jurisdição logística e proximidade espacial declarada.
- **Repositories**: Interfaces no *Core* determinam o contrato (`IDemandaRepository`), sendo implementadas como *Prisma Adapters* na infraestrutura.
