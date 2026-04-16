# Design — Stack Vite + React, deploy Windows/IIS/PM2, preparação RN

## Visão da nova stack

| Camada | Tecnologia |
|---|---|
| Build tool frontend | **Vite** (última estável, ecossistema rollup/esbuild) |
| Biblioteca UI | **React 19** |
| Roteamento | **TanStack Router** (type-safe, file-based routing opcional) |
| Data fetching / cache | **TanStack Query** |
| Formulários | **react-hook-form** + **zod** |
| Estado cliente | **Zustand** |
| Design system | **Tailwind CSS** + **shadcn/ui** (componentes copiados para o repo, não dependência runtime) |
| PWA | **vite-plugin-pwa** (Workbox) |
| Backend | **NestJS 10+** (inalterado) |
| Monorepo | **Turborepo + pnpm** (inalterado) |
| Banco | **SQL Server + Prisma** (inalterado) |
| Cache/Auth | **Redis + JWT** (inalterado) |
| Deploy web | **IIS** (arquivos estáticos + reverse proxy `/api/*`) |
| Deploy backend | **PM2** (process manager, serviço Windows) |
| Mobile futuro | **Expo + React Native** consumindo packages compartilhados |

## Monorepo alvo

```
fgr-ops/
├── apps/
│   ├── api/          # NestJS 10+ (REST)
│   ├── web/          # Vite + React 19 + Tailwind + shadcn/ui (PWA)
│   └── mobile/       # Expo + React Native (Fase 2 — preparado via packages)
├── packages/
│   ├── types/        # Tipos TS (DTOs do Nest, enums de domínio)
│   ├── schemas/      # Validações zod (reutilizáveis web + mobile)
│   ├── api-client/   # Funções tipadas de chamada HTTP
│   ├── domain/       # Regras puras de domínio (scoring, SLA, transições)
│   ├── config/       # ESLint, TS, tailwind preset
│   └── utils/        # Utilitários comuns
├── turbo.json
└── pnpm-workspace.yaml
```

Os packages `types`, `schemas`, `api-client` e `domain` são a ponte de reuso web → mobile.

## Arquitetura de deploy (Windows Server + IIS + PM2)

```
Internet
   │ HTTPS (443, cert Windows)
   ▼
  IIS
   ├── Site "fgr-ops-web"
   │   ├── Raiz: C:\www\fgr-ops\web\  (saída estática de `pnpm --filter web build`)
   │   └── URL Rewrite:
   │       /api/*   → http://localhost:3000  (ARR reverse proxy)
   │       /ws      → http://localhost:3000  (WebSocket upgrade para NestJS Gateway)
   │       /*       → serve estáticos + fallback SPA para index.html
   │
   └── Headers/compressão/cache controlados pelo IIS
            │
            ▼ loopback
  PM2 (pm2-windows-service)
   └── Processo "fgr-ops-api"
       ├── apps/api/dist/main.js (NestJS)
       ├── Porta 3000 (loopback; não exposta externamente)
       ├── Auto-restart em crash
       ├── Cluster mode opcional
       └── Logs rotativos em C:\logs\fgr-ops-api\
                 │
                 ▼
          SQL Server + Redis
```

**Racional:**
- IIS faz o que faz melhor: TLS, HTTP/2, compressão, servir estáticos, reverse proxy.
- PM2 faz o que faz melhor: gerenciar o processo Node, auto-restart, cluster, logs.
- Sem `iisnode` (abandonado desde 2018).
- Porta 3000 do NestJS é loopback only — nunca exposta diretamente à internet.

## Ficheiros alvo

### PRD

- `docs/PRD/04-requisitos-nao-funcionais.md`
  - `REQ-NFR-002` — substituir menções a Angular 20 por React 19 + Vite; adicionar menção a Tailwind + shadcn/ui; referenciar DEC-021.

### SPEC

- `docs/SPEC/00-visao-arquitetura.md`
  - §2 (Visão Macro) — `apps/web` com nova stack; adicionar referência a packages compartilhados e `apps/mobile` futuro.
  - ADR **D7** — conteúdo revisto (Vite + React + Tailwind + shadcn/ui). Referenciar DEC-021, DEC-022, DEC-023.
  - ADR **D1** — nota adicional sobre packages compartilhados para mobile futuro (DEC-023).
  - §Princípios arquiteturais — ajustar linguagem de Angular-específica para framework-agnóstica.

