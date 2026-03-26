# Autenticação e RBAC

Fluxo visual do login segmentado por perfil, emissão de tokens JWT, isolamento multi-tenant e bypass cross-tenant.

**PRD fonte:** [../PRD/01-usuarios-rbac.md](../PRD/01-usuarios-rbac.md), [../PRD/04-requisitos-nao-funcionais.md](../PRD/04-requisitos-nao-funcionais.md)

**Módulos SPEC relacionados:** [04-rbac-permissoes](../SPEC/04-rbac-permissoes.md), [00-visao-arquitetura](../SPEC/00-visao-arquitetura.md)

**REQ-* cobertos:** REQ-RBAC-001, REQ-RBAC-002, REQ-RBAC-003, REQ-RBAC-004, REQ-RBAC-005, REQ-RBAC-006, REQ-NFR-005, REQ-NFR-006, REQ-NFR-007, REQ-ACE-001, REQ-ACE-008

**Decisões aplicadas:** DEC-004

---

## Login segmentado por perfil (DEC-004)

```mermaid
flowchart TD
    START["Utilizador abre app / portal"]

    START --> TIPO{"Perfil de campo\nou administrativo?"}

    subgraph CAMPO["Perfis de Campo — REQ-NFR-007 (DEC-004)"]
        CF1["Empreiteiro / Operador\napp mobile (PWA)"]
        CF2["Credenciais: Usuário + PIN"]
        CF3["Rate limiting: /auth/pin\n(lockout progressivo)"]
        CF4["Sessão: 12h · idle timeout: 30 min"]
        CF5["Hash bcrypt · troca PIN a cada 90 dias"]
        CF1 --> CF2 --> CF3 --> CF4 --> CF5
    end

    subgraph ADMIN["Perfis Administrativos — REQ-NFR-007 (DEC-004)"]
        AD1["AdminOperacional / UsuarioInternoFGR\nSuperAdmin / Board\nportal web"]
        AD2["Credenciais: palavra-passe forte\n(≥8 chars, 4 classes obrigatórias)"]
        AD3["Rate limiting: /auth/login\nLockout 15 min após tentativas falhadas"]
        AD4["Sem reutilização das últimas 3 palavras-passe"]
        AD5["Troca a cada 180 dias"]
        AD1 --> AD2 --> AD3 --> AD4 --> AD5
    end

    TIPO -->|Campo| CF1
    TIPO -->|Admin| AD1

    CF5 --> JWT
    AD5 --> JWT

    subgraph JWT["REQ-NFR-005 — Emissão de tokens"]
        J1["Bearer JWT emitido\n(access token curto)"]
        J2["Refresh token (rotativo)"]
        J3["AuthAuditLog: userId, role, timestamp, IP"]
        J1 --- J2
        J1 --> J3
    end
```

## Controlo de acesso por perfil (RBAC)

```mermaid
flowchart TD
    REQ["Request HTTP com Bearer JWT"]
    REQ --> AUTH["Guard: valida JWT + extrai role"]
    AUTH --> PERM{"Guard: verifica permissão\n<módulo>:<recurso>:<ação>"}

    PERM -->|"Permitido"| TENANT

    subgraph TENANT["Isolamento multi-tenant"]
        T1{"Perfil cross-tenant?\n(SuperAdmin / Board)"}
        T2["Filtra por obraId obrigatório\n(tenant-scoped)"]
        T3["Acesso cross-tenant permitido"]
        T4["Regista em AuditLogCrossTenant:\nuserId, role, endpoint, obraIdAlvo, timestamp"]
        T1 -->|Não| T2
        T1 -->|Sim| T3 --> T4
    end

    PERM -->|"Negado"| ERR["HTTP 403 Forbidden\n(antes de atingir controlador)"]

    subgraph BOARD_GUARD["Guard especial — perfil Board"]
        B1{"Verbo HTTP = POST/PUT/PATCH/DELETE?"}
        B2["HTTP 403 imediato"]
        B3["GET / analytics permitidos"]
        B1 -->|Sim| B2
        B1 -->|Não| B3
    end

    T3 --> BOARD_GUARD
```

## Fluxo de refresh de token

```mermaid
sequenceDiagram
    actor U as Utilizador
    participant API as Backend
    participant DB as AuthAuditLog

    U->>API: POST /auth/refresh (refresh token)
    API-->>API: Valida + invalida token anterior (rotativo)
    API-->>U: Novo access token + novo refresh token
    API->>DB: Registo de rotação (userId, timestamp)

    Note over U,API: Se refresh token expirado ou revogado → HTTP 401
    U->>API: POST /auth/logout
    API-->>API: Revoga refresh token
    API->>DB: Registo de logout (userId, timestamp)
```

---

## Critérios de aceite relacionados (PRD)

- [REQ-ACE-001](../PRD/05-criterios-aceite.md#isolamento-rbac-e-multi-tenancy)
- [REQ-ACE-007](../PRD/05-criterios-aceite.md#seguranca-de-token)
- [REQ-ACE-008](../PRD/05-criterios-aceite.md#auditoria-cross-tenant)

-> SPEC: [../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass](../SPEC/04-rbac-permissoes.md#regras-transversais-de-isolamento-e-bypass)
-> SPEC: [../SPEC/04-rbac-permissoes.md#perfis-de-acesso](../SPEC/04-rbac-permissoes.md#perfis-de-acesso)
-> SPEC: [../SPEC/00-visao-arquitetura.md#politica-autenticacao-senha](../SPEC/00-visao-arquitetura.md#politica-autenticacao-senha)
