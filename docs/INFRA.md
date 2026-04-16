# Infraestrutura e Setup Local — FGR-Ops

Guia de configuração do ambiente de desenvolvimento do monorepo Turborepo e do deploy em produção sobre Windows Server + IIS + PM2.

**Referências SPEC:** [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) (ADRs D1–D7), [audit/decisions-log.md](audit/decisions-log.md) (DEC-021 — stack Vite+React; DEC-022 — deploy Windows/IIS/PM2; DEC-023 — preparação mobile RN; DEC-004 — parâmetros de sessão).

---

## 1. Pré-requisitos

### Desenvolvimento local

| Ferramenta | Versão mínima | Notas |
|-----------|---------------|-------|
| Node.js | 20 LTS | Compatível com Vite 5+, React 19 e NestJS 10+ |
| pnpm | 9.x | Gestor de pacotes do monorepo |
| Turborepo | última estável | `pnpm add -g turbo` |
| SQL Server | 2019+ ou Azure SQL | Banco principal (D2) |
| Redis | 7.x | Blacklist de JWT e rate limiting (D3) |
| Git | 2.x | — |

### Produção (Windows Server — fornecido pela FGR)

| Componente | Versão / requisito | Função |
|---|---|---|
| Windows Server | 2019+ | Sistema operacional de produção |
| IIS | 10+ | Reverse proxy + servidor de estáticos + TLS termination |
| IIS URL Rewrite Module | última | Reescrita de URLs para proxy |
| IIS Application Request Routing (ARR) | última | Reverse proxy HTTP/HTTPS/WebSocket |
| IIS WebSocket Protocol | habilitado | Upgrade para `/ws` (NestJS Gateway) |
| Node.js | 20 LTS (Windows MSI) | Runtime do NestJS em produção |
| PM2 | última estável | Process manager |
| `pm2-windows-service` | última | Registrar PM2 como serviço Windows |
| SQL Server | 2019+ | Banco (pode ser remoto) |
| Redis | 7.x (Windows build, WSL ou remoto) | Cache / blacklist JWT |

---

## 2. Estrutura do monorepo

```
fgr-ops/
├── apps/
│   ├── api/          # Backend NestJS 10+ (REST + WebSocket Gateway)
│   ├── web/          # Frontend Vite + React 19 (PWA, mobile-first)
│   └── mobile/       # (previsto — DEC-023) Expo + React Native
├── packages/
│   ├── types/        # DTOs e enums (fonte única de contratos)
│   ├── schemas/      # Validações zod (reutilizáveis web + mobile)
│   ├── api-client/   # Chamadas HTTP tipadas (agnóstico a ambiente)
│   ├── domain/       # Regras puras de domínio (scoring, SLA, transições)
│   ├── config/       # ESLint, TS, Tailwind preset
│   └── utils/        # Utilitários comuns
├── turbo.json
├── pnpm-workspace.yaml
└── .env              # (não versionado — ver .env.example abaixo)
```

> **DEC-023:** `apps/mobile` não é criado no MVP; apenas a estrutura de packages é preparada e consumida por `apps/web`. Quando o app mobile for desenvolvido, bastará criar `apps/mobile` com Expo e consumir os mesmos 4 packages (`types`, `schemas`, `api-client`, `domain`).

---

## 3. Variáveis de ambiente (`.env.example`)

Copiar para `.env` na raiz e preencher os valores para o ambiente local. O Vite expõe para o cliente **apenas** variáveis prefixadas com `VITE_` (segurança — o restante fica no servidor NestJS).

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

# ── API (NestJS — variáveis servidor-side apenas) ────────────────────────────
API_PORT=3000
API_HOST="127.0.0.1"              # loopback em produção (atrás do IIS)
NODE_ENV="development"

# ── Frontend Vite + React (apenas VITE_* são expostas ao browser) ────────────
VITE_API_BASE_URL="http://localhost:3000/api/v1"
VITE_WS_URL="ws://localhost:3000/ws"
VITE_APP_NAME="FGR-OPS"
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
# turbo dev --filter=api    (NestJS em :3000)
# turbo dev --filter=web    (Vite em :5173)
```

> `turbo dev` inicia `apps/api` (`:3000`) e `apps/web` (`:5173`) em paralelo com hot-reload.

---

## 5. Adicionar componentes shadcn/ui

Os componentes shadcn/ui são **copiados para o repositório** (não são dependência runtime). Para adicionar um novo:

```bash
# A partir de apps/web (configurado com components.json do shadcn)
pnpm --filter web exec shadcn@latest add button
pnpm --filter web exec shadcn@latest add dialog input label select
```

Os arquivos são gerados em `apps/web/src/components/ui/` e passam a ser propriedade do repositório — edite livremente.

---

## 6. Executar testes

```bash
# Todos os workspaces
turbo test

