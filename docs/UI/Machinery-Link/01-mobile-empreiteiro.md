# Tela: Mobile do Empreiteiro — Criação de Demandas

**Aplicação:** Machinery Link (Módulo)
**Device:** Mobile
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-JOR-001`, `REQ-FUNC-001`, `REQ-FUNC-008`, `REQ-ACE-006`
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.1](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/02-modelo-dados.md`](../../SPEC/02-modelo-dados.md)
→ SPEC: [`docs/SPEC/03-fila-scoring-estados-sla.md`](../../SPEC/03-fila-scoring-estados-sla.md)

---

## 1. Objetivo

Permitir ao empreiteiro solicitar maquinário no campo de forma ágil, com o mínimo de digitação possível, acompanhar o estado das suas demandas e cancelar solicitações pendentes.

---

## 2. Layout Principal — "Minhas Solicitações"

```
┌──────────────────────────┐
│  HEADER                  │
│  "Minhas Solicitações"   │
│                    [👤]  │
├──────────────────────────┤
│                          │
│  ┌────────────────────┐  │
│  │ 🔵 Pendente        │  │
│  │ Escavação — Q12/L3 │  │
│  │ 14:32         [✕]  │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 🟢 Em Andamento    │  │
│  │ Terraplanagem —    │  │
│  │ Q08/L1             │  │
│  │ 13:15              │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 🟡 Pausada         │  │
│  │ Movimentação —     │  │
│  │ Q05/L7 → Q12/L2   │  │
│  │ 11:40              │  │
│  └────────────────────┘  │
│                          │
│                          │
│               ┌──────┐   │
│               │  +   │   │
│               │ FAB  │   │
│               └──────┘   │
├──────────────────────────┤
│  [🏠] [📋] [📊] [👤]   │
│  BOTTOM NAV              │
└──────────────────────────┘
```

---

## 3. Componentes

### 3.1 Header

| Elemento | Descrição |
|---|---|
| **Título** | "Minhas Solicitações" — `20px/600`, `--color-text-primary` |
| **Avatar** | Ícone de perfil do empreiteiro, `40px`, border-radius `full` |
| **Background** | `--color-surface` com `shadow-sm` na borda inferior |

### 3.2 Cards de Demanda

Cada demanda ativa é renderizada como um card:

| Propriedade | Valor |
|---|---|
| **Background** | `--color-surface` |
| **Border** | `1px solid --color-surface-border`, radius `12px` |
| **Shadow** | `shadow-md` |
| **Padding** | `16px` |
| **Gap entre cards** | `12px` |

**Conteúdo do card:**

| Elemento | Estilo | Notas |
|---|---|---|
| **Status Badge** | Pill badge com cores semânticas (ver tabela abaixo) | Topo esquerdo |
| **Serviço** | `16px/600`, `--color-text-primary` | Nome do serviço solicitado |
| **Localização** | `14px/400`, `--color-text-secondary` | Quadra/Lote ou Local Externo |
| **Timestamp** | `12px/400`, `--color-text-muted` | Hora da criação |
| **Botão Cancelar** | Ícone `✕`, `--color-neutral`, `32x32px` | **Apenas** em demandas `PENDENTE` de autoria própria |

### 3.3 FAB — "Nova Demanda"

| Propriedade | Valor |
|---|---|
| **Posição** | Fixed, `bottom: 88px`, `right: 24px` (acima do bottom nav) |
| **Tamanho** | `56x56px` |
| **Background** | `--color-primary` (`#ad0f0a`) |
| **Ícone** | `+` branco, `24px`, `stroke: 2px` |
| **Shadow** | `shadow-lg` |
| **Hover/Pressed** | `--color-primary-hover`, scale `1.05` |

### 3.4 Bottom Navigation

| Item | Ícone | Label | Rota |
|---|---|---|---|
| Início | 🏠 | Início | `/` |
| Solicitações | 📋 | Solicitar | `/minhas` (ativo) |
| Status | 📊 | Status | `/historico` |
| Perfil | 👤 | Perfil | `/perfil` |

**Estilo:**
- Background: `--color-surface`
- Item ativo: `--color-primary` (ícone + label)
- Item inativo: `--color-neutral`
- Height: `64px`
- Border top: `1px solid --color-surface-border`

---

## 4. Formulário de Nova Demanda (BottomSheet)

Acionado pelo FAB. Abre como **BottomSheet modal** (60-90% da viewport height).

