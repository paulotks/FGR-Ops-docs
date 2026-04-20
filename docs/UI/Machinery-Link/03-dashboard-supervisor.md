# Tela: Dashboard Supervisor / Subordinado

**Aplicação:** Machinery Link (Módulo)
**Device:** Desktop (≥ 1280px)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-JOR-005`, `REQ-FUNC-009`, `REQ-FUNC-011`, `REQ-FUNC-013`, `REQ-NFR-002`, `REQ-ACE-004`, `REQ-ACE-005`
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.3](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/03-fila-scoring-estados-sla.md`](../../SPEC/03-fila-scoring-estados-sla.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)

---

## 1. Objetivo

**Sala de controle** para monitoramento em tempo real de todas as demandas, operadores e SLAs. Permite triagem, reordenação manual (blindagem), aprovação de demandas e resolução de eventos operacionais. Interface densa, com forte apelo a dados e color-coding para resposta rápida a incidentes.

---

## 2. Layout Principal

```
┌────────────────────────────────────────────────────────────────────────────┐
│  APP SHELL — TOP BAR                                                       │
│  Logo FGR Ops   [Machinery Link]    [Obra: Site Alpha ▾]    [👤 Admin ▾]  │
├────────┬───────────────────────────────────────────────────────────────────┤
│        │  TOP TOOLBAR                                                      │
│  SIDE  │  ┌────────┐ ┌──────────┐ ┌──────────┐    Operadores: 12 ativos  │
│  BAR   │  │Filtro ▾│ │Setor   ▾ │ │Urgência ▾│    Demandas: 34 ativas   │
│        │  └────────┘ └──────────┘ └──────────┘                            │
│  ┌──┐  ├──────────────────────────────────────────────────────────────────┤
│  │📋│  │                                                                  │
│  │Fi│  │   KANBAN / TABLE VIEW                                            │
│  │la│  │                                                                  │
│  └──┘  │   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│        │   │ PENDENTE  │ │ EM EXEC. │ │ PAUSADA  │ │CONCLUÍDA │          │
│  ┌──┐  │   │          │ │          │ │          │ │          │          │
│  │📊│  │   │ Card 1   │ │ Card 4   │ │ Card 7   │ │ Card 9   │          │
│  │Da│  │   │ Card 2   │ │ Card 5   │ │          │ │ Card 10  │          │
│  │sh│  │   │ Card 3   │ │ Card 6   │ │          │ │          │          │
│  └──┘  │   │          │ │          │ │          │ │          │          │
│        │   └──────────┘ └──────────┘ └──────────┘ └──────────┘          │
│  ┌──┐  │                                                                  │
│  │📝│  ├──────────────────────────────────────────────────────────────────┤
│  │Au│  │  APPROVAL INBOX (collapsible bottom panel)                       │
│  │di│  │  🔔 3 itens pendentes de aprovação                              │
│  │t │  │  ┌──────┐ ┌──────┐ ┌──────┐                                    │
│  └──┘  │  │Aprov.│ │Aprov.│ │Aprov.│                                    │
│        │  └──────┘ └──────┘ └──────┘                                    │
└────────┴──────────────────────────────────────────────────────────────────┘
```

---

## 3. Componentes

### 3.1 Sidebar (Navegação do Módulo)

Herda do App Shell com itens específicos do Machinery Link:

| Item | Ícone | Rota |
|---|---|---|
| **Fila de Demandas** | 📋 | `/machinery-link/fila` (ativo) |
| **Dashboard** | 📊 | `/machinery-link/dashboard` |
| **Auditoria** | 📝 | `/machinery-link/auditoria` |
| **Operadores** | 👷 | `/machinery-link/operadores` |

### 3.2 Top Toolbar (Filtros Globais)

Barra de filtros e métricas rápidas acima do conteúdo principal.

| Elemento | Tipo | Descrição |
|---|---|---|
| **Filtro Setor** | Dropdown multi-select | Filtra por SetorOperacional |
| **Filtro Urgência** | Dropdown | MAXIMA, ELEVADA, NORMAL |
| **Filtro Equipamento** | Dropdown searchable | Por tipo de maquinário |
| **Filtro Período** | Date range picker | Range de data/hora |
| **Contadores** | Badges inline | Operadores ativos, Demandas ativas, SLAs em violação |

**Estilo:**
- Background: `--color-surface`
- Border bottom: `1px solid --color-surface-border`
- Padding: `12px 24px`
- Chips de filtro ativos com `--color-primary-light` bg e `--color-primary` text

### 3.3 View Kanban

