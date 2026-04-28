## DEC-033 — Pipeline Turborepo — separação test (rápido) vs test:integration (depende de build) e .env por app

- **Estado:** Rascunho _(revisar e aplicar em decisions-log.md)_
- **Data:** 2026-04-28
- **Contexto:** Bootstrap do monorepo Turborepo (Fase 1.1). Três decisões de configuração precisam ser fixadas antes de criar `turbo.json`, `package.json` raiz e os `.env`:

(a) **Localização do `.env`:** `INFRA.md §3` exemplifica um único `.env` na raiz misturando segredos de back e variáveis `VITE_*` do front.
(b) **Cache do `turbo dev`:** Turbo por padrão não cacheia tasks `persistent`, mas o comportamento é implícito.
(c) **Dependência do target `test`:** `dev-todo.md` original sugeria `test → build`. Porém `packages/domain` (regras puras de scoring/SLA/máquina de estados) será o foco do TDD na Fase 1.5 e roda Vitest sobre TS fonte direto — sem precisar de artefato.
- **Opções consideradas:**
  - A) (a1) .env único na raiz | (b1) cache implícito | (c1) test depende de build
  - B) (a2) .env por app | (b2) cache: false explícito | (c2) test independente; integration manual
  - C) (a3) .env por app | (b3) cache: false explícito | (c3) test rápido + test:integration separado — ESCOLHIDO
- **Decisão:** (a) **`.env` por app**: cada app gerencia seu próprio `.env`/`.env.example` (`apps/api/.env`, `apps/web/.env`). Não há `.env` na raiz. Isolamento explícito de segredos do back vs variáveis `VITE_*` do front. (b) **`"cache": false` explícito** em todas as tasks `dev` no `turbo.json`. Documenta a intenção e protege contra alguém marcar `dev` como cacheável por engano. (c) **Dois targets de teste**: `test` (sem dependências, loop TDD rápido contra TS fonte) e `test:integration` (depende de `build` e `^build`, para testes que precisam do dist/Prisma client). `turbo run test` é o default; CI roda ambos.
- **Justificativa:** (a) Limpa fronteira entre backend e frontend; evita que dev confunda `JWT_SECRET` (server-only) com `VITE_API_BASE_URL` (browser-exposto). Plano futuro `apps/mobile` (DEC-023) reutiliza o padrão. (b) Custo zero, ganho de legibilidade — Turbo já tem o comportamento por padrão, só estamos documentando. (c) Velocidade do TDD: ciclo red-green-refactor de `packages/domain` precisa ser sub-segundo. Forçar `test → build` faria cada teste compilar 6+ packages antes. Padrão popular em turbo.build/vercel-examples e nrwl/nx.
- **SPECs/REQ-IDs afetados:** INFRA.md §2, INFRA.md §3, INFRA.md §6

---
> **Como aplicar:** Abra o projeto FGR-Ops-docs e peça à IA para aplicar este rascunho
> em `docs/audit/decisions-log.md` seguindo o formato canônico com rastreio SPEC.
