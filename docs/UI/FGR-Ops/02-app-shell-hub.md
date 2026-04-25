# Tela: App Shell / Hub de Módulos

**Aplicação:** FGR Ops (Plataforma)
**Device:** Desktop / Mobile (Responsivo)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-RBAC-003`
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.4](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)
→ SPEC: [`docs/SPEC/01-modulos-plataforma.md` §Fluxo de autenticação](../../SPEC/01-modulos-plataforma.md) · DEC-030

---

## 1. Objetivo

Funcionar como o **hub central** pós-login para **funcionários FGR**. O App Shell é o container global que envolve todos os módulos FGR Ops. Exibe os módulos disponíveis para o perfil do usuário logado e permite navegação rápida entre contextos.

> **Escopo:** FGR Ops (e seu App Shell) é destinado exclusivamente a funcionários da FGR — perfis `SuperAdmin`, `Board`, `AdminOperacional` e `UsuarioInternoFGR`. Empreiteiro e Operador acessam aplicações separadas: o Empreiteiro vai diretamente ao módulo Machinery Link da sua obra ao logar; o Operador utiliza o app de campo para receber e atender solicitações.

---

## 2. Layout

### 2.1 Desktop (≥ 1024px) — Sidebar + Content

```
┌────────────────────────────────────────────────────────────────┐
│  TOP BAR                                                       │
│  ┌──────┐  FGR Ops          [Obra: Site Alpha ▾]  [👤 User ▾] │
│  │ Logo │                                                      │
│  └──────┘                                                      │
├────────┬───────────────────────────────────────────────────────┤
│        │                                                       │
│  SIDE  │   CONTENT AREA                                        │
│  BAR   │                                                       │
│        │   "Módulos Disponíveis"                               │
│  ┌──┐  │                                                       │
│  │🏗│  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ML│  │   │  📦          │  │  📊         │  │  ⚙️          │ │
│  └──┘  │   │  Machinery   │  │  Relatórios │  │  Config.    │ │
│        │   │  Link        │  │  (em breve) │  │  (em breve) │ │
│  ┌──┐  │   │              │  │             │  │             │ │
│  │📊│  │   └─────────────┘  └─────────────┘  └─────────────┘ │
│  │RP│  │                                                       │
│  └──┘  │                                                       │
│        │                                                       │
├────────┴───────────────────────────────────────────────────────┤
│  FOOTER: © FGR Ops · v1.0 · Suporte                           │
└────────────────────────────────────────────────────────────────┘
```

### 2.2 Mobile (< 1024px) — Bottom Nav + Content

```
┌──────────────────────────┐
│  TOP BAR                 │
│  Logo  FGR Ops   [👤]   │
├──────────────────────────┤
│                          │
│  "Módulos"               │
│                          │
│  ┌────────────────────┐  │
│  │  📦 Machinery Link │  │
│  │  Gestão de         │  │
│  │  Maquinário        │  │
│  │            Acessar →│  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │  📊 Relatórios     │  │
│  │  Em breve          │  │
│  └────────────────────┘  │
│                          │
├──────────────────────────┤
│  [🏠] [📦] [⚙] [👤]    │
│  BOTTOM NAV              │
└──────────────────────────┘
```

---

## 3. Componentes

### 3.1 Top Bar

| Elemento | Descrição |
|---|---|
| **Logo** | Logo FGR em versão com cor primária, `height: 32px` |
| **Título** | "FGR Ops" — `--color-text-primary`, `18px/600` |
| **Obra Selector** | Dropdown para troca de `obraId` (contexto de tenant). Exibe nome da obra ativa. Visível apenas para perfis com acesso multi-obra (SuperAdmin, Board). |
| **User Menu** | Avatar + nome do usuário. Dropdown com: Perfil, Configurações, Sair |

**Estilo Top Bar:**
- Background: `--color-surface` (`#ffffff`)
- Border bottom: `1px solid --color-surface-border`
- Height: `64px`
- Shadow: `shadow-sm`

### 3.2 Sidebar (Desktop)

| Elemento | Descrição |
|---|---|
| **Módulo Link** | Ícone + label, highlight quando ativo |
| **Estado ativo** | Background `--color-primary-light`, borda esquerda `3px --color-primary` |
| **Estado inativo** | Texto `--color-text-secondary`, sem fundo |
| **Hover** | Background `--color-primary-light` suave |