```
┌──────────────────────────┐
│  ─── (drag handle)       │
│                          │
│  "Nova Demanda"    [✕]   │
│                          │
│  Serviço                 │
│  ┌────────────────────┐  │
│  │ Selecione...    ▾  │  │
│  └────────────────────┘  │
│                          │
│  Maquinário              │
│  ┌────────────────────┐  │
│  │ Selecione...    ▾  │  │
│  └────────────────────┘  │
│                          │
│  Localização (Origem)    │
│  [Quadra/Lote] [Local ↔] │
│  ┌────────────────────┐  │
│  │ Quadra: ▾  Lote: ▾ │  │
│  └────────────────────┘  │
│                          │
│  Urgência                │
│  (●) O mais rápido       │
│  ( ) Agendar para...     │
│  ┌────────────────────┐  │
│  │ 📅 Data e hora     │  │
│  └────────────────────┘  │
│                          │
│  Material (opcional)     │
│  ┌────────────────────┐  │
│  │ Selecione...    ▾  │  │
│  └────────────────────┘  │
│                          │
│  Destino (condicional)   │
│  ┌────────────────────┐  │
│  │ Quadra: ▾  Lote: ▾ │  │
│  └────────────────────┘  │
│  ☐ Transporte Interno    │
│                          │
│  Descrição (opcional)    │
│  ┌────────────────────┐  │
│  │                    │  │
│  │                    │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │    SOLICITAR        │  │
│  └────────────────────┘  │
│                          │
└──────────────────────────┘
```

### Campos do Formulário

| Campo | Tipo | Obrigatório | Lógica |
|---|---|---|---|
| **Serviço** | Dropdown searchable | ✅ | Lista de serviços cadastrados. Filtra maquinários compatíveis |
| **Maquinário** | Dropdown searchable | ✅ | Filtrado por `TipoMaquinario` compatível com serviço selecionado |
| **Localização (Origem)** | Toggle Quadra/Lote ↔ Local Externo | ✅ | Alternância simples entre os dois modos |
| **Urgência** | Radio: ASAP / Agendar | ✅ | Default: ASAP. Se agendar → DateTimePicker |
| **Material** | Dropdown | — | Catálogo de materiais. Alimenta `fator_material` no score |
| **Destino** | Quadra/Lote (aparece se `exigeTransporte=true`) | Condicional | Obrigatório quando serviço exige transporte |
| **Transporte Interno** | Checkbox | — | Auto-preenche destino = origem |
| **Descrição** | Textarea | — | Campo livre, recomendado para movimentação |

### Validação (zod via react-hook-form)

| Regra | Mensagem |
|---|---|
| Serviço não selecionado | "Selecione um serviço" |
| Maquinário não selecionado | "Selecione um maquinário" |
| Localização não preenchida | "Informe a localização" |
| Destino obrigatório (exigeTransporte) e vazio | "Este serviço exige destino. Informe Quadra/Lote de destino ou marque Transporte Interno" |
| Data agendada no passado | "A data deve ser futura" |

### Botão "Solicitar"

- **Background:** `--color-primary` (`#ad0f0a`)
- **Texto:** "SOLICITAR" — `16px/700`, branco
- **Width:** `100%`, height `48px`
- **Loading:** Spinner + "Enviando..."
- **Sucesso:** Toast _"Demanda criada com sucesso!"_ + fecha BottomSheet + card aparece na lista

---

## 5. Modal de Cancelamento

Acionado pelo ícone `✕` nos cards `PENDENTE` de autoria própria.

```
┌──────────────────────────┐
│                          │
│  "Cancelar Demanda"      │
│                          │
│  Demanda #142            │
│  Escavação — Q12/L3      │
│                          │
│  Justificativa *         │
│  ┌────────────────────┐  │
│  │                    │  │
│  │                    │  │
│  └────────────────────┘  │
│  Mínimo 10 caracteres    │
│                          │
│  ┌────────────────────┐  │
│  │ CONFIRMAR CANCEL.  │  │
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
| **Título** | "Cancelar Demanda" — `18px/600` |
| **Resumo** | ID + Serviço + Localização — `14px`, `--color-text-secondary` |
| **Justificativa** | Textarea, `min-length: 10`, contador de caracteres |
| **Botão Confirmar** | `--status-danger` (`#D32F2F`), branco, `width: 100%` — habilitado somente com ≥10 chars |
| **Botão Voltar** | Outline, `--color-neutral`, `width: 100%` |

> **DEC-013:** Justificativa obrigatória (mín. 10 caracteres), exigência de trilha auditável (`REQ-ACE-006`).

---

## 6. State-to-UI Mapping (Empreiteiro)

| Estado | Badge | Cor | Ações Disponíveis |
|---|---|---|---|
| `AGENDADA` | "Agendada" | `--status-info` | Cancelar (se autoria própria) |
| `PENDENTE` | "Pendente" | `--status-info` | Cancelar (se autoria própria) |
| `EM_ANDAMENTO` | "Em Andamento" | `--status-success` | Nenhuma |
| `PAUSADA` | "Pausada" | `--status-warning` | Nenhuma |
| `RETORNADA` | "Retornando" | `--status-warning` | Nenhuma |
| `CONCLUIDA` | "Concluída" | `--status-success` | Move para histórico |
| `CANCELADA` | "Cancelada" | `--status-danger` | Remove da lista ativa (Toast) |

---

## 7. Acessibilidade Mobile

| Critério | Implementação |
|---|---|
| **Touch targets** | Mínimo `48x48px` em todos os botões e inputs |
| **Font size** | Mínimo `16px` em inputs (previne zoom iOS) |
| **FAB contrast** | Branco sobre `#ad0f0a` — ratio 9.2:1 ✅ |
| **Swipe gestures** | BottomSheet com drag handle nativo (não obrigatório) |
| **Offline** | Banner de status offline visível no header quando sem conexão |