Quatro colunas representando os estados operacionais:

| Coluna | Header Color | Descrição |
|---|---|---|
| **Pendente** | `--status-info` | Demandas aguardando atribuição ou início |
| **Em Execução** | `--status-success` | Demandas ativas no campo |
| **Pausada** | `--status-warning` | Demandas com pausa registrada |
| **Concluída** | `--status-success` (sólido, tom suave) | Demandas finalizadas no dia |

**Colunas:**
- Width: `min-width: 280px`, flex grow
- Background: `--color-background`
- Header: Barra colorida de `4px` no topo + contagem de cards
- Overflow: scroll vertical por coluna

### 3.4 Demand Cards (dentro do Kanban)

| Propriedade | Valor |
|---|---|
| **Background** | `--color-surface` |
| **Border left** | `4px solid` cor do status |
| **Border radius** | `8px` |
| **Shadow** | `shadow-sm` |
| **Padding** | `12px 16px` |
| **Margin bottom** | `8px` |

**Conteúdo do card:**

| Elemento | Estilo | Posição |
|---|---|---|
| **ID** | `#142` — `12px/600`, `--color-text-muted` | Top left |
| **SLA Badge** | Pill badge com cor SLA escalada | Top right |
| **Serviço** | `14px/600`, `--color-text-primary` | Row 2 |
| **Localização** | `12px/400`, `--color-text-secondary` | Row 3 |
| **Operador** | Avatar mini (`24px`) + nome — `12px` | Row 4 (se atribuído) |
| **Tempo Decorrido** | Relógio com contagem — `12px/mono` | Bottom right |

### SLA Visual Escalation nos Cards

| Estado SLA | Borda | Badge | Animação |
|---|---|---|---|
| **Dentro do prazo** | `--status-success` (esquerda) | 🟢 Verde | Nenhuma |
| **≥75% consumido** | `--status-warning` (esquerda) | 🟡 Amarelo + ⏰ | Nenhuma |
| **SLA violado** | `--status-danger` (esquerda, `3px`) | 🔴 Vermelho | **Pulse animation** na borda + glow sutil |

CSS para SLA violado:
```css
@keyframes sla-pulse {
  0%, 100% { box-shadow: 0 0 0 0 rgba(211, 47, 47, 0.4); }
  50% { box-shadow: 0 0 0 6px rgba(211, 47, 47, 0); }
}
.card-sla-violated {
  border-left: 4px solid var(--status-danger);
  animation: sla-pulse 2s ease-in-out infinite;
}
```

### 3.5 View Alternativa — Tabela de Alta Densidade

Toggle entre Kanban e Table via botão no toolbar. A tabela é ideal para análise rápida de grandes volumes.

| Coluna | Largura | Conteúdo |
|---|---|---|
| **ID** | `80px` | `#142` |
| **Status** | `120px` | Badge pill colorido |
| **Serviço** | `flex` | Nome do serviço |
| **Localização** | `150px` | Quadra/Lote |
| **Operador** | `150px` | Nome + avatar |
| **SLA** | `100px` | Badge + tempo restante |
| **Prioridade** | `100px` | Score numérico + badge |
| **Criada em** | `120px` | Timestamp |
| **Ações** | `80px` | Menu ⋮ contextual |

**Estilo tabela:**
- Alternating row colors: `--color-surface` / `--color-background`
- Hover: `--color-primary-light`
- Rows com SLA violado: `--status-danger-bg` como fundo
- Sortable columns (click no header)
- Sticky header

---

## 4. Efeito Blindagem (Drag & Drop)

O `AdminOperacional` pode reordenar demandas manualmente, sobrepondo o algoritmo de score.

### Interação

1. **Drag:** Segurar card por `500ms` ou usar handle ⠿ no canto do card
2. **Drop zones:** Colunas do Kanban aceitam drop para reordenação intra-coluna
3. **Feedback visual:** Ghost do card com `opacity: 0.6`, drop zone highlighted com `--color-primary-light` border dashed
4. **Confirmação:** Após drop, toast: _"Demanda #142 reposicionada. Blindagem ativa."_
5. **Indicador de blindagem:** Cards reordenados manualmente exibem badge 🛡️ com tooltip _"Prioridade manual"_

### Atribuição Direta

Arrastar card para o nome de um operador na lista atribui a demanda diretamente. Se o operador já tem demanda `EM_ANDAMENTO`, a nova entra como próxima na fila dele.

---

## 5. Approval Inbox (Painel Inferior Colapsável)

