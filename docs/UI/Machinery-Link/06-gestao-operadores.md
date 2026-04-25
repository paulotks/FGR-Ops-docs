# Tela: Gestão de Operadores

**Aplicação:** Machinery Link (Módulo)
**Device:** Desktop (≥ 1280px)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-JOR-004`, `REQ-JOR-005`, `REQ-FUNC-013`, `REQ-NFR-002`
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.3 — Indicador de Operador Inativo](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.2 — Mobile do Operador](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)

---

## 1. Objetivo

Visão em tempo real do estado operacional de todos os operadores da obra. Permite ao `AdminOperacional` e `UsuarioInternoFGR` monitorar quem está ativo no campo, identificar inatividade (badge âmbar com limiar de 5 min — `REQ-FUNC-013`), consultar histórico de expedientes e visualizar a fila individual de cada operador. Não é tela de cadastro — o cadastro de operadores está em [`08-gestao-acessos.md`](./08-gestao-acessos.md).

---

## 2. Layout

```
┌────────────────────────────────────────────────────────────────────────────┐
│  APP SHELL — TOP BAR                                                       │
│  Logo FGR Ops   [Machinery Link]    [Obra: Site Alpha ▾]    [👤 Admin ▾]  │
├────────┬───────────────────────────────────────────────────────────────────┤
│        │  BREADCRUMB: FGR Ops > Machinery Link > Operadores                │
│  SIDE  ├──────────────────────────────────────────────────────────────────┤
│  BAR   │  TOP TOOLBAR                                                      │
│        │  [Todos ●]  [Em Campo]  [Inativos ⚠]  [Sem Expediente]           │
│  ┌──┐  │  ────────────────────────────────────────────────────────────    │
│  │📋│  │                                                                  │
│  │Fi│  │  GRID DE OPERADORES                                              │
│  │la│  │  ┌────────────────────┐ ┌────────────────────┐                  │
│  └──┘  │  │ 👷 José da Silva    │ │ 👷 Carlos Alves     │                  │
│        │  │ 🟢 EM ANDAMENTO     │ │ 🟡 PARADO há 7 min  │                  │
│  ┌──┐  │  │ Retroescavadeira    │ │ Caminhão Basculante │                  │
│  │📊│  │  │ Demanda #142        │ │ Demanda #145 pend.  │                  │
│  │Da│  │  │ Q14/L2 · há 22 min │ │ Q08/L5              │                  │
│  │sh│  │  │ [👁 Ver Fila]       │ │ [👁 Ver Fila]        │                  │
│  └──┘  │  └────────────────────┘ └────────────────────┘                  │
│        │  ┌────────────────────┐ ┌────────────────────┐                  │
│  ┌──┐  │  │ 👷 Ana Ferreira     │ │ 👷 Roberto Lima     │                  │
│  │📝│  │  │ ⚪ DISPONÍVEL       │ │ ⚫ Sem expediente   │                  │
│  │Au│  │  │ Pá Carregadeira     │ │ —                   │                  │
│  │di│  │  │ Fila vazia          │ │ Check-in não feito  │                  │
│  │t │  │  │ [👁 Ver Fila]       │ │  —                  │                  │
│  └──┘  │  └────────────────────┘ └────────────────────┘                  │
│        │                                                                  │
│  ┌──┐  │  Operadores: 12 · Em campo: 9 · Inativos: 2 · Sem exp.: 1       │
│  │👷│  │                                                                  │
│  │Op│  │                                                                  │
│  └──┘  │                                                                  │
└────────┴──────────────────────────────────────────────────────────────────┘
```

---

## 3. Componentes

### 3.1 Sidebar (Navegação do Módulo)

Item **Operadores** ativo:

| Item | Ícone | Rota | Perfis |
|---|---|---|---|
| **Fila de Demandas** | 📋 | `/machinery-link/fila` | AdminOperacional, UsuarioInternoFGR |
| **Dashboard** | 📊 | `/machinery-link/dashboard` | AdminOperacional, UsuarioInternoFGR, Board |
| **Auditoria** | 📝 | `/machinery-link/auditoria` | AdminOperacional, UsuarioInternoFGR, Board |
| **Operadores** | 👷 | `/machinery-link/operadores` | AdminOperacional, UsuarioInternoFGR |

### 3.2 Filtros por Status (Tab Chips)

| Tab | Critério de exibição |
|---|---|
| **Todos** | Todos os operadores com expediente aberto hoje |
| **Em Campo** | Operadores com demanda `EM_ANDAMENTO` |
| **Inativos ⚠** | Operadores com `PENDENTE` mais antiga > 5 min sem início (REQ-FUNC-013) |
| **Sem Expediente** | Operadores habilitados mas sem check-in hoje |

### 3.3 Cards de Operador

Cada operador é representado por um card no grid responsivo:

| Elemento | Estilo | Conteúdo |
|---|---|---|
| **Avatar** | Ícone 👷 ou foto | Inicial do nome |
| **Nome** | `14px/600` | Nome completo |
| **Badge de Status** | Pill colorido | Indicador de atividade (ver tabela abaixo) |
| **Maquinário** | `12px/400` | Tipo de maquinário em uso no expediente ativo |
| **Demanda ativa** | `12px/400` | ID + local (ou "Fila vazia") |
| **Tempo** | `12px/mono` | Tempo desde início da demanda ativa (ou inatividade) |
| **Ação** | Botão "Ver Fila" | Abre drawer com a fila completa do operador |

**Grid:**
- `auto-fill, minmax(240px, 1fr)`
- Gap: `16px`
- Card border-radius: `8px`
- Card border: `1px solid --color-surface-border`
- Card shadow: `shadow-sm`

### 3.4 Indicador de Status do Operador (`REQ-FUNC-013`)

| Status | Badge | Cor | Borda esquerda do card | Condição |
|---|---|---|---|---|
| **Em Andamento** | 🟢 EM ANDAMENTO | `--status-success` | `--status-success` | Demanda `EM_ANDAMENTO` ativa |
| **Parado** (inativo) | 🟡 PARADO há Xmin | `--status-warning` | `--status-warning` | Demanda `PENDENTE` mais antiga > 5 min sem início |
| **Disponível** | ⚪ DISPONÍVEL | `--color-neutral` | `--color-neutral-light` | Expediente aberto, fila vazia |
| **Pausado** | 🟠 PAUSADO | `--status-warning` | `--status-warning` | Demanda em `PAUSADA` |
| **Sem expediente** | ⚫ SEM EXPEDIENTE | `--color-neutral-dark` | `--color-neutral-light` | Check-in não realizado |

> **Limiar de inatividade MVP:** 5 minutos configurável por obra (SPEC/07 §1.3). O badge "PARADO" é atualizado em tempo real via WebSocket. **Não há automação de escalação** — o AdminOperacional contata o operador manualmente (rádio, telefone).

---

### 3.5 Contador Resumido (Rodapé da Tela)

Linha de métricas rápidas sempre visível:

```
Operadores: 12 · Em campo: 9 · Inativos ⚠: 2 · Sem expediente: 1
```

Atualizada em tempo real via WebSocket (`INVALIDATE_QUEUE`).

---

### 3.6 Drawer: Fila do Operador

Clicar em "Ver Fila" abre um `Sheet` lateral com:

```
┌──────────────────────────────────────────────────────┐
│  👷 JOSÉ DA SILVA                              [✕]   │
│  Retroescavadeira · Expediente aberto às 07:30       │
│  ──────────────────────────────────────────────────  │
│  FILA ATUAL                                          │
│  ● #142 EM_ANDAMENTO  · Q14/L2 · Escavação  · 22min  │
│  ● #147 PENDENTE      · Q15/L3 · Nivelamento         │
│  ● #148 PENDENTE      · Q14/L1 · Compactação         │
│  ──────────────────────────────────────────────────  │
│  Demandas concluídas hoje: 3                         │
└──────────────────────────────────────────────────────┘
```

Demandas listadas com badge de SLA e prioridade. `AdminOperacional` pode arrastar para reordenar (Blindagem) diretamente pelo drawer.

---

### 3.7 Vista Alternativa: Tabela de Alta Densidade

Toggle no toolbar para alternar entre Grid e Tabela (útil para obras com muitos operadores).

| Coluna | Largura | Conteúdo |
|---|---|---|
| **Operador** | `200px` | Nome + avatar |
| **Status** | `150px` | Badge de status |
| **Maquinário** | `180px` | Tipo em uso |
| **Demanda Ativa** | `120px` | ID clicável |
| **Local** | `140px` | Quadra/Lote |
| **Inativo há** | `100px` | Tempo sem início (em laranja se > 5 min) |
| **Fila** | `80px` | Contagem de demandas pendentes |
| **Ações** | `80px` | Menu ⋮ |

---

## 4. Estado-to-UI Mapping (Operadores)

| Condição do Operador | Card | Tabela |
|---|---|---|
| Demanda `EM_ANDAMENTO` | Verde + tempo ativo | Linha verde |
| `PENDENTE` > 5 min sem início | Âmbar + "PARADO há Xmin" | Linha âmbar, coluna "Inativo há" em laranja |
| Fila vazia | Neutro + "DISPONÍVEL" | Linha neutra, sem tempo |
| Demanda `PAUSADA` | Laranja + "PAUSADO" | Linha laranja |
| Sem expediente hoje | Cinza escuro + "SEM EXPEDIENTE" | Linha cinza, sem ações |

---

## 5. RBAC — Controle de Acesso

| Ação | AdminOperacional | UsuarioInternoFGR | Board | SuperAdmin |
|---|---|---|---|---|
| **Visualizar lista de operadores** | ✅ | ✅ | ✅ (read-only via dashboard) | ✅ |
| **Ver fila individual** | ✅ | ✅ | ✅ (somente leitura) | ✅ |
| **Reordenar fila via drawer** | ✅ | ✗ | ✗ | ✅ |
| **Acessar sidebar "Operadores"** | ✅ | ✅ | ✗ | ✅ |

`Board` não tem acesso à sidebar "Operadores"; a tela pode ser acessada apenas embarcada no Dashboard via widget resumido.

---

## 6. Real-Time Updates

| Mecanismo | Evento |
|---|---|
| **WebSocket** | `OPERATOR_STATUS_CHANGE` — atualiza badge de status no card em tempo real |
| **WebSocket** | `INVALIDATE_QUEUE` — atualiza contadores e métricas do rodapé |
| **TanStack Query** | `keepPreviousData: true` — sem flicker durante atualizações de cards |

---

## 7. Responsividade

| Breakpoint | Comportamento |
|---|---|
| **≥ 1280px** | Grid de cards 4+ colunas |
| **1024–1279px** | Grid 2–3 colunas |
| **< 1024px** | Sidebar collapsa; lista vertical de cards; drawer vira modal |
