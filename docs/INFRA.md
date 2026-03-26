# Infraestrutura e Setup Local — FGR-Ops

Guia de configuração do ambiente de desenvolvimento do monorepo Turborepo.

**Referências SPEC:** [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) (ADRs D1-D7), [audit/decisions-log.md](audit/decisions-log.md) (DEC-004 — parâmetros de sessão)

---

## 1. Pré-requisitos

| Ferramenta | Versão mínima | Notas |
|-----------|---------------|-------|
| Node.js | 20 LTS | Compatível com Angular 20 e NestJS 10+ |
| pnpm | 9.x | Gestor de pacotes do monorepo |
| Turborepo | última estável | `pnpm add -g turbo` |
| SQL Server | 2019+ ou Azure SQL | Banco principal (D2) |
| Redis | 7.x | Blacklist de JWT e rate limiting (D3) |
| Git | 2.x | — |

> **Angular 20:** validar o patch mais recente da série `20.x` antes de fixar `package.json` (conforme DEC-007 / D7).

---

## 2. Estrutura do monorepo

```
fgr-ops/
├── apps/
│   ├── api/          # Backend NestJS 10+ (REST)
│   └── web/          # Frontend Angular 20 (PWA, mobile-first)
├── packages/
│   ├── types/        # DTOs e tipos partilhados (Zod/Valibot)
│   ├── config/       # Configurações partilhadas (ESLint, TS, etc.)
│   └── utils/        # Utilitários comuns
├── turbo.json
├── pnpm-workspace.yaml
└── .env              # (não versionado — ver .env.example abaixo)
```

---

## 3. Variáveis de ambiente (`.env.example`)

Copiar para `.env` na raiz e preencher os valores para o ambiente local.

```dotenv
# ── Base de dados (D2 — SQL Server com Prisma ORM) ──────────────────────────
DATABASE_URL="sqlserver://localhost:1433;database=fgrops_dev;user=sa;password=SUA_SENHA;trustServerCertificate=true"

# ── Redis (D3 — blacklist JWT e rate limiting) ───────────────────────────────
REDIS_URL="redis://localhost:6379"

# ── JWT (D3) ─────────────────────────────────────────────────────────────────
JWT_SECRET="trocar-por-segredo-forte-em-producao"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"
JWT_REFRESH_FIELD_EXPIRES_IN="12h"   # Sessão reduzida para perfis de campo (DEC-004)

# ── Bcrypt (D6 — hash de palavra-passe e PIN) ────────────────────────────────
BCRYPT_COST_FACTOR=10

# ── Rate limiting (D3 / REQ-NFR-006) ─────────────────────────────────────────
RATE_LIMIT_AUTH_MAX=5           # req/min para /auth/login e /auth/pin
RATE_LIMIT_AUTH_WINDOW_MS=60000
RATE_LIMIT_AUTH_BLOCK_MS=900000 # 15 min de bloqueio
RATE_LIMIT_DEMANDA_MAX=20       # req/min para POST /demandas e /demandas/bulk
RATE_LIMIT_DEMANDA_WINDOW_MS=60000

# ── PIN lockout progressivo (DEC-004 / D6) ───────────────────────────────────
PIN_LOCKOUT_THRESHOLD_1=3        # falhas → 1 min
PIN_LOCKOUT_THRESHOLD_2=5        # falhas → 5 min
PIN_LOCKOUT_THRESHOLD_3=10       # falhas → 15 min

# ── Sessão idle (DEC-004) ─────────────────────────────────────────────────────
SESSION_IDLE_TIMEOUT_FIELD_MS=1800000  # 30 min para dispositivos de campo

# ── Timezone operacional (REQ-MET-002 — quinzenas) ──────────────────────────
TZ="America/Sao_Paulo"

# ── API ───────────────────────────────────────────────────────────────────────
API_PORT=3000
API_BASE_URL="http://localhost:3000/api/v1"
NODE_ENV="development"

# ── Frontend Angular ──────────────────────────────────────────────────────────
VITE_API_BASE_URL="http://localhost:3000/api/v1"  # ou variável Angular-specific
```

---

## 4. Bootstrap do ambiente local

```bash
# 1. Clonar o repositório
git clone <url-repo> fgr-ops
cd fgr-ops

# 2. Copiar variáveis de ambiente
cp .env.example .env
# Editar .env com as credenciais locais

# 3. Instalar dependências (todos os workspaces)
pnpm install

# 4. Gerar cliente Prisma e executar migrações
pnpm --filter api exec prisma generate
pnpm --filter api exec prisma migrate dev --name init

# 5. (Opcional) Popular dados de seed
pnpm --filter api exec prisma db seed

# 6. Iniciar todos os apps em modo dev (Turborepo)
turbo dev
# ou individualmente:
# turbo dev --filter=api
# turbo dev --filter=web
```

> `turbo dev` inicia `apps/api` (`:3000`) e `apps/web` em paralelo com hot-reload.

---

## 5. Executar testes

```bash
# Todos os workspaces
turbo test

# Só backend (testes de integração e unitários)
pnpm --filter api test

# Cobertura
pnpm --filter api test:cov

# E2E (requer apps em execução ou ambiente de CI)
pnpm --filter api test:e2e
```

Cenários de teste mapeados em [tests/plano-testes.md](tests/plano-testes.md).

---

## 6. Build de produção

```bash
turbo build
# Artefactos:
#   apps/api/dist/
#   apps/web/dist/
```

---

## 7. Referências

- [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) — ADRs D1 (Turborepo), D2 (SQL Server/Prisma), D3 (JWT/Redis), D6 (política de autenticação), D7 (Angular 20)
- [audit/decisions-log.md](audit/decisions-log.md) — DEC-004 (parâmetros de sessão por perfil), DEC-007 (Angular 20 baseline)
- [SPEC/08-api-contratos.md](SPEC/08-api-contratos.md) — Rate limiting por endpoint
- [tests/plano-testes.md](tests/plano-testes.md) — Plano de testes de integração e E2E
