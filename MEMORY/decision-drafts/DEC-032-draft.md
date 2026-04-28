## DEC-032 — Política de versões do ambiente local — Node 24, pnpm 10, Memurai, SQL Express

- **Estado:** Rascunho _(revisar e aplicar em decisions-log.md)_
- **Data:** 2026-04-27
- **Contexto:** O `INFRA.md` (escrito em 2026-04) especifica Node 20 LTS, pnpm 9.x e Redis 7.x (Linux) como pré-requisitos. Na auditoria do ambiente local de bootstrap (2026-04-27) constatou-se: Node v24.15.0 já instalado, pnpm 10.33.2 já instalado, Memurai 4.2.2 (compatível com Redis API 7.4.7) já instalado e em execução como serviço Windows, SQL Server Express 2019 instalado com instância nomeada `SQLEXPRESS` em execução. O time é pequeno (1 dev no momento) e a produção é Windows Server (DEC-022). Há um trade-off entre "seguir a doc" (downgrade) e "consolidar o que já está estável e em produção-paridade".
- **Opções consideradas:**
  - A) Downgrade para Node 20 LTS e pnpm 9 (seguir INFRA.md à letra)
  - B) Adotar versões já instaladas (Node 24, pnpm 10) e atualizar INFRA.md
  - C) Tornar Node 20 e 24 ambos suportados via .nvmrc + matrix CI
- **Decisão:** Adotar Node 24 LTS, pnpm 10 e Memurai (Redis para Windows) como baseline oficial do FGR-Ops. SQL Server Express 2019 com instância nomeada `SQLEXPRESS` é aceito para desenvolvimento local — `DATABASE_URL` deve usar o formato `sqlserver://localhost\\SQLEXPRESS;database=fgrops_dev;...` ao invés da porta 1433 padrão. Turborepo será instalado via dual-install (global para CLI + devDependency no root para pinning), conforme recomendação atual do projeto Turborepo. Pinagem reforçada via `packageManager: "pnpm@10.x"` e `engines: { "node": ">=24" }` no `package.json` raiz.
- **Justificativa:** 1) Paridade dev/prod: Memurai é o build oficial do Redis para Windows e a produção é Windows Server — usar Memurai em dev elimina a divergência que aparece só no deploy. 2) Node 24 entrou em LTS em 2025-10 e tem suporte completo de NestJS 10+, Vite 5+, React 19 e Prisma. Não há razão técnica para downgrade quando o time é pequeno e o ambiente já está consolidado. 3) pnpm 10 fixa o lockfile em `lockfileVersion: '10.0'`; usar `packageManager` no root garante que Corepack force a versão correta em qualquer máquina. 4) Turbo dual-install é a recomendação oficial atual (verificada em context7/turborepo.dev): o global oferece CLI conveniente, e a devDep faz pinning por repo — o global automaticamente defere para a versão local quando presente. 5) SQL Express com instância nomeada exige connection string específica; documentar isso evita a próxima hora de debug.
- **SPECs/REQ-IDs afetados:** INFRA.md §1, INFRA.md §3, INFRA.md §4

---
> **Como aplicar:** Abra o projeto FGR-Ops-docs e peça à IA para aplicar este rascunho
> em `docs/audit/decisions-log.md` seguindo o formato canônico com rastreio SPEC.
