# Tela: Mobile do Operador — Execução em Campo

**Aplicação:** Machinery Link (Módulo)
**Device:** Mobile
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-JOR-004`, `REQ-FUNC-009`, `REQ-FUNC-011`, `REQ-FUNC-013`, `REQ-ACE-005`
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.2](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/03-fila-scoring-estados-sla.md`](../../SPEC/03-fila-scoring-estados-sla.md)
→ SPEC: [`docs/SPEC/06-definicoes-complementares.md`](../../SPEC/06-definicoes-complementares.md)

---

## 1. Objetivo

Foco absoluto na **demanda de maior prioridade**. O operador não escolhe demandas — segue a fila imposta pelo algoritmo de SLA. Interface desenhada para uso com **luvas, vibração e exposição solar**, com botões gigantes e alto contraste.

---

## 2. Fluxo de Telas

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  CHECK-IN    │────▶│  DEMANDA     │────▶│  CONCLUSÃO/  │
│  DIÁRIO      │     │  ATIVA       │     │  FILA VAZIA  │
│  (bloqueante)│     │  (center     │     │              │
│              │     │   stage)     │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
                           │
                     ┌─────┴──────┐
                     │  FILA      │
                     │  (próximas │
                     │   2)       │
                     └────────────┘
```

---

## 3. Tela de Check-in Diário (Bloqueante)

Exibida **uma vez** no início do turno, antes de qualquer interação com a fila.

```
┌──────────────────────────┐
│                          │
│                          │
│       🏗️                │
│                          │
│   "Bom dia, João!"      │
│                          │
│   Turno: 07:00 - 17:00  │
│   Equipamento: PC-220    │
│                          │
│                          │
│  ┌────────────────────┐  │
│  │                    │  │
│  │   INICIAR TURNO    │  │
│  │                    │  │
│  └────────────────────┘  │
│                          │
│                          │
└──────────────────────────┘
```

| Elemento | Estilo |
|---|---|
| **Ícone** | Ícone de maquinário, `64px`, `--color-primary` |
| **Saudação** | "Bom dia/tarde, {nome}" — `24px/700`, `--color-text-primary` |
| **Info turno** | Horário + equipamento — `16px/400`, `--color-text-secondary` |
| **Botão** | `--color-primary`, branco, **`height: 64px`**, `width: 80%`, `border-radius: 12px`, `font: 20px/700` |
| **Background** | `--color-background` |

---

## 4. Tela Principal — Demanda Ativa (Center Stage)

```
┌──────────────────────────┐
│  HEADER                  │
│  🟢 Turno Ativo   [⚙]  │
├──────────────────────────┤
│                          │
│  ┌────────────────────┐  │
│  │                    │  │
│  │  CARD DEMANDA      │  │
│  │  ATIVA             │  │
│  │                    │  │
│  │  🟢 Em Andamento   │  │
│  │                    │  │
│  │  ESCAVAÇÃO         │  │
│  │  Quadra 12 / Lote 3│  │
│  │  Empr.: Silva      │  │
│  │                    │  │
│  │  ┌──────────────┐  │  │
│  │  │              │  │  │
│  │  │  FINALIZAR   │  │  │
│  │  │              │  │  │
│  │  └──────────────┘  │  │
│  │                    │  │
│  │  ┌──────────────┐  │  │
│  │  │   PAUSAR     │  │  │
│  │  └──────────────┘  │  │
│  │                    │  │
│  │  ┌──────────────┐  │  │
│  │  │  CANCELAR    │  │  │
│  │  └──────────────┘  │  │
│  │                    │  │
│  └────────────────────┘  │
│                          │
├──────────────────────────┤
│  PRÓXIMAS NA FILA        │
│  ┌────────────────────┐  │
│  │ Terraplanagem Q08  │  │
│  └────────────────────┘  │
│  ┌────────────────────┐  │
│  │ Movimentação Q05   │  │
│  └────────────────────┘  │
└──────────────────────────┘
```

### 4.1 Header

| Elemento | Estilo |
|---|---|
| **Status Badge** | 🟢 "Turno Ativo" — `--status-success`, pill badge |
| **Config** | Ícone engrenagem para acessar info do turno |
| **Background** | `--color-surface`, `shadow-sm` |

### 4.2 Card de Demanda Ativa (Main Card)

Este é o componente **central** da experiência do operador. Ocupa a maior parte da viewport.

| Propriedade | Valor |
|---|---|
| **Background** | `--color-surface` |
| **Border** | `2px solid` cor do status da demanda |
| **Border radius** | `16px` |
| **Shadow** | `shadow-lg` |
| **Padding** | `24px` |
| **Min-height** | `60vh` |

**Conteúdo:**

| Elemento | Estilo |
|---|---|
| **Status Badge** | Pill com cor do estado, `14px/600`, UPPERCASE |
| **Serviço** | `24px/700`, `--color-text-primary` — destaque máximo |
| **Localização** | `18px/400`, `--color-text-secondary` — Quadra/Lote ou Local Externo |
| **Empreiteiro** | `16px/400`, `--color-text-muted` — "Solicitado por: {nome}" |

### 4.3 Botões de Ação (Dinâmicos por Estado)

Os botões são **gigantes** para uso com luvas e em ambientes com vibração.

| Botão | Visível em | Estilo | Tamanho |
|---|---|---|---|
| **"Cheguei ao Local"** | `PENDENTE` → transita para `EM_ANDAMENTO` | `--status-success` bg, branco | `height: 72px`, `width: 100%`, `font: 20px/700` |
| **"Finalizar"** | `EM_ANDAMENTO` | `--status-success` bg, branco | `height: 72px`, `width: 100%`, `font: 20px/700` |
| **"Pausar"** | `EM_ANDAMENTO` | `--status-warning` outline, `border: 2px` | `height: 56px`, `width: 100%`, `font: 16px/600` |
| **"Cancelar"** | `EM_ANDAMENTO` | `--color-neutral` outline, `border: 1px` | `height: 48px`, `width: 100%`, `font: 14px/500` |

> **Hierarquia visual intencional:** Finalizar é o maior e mais proeminente. Pausar é secundário. Cancelar é terciário e discreto — evita toques acidentais.

### 4.4 Fila Informativa (Footer)

Lista compacta das **próximas 2 demandas** na fila. Somente leitura, sem ações.

| Propriedade | Valor |
|---|---|
| **Card** | Compacto, `height: 56px`, `border-radius: 8px`, `--color-background` |
| **Conteúdo** | Serviço + Localização — `14px`, `--color-text-secondary` |
| **Interatividade** | Nenhuma — cards não são clicáveis |
| **Separador** | Label "Próximas na fila" — `12px/600`, `--color-text-muted`, UPPERCASE |

---

## 5. Tela de Fila Vazia

Exibida quando não há demandas atribuídas ao operador.

```
┌──────────────────────────┐
│  HEADER                  │
│  🟢 Turno Ativo   [⚙]  │
├──────────────────────────┤
│                          │
│                          │
│         ☕               │
│                          │
│   "Sem demandas          │
│    no momento"           │
│                          │
│   Aguardando novas       │
│   solicitações...        │
│                          │
│                          │
│                          │
└──────────────────────────┘
```

| Elemento | Estilo |
|---|---|
| **Ícone** | Ilustração de "espera" (ícone leve), `80px`, `--color-neutral-light` |
| **Título** | "Sem demandas no momento" — `20px/600`, `--color-text-primary` |
| **Subtítulo** | "Aguardando novas solicitações..." — `16px/400`, `--color-text-secondary` |

---

## 6. Notificação de Nova Demanda

### 6.1 Cenário A — Fila Vazia (Pop-up Full-Screen)

```
┌──────────────────────────┐
│  ████████████████████████│
│  ██ OVERLAY ESCURO █████│
│  ████████████████████████│
│  ┌────────────────────┐  │
│  │                    │  │
│  │   🔔 NOVA DEMANDA │  │
│  │                    │  │
│  │   Escavação        │  │
│  │   Quadra 12/Lote 3 │  │
│  │                    │  │
│  │  ┌──────────────┐  │  │
│  │  │              │  │  │
│  │  │ INICIAR AGORA│  │  │
│  │  │              │  │  │
│  │  └──────────────┘  │  │
│  │                    │  │
│  │  ┌──────────────┐  │  │
│  │  │ INICIAR      │  │  │
│  │  │ DEPOIS       │  │  │
│  │  └──────────────┘  │  │
│  │                    │  │
│  └────────────────────┘  │
└──────────────────────────┘
```

| Elemento | Estilo |
|---|---|
| **Overlay** | `rgba(0,0,0,0.7)` — bloqueia interação com fundo |
| **Card** | `--color-surface`, `border-radius: 16px`, `shadow-lg`, centralizado |
| **Alerta** | 🔔 Vibração + alerta sonoro disparados pelo dispositivo |
| **Serviço** | `22px/700`, `--color-text-primary` |
| **Localização** | `16px/400`, `--color-text-secondary` |
| **"Iniciar Agora"** | `--status-success` bg, branco, `height: 64px`, `font: 18px/700` |
| **"Iniciar Depois"** | Outline, `--color-neutral`, `height: 48px`, `font: 16px/500` |

> **Sem botão de recusa.** Cancelamento segue o fluxo padrão (`REQ-FUNC-009`).

### 6.2 Cenário B — Fila com Demandas Ativas

- **Nenhum pop-up exibido**
- Nova demanda entra diretamente na fila, reordenada pelo motor de score
- A seção "Próximas na fila" atualiza silenciosamente

---

## 7. Modal de Pausa (`REQ-FUNC-011`)

Acionado pelo botão "Pausar" durante `EM_ANDAMENTO`.

```
┌──────────────────────────┐
│                          │
│  "Pausar Demanda"        │
│                          │
│  Motivo da Pausa *       │
│  ┌────────────────────┐  │
│  │ Selecione...    ▾  │  │
│  └────────────────────┘  │
│  • Quebra de equipamento │
│  • Condição climática    │
│  • Falta de material     │
│  • Outros                │
│                          │
│  Observação (se Outros)  │
│  ┌────────────────────┐  │
│  │                    │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ CONFIRMAR PAUSA    │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │     VOLTAR         │  │
│  └────────────────────┘  │
│                          │
└──────────────────────────┘
```

| Elemento | Estilo |
|---|---|
| **Motivo** | Dropdown obrigatório com opções pré-definidas |
| **Observação** | Textarea (obrigatório se "Outros") |
| **Confirmar** | `--status-warning` bg, branco, `width: 100%` |
| **Voltar** | Outline, `--color-neutral`, `width: 100%` |

---

## 8. Modal de Cancelamento (Operador)

Similar ao do empreiteiro, com justificativa obrigatória (≥10 caracteres).

| Elemento | Estilo |
|---|---|
| **Título** | "Cancelar Demanda" — `18px/600` |
| **Justificativa** | Textarea, obrigatória, `min-length: 10` |
| **Confirmar** | `--status-danger` bg, branco, habilitado após ≥10 chars |
| **Voltar** | Outline, `--color-neutral` |

> **DEC-013:** Justificativa obrigatória para trilha auditável (`REQ-ACE-006`).

---

## 9. State-to-UI Mapping (Operador)

| Estado | Card Ativo | Botões Visíveis | Fila |
|---|---|---|---|
| `PENDENTE` (próxima) | Card expandido | "Cheguei ao Local" | Próximas 2 abaixo |
| `EM_ANDAMENTO` | Card expandido (borda verde) | "Finalizar", "Pausar", "Cancelar" | Próximas 2 abaixo |
| `PAUSADA` | Card com borda amarela, motivo exibido | "Retomar" (volta a `EM_ANDAMENTO`) | Fila recalculada |
| Fila vazia | Tela de espera | Nenhum | — |

---

## 10. Acessibilidade e Ergonomia de Campo

| Critério | Implementação |
|---|---|
| **Botões gigantes** | Mín. `height: 56px` para ações principais (72px para primárias) |
| **Alto contraste** | Texto escuro sobre fundo claro, badges com bordas reforçadas |
| **Luvas** | Touch targets de `64px+` para ações críticas |
| **Sol direto** | Cores high-contrast, sem gradientes sutis que desaparecem sob luz |
| **Vibração** | Alertas com multi-sensorial (som + vibração + visual) |
| **Offline** | Banner persistente "Sem Conexão" no header + offline queue ativo |
