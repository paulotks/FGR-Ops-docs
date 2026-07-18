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

> **Hub por obra — [DEC-048]:** o hub de módulos é **obra-scoped**: vive em `/obras/{obraId}` (nível "Obra" da navegação, entre a plataforma `/ops` e os módulos). "Selecionar obra" no `/ops` leva ao hub; o card do módulo leva a `/machinery-link/{obraId}`; o link "Usuários da obra" leva a `/obras/{obraId}/usuarios` (gestão de `AdminOperacional`/`UsuarioInternoFGR`). Detalhe em [`04-hub-obra.md`](04-hub-obra.md).

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
| **Nome da Obra** | Nome da obra ativa (read-only), derivado do `obraId` **no path** (`/machinery-link/{obraId}/*`, fonte de verdade). A troca de obra **não** acontece aqui — vive no `/ops` (ver §4). **[DEC-047]** |
| **Botão "← FGR Ops"** | Retorna à shell FGR-Ops (`/ops`). Visível apenas para perfis cross-obra (SuperAdmin, Board); substitui o antigo dropdown de troca no top bar. **[DEC-047]** |
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

## 4. Troca de Contexto (Obra / Tenant) — **[DEC-047]**

A obra é **`obraId` no path** (`/machinery-link/{obraId}/*`) — fonte de verdade única, linkável por obra. A troca de obra **não** é um dropdown no top bar do módulo; ela vive na shell FGR-Ops (`/ops`, ObraSwitcher). O header do módulo mostra o **nome** da obra ativa + um botão **"← FGR Ops"** (só cross-obra) para voltar e escolher outra.

| Perfil | Comportamento |
|---|---|
| **SuperAdmin** | Escolhe a obra no `/ops` (ObraSwitcher, lista todas), entra em `/machinery-link/{obraId}`; "← FGR Ops" retorna ao `/ops`. Pode navegar qualquer obra pela URL. |
| **Board** | Idem SuperAdmin, obras do seu escopo. |
| **AdminOperacional** | Obra fixa (do JWT); o `obraId` ainda aparece no path + nome no header. Sem troca; **sem** botão "← FGR Ops". Tentar outra obra na URL → **redirect para a própria obra** (guard de tenant, Rule 1/3). |
| **UsuarioInternoFGR** | Idem AdminOperacional. |

Trocar de obra (via `/ops`) recarrega fila, dashboard e configurações da obra selecionada. O guard de tenant garante que a UI de um tenant admin **nem aparente** cross-obra.

> **Nota:** Empreiteiro e Operador não acessam o FGR Ops. Eles não aparecem nesta tabela de contexto pois utilizam aplicações próprias.

---

## 5. Estados e Interações

| Estado | Comportamento |
|---|---|
| **Loading inicial** | Skeleton loader nos cards de módulo (3 placeholders) |
| **Erro de carregamento** | Card de erro com botão "Tentar novamente" |
| **Sem módulos** | Mensagem: _"Nenhum módulo disponível para seu perfil. Contate o administrador."_ |
| **Navegação para módulo** | Click no card do hub (`/obras/{obraId}`) navega para `/machinery-link/{obraId}` (DEC-048). Sidebar marca o módulo ativo. |

---

## 6. Navegação Interna (Dentro de um Módulo)

Após entrar em um módulo, o App Shell permanece como container. A sidebar atualiza para exibir a navegação interna do módulo:

> **Convergência de rotas — [DEC-047]:** todas as telas do Machinery Link agora vivem sob **`/machinery-link/{obraId}/*`** (obra no path). O split anterior `/admin/*` (catálogo/config) × `/machinery-link/*` **foi removido**: catálogo e configuração ficam sob `configuracoes/`, com `dashboard` e `operadores` no topo da obra. As rotas abaixo omitem o segmento `{obraId}` por brevidade (ele é sempre o 2º segmento).

### Machinery Link — Itens de Navegação

| Item | Ícone | Rota (sob `/machinery-link/{obraId}/`) | Perfis | Status |
|---|---|---|---|---|
| **Dashboard** | 📊 | `dashboard` | AdminOperacional, UsuarioInternoFGR, Board | ✅ MVP (placeholder) |
| **Operadores** | 👷 | `operadores` | AdminOperacional, UsuarioInternoFGR | ✅ MVP |
| **Configurações** | ⚙ | `configuracoes/{maquinarios,tipos-maquinario,setores,ruas,quadras,locais-externos,servicos}` | AdminOperacional, SuperAdmin | ✅ MVP |
| **Fila de Demandas** | 📋 | `fila` | AdminOperacional, UsuarioInternoFGR | 🔜 Slice 6/7 |
| **Auditoria** | 📝 | `auditoria` | AdminOperacional, UsuarioInternoFGR, Board | 🔜 Em breve |
| **Acessos** | 👥 | `acessos` | AdminOperacional, SuperAdmin | 🔜 Em breve |

> **Tab Agendamentos** (Dashboard): acessível via tab switcher no conteúdo do Dashboard, não pela sidebar — ver [`docs/UI/Machinery-Link/05-gestao-agendamentos.md`](../Machinery-Link/05-gestao-agendamentos.md).

---

## 7. Visual Polish

- **Transição suave** entre módulos (fade + slide, `200ms`)
- **Breadcrumb** no content area: `FGR Ops > Machinery Link > Fila`
- **Collapse sidebar** com toggle (ícone hamburger) — memoriza estado no `localStorage`
- **Responsive breakpoint:** Sidebar vira bottom nav em `< 1024px`
