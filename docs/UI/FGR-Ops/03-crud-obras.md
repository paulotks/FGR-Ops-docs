# Tela: CRUD de Obras

**Aplicação:** FGR Ops (Plataforma)
**Device:** Desktop / Mobile (Responsivo)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-SCO-001`, `REQ-SCO-002`, `REQ-SCO-003`
→ SPEC: [`docs/SPEC/01-modulos-plataforma.md` §Bootstrapping-de-obra](../../SPEC/01-modulos-plataforma.md)
→ SPEC: [`docs/SPEC/01-modulos-plataforma.md` §Arquitetura-de-duas-camadas](../../SPEC/01-modulos-plataforma.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)

---

## 1. Objetivo

Gerenciar o ciclo de vida de `Obras` no nível da plataforma FGR Ops. Exclusivo para `SuperAdmin`. Permite cadastrar novas obras, editar seus dados e ativar/desativar o módulo **Machinery Link** por obra (toggle binário). É o passo inicial da sequência canônica de bootstrapping (`#1` e `#2` da tabela SPEC/01), sem a qual nenhum AdminOperacional pode configurar a obra no módulo.

> **Escopo:** Esta tela opera no nível cross-tenant do FGR Ops. O `AdminOperacional` **não** acessa esta tela — ele gerencia configurações operacionais dentro do módulo Machinery Link (ver [`07-configuracoes-obra.md`](../Machinery-Link/07-configuracoes-obra.md)).

---

## 2. Layout

### 2.1 Lista de Obras (View Principal)

```
┌────────────────────────────────────────────────────────────────┐
│  APP SHELL — TOP BAR                                           │
│  Logo FGR Ops          [👤 SuperAdmin ▾]                      │
├────────┬───────────────────────────────────────────────────────┤
│        │  BREADCRUMB: FGR Ops > Obras                          │
│  SIDE  ├───────────────────────────────────────────────────────┤
│  BAR   │  HEADER                                               │
│        │  Obras                              [+ Nova Obra]     │
│  ┌──┐  ├───────────────────────────────────────────────────────┤
│  │🏗│  │  ┌──────────────────────────────────────────────────┐ │
│  │Ob│  │  │ 🔍 Buscar por nome ou código...                  │ │
│  │ra│  │  └──────────────────────────────────────────────────┘ │
│  └──┘  │                                                       │
│        │  TABELA DE OBRAS                                      │
│  ┌──┐  │  ┌────────────┬───────────┬───────────┬──────────┐  │
│  │👥│  │  │   Nome     │  Código   │Mach. Link │  Ações   │  │
│  │Us│  │  ├────────────┼───────────┼───────────┼──────────┤  │
│  │r │  │  │ Site Alpha │  OBR-001  │  ✅ Ativo │  ✎  🗑  │  │
│  └──┘  │  │ Site Beta  │  OBR-002  │  ⏸ Inativo│  ✎  🗑  │  │
│        │  │ Site Gamma │  OBR-003  │  ✅ Ativo │  ✎  🗑  │  │
│        │  └────────────┴───────────┴───────────┴──────────┘  │
└────────┴──────────────────────────────────────────────────────┘
```

### 2.2 Formulário de Criação / Edição (Modal ou Page)

```
┌──────────────────────────────────────────────────────────┐
│  NOVA OBRA                                         [✕]   │
│  ─────────────────────────────────────────────────────── │
│  Nome da Obra *                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │ Site Alpha                                        │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Código Interno *                                        │
│  ┌──────────────────────────────────────────────────┐   │
│  │ OBR-001                                          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Módulos Ativos                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  📦 Machinery Link       [Toggle ●──────○]       │   │
│  │  📊 Relatórios           [Em breve — desabilitado]│   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Descrição (opcional)                                    │
│  ┌──────────────────────────────────────────────────┐   │
│  │                                                   │   │
│  └──────────────────────────────────────────────────┘   │
│  ─────────────────────────────────────────────────────── │
│                          [Cancelar]  [💾 Salvar Obra]    │
└──────────────────────────────────────────────────────────┘
```

---

## 3. Componentes

### 3.1 Sidebar (Navegação FGR Ops)