**Estilo Sidebar:**
- Width: `240px` (collapsible para `64px` com ícones only)
- Background: `--color-surface`
- Border right: `1px solid --color-surface-border`

### 3.3 Module Cards (Hub View)

Cada módulo é apresentado como um card:

| Propriedade | Valor |
|---|---|
| **Tamanho** | `min-width: 280px`, em grid responsivo (`auto-fill, minmax(280px, 1fr)`) |
| **Border** | `1px solid --color-surface-border`, radius `12px` |
| **Shadow** | `shadow-md` |
| **Hover** | Elevação `shadow-lg`, borda `--color-primary`, scale `1.02` |
| **Header** | Ícone do módulo (48px) + Nome do módulo (`18px/600`) |
| **Description** | Breve descrição do módulo (`14px`, `--color-text-secondary`) |
| **Footer** | Botão "Acessar" ou badge "Em breve" (`--color-neutral`, disabled) |

### 3.4 Módulos Renderizados por RBAC

A visibilidade dos módulos depende do perfil do usuário logado:

| Módulo | Perfis com Acesso | Status |
|---|---|---|
| **Machinery Link** | SuperAdmin, Board, AdminOperacional, UsuarioInternoFGR | ✅ MVP |
| **Relatórios** | AdminOperacional, UsuarioInternoFGR (Gerente), Board, SuperAdmin | 🔜 Em breve |
| **Configurações** | AdminOperacional, SuperAdmin | 🔜 Em breve |

- Módulos "Em breve" aparecem com `opacity: 0.6` e badge cinza
- Módulos sem permissão simplesmente **não são renderizados** (não exibir desabilitado)

---

## 4. Troca de Contexto (Obra / Tenant)

| Perfil | Comportamento |
|---|---|
| **SuperAdmin** | Dropdown de obra visível no top bar, lista todas as obras |
| **Board** | Dropdown visível, lista obras do seu escopo |
| **AdminOperacional** | Obra fixa, sem dropdown |
| **UsuarioInternoFGR** | Obra fixa, sem dropdown |

A troca de obra recarrega os dados da fila, dashboard e configurações do módulo ativo.

> **Nota:** Empreiteiro e Operador não acessam o FGR Ops. Eles não aparecem nesta tabela de contexto pois utilizam aplicações próprias.

---

## 5. Estados e Interações

| Estado | Comportamento |
|---|---|
| **Loading inicial** | Skeleton loader nos cards de módulo (3 placeholders) |
| **Erro de carregamento** | Card de erro com botão "Tentar novamente" |
| **Sem módulos** | Mensagem: _"Nenhum módulo disponível para seu perfil. Contate o administrador."_ |
| **Navegação para módulo** | Click no card navega para `/machinery-link/` (ou rota equivalente). Sidebar marca o módulo ativo. |

---

## 6. Navegação Interna (Dentro de um Módulo)

Após entrar em um módulo, o App Shell permanece como container. A sidebar atualiza para exibir a navegação interna do módulo:

### Machinery Link — Itens de Navegação

| Item | Ícone | Rota | Perfis |
|---|---|---|---|
| **Fila de Demandas** | 📋 | `/machinery-link/fila` | AdminOperacional, UsuarioInternoFGR |
| **Dashboard** | 📊 | `/machinery-link/dashboard` | AdminOperacional, UsuarioInternoFGR, Board |
| **Auditoria** | 📝 | `/machinery-link/auditoria` | AdminOperacional, UsuarioInternoFGR, Board |
| **Operadores** | 👷 | `/machinery-link/operadores` | AdminOperacional, UsuarioInternoFGR |
| **Configurações** | ⚙ | `/machinery-link/configuracoes` | AdminOperacional, SuperAdmin |
| **Acessos** | 👥 | `/machinery-link/acessos` | AdminOperacional, SuperAdmin |

> **Tab Agendamentos** (Dashboard): acessível via tab switcher no conteúdo do Dashboard, não pela sidebar — ver [`docs/UI/Machinery-Link/05-gestao-agendamentos.md`](../Machinery-Link/05-gestao-agendamentos.md).

---

## 7. Visual Polish

- **Transição suave** entre módulos (fade + slide, `200ms`)
- **Breadcrumb** no content area: `FGR Ops > Machinery Link > Fila`
- **Collapse sidebar** com toggle (ícone hamburger) — memoriza estado no `localStorage`
- **Responsive breakpoint:** Sidebar vira bottom nav em `< 1024px`
