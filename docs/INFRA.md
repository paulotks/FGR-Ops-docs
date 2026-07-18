# Infraestrutura e Setup Local — FGR-Ops

Guia de configuração do ambiente de desenvolvimento do monorepo Turborepo e do deploy em produção sobre Nginx (proxy reverso + SSL) + Windows Server com IIS (estáticos) + PM2 (NestJS).

**Referências SPEC:** [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) (ADRs D1–D7), [audit/decisions-log.md](audit/decisions-log.md) (DEC-021 — stack Vite+React; DEC-022 — deploy Windows/IIS/PM2; DEC-023 — preparação mobile RN; DEC-004 — parâmetros de sessão).

---

## 1. Pré-requisitos

### Desenvolvimento local

| Ferramenta | Versão | Notas |
|-----------|--------|-------|
| Node.js | **24 LTS** | NestJS 10+, Vite 5+, React 19, Prisma; pinado em `engines.node` (`DEC-032`) |
| pnpm | **10.x** | Gestor de pacotes do monorepo; versão forçada via `packageManager` no root (`DEC-032`) |
| Turborepo | última estável | Dual-install: `pnpm add -g turbo` (CLI global) + `devDependency` no root (pinning) — `DEC-032` |
| SQL Server Express 2019 | instância `SQLEXPRESS` | Dev local; connection string com instância nomeada, ver §3 (`DEC-032`) |
| Memurai | **4.x** (Redis API 7.4.7) | Redis para Windows — blacklist JWT e rate limiting (D3); paridade com Windows Server prod (`DEC-032`) |
| Git | 2.x | — |

### Produção

**Servidor Nginx** (separado — gerencia certificado TLS):

