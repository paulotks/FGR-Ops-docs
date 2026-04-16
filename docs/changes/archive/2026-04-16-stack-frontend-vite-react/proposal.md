# Proposta — Stack de frontend web: Vite + React, deploy Windows/IIS/PM2, preparação mobile RN

## Resumo

Substituir a stack de frontend web canónica do FGR-OPS (Angular 20 PWA, definida em DEC-007 e DEC-008) por **Vite + React 19** com **Tailwind CSS + shadcn/ui**, formalizar a arquitetura de deploy em **Windows Server + IIS + PM2** (infraestrutura fornecida pela FGR, não negociável) e preparar o monorepo para o futuro aplicativo móvel em **React Native (Expo)** através de packages compartilhados.

## Motivação

1. **Alinhamento com roadmap móvel:** O desenvolvimento futuro do app mobile em React Native exige que o frontend web compartilhe o mesmo mental model e bibliotecas (React, TanStack Query, zod, react-hook-form). Angular e React Native não compartilham componentes, estado, nem conceitos fundamentais — manter ambos obrigaria dev solo a sustentar duas stacks de frontend totalmente distintas.

2. **Perfil do time:** O sistema será desenvolvido por um desenvolvedor solo com experiência básica em React e sem experiência em React Native. A curva de aprendizado do Angular (RxJS, Zone.js, módulos, Reactive Forms) é mais íngreme do que a do React; migrar para React reduz risco de entrega.

3. **Adequação à infraestrutura de hospedagem:** A FGR disponibiliza apenas Windows Server com IIS e PM2 como infraestrutura operacional. O padrão Next.js (considerado como alternativa) assume ambiente serverless/Edge (Vercel) para várias de suas features diferenciais (ISR, middleware Edge, otimização de imagens, Server Actions). Em Windows/IIS, essas features funcionam parcialmente ou não funcionam. Vite + React com export estático é servido nativamente pelo IIS sem Node em path de resposta, reduzindo superfície operacional.

4. **PWA mobile-first:** `REQ-NFR-002` exige PWA responsiva. `vite-plugin-pwa` (baseado em Workbox) oferece controle fino e maduro de Service Worker, estratégias de cache offline e prompt de instalação — aderente à estratégia PWA offline definida em `SPEC/06`.

5. **Independência de fornecedor:** A trajetória recente do Next.js tem sido otimizada para deploy em Vercel, criando acoplamento não-desejável a um fornecedor específico. Vite é um build tool agnóstico mantido por comunidade independente.

## REQ novos, alterados ou removidos

### Alterados

- **`REQ-NFR-002`** (Interface mobile-first em PWA) — texto atualizado: "Angular na linha major estável 20" → "React 19 com Vite"; remoção das notas de validação de patch 20.x; menção a Tailwind CSS + shadcn/ui como design system; PWA via `vite-plugin-pwa` (Workbox).

### Mantidos (sem alteração)

- **`REQ-NFR-001`** (Monorepo Turborepo) — permanece. Preparação para `apps/mobile` via packages compartilhados é interna ao monorepo e não altera o requisito.
- **`REQ-NFR-003`** (Backend NestJS 10+) — permanece. NestJS é mantido.
- **`REQ-NFR-004`** (SQL Server + Prisma) — permanece.
- **`REQ-NFR-005`, `REQ-NFR-006`, `REQ-NFR-007`** (JWT, rate limiting, política de autenticação) — permanecem.

### Novos

Nenhum REQ novo criado. Mudança é de implementação tecnológica, não de requisito funcional/não-funcional.

## Decisões (DEC)

- **DEC-021** — Stack de frontend web: Vite + React 19 com Tailwind CSS + shadcn/ui (supersede DEC-007 — Angular 20 — e DEC-008 — Zoneless/Signals).
- **DEC-022** — Infraestrutura de deploy: Windows Server + IIS (reverse proxy + arquivos estáticos) + PM2 (process manager do NestJS).
- **DEC-023** — Preparação do monorepo para aplicativo mobile React Native (Expo) via packages compartilhados (`packages/types`, `packages/schemas`, `packages/api-client`, `packages/domain`).

## ADRs impactados

- **D7** (Frontend web em Angular) — conteúdo revisto para Vite + React 19 mantendo o número do ADR. DEC-021 é a decisão normativa.
- **D1** (Monorepo com Turborepo) — conteúdo mantido; nota adicional sobre packages compartilhados para mobile futuro (DEC-023).
- **D2, D3, D4, D5, D6** — inalterados.

## Riscos e ambiguidades

- **Curva de aprendizado do stack React moderno** (TanStack Router, TanStack Query, shadcn/ui copy-paste pattern): mitigado pela documentação oficial robusta e pela experiência prévia do dev com React básico.
- **Expo Router universal descartado:** ponderou-se usar Expo + React Native Web para unificar web e mobile em uma codebase, mas foi descartado por exigir aprender React Native antes de qualquer entrega web e por introduzir SSR/SEO limitados que não são necessários (aplicação é interna, autenticada).
- **Migração futura de telas**: `SPEC/07-design-ui-logica.md` ainda referencia conceitos específicos de Angular 20 (Signals, Reactive Forms). Seção §3 será reescrita para padrões React equivalentes.
- **Integração IIS ↔ NestJS**: requer URL Rewrite e Application Request Routing (ARR) instalados no IIS. `INFRA.md` documentará configuração.

## Referências

- Audit decisions: [`docs/audit/decisions-log.md`](../../audit/decisions-log.md) — DEC-007 (a ser superseded), DEC-008 (a ser superseded), DEC-021 (novo)
- SPEC afetadas: `00-visao-arquitetura.md`, `07-design-ui-logica.md`, `08-api-contratos.md`, `_index.md`
- PRD afetado: `04-requisitos-nao-funcionais.md` (`REQ-NFR-002`)
- Infra afetada: `docs/INFRA.md` (reescrita extensa)
- Matriz: `docs/traceability.md` (linha `REQ-NFR-002`)
- Testes: `docs/tests/plano-testes.md` (linha 149, referência a componente Angular)