- `docs/SPEC/07-design-ui-logica.md`
  - Frontmatter `title` — "Angular 20" → "React + Vite + Tailwind + shadcn/ui".
  - Intro — "implementação no Angular 20" → "implementação em React com Vite e Tailwind CSS".
  - §2 (State-to-UI Mapping) — remover "aplicando as decisões do Angular 20" no cabeçalho.
  - §3 (Componentes-Chave & Padrões) — reescrever inteiramente:
    - 1. Componentes Reativos com React Hooks + Zustand (substitui Signals).
    - 2. Formulários com react-hook-form + zod (substitui Reactive Forms + Valibot).
    - 3. Status Indicators com Tailwind variantes + shadcn/ui Badge.
    - 4. `ActionButton` componente React com guard RBAC via hook.
  - Referência DEC-013 (já existente) mantida — conceito de justificativa obrigatória independe de framework.

- `docs/SPEC/_index.md`
  - Linha de `07-design-ui-logica.md` — atualizar resumo.

- `docs/SPEC/08-api-contratos.md`
  - Linha 11 — "frontend Angular 20" → "frontend React 19".

### Audit / decisões

- `docs/audit/decisions-log.md`
  - Adicionar DEC-021 (stack frontend), DEC-022 (infra Windows/IIS/PM2), DEC-023 (preparação mobile RN).
  - Supersedência explícita: DEC-007 e DEC-008 marcadas como *superseded by DEC-021* (mantidas no log por imutabilidade).

### Infra

- `docs/INFRA.md` — reescrita significativa:
  - Tabela de pré-requisitos: remover Angular, adicionar Vite/React assumptions.
  - Estrutura do monorepo: refletir `apps/mobile` e novos packages.
  - `.env.example`: prefixos `VITE_*` corretos; remover variáveis Angular-específicas.
  - Bootstrap: comandos `pnpm` atualizados para Vite; remover `ng` commands.
  - Nova seção: **Deploy em Windows Server + IIS + PM2** (com passo a passo: ARR/URL Rewrite no IIS, `pm2-windows-service`, layout de pastas, configuração `web.config`, ecosystem.config.js).

### Matriz

- `docs/traceability.md`
  - Linha `REQ-NFR-002` — atualizar notas: remover referência Angular 20, adicionar React 19 + Vite + Tailwind/shadcn; referenciar DEC-021, DEC-022, DEC-023.

### Testes

- `docs/tests/plano-testes.md`
  - Linha 149 — "Componente: `OperadorFilaView` (Angular 20)" → "Componente: `OperadorFilaView` (React)".

### CLAUDE.md

- Target stack: Angular 20 → Vite + React 19 + Tailwind + shadcn/ui.
- Tabela de ADRs: D7 revisado.
- Current State — "Última decisão registrada: DEC-023" e "Próxima: **DEC-024**".

## Ligações cruzadas planeadas

- `REQ-NFR-002` (PRD/04) ↔ `SPEC/00` #visao-macro (revisto) ↔ `SPEC/07` (revisto) ↔ DEC-021.
- `INFRA.md` ↔ `SPEC/00` (ADR D7 revisto + referência DEC-022) ↔ DEC-022.
- DEC-023 (mobile prep) ↔ `SPEC/00` (ADR D1 nota) ↔ `SPEC/05` (futuros itens Fase 2 opcionalmente anotar reutilização).

## Não-afetados (verificado por inspeção)

- `docs/UI-DESIGN.md` — puramente visual (cores, tipografia, moodboard), framework-agnóstico.
- `docs/SPEC/06-definicoes-complementares.md` — PWA (Service Worker, IndexedDB, Cache API, WebSocket) é framework-agnóstico; NestJS Gateway permanece.
- `docs/SPEC/05-backlog-mvp-glossario.md` — menciona NestJS/SQL Server/Prisma (todos mantidos).
- `docs/SPEC/04-rbac-permissoes.md` — menciona NestJS Guards (mantido).
- `docs/PRD/*` exceto `04-requisitos-nao-funcionais.md` — nenhum outro PRD referencia tech-stack de frontend.
