# Tasks — Stack Vite + React, deploy IIS/PM2, preparação RN

## Audit / Decisões

- [x] Registrar `DEC-021` (Vite + React como stack frontend; supersede DEC-007, DEC-008) em `docs/audit/decisions-log.md`
- [x] Registrar `DEC-022` (Infra deploy Windows Server + IIS + PM2) em `docs/audit/decisions-log.md`
- [x] Registrar `DEC-023` (Preparação mobile RN via packages compartilhados) em `docs/audit/decisions-log.md`
- [x] Marcar `DEC-007` e `DEC-008` como *Superseded por DEC-021*

## PRD

- [x] Atualizar `REQ-NFR-002` em `docs/PRD/04-requisitos-nao-funcionais.md` — Angular 20 → React 19 + Vite + Tailwind + shadcn/ui; remover notas de patch 20.x; referenciar DEC-021/022/023

## SPEC

- [x] Revisar `docs/SPEC/00-visao-arquitetura.md` §2 Visão Macro — `apps/web` com React+Vite; `apps/mobile` previsto; packages compartilhados
- [x] Revisar ADR **D7** em `docs/SPEC/00-visao-arquitetura.md` — conteúdo Vite+React; referenciar DEC-021, DEC-022, DEC-023
- [x] Adicionar nota a ADR **D1** sobre packages compartilhados mobile (DEC-023)
- [x] Ajustar princípios arquiteturais (§1) — remover específicos Angular
- [x] Reescrever `docs/SPEC/07-design-ui-logica.md` — frontmatter, intro, §2 heading, §3 (Componentes React/Hooks/Zustand/react-hook-form+zod/Tailwind+shadcn + PWA Workbox); DEC-013 callout revisto
- [x] Atualizar `docs/SPEC/_index.md` — resumo da linha 07
- [x] Atualizar `docs/SPEC/08-api-contratos.md` — linha 11 (Angular 20 → React 19)

## Infraestrutura

- [x] Reescrever `docs/INFRA.md`:
  - [x] Tabela de pré-requisitos (dev + produção)
  - [x] Estrutura do monorepo (com `apps/mobile` e novos packages)
  - [x] `.env.example` (prefixos VITE_*)
  - [x] Bootstrap (pnpm + vite + turbo)
  - [x] Seção shadcn/ui CLI
  - [x] Testes (Vitest, Playwright)
  - [x] Build
  - [x] Seção nova: **Deploy Windows Server + IIS + PM2** (ARR, URL Rewrite, web.config, pm2-windows-service, ecosystem.config.js, procedimento de deploy)
  - [x] Referências (DECs atualizados)

## Matriz global

- [x] Atualizar linha `REQ-NFR-002` em `docs/traceability.md` — notas com React 19 + Vite + Tailwind + shadcn/ui; DEC-021, DEC-022, DEC-023

## Testes

- [x] Atualizar linha 149 de `docs/tests/plano-testes.md` — "Angular 20" → "React"

## Meta

- [x] Atualizar `CLAUDE.md` — target stack, ADR D7, próxima DEC (DEC-024), Current State (data + OpsX ativo)

## Encerramento

- [x] Revisão cruzada: todos os REQ-IDs mantêm rastreio; sem links quebrados
- [x] Mover `docs/changes/stack-frontend-vite-react/` para `docs/changes/archive/2026-04-16-stack-frontend-vite-react/`
