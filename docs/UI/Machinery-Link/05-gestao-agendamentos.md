# Tela: Gestão de Agendamentos (Tab do Dashboard)

**Aplicação:** Machinery Link (Módulo)
**Device:** Desktop (≥ 1280px)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-FUNC-006`, `REQ-RBAC-004`
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.3 — Tela de gestão de agendamentos](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §2.1 — Estados de agendamento](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/03-fila-scoring-estados-sla.md`](../../SPEC/03-fila-scoring-estados-sla.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)

---

## 1. Objetivo

Aba integrada ao **Dashboard** (acessível pelo tab switcher do painel, não pela sidebar) para gestão completa do ciclo de vida de demandas agendadas. Consolida em quatro sub-abas: fila de aprovação pendente (`AGUARDANDO_APROVACAO`), agendamentos ativos (`AGENDADA`), solicitações de cancelamento dos operadores e histórico de demandas não executadas (`NAO_EXECUTADA`). Atende aos fluxos DEC-026, DEC-027, DEC-028 e DEC-029.

> **Navegação:** Esta tela é uma **aba do Dashboard**, não um item de sidebar. O usuário acessa via tab switcher no topo do conteúdo do Dashboard: `[Fila de Demandas] [Agendamentos 🔔3]`. A rota sugerida é `/machinery-link/dashboard?tab=agendamentos`.

---

## 2. Layout

### 2.1 Tab Switcher do Dashboard (contexto de acesso)

```
┌──────────────────────────────────────────────────────────────────────────┐
│  APP SHELL — TOP BAR                                                     │
│  Logo FGR Ops   [Machinery Link]   [Obra: Site Alpha ▾]   [👤 Admin ▾] │
├────────┬─────────────────────────────────────────────────────────────────┤
│        │  BREADCRUMB: FGR Ops > Machinery Link > Dashboard               │
│  SIDE  ├─────────────────────────────────────────────────────────────────┤
│  BAR   │  ┌──────────────────────────────┐ ┌───────────────────────────┐ │
│        │  │   📋 Fila de Demandas        │ │  📅 Agendamentos  🔔 3   │ │
│  ┌──┐  │  └──────────────────────────────┘ └───────────────────────────┘ │
│  │📋│  │  ═══════════════════════════════════════════════════════════════ │
│  │Fi│  │                                                                 │
│  │la│  │  (Conteúdo da aba Agendamentos — descrito abaixo)               │
│  └──┘  │                                                                 │
└────────┴─────────────────────────────────────────────────────────────────┘
```

### 2.2 Aba Agendamentos — Sub-abas

```
┌──────────────────────────────────────────────────────────────────────────┐
│  [Aprovação 🔔2]  [Agendamentos Ativos]  [Cancelamentos 🔔1]  [Histórico]│
│  ──────────────────────────────────────────────────────────────────────  │
│                                                                          │
│  SUB-ABA APROVAÇÃO (default quando badge > 0)                            │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  DEMANDA #156 — Nivelamento                                        │  │
│  │  📅 Agendado para 26/04 às 08:00 · Setor Norte · Q03/L7           │  │
│  │  Solicitado por: Maria Souza (UsuarioInternoFGR) · há 12 min       │  │
│  │                                                                    │  │
│  │  Justificativa do agendamento: "Prioridade de fundação no Q3"      │  │
│  │                                                                    │  │
│  │  [❌ Rejeitar]                              [✅ Aprovar → AGENDADA]│  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  DEMANDA #155 — Transporte de Material                             │  │
│  │  📅 Agendado para 26/04 às 10:30 · Setor Sul · Q11/L2             │  │
│  │  ...                                                               │  │
│  │  [❌ Rejeitar]                              [✅ Aprovar → AGENDADA]│  │
│  └────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Componentes

### 3.1 Tab Switcher (no Dashboard)

Badge numérico no tab "Agendamentos" exibe o total de **itens pendentes de ação** (aprovações + cancelamentos pendentes). Zera quando todos os itens são processados.

| Estado do badge | Valor | Estilo |
|---|---|---|
| Sem pendências | Sem badge | — |
| 1–9 pendências | Número | `--status-warning-bg` + `--status-warning` text |
| ≥ 10 pendências | `9+` | `--status-danger-bg` + `--status-danger` text |

### 3.2 Sub-aba 1: Fila de Aprovação (`AGUARDANDO_APROVACAO`)

Lista de demandas criadas por `UsuarioInternoFGR` aguardando aprovação do `AdminOperacional` ou `SuperAdmin` (DEC-027).

**Card de aprovação:**

| Elemento | Conteúdo |
|---|---|
| **Header** | ID + nome do serviço + tipo de maquinário |
| **Data/hora** | Data agendada (`dataAgendada`) e hora cravada |
| **Localização** | Setor + Quadra/Lote |
| **Solicitante** | Nome + perfil + tempo desde criação |
| **Justificativa** | Texto da justificativa do solicitante (se informada) |
| **Ações** | `[Rejeitar]` (botão secundário) · `[Aprovar → AGENDADA]` (botão primário) |

**Modal de Rejeição:**
- Campo "Motivo da rejeição" obrigatório (mín. 10 caracteres)
- Demanda transita `AGUARDANDO_APROVACAO → CANCELADA` com log de rejeição

**Permissão:** `machinery:demanda:approve` + `machinery:demanda:reject` → SuperAdmin, AdminOperacional.

---

### 3.3 Sub-aba 2: Agendamentos Ativos (`AGENDADA`)

Tabela de demandas já aprovadas aguardando aceite dos operadores.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  AGENDAMENTOS ATIVOS                                                     │
│                                                                          │
│  ┌────┬─────────┬──────────────┬───────────┬──────────────┬──────────┐  │
│  │ ID │ Serviço │  Agendado p/ │   Aceite  │   Expiração  │  Ações   │  │
│  ├────┼─────────┼──────────────┼───────────┼──────────────┼──────────┤  │
│  │#148│Escav.   │ 26/04 08:00  │ ✅ Op.José│   —          │ Cancelar │  │
│  │#149│Transp.  │ 26/04 10:30  │ ⏳ Aguard.│  T-1h: 09:30 │ Antecipar│  │
│  │#150│Nível.   │ 26/04 14:00  │ ❌ Recusou│  T-1h: 13:00 │ Antecipar│  │
│  └────┴─────────┴──────────────┴───────────┴──────────────┴──────────┘  │
└──────────────────────────────────────────────────────────────────────────┘
```