Painel fixo na parte inferior do dashboard, colapsável. Centraliza aprovações pendentes.

```
┌──────────────────────────────────────────────────────────────┐
│  🔔 Itens pendentes (3)                          [▲ Expand] │
├──────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────┐ │
│  │ Aprovação         │ │ Cancel. Justif.  │ │ Pausa Justif.│ │
│  │ Demanda #145      │ │ Demanda #130     │ │ Demanda #128 │ │
│  │ Escavação Q14/L2  │ │ "Material errado │ │ "Quebra hid- │ │
│  │                   │ │  solicitado"     │ │  ráulica"    │ │
│  │ [✅ Aprovar]      │ │ [✅ Aceitar]     │ │ [👁 Visualiz]│ │
│  │ [❌ Rejeitar]     │ │ [❌ Contestar]   │ │              │ │
│  └──────────────────┘ └──────────────────┘ └──────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

| Tipo de Item | Ações | Cor do card |
|---|---|---|
| **Nova demanda** | Aprovar / Rejeitar | `--status-info-bg` |
| **Cancelamento (justificativa)** | Aceitar / Contestar | `--status-danger-bg` |
| **Pausa (justificativa)** | Visualizar (informativo) | `--status-warning-bg` |

**Estilo do painel:**
- Background: `--color-surface`
- Border top: `2px solid --color-primary`
- Height collapsed: `48px` (apenas header com contagem)
- Height expanded: `200px`
- Cards horizontais em scroll horizontal

---

## 6. Indicador de Operador Inativo (`REQ-FUNC-013`)

Na view de operadores (acessível pela sidebar), cada operador com fila não vazia mas sem demanda `EM_ANDAMENTO` exibe alerta visual:

| Condição | Indicador |
|---|---|
| Demanda `PENDENTE` mais antiga > **5 min** sem início | Badge âmbar 🕐 _"Parado"_ na linha do operador |
| Operador com demanda `EM_ANDAMENTO` | Indicador verde ativo 🟢 |
| Fila vazia | Indicador cinza neutro ⚪ _"Disponível"_ |

O badge desaparece quando o operador inicia a demanda. **Não há automação de escalação** — o `AdminOperacional` aciona contato manual (rádio, telefone).

---

## 7. State-to-UI Mapping (Dashboard)

| Estado | Coluna Kanban | Borda | Badge | Ações Admin |
|---|---|---|---|---|
| `AGENDADA` | Aba separada "Agendamentos" | `--status-info` | "Agendada" + data/hora | Antecipar, Cancelar |
| `PENDENTE` | Pendente | `--status-info` | SLA badge dinâmico | Aprovar, Atribuir, Cancelar |
| `EM_ANDAMENTO` | Em Execução | `--status-success` | Operador ativo 🟢 | Visualizar, Realocar |
| `PAUSADA` | Pausada | `--status-warning` | Motivo exibido | Visualizar justificativa |
| `RETORNADA` | Pendente (transitório) | `--status-warning` | "RETORNADA" laranja | Auto-transição para PENDENTE |
| `CONCLUIDA` | Concluída | `--status-success` (sólido) | Verde ✓ | Mover para Auditoria |
| `CANCELADA` | — (removida da view) | `--status-danger` | Riscado vermelho | Aba Auditoria / Histórico |

---

## 8. Real-Time Updates

| Mecanismo | Uso |
|---|---|
| **WebSocket** | `INVALIDATE_QUEUE` — atualiza fila Kanban/tabela sem refresh |
| **TanStack Query** | `keepPreviousData: true` — sem flicker durante atualizações |
| **Zustand** | Estado local para filtros, seleções de Kanban, flags de UI |
| **Otimistic Updates** | Drag & drop aplica visualmente antes de confirmar no servidor |

---

## 9. Responsividade

| Breakpoint | Comportamento |
|---|---|
| **≥ 1280px** | Layout completo: sidebar + Kanban 4 colunas + approval inbox |
| **1024–1279px** | Kanban com scroll horizontal, 2 colunas visíveis |
| **< 1024px** | Sidebar collapsa. View alterna para tabela compacta. Approval inbox vira modal |

---

## 10. Acessibilidade

| Critério | Implementação |
|---|---|
| **Keyboard drag & drop** | `Arrow keys` para mover cards entre colunas, `Space` para drop |
| **Screen reader** | `aria-live="polite"` em contadores de SLA e approval inbox |
| **Focus management** | Tab order lógico: filtros → colunas → cards → approval |
| **Color + text** | Todos os status usam ícone + cor + texto (nunca cor sozinha) |