| Item | Ícone | Rota | Perfis |
|---|---|---|---|
| **Obras** | 🏗 | `/obras` | SuperAdmin |
| **Usuários** | 👥 | `/usuarios` | SuperAdmin, Board |

### 3.2 Tabela de Obras

| Coluna | Largura | Conteúdo |
|---|---|---|
| **Nome** | `flex` | Nome exibível da obra |
| **Código** | `130px` | Identificador interno (ex.: `OBR-001`) |
| **Machinery Link** | `140px` | Badge de status do módulo |
| **Ações** | `100px` | Botões Editar (✎) e Desativar (🗑) |

**Badge de status do módulo:**

| Estado | Badge | Estilo |
|---|---|---|
| Machinery Link ativo | ✅ Ativo | `--status-success-bg`, texto `--status-success` |
| Machinery Link inativo | ⏸ Inativo | `--color-neutral-light`, texto `--color-neutral-dark` |

### 3.3 Formulário de Obra

| Campo | Tipo | Validação |
|---|---|---|
| **Nome da Obra** | `input[type=text]` | Obrigatório, máx. 100 caracteres |
| **Código Interno** | `input[type=text]` | Obrigatório, único, formato `OBR-NNN` sugerido |
| **Machinery Link** | Toggle switch | Ativação binária do módulo por obra |
| **Descrição** | `textarea` | Opcional, máx. 500 caracteres |

**Comportamento do Toggle de Módulo:**

- Ao ativar, nenhuma configuração adicional é feita aqui — o AdminOperacional faz o setup dentro do módulo.
- Ao **desativar** uma obra com Machinery Link já em produção: exibir diálogo de confirmação com aviso: _"Desativar o módulo ocultará o acesso para todos os usuários desta obra. Os dados históricos são preservados."_
- Módulos futuros (Relatórios, etc.) exibidos como desabilitados com badge "Em breve".

### 3.4 Ações por Linha

| Ação | Ícone | Comportamento |
|---|---|---|
| **Editar** | ✎ | Abre o formulário em modo edição com dados preenchidos |
| **Desativar** | 🗑 | Diálogo de confirmação antes de executar; `core:obra:delete` (SuperAdmin) |

> A exclusão permanente de uma `Obra` não é disponibilizada na UI MVP — apenas desativação lógica, para preservar integridade do histórico multi-tenant.

---

## 4. Estados e Interações

| Estado | Comportamento |
|---|---|
| **Lista vazia** | Ilustração + _"Nenhuma obra cadastrada. Crie a primeira obra para iniciar o bootstrapping."_ + botão "+ Nova Obra" |
| **Loading** | Skeleton de 3 linhas na tabela |
| **Salvando** | Botão "Salvar Obra" com spinner + _"Salvando…"_ — formulário desabilitado |
| **Erro de nome duplicado** | Borda vermelha no campo Nome + _"Já existe uma obra com este nome."_ |
| **Código duplicado** | Borda vermelha no campo Código + _"Código já utilizado."_ |
| **Sucesso ao criar** | Toast: _"Obra 'Site Alpha' criada com sucesso."_ |
| **Sucesso ao ativar módulo** | Toast: _"Machinery Link ativado para Site Alpha."_ |

---

## 5. RBAC — Controle de Acesso

| Ação | SuperAdmin | Board | AdminOperacional | UsuarioInternoFGR |
|---|---|---|---|---|
| **Listar obras** | ✅ | ✅ (somente leitura) | ✅ (apenas própria obra) | ✅ (apenas própria obra) |
| **Criar obra** | ✅ | ✗ | ✗ | ✗ |
| **Editar obra** | ✅ | ✗ | ✗ | ✗ |
| **Ativar/Desativar módulo** | ✅ | ✗ | ✗ | ✗ |
| **Desativar obra** | ✅ | ✗ | ✗ | ✗ |

Permissões aplicadas: `core:obra:create`, `core:obra:update`, `core:obra:delete`.

`Board` acessa a listagem de obras via dashboard/relatórios, mas **não** visualiza esta tela de CRUD — a navegação para `/obras` é ocultada para o perfil `Board`.

---

## 6. Responsividade

| Breakpoint | Comportamento |
|---|---|
| **≥ 1024px** | Tabela completa com sidebar |
| **< 1024px** | Sidebar collapsa; tabela compacta; formulário em tela cheia |