| Coluna | Conteúdo |
|---|---|
| **ID** | Número clicável para drawer de detalhe |
| **Serviço** | Nome + tipo de maquinário |
| **Agendado p/** | `dataAgendada` formatado |
| **Aceite** | ✅ Operador aceito (nome) · ⏳ Aguardando aceite · ❌ Recusado (por quem) |
| **Expiração T-1h** | Countdown para `NAO_EXECUTADA`; destaque visual âmbar quando ≤ 2h |
| **Ações** | [Cancelar] (com justificativa obrigatória) · [Antecipar → PENDENTE] |

**Indicação de expiração iminente:**
- Quando `dataAgendada - agora ≤ 1h`: linha recebe fundo `--status-warning-bg` e badge 🕐 _"Expiração iminente"_.
- Após expiração sem aceite: demanda transita automaticamente para `NAO_EXECUTADA` (DEC-028) e sai desta aba.

**Ação Antecipar:** `allocate` / `antecipar` — injeta demanda diretamente em `PENDENTE` (DEC-026). Confirmação obrigatória via diálogo.

---

### 3.4 Sub-aba 3: Solicitações de Cancelamento

Lista de `cancel-request` enviados por operadores sobre demandas agendadas que aceitaram (DEC-029).

**Card de solicitação:**

| Elemento | Conteúdo |
|---|---|
| **Header** | ID + nome do serviço |
| **Operador** | Nome do operador solicitante |
| **Motivo** | Texto da solicitação de cancelamento |
| **Demanda permanece** | Status atual: `AGENDADA` (aceita) — não cancelada enquanto solicitação está pendente |
| **Ações** | `[Rejeitar solicitação]` · `[Aprovar cancelamento → CANCELADA]` |

**Permissão:** `machinery:demanda:approve` (cancel) + `machinery:demanda:reject` (cancel) → SuperAdmin, AdminOperacional.

---

### 3.5 Sub-aba 4: Histórico (`NAO_EXECUTADA`)

Tabela de demandas agendadas que expiraram sem aceite — estado terminal, somente leitura.

| Coluna | Conteúdo |
|---|---|
| **ID** | Número da demanda |
| **Serviço** | Nome + maquinário |
| **Agendado p/** | Data/hora original |
| **Motivo** | Expiração T-1h sem aceite + log de operadores: `RECUSADA` / `NAO_RESPONDIDA` |
| **Data da expiração** | Timestamp do evento `NAO_EXECUTADA` |

Filtros adicionais: período de data, tipo de serviço. Sem ações disponíveis — estado terminal (DEC-028).

---

## 4. State-to-UI Mapping (Agendamentos)

| Estado | Sub-aba | Badge | Ações Admin |
|---|---|---|---|
| `AGUARDANDO_APROVACAO` | Fila de Aprovação | 🟡 Amarelo "Pendente" | Aprovar, Rejeitar |
| `AGENDADA` — aguardando aceite | Agendamentos Ativos | 🔵 Azul "Agendada" | Antecipar, Cancelar |
| `AGENDADA` — aceita | Agendamentos Ativos | 🔵 Azul escuro "Aceita" | Cancelar |
| `AGENDADA` — expiração iminente | Agendamentos Ativos | 🟡 Âmbar "T-1h" | Antecipar urgente |
| `cancel-request` pendente | Cancelamentos | 🔶 Laranja "Solicitação" | Aprovar, Rejeitar |
| `NAO_EXECUTADA` | Histórico | ⚪ Cinza "Não executada" | Somente leitura |

---

## 5. RBAC — Controle de Acesso

| Ação | AdminOperacional | UsuarioInternoFGR | SuperAdmin |
|---|---|---|---|
| **Visualizar todas as sub-abas** | ✅ | ✅ (somente leitura) | ✅ |
| **Aprovar agendamento** | ✅ | ✗ | ✅ |
| **Rejeitar agendamento** | ✅ | ✗ | ✅ |
| **Cancelar demanda agendada** | ✅ | ✗ | ✅ |
| **Antecipar para PENDENTE** | ✅ | ✗ | ✅ |
| **Aprovar/rejeitar cancel-request** | ✅ | ✗ | ✅ |

`UsuarioInternoFGR` pode visualizar todas as sub-abas (incluindo Fila de Aprovação) mas os botões de ação são ocultados via `usePermission('machinery:demanda:approve')`.

---

## 6. Estados da Tela

| Estado | Comportamento |
|---|---|
| **Sub-aba sem itens** | Ilustração + mensagem contextual por sub-aba |
| **Aprovação em andamento** | Card com spinner + _"Aprovando…"_ — botões desabilitados |
| **Erro ao aprovar/rejeitar** | Toast de erro + card retorna ao estado anterior |
| **Nova aprovação via WebSocket** | Badge do tab atualiza + novo card aparece no topo com animação de entrada |