# Backend (Jest ou Vitest — unitários e integração)
pnpm --filter api test
pnpm --filter api test:cov

# Frontend (Vitest + Testing Library)
pnpm --filter web test

# E2E (Playwright — requer apps em execução ou ambiente de CI)
pnpm --filter web test:e2e
```

Cenários de teste mapeados em [tests/plano-testes.md](tests/plano-testes.md).

---

## 7. Build de produção

```bash
turbo build
# Artefactos:
#   apps/api/dist/     → Node bundle do NestJS (executado via PM2)
#   apps/web/dist/     → export estático (HTML/JS/CSS) — servido pelo IIS
```

---

## 8. Deploy em Windows Server + IIS + PM2 (DEC-022)

### 8.1 Visão da arquitetura

```
Internet
   │ HTTPS (443, certificado Windows)
   ▼
  IIS
   ├── Site "fgr-ops-web"
   │   ├── Raiz: C:/www/fgr-ops/web/    (saída de vite build)
   │   ├── web.config com rewrite rules (ARR + SPA fallback)
   │   └── URL Rewrite:
   │       /api/*  → http://127.0.0.1:3000  (NestJS via ARR)
   │       /ws     → http://127.0.0.1:3000  (WebSocket upgrade)
   │       /*      → estáticos; fallback para index.html (SPA)
   │
   └── Loopback
            │
            ▼
  PM2 (serviço Windows via pm2-windows-service)
   └── Processo "fgr-ops-api"
       ├── apps/api/dist/main.js (NestJS, porta 3000)
       ├── Auto-restart em crash
       ├── Logs rotativos em C:/logs/fgr-ops-api/
       └── Cluster mode opcional conforme carga
                 │
                 ▼
          SQL Server + Redis
```

**Porta 3000 nunca é exposta à internet** — só o IIS expõe 443.

### 8.2 Preparar o IIS (uma única vez por servidor)

1. Instalar **URL Rewrite Module** e **Application Request Routing (ARR)** — ambos via Web Platform Installer ou download direto da Microsoft.
2. Habilitar o roteamento de proxy em ARR:
   - IIS Manager → selecionar o servidor → *Application Request Routing Cache* → *Server Proxy Settings* → marcar **"Enable proxy"** → Apply.
3. Habilitar o recurso **WebSocket Protocol** em Server Manager → *Add Roles and Features* → *Web Server (IIS)* → *Application Development* → *WebSocket Protocol*.
4. Criar o site `fgr-ops-web` apontando para `C:/www/fgr-ops/web/` com binding HTTPS (443) e certificado Windows.

### 8.3 `web.config` do site (exemplo)

Criar em `C:/www/fgr-ops/web/web.config`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="Proxy API" stopProcessing="true">
          <match url="^api/(.*)$" />
          <action type="Rewrite" url="http://127.0.0.1:3000/api/{R:1}" />
        </rule>
        <rule name="Proxy WebSocket" stopProcessing="true">
          <match url="^ws$" />
          <action type="Rewrite" url="http://127.0.0.1:3000/ws" />
        </rule>
        <rule name="SPA Fallback" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>
    <staticContent>
      <clientCache cacheControlMode="UseMaxAge" cacheControlMaxAge="365.00:00:00" />
      <remove fileExtension=".webmanifest" />
      <mimeMap fileExtension=".webmanifest" mimeType="application/manifest+json" />
    </staticContent>
    <httpProtocol>
      <customHeaders>
        <add name="X-Content-Type-Options" value="nosniff" />
        <add name="X-Frame-Options" value="DENY" />
        <add name="Referrer-Policy" value="strict-origin-when-cross-origin" />
      </customHeaders>
    </httpProtocol>
  </system.webServer>
</configuration>
```

> O Service Worker (`sw.js` gerado pelo `vite-plugin-pwa`) e o `manifest.webmanifest` devem ser servidos **sem cache agressivo** — ajustar regras específicas de cache no IIS para esses dois arquivos se necessário.

### 8.4 Configurar PM2 como serviço Windows

```powershell
# Instalar PM2 globalmente
npm install -g pm2

# Instalar wrapper de serviço Windows
npm install -g pm2-windows-service

# Registrar PM2 como serviço
pm2-service-install -n "PM2-FGR-OPS"

# Iniciar o serviço Windows
net start PM2-FGR-OPS
```

### 8.5 `ecosystem.config.js` do NestJS

Criar em `C:/apps/fgr-ops-api/ecosystem.config.js`:

```javascript
module.exports = {
  apps: [
    {
      name: 'fgr-ops-api',
      script: './dist/main.js',
      cwd: 'C:/apps/fgr-ops-api',
      instances: 1,                  // aumentar para cluster mode conforme carga
      exec_mode: 'fork',             // ou 'cluster' em produção sob carga
      env: {
        NODE_ENV: 'production',
        API_PORT: 3000,
        API_HOST: '127.0.0.1',
        // demais variáveis lidas de C:/apps/fgr-ops-api/.env
      },
      error_file: 'C:/logs/fgr-ops-api/error.log',
      out_file: 'C:/logs/fgr-ops-api/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      max_memory_restart: '512M',
      autorestart: true,
      watch: false,
    },
  ],
};
```

### 8.6 Procedimento de deploy

**Backend (NestJS):**

```powershell
# Pipeline CI/CD copia:
#   apps/api/dist/           → C:/apps/fgr-ops-api/dist/
#   apps/api/node_modules/   → C:/apps/fgr-ops-api/node_modules/  (ou pnpm deploy)
#   apps/api/prisma/         → C:/apps/fgr-ops-api/prisma/
#   apps/api/ecosystem.config.js → C:/apps/fgr-ops-api/

# Aplicar migrações
cd C:/apps/fgr-ops-api
npx prisma migrate deploy

# Reload zero-downtime
pm2 reload fgr-ops-api

# Persistir lista de processos entre reboots
pm2 save
```

**Frontend (Vite + React):**

```powershell
# Pipeline CI/CD executa:
#   pnpm --filter web build
#
# Copiar apps/web/dist/* → C:/www/fgr-ops/web/
# Nenhum restart necessário — IIS serve os novos arquivos na próxima requisição.
```

### 8.7 Observações de produção

- **TLS:** certificado Windows administrado pelo IIS; renovação automática via *Windows Certificate Store* ou ferramenta corporativa da FGR.
- **Portas:** 443 (HTTPS) exposta; 80 (HTTP) deve redirecionar para 443 via regra de rewrite; 3000 (NestJS) em loopback apenas (`127.0.0.1`), nunca exposta externamente.
- **Logs do IIS:** `%SystemDrive%/inetpub/logs/LogFiles/` — rotação padrão Windows.
- **Logs do NestJS:** `C:/logs/fgr-ops-api/` com rotação gerenciada pelo PM2 (módulo `pm2-logrotate`).
- **Variáveis sensíveis:** `JWT_SECRET`, `DATABASE_URL`, `REDIS_URL` em `C:/apps/fgr-ops-api/.env` com ACL restrita ao usuário do serviço PM2.
- **Backup:** SQL Server backup gerenciado pela FGR; Redis pode ser volátil (apenas blacklist/rate-limit).

---

## 9. Referências

- [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) — ADRs D1 (Turborepo), D2 (SQL Server/Prisma), D3 (JWT/Redis), D6 (política de autenticação), D7 revista (React + Vite + Tailwind + shadcn/ui)
- [audit/decisions-log.md](audit/decisions-log.md) — DEC-004 (parâmetros de sessão por perfil), DEC-021 (stack frontend Vite+React, supersede DEC-007/DEC-008), DEC-022 (infra Windows/IIS/PM2), DEC-023 (preparação mobile RN)
- [SPEC/07-design-ui-logica.md](SPEC/07-design-ui-logica.md) — padrões React, Tailwind + shadcn/ui, react-hook-form + zod
- [SPEC/08-api-contratos.md](SPEC/08-api-contratos.md) — contratos REST, rate limiting por endpoint
- [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) — estratégia PWA offline (Service Worker, IndexedDB), WebSocket
- [tests/plano-testes.md](tests/plano-testes.md) — plano de testes de integração e E2E
