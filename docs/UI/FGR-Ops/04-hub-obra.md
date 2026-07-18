# Tela: Hub da Obra (módulos + usuários da obra)

**Aplicação:** FGR Ops (Plataforma — nível Obra)
**Device:** Desktop / Mobile (Responsivo)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-RBAC-003`
→ SPEC: [`docs/SPEC/01-modulos-plataforma.md`](../../SPEC/01-modulos-plataforma.md) · DEC-048
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)
→ UI: [`02-app-shell-hub.md`](02-app-shell-hub.md) · [`03-crud-obras.md`](03-crud-obras.md)

---

## 1. Objetivo

Nível de navegação **"Obra"** (DEC-048), entre a plataforma (`/ops`) e os módulos (`/machinery-link/{obraId}`). Ao "entrar" numa obra, o usuário vê os **módulos habilitados** (MVP: card único do Machinery Link, hardcoded — ativação por obra é Fase 2 de DEC-014) e o link de **usuários da obra**.

## 2. Rotas

| Rota | Conteúdo | Guard |
|---|---|---|
| `/obras/{obraId}` | Hub: card(s) de módulo + link "Usuários da obra" | Idêntico ao `machinery-link/{obraId}` (DEC-047): login → quarteto (`SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`) → tenant admin fora da própria obra é redirecionado à própria; `SuperAdmin`/`Board` navegam livre e sincronizam a obra ativa |
| `/obras/{obraId}/usuarios` | Gestão de usuários da obra: `AdminOperacional`, `UsuarioInternoFGR` (lista, criar, desativar) | Herdado do layout acima |

## 3. Gestão de usuário em 3 níveis (DEC-048)

| Nível | Tela | Perfis geridos | Escopo |
|---|---|---|---|
| Plataforma | `/ops/usuarios` ("Usuários da plataforma") | `SuperAdmin`, `Board` | cross-tenant, sem `obraId` |
| Obra | `/obras/{obraId}/usuarios` | `AdminOperacional`, `UsuarioInternoFGR` | por obra, multi-módulo |
| Módulo | `/machinery-link/{obraId}/operadores` · `/machinery-link/{obraId}/tower-operators` | `Operador` · `TowerOperator` | por obra, exclusivo do módulo (DEC-031) |

- As 3 telas usam `GET/POST/DELETE /usuarios` (sem endpoint novo); filtro de perfil client-side; `obraId` de criação derivado do path nas telas obra-scoped (nunca campo manual).
- Escrita gated por `USUARIO_WRITE_PERFIS` (`AdminOperacional`, `SuperAdmin`) + `perfilPodeGerenciar` (D8) — `Board`/`UsuarioInternoFGR` read-only. Enforcement real no BE (inalterado).

## 4. Fluxos

- `SuperAdmin`/`Board`: `/ops` → "Selecionar obra" → `/obras/{obraId}` (hub) → card do módulo → `/machinery-link/{obraId}`.
- `AdminOperacional`/`UsuarioInternoFGR`: login → **direto** em `/machinery-link/{obraId}` (atalho de `SPEC/01` mantido); alcançam o nível Obra pelo link "Usuários da obra" no header da shell.

## 5. Componentes

| Elemento | Descrição |
|---|---|
| **Header** | Mesmo header da shell de obra (`ObraShellHeader`): nome da obra, "← FGR Ops" (só cross-obra), link "Usuários da obra", perfil, Sair |
| **Card de módulo** | Nome + descrição + botão "Acessar módulo" (padrão card do hub, [`02-app-shell-hub.md`](02-app-shell-hub.md) §3.3) |
| **Tela de usuários** | Tabela (Nome, E-mail, Perfil, Status, Ações) + diálogo "Novo usuário" (nome, e-mail, perfil do bucket, senha — sem campo Obra) |