| Componente | Versão / requisito | Função |
|---|---|---|
| Linux (distribuição FGR) | — | Sistema operacional do servidor de borda |
| Nginx | última estável | Reverse proxy + TLS termination; roteia `/api/v1/*` → PM2 e `/` → IIS |
| Certificado TLS | — | Gerenciado neste servidor (Let's Encrypt ou certificado corporativo) |

**Servidor(es) de backend** (Windows Server — fornecido pela FGR):

| Componente | Versão / requisito | Função |
|---|---|---|
| Windows Server | 2019+ | Sistema operacional de produção |
| Node.js | **24 LTS** (Windows MSI) | Runtime do NestJS em produção (`DEC-032`) |
| PM2 | última estável | Process manager do NestJS (porta 3000) |
| `pm2-windows-service` | última | Registrar PM2 como serviço Windows |
| IIS | 10+ | Servidor de arquivos estáticos do Vite build (`apps/web/dist/`) |
| IIS WebSocket Protocol | habilitado | Upgrade para `/ws` se NestJS Gateway for servido pelo IIS |
| SQL Server | 2019+ | Banco (pode ser remoto) |
| Memurai | 4.x (Redis para Windows) | Cache / blacklist JWT — build oficial Redis para Windows Server (`DEC-032`) |

> **Nota:** IIS **não** atua como reverse proxy nesta topologia — esse papel é do Nginx. O módulo ARR e o URL Rewrite do IIS não são necessários.

---

## 2. Estrutura do monorepo

```
fgr-ops/
├── apps/
│   ├── api/          # Backend NestJS 10+ (REST + WebSocket Gateway)
│   │   ├── .env      # (não versionado) segredos backend — ver §3
│   │   └── .env.example
│   ├── web/          # Frontend Vite + React 19 (PWA, mobile-first)
│   │   ├── .env      # (não versionado) variáveis VITE_* — ver §3
│   │   └── .env.example
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
└── package.json      # engines: node>=24; packageManager: pnpm@10.x
```

> **DEC-023:** `apps/mobile` não é criado no MVP; apenas a estrutura de packages é preparada e consumida por `apps/web`. Quando o app mobile for desenvolvido, bastará criar `apps/mobile` com Expo e consumir os mesmos 4 packages (`types`, `schemas`, `api-client`, `domain`).
>
> **DEC-033:** Não há `.env` na raiz. Cada app gerencia seu próprio `.env`/`.env.example` para isolar segredos backend (`JWT_SECRET`, `DATABASE_URL`) das variáveis expostas ao browser (`VITE_*`).

---

## 3. Variáveis de ambiente

Cada app possui seu próprio `.env`/`.env.example` (`DEC-033`). O Vite expõe ao browser **apenas** variáveis prefixadas com `VITE_` — as demais ficam exclusivamente no servidor NestJS.

### `apps/api/.env.example`

```dotenv
# ── Base de dados (D2 — SQL Server com Prisma ORM) ──────────────────────────
# Dev local com SQL Server Express 2019 (instância nomeada — DEC-032):
DATABASE_URL="sqlserver://localhost\\SQLEXPRESS;database=fgrops_dev;user=sa;password=SUA_SENHA;trustServerCertificate=true"
# Produção ou SQL Server padrão (porta 1433):
# DATABASE_URL="sqlserver://localhost:1433;database=fgrops_dev;user=sa;password=SUA_SENHA;trustServerCertificate=true"

# ── Redis / Memurai (D3 — blacklist JWT e rate limiting) ─────────────────────
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
```

### `apps/web/.env.example`

```dotenv
# ── Frontend Vite + React (apenas VITE_* são expostas ao browser) ────────────
# VITE_API_BASE_URL carrega SÓ a origem — o prefixo /api/v1 (SPEC/08 §1) é
# anexado pelo código (apps/web/src/lib/http.ts, idempotente). Não coloque
# /api/v1 aqui (o código tolera, mas a origem é o contrato desta env).
VITE_API_BASE_URL="http://localhost:3000"
VITE_WS_URL="ws://localhost:3000/ws"
VITE_APP_NAME="FGR-OPS"
```

---

## 4. Bootstrap do ambiente local

```bash
# 1. Clonar o repositório
git clone <url-repo> fgr-ops
cd fgr-ops

# 2. Instalar Turborepo global (CLI conveniente) — DEC-032
# O global defere automaticamente para a devDependency local quando presente
pnpm add -g turbo

# 3. Copiar variáveis de ambiente por app — DEC-033
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env
# Editar apps/api/.env com DATABASE_URL (instância nomeada), JWT_SECRET, etc.
# Editar apps/web/.env com VITE_API_BASE_URL se necessário

# 4. Instalar dependências (todos os workspaces)
pnpm install

# 5. Gerar cliente Prisma e executar migrações
pnpm --filter api exec prisma generate
pnpm --filter api exec prisma migrate dev --name init

# 6. (Opcional) Popular dados de seed
pnpm --filter api exec prisma db seed

# 7. Iniciar todos os apps em modo dev (Turborepo)
turbo dev
# ou individualmente:
# turbo dev --filter=api    (NestJS em :3000)
# turbo dev --filter=web    (Vite em :5173)
```

> `turbo dev` inicia `apps/api` (`:3000`) e `apps/web` (`:5173`) em paralelo com hot-reload. A task `dev` tem `"cache": false` explícito no `turbo.json` (`DEC-033`).

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

Dois targets distintos (`DEC-033`):

| Target | Dependências Turbo | Uso |
|---|---|---|
| `test` | nenhuma | Loop TDD rápido — Vitest sobre TS fonte direto (sem build) |
| `test:integration` | `build`, `^build` | Requer dist compilado e Prisma client gerado |

```bash
# Loop TDD rápido (sem build — default)
turbo test

# Testes de integração (requerem build completo)
turbo test:integration

# Backend — unitários
pnpm --filter api test

# Backend — integração
pnpm --filter api test:integration
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

## 8. Deploy em produção — Nginx + Windows Server (IIS + PM2) (DEC-022)

### 8.1 Visão da arquitetura

```
Internet
   │ HTTPS (443) — certificado TLS aqui
   ▼
Nginx  (servidor Linux separado — borda/DMZ)
   ├── /api/v1/*  ──────────────────────────────────────────────┐
   ├── /health    ──────────────────────────────────────────────┤  HTTP → <IP-backend>:3000
   └── /*  (web) ──────────────────────────────────────────────┐│
                                                               ││
                          Servidor(es) Windows (backend) ◄─────┘│
                           ├── PM2 (porta 3000, loopback)       │
                           │    └── apps/api/dist/main.js ◄─────┘
                           │         (NestJS — responde /api/v1/*)
                           └── IIS (porta 80, HTTP)
                                └── C:/www/fgr-ops/web/
                                     (apps/web/dist/ — SPA Vite)
                                              │
                                              ▼
                                     SQL Server + Memurai (Redis)
```

**Fluxo de uma chamada de API:**
`Browser → Nginx :443 → PM2/NestJS :3000` (direto, sem IIS no caminho)

**Fluxo de uma chamada de FE estático:**
`Browser → Nginx :443 → IIS :80 → arquivo em dist/`

> **Porta 3000 nunca é exposta à internet** — firewall do servidor Windows bloqueia acesso externo; só o IP do servidor Nginx é autorizado a alcançar a porta 3000.

### 8.2 Configurar Nginx (servidor de borda)

Criar `/etc/nginx/sites-available/fgr-ops` (ou equivalente na distro):

```nginx
server {
    listen 80;
    server_name fgr-ops.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name fgr-ops.example.com;

    ssl_certificate     /etc/ssl/certs/fgr-ops.crt;
    ssl_certificate_key /etc/ssl/private/fgr-ops.key;

    # API — direto para PM2/NestJS (já tem prefixo /api/v1 internamente)
    location /api/v1/ {
        proxy_pass         http://<IP-servidor-backend>:3000;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   X-Request-Id      $request_id;
    }

    # Health check (excluído do setGlobalPrefix — sem /api/v1)
    location /health {
        proxy_pass http://<IP-servidor-backend>:3000;
    }

    # WebSocket (NestJS Gateway — se habilitado)
    location /ws {
        proxy_pass          http://<IP-servidor-backend>:3000;
        proxy_http_version  1.1;
        proxy_set_header    Upgrade    $http_upgrade;
        proxy_set_header    Connection "upgrade";
    }

    # Web estático — IIS no servidor backend (porta 80)
    location / {
        proxy_pass http://<IP-servidor-backend>:80;
        proxy_set_header Host $host;
    }
}
```

> **`VITE_API_BASE_URL` de produção:** a **origem** da API — ex.: `https://operationsystem-api.fgr.com.br` (o FE fica em `https://operationsystem.fgr.com.br`). O prefixo `/api/v1` (SPEC/08 §1) é anexado pelo código (`apps/web/src/lib/http.ts`, idempotente), **não** vai neste valor. O NestJS recebe `/api/v1/*` intacto. ⚠️ Histórico: em 2026-07-10 este secret de CI ficou sem o `/api/v1` e derrubou o login (404); mover o prefixo para o código eliminou a classe do bug.

### 8.3 Preparar o IIS para estáticos (servidor backend)

O IIS **não** atua como proxy reverso nesta topologia — serve apenas arquivos estáticos.

1. Criar o site `fgr-ops-web` apontando para `C:/www/fgr-ops/web/` com binding HTTP na porta 80 (só loopback/privado — não exposto à internet diretamente).
2. Habilitar o recurso **WebSocket Protocol** apenas se o NestJS Gateway for servido pelo IIS no futuro.
3. Não instalar ARR nem URL Rewrite Module (desnecessários).

### 8.4 `web.config` do site IIS (SPA + estáticos)

Criar em `C:/www/fgr-ops/web/web.config`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <!-- SPA fallback: toda rota não-arquivo → index.html (TanStack Router) -->
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

> O Service Worker (`sw.js`) e o `manifest.webmanifest` devem ser servidos **sem cache agressivo** — ajustar regras de cache específicas para esses arquivos se necessário.

### 8.5 Configurar PM2 como serviço Windows

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

### 8.6 `ecosystem.config.js` do NestJS

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
        API_HOST: '0.0.0.0',     // escuta em todas as interfaces p/ o Nginx alcançar
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

### 8.7 Procedimento de deploy

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

### 8.8 Observações de produção

- **TLS:** certificado gerenciado no servidor Nginx (Let's Encrypt ou certificado corporativo); o servidor Windows não precisa de certificado próprio.
- **Firewall do servidor Windows:** bloquear acesso externo à porta 3000; liberar apenas o IP do servidor Nginx. A porta 80 do IIS também deve ser restrita ao Nginx (não exposta à internet diretamente).
- **`API_HOST` em produção:** `0.0.0.0` para o NestJS escutar em todas as interfaces (necessário para o Nginx em servidor separado alcançar a porta 3000). Em dev local, `127.0.0.1` é suficiente.
- **Logs do Nginx:** `/var/log/nginx/` — rotação via `logrotate`.
- **Logs do IIS:** `%SystemDrive%/inetpub/logs/LogFiles/` — rotação padrão Windows.
- **Logs do NestJS:** `C:/logs/fgr-ops-api/` com rotação gerenciada pelo PM2 (módulo `pm2-logrotate`).
- **Variáveis sensíveis:** `JWT_SECRET`, `DATABASE_URL`, `REDIS_URL` em `C:/apps/fgr-ops-api/.env` com ACL restrita ao usuário do serviço PM2.
- **Backup:** SQL Server backup gerenciado pela FGR; Redis pode ser volátil (apenas blacklist/rate-limit).

---

## 9. Referências

- [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) — ADRs D1 (Turborepo), D2 (SQL Server/Prisma), D3 (JWT/Redis), D6 (política de autenticação), D7 revista (React + Vite + Tailwind + shadcn/ui)
- [audit/decisions-log.md](audit/decisions-log.md) — DEC-004 (parâmetros de sessão por perfil), DEC-021 (stack frontend Vite+React, supersede DEC-007/DEC-008), DEC-022 (infra Windows/IIS/PM2), DEC-023 (preparação mobile RN), DEC-032 (versões Node 24/pnpm 10/Memurai/SQL Express), DEC-033 (.env por app, test vs test:integration)
- [SPEC/07-design-ui-logica.md](SPEC/07-design-ui-logica.md) — padrões React, Tailwind + shadcn/ui, react-hook-form + zod
- [SPEC/08-api-contratos.md](SPEC/08-api-contratos.md) — contratos REST, rate limiting por endpoint
- [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) — estratégia PWA offline (Service Worker, IndexedDB), WebSocket
- [tests/plano-testes.md](tests/plano-testes.md) — plano de testes de integração e E2E
