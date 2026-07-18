# Tela: Configurações da Obra

**Aplicação:** Machinery Link (Módulo)
**Device:** Desktop (≥ 1280px) / Mobile (parcial)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-FUNC-001`, `REQ-FUNC-002`, `REQ-FUNC-003`
→ SPEC: [`docs/SPEC/01-modulos-plataforma.md` §Bootstrapping-de-obra](../../SPEC/01-modulos-plataforma.md)
→ SPEC: [`docs/SPEC/01-modulos-plataforma.md` §Sequência-canônica](../../SPEC/01-modulos-plataforma.md)
→ SPEC: [`docs/SPEC/03-fila-scoring-estados-sla.md`](../../SPEC/03-fila-scoring-estados-sla.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)

---

## 1. Objetivo

Tela de setup operacional da obra, acessível ao `AdminOperacional` dentro do módulo Machinery Link (escopo `tenant-scoped` por `obraId`). Agrupa em três domínios os cadastros necessários para a sequência canônica de bootstrapping (SPEC/01 §Bootstrapping): **Malha Espacial** (passos #4–#9), **Catálogos** (passos #10–#14) e **Parâmetros** (passo #18). Os cadastros de usuários de campo (Empreiteiras, Operadores, Empreiteiros, Ajudantes — passos #13–#17) estão na tela [`08-gestao-acessos.md`](./08-gestao-acessos.md).

> **Contexto arquitetural:** Esta tela pertence ao escopo do **Machinery Link** (tenant-scoped). O cadastro da `Obra` em si e a ativação do módulo são feitos pelo `SuperAdmin` via FGR Ops ([`docs/UI/FGR-Ops/03-crud-obras.md`](../FGR-Ops/03-crud-obras.md)).

---

## 2. Layout

### 2.1 Estrutura Geral

```
┌────────────────────────────────────────────────────────────────────────────┐
│  APP SHELL — TOP BAR                                                       │
│  Logo FGR Ops   [Machinery Link]    [Obra: Site Alpha ▾]    [👤 Admin ▾]  │
├────────┬───────────────────────────────────────────────────────────────────┤
│        │  BREADCRUMB: FGR Ops > Machinery Link > Configurações             │
│  SIDE  ├──────────────────────────────────────────────────────────────────┤
│  BAR   │                                                                  │
│        │  TABS DE DOMÍNIO                                                 │
│  ┌──┐  │  [🗺 Malha Espacial ●]  [📦 Catálogos]  [⚙ Parâmetros]          │
│  │📋│  │  ──────────────────────────────────────────────────────────────  │
│  │Fi│  │                                                                  │
│  │la│  │  SUB-NAVEGAÇÃO (Malha Espacial)                                  │
│  └──┘  │  [Setores] [Quadras] [Lotes] [Adjacências] [Locais Externos]     │
│        │  ──────────────────────────────────────────────────────────────  │
│  ┌──┐  │                                                                  │
│  │📊│  │  TABELA / FORMULÁRIO DO ITEM SELECIONADO                         │
│  │Da│  │  (ver detalhes por domínio nas seções abaixo)                    │
│  │sh│  │                                                                  │
│  └──┘  │                                                                  │
│        │                                                                  │
│  ┌──┐  │                                                                  │
│  │⚙│  │                                                                  │
│  │Cf│  │                                                                  │
│  └──┘  │                                                                  │
└────────┴──────────────────────────────────────────────────────────────────┘
```

---

## 3. Componentes

### 3.1 Sidebar (Navegação do Módulo)

Item **Configurações** ativo:

| Item | Ícone | Rota | Perfis |
|---|---|---|---|
| **Fila de Demandas** | 📋 | `/machinery-link/fila` | AdminOperacional, UsuarioInternoFGR |
| **Dashboard** | 📊 | `/machinery-link/dashboard` | AdminOperacional, UsuarioInternoFGR, Board |
| **Auditoria** | 📝 | `/machinery-link/auditoria` | AdminOperacional, UsuarioInternoFGR, Board |
| **Operadores** | 👷 | `/machinery-link/operadores` | AdminOperacional, UsuarioInternoFGR |
| **Configurações** | ⚙ | `/machinery-link/configuracoes` | AdminOperacional, SuperAdmin |
| **Acessos** | 👥 | `/machinery-link/acessos` | AdminOperacional, SuperAdmin |

### 3.2 Tabs de Domínio

| Tab | Domínio | Itens gerenciados |
|---|---|---|
| **🗺 Malha Espacial** | Estrutura territorial da obra | Setor, Quadra, Lote, LoteAdjacencia, LocalExterno |
| **📦 Catálogos** | Inventário operacional | TipoMaquinario, Servico, Maquinario, Material |
| **⚙ Parâmetros** | Regras operacionais | Expediente (rota própria, ver §6), Pesos da Fila (pós-MVP — não implementado, ver §6) |

Cada tab mantém seu próprio estado de navegação. A URL reflete a navegação: `/machinery-link/configuracoes?tab=malha&sub=setores`.

---

## 4. Domínio 1: Malha Espacial

### 4.1 Sub-aba Setores Operacionais

Passos #4 do bootstrapping. Rastreio: `core:setor-operacional:create/update/delete`.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  SETORES OPERACIONAIS                           [+ Novo Setor]           │
│  ──────────────────────────────────────────────────────────────────────  │
│  ┌──────────────────────────────┬──────────────────┬───────────────────┐ │
│  │  Nome do Setor               │  Código          │  Ações            │ │
│  ├──────────────────────────────┼──────────────────┼───────────────────┤ │
│  │  Setor Norte                 │  SET-001         │  ✎  🗑            │ │
│  │  Setor Sul                   │  SET-002         │  ✎  🗑            │ │
│  └──────────────────────────────┴──────────────────┴───────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

**Formulário de Setor:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome | `input[type=text]` | Obrigatório, único por obra |
| Código | `input[type=text]` | Obrigatório, único por obra |
| Descrição | `textarea` | Opcional |

### 4.2 Sub-aba Quadras

Passo #6. Cada Quadra pertence a um `SetorOperacional`. Rastreio: `core:quadra:create/update/delete`.

**Formulário de Quadra:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome / Código | `input[type=text]` | Obrigatório, único por obra |
| Setor Operacional | Dropdown (`SetorOperacional`) | Obrigatório — dependência #4 |
| Rua (opcional) | Dropdown (`Rua`) | Opcional — dependência #5 |

### 4.3 Sub-aba Lotes

Passo #7. Cada Lote pertence a uma `Quadra`. Rastreio: `core:lote:create/update/delete`.

**Formulário de Lote:**

| Campo | Tipo | Validação |
|---|---|---|
| Código do Lote | `input[type=text]` | Obrigatório, único por Quadra |
| Quadra | Dropdown (`Quadra`) | Obrigatório — dependência #6 |

### 4.4 Sub-aba Adjacências

Passo #8. Define contiguidade entre Lotes para o cálculo de `fator_adjacencia`. Rastreio: `core:lote-adjacencia:create/delete`.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  ADJACÊNCIAS DE LOTES                          [+ Nova Adjacência]       │
│  ──────────────────────────────────────────────────────────────────────  │
│  Lote A           Lote B             Distância (m)      Ações            │
│  Q14/L1    ↔     Q14/L2            15 m               🗑                 │
│  Q14/L2    ↔     Q14/L3            20 m               🗑                 │
│  ──────────────────────────────────────────────────────────────────────  │
│  ⓘ Adjacências ausentes degradam a qualidade da priorização automática,  │
│     mas não bloqueiam criação de demandas (SPEC/01 §Regras de Integridade)│
└──────────────────────────────────────────────────────────────────────────┘
```

**Formulário de Adjacência:**

| Campo | Tipo | Validação |
|---|---|---|
| Lote A | Dropdown searchable | Obrigatório |
| Lote B | Dropdown searchable | Obrigatório, diferente de Lote A |
| Distância (m) | `input[type=number]` | Opcional, numérico positivo |

### 4.5 Sub-aba Locais Externos

Passo #9. Portaria, Pulmão, Garagem e demais locais fora da malha de lotes. Rastreio: sem permissão específica — coberto por `core:setor-operacional`.

**Formulário de Local Externo:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome | `input[type=text]` | Obrigatório, único por obra |
| Tipo | Dropdown (Portaria, Pulmão, Garagem, Outro) | Obrigatório |
| Setor Operacional | Dropdown (`SetorOperacional`) | Obrigatório |

---

## 5. Domínio 2: Catálogos

### 5.1 Sub-aba Tipos de Maquinário

Passo #10. Catálogo global (reutilizado entre obras). Rastreio: `machinery:tipo-maquinario:create/update/delete`.

**Formulário:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome | `input[type=text]` | Obrigatório, único globalmente |
| Descrição | `textarea` | Opcional |

> **Nota:** `TipoMaquinario` é um catálogo global — modificações afetam todas as obras. Aviso visual ao editar ou excluir item com registros vinculados.

### 5.2 Sub-aba Serviços

Passo #11. Serviços vinculados a `TipoMaquinario`. Rastreio: `machinery:servico:create/update/delete`.

**Formulário:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome do Serviço | `input[type=text]` | Obrigatório |
| Tipo de Maquinário | Dropdown (`TipoMaquinario`) | Obrigatório — dependência #10 |
| Exige Transporte | Toggle `exigeTransporte` | Quando ativo, torna Destino obrigatório na abertura de Demanda |

**Badge `exigeTransporte`:** serviços com flag ativa exibem badge 🚛 na tabela, sinalizando que a demanda vai exigir campo de Destino.

### 5.3 Sub-aba Maquinários

Passo #14. Instâncias físicas, vinculadas à obra e ao `TipoMaquinario`. Rastreio: `machinery:maquinario:create/update/delete`.

**Formulário:**

| Campo | Tipo | Validação |
|---|---|---|
| Identificador / Placa | `input[type=text]` | Obrigatório, único por obra |
| Tipo de Maquinário | Dropdown (`TipoMaquinario`) | Obrigatório — dependência #10 |
| Propriedade | Radio: FGR / Empreiteira | Obrigatório |
| Empreiteira | Dropdown (`Empreiteira`) | Obrigatório se propriedade = Empreiteira — dependência #13 |
| Status | Toggle Ativo/Inativo | Maquinários inativos não entram na fila |

### 5.4 Sub-aba Materiais

Passo #12. Catálogo de materiais da obra, para `fator_material` do score. Rastreio: `machinery:material:create/update/delete`.

**Formulário:**

| Campo | Tipo | Validação |
|---|---|---|
| Nome do Material | `input[type=text]` | Obrigatório |
| Nível de Risco | Dropdown (Baixo, Médio, Alto) | Determina `fator_material` no score |
| Descrição | `textarea` | Opcional |

---

## 6. Domínio 3: Parâmetros Operacionais

Passo #18. **Amendment 2026-07-16 (DEC-050, `REQ-FUNC-004`):** a tela real (`apps/web/src/routes/machinery-link/$obra/configuracoes/expediente.tsx`) vive em rota própria (item **"Expediente"** no grupo "Configurações" da sidebar do módulo, `/machinery-link/$obra/configuracoes/expediente`), não como sub-aba de uma tela de "Parâmetros" tabulada — o mockup abaixo é atualizado para os 4 campos reais e o switch tudo-ou-nada; a estrutura de tabs/sidebar do resto do arquivo (§2, §3) não foi revisitada nesta amenda (fora do escopo). **Pesos da fila (`W_adj`/`W_srv`/`W_mat`) são pós-MVP** — não há UI de configuração deles; o motor usa os pesos fixos 50/30/20 (`SPEC/03`).

```
┌──────────────────────────────────────────────────────────────────────────┐
│  EXPEDIENTE                                                              │
│  ──────────────────────────────────────────────────────────────────────  │
│  [✓] Controle de expediente ativo                                        │
│                                                                          │
│  Início do Expediente *    Fim do Expediente *                           │
│  ┌──────────────────┐      ┌──────────────────┐                         │
│  │  07:00           │      │  17:00           │                         │
│  └──────────────────┘      └──────────────────┘                         │
│                                                                          │
│  Tolerância de hora extra                                                │
│  Horas ┌──────┐   Minutos ┌──────┐                                       │
│        │  1   │           │  30  │                                       │
│        └──────┘           └──────┘                                       │
│                                                                          │
│  Dias ativos                                                             │
│  [✓]Seg [✓]Ter [✓]Qua [✓]Qui [✓]Sex [ ]Sáb [ ]Dom                       │
│                                                                          │
│                                              [ Salvar ]                  │
└──────────────────────────────────────────────────────────────────────────┘
```

Desligar o switch **"Controle de expediente ativo"** abre um diálogo de confirmação (_"Isso remove o horário, a tolerância de hora extra e os dias ativos configurados para esta obra. Deseja continuar?"_) — ao confirmar, envia os 4 campos como `null` (tudo-ou-nada, `SPEC/08`). Com o switch desligado, o formulário some e exibe apenas uma nota informativa.

**Campos de Parâmetros (`ObraConfiguracoesDto`, `SPEC/08` §`GET/PATCH /obras/:id/configuracoes`):**

| Campo | Tipo | Validação | Default (form ligado) |
|---|---|---|---|
| Início do Expediente (`expedienteInicio`) | `input[type=time]` | Obrigatório, anterior ao fim (`HH:MM`) | `07:00` |
| Fim do Expediente (`expedienteFim`) | `input[type=time]` | Obrigatório, posterior ao início; `fim + tolerância` não pode cruzar meia-noite | `17:00` |
| Tolerância de hora extra — Horas | `input[type=number]` | Inteiro 0–7 | `0` |
| Tolerância de hora extra — Minutos | `input[type=number]` | Inteiro 0–59 | `0` |
| Dias ativos (`diasAtivos`) | checkboxes Seg–Dom (ISO 1–7) | Ao menos 1 dia selecionado | `Seg, Ter, Qua, Qui, Sex` (`[1,2,3,4,5]`) |

Horas+Minutos de tolerância se combinam em `limiteHoraExtraMin` (payload) antes do envio. Validação client-side cobre formato/obrigatoriedade; a validação canônica de negócio (tudo-ou-nada, `inicio < fim`, cruzamento de meia-noite) roda no BE — erro `422` exibido via toast com a mensagem do servidor (sem reimplementação no cliente).

---

## 7. Padrão de CRUD Compartilhado

Todos os domínios seguem o mesmo padrão de interação:

| Ação | Interação | Confirmação |
|---|---|---|
| **Criar** | Botão "+ Novo X" → formulário inline ou modal | Toast de sucesso |
| **Editar** | Ícone ✎ → formulário pré-preenchido | Toast de sucesso |
| **Excluir** | Ícone 🗑 → diálogo de confirmação | Aviso se houver dependências ativas |

**Diálogo de exclusão com dependências:** quando o item tem registros vinculados (ex.: Setor com Quadras), exibir: _"Este setor possui 3 quadras vinculadas. Remova-as antes de excluir o setor."_ — botão "Confirmar" desabilitado.

---

## 8. Indicador de Completude do Bootstrapping

Banner informativo no topo da tela de Configurações exibindo o progresso mínimo para elegibilidade de criação de demandas (SPEC/01 §Regras de integridade):

```
┌──────────────────────────────────────────────────────────────────────────┐
│  ⚠ Esta obra ainda não está pronta para receber demandas.               │
│  Itens faltantes: Lote (0 cadastrados) · Parâmetros de expediente        │
│  [Ver guia de configuração]                                              │
└──────────────────────────────────────────────────────────────────────────┘
```

Quando todos os pré-requisitos mínimos estão atendidos, o banner é substituído por:

```
┌──────────────────────────────────────────────────────────────────────────┐
│  ✅ Obra pronta para operação. Demandas podem ser criadas.                │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 9. RBAC — Controle de Acesso

| Ação | AdminOperacional | SuperAdmin | UsuarioInternoFGR | Board |
|---|---|---|---|---|
| **Criar/editar/excluir Setores, Quadras, Lotes, Adjacências** | ✅ | ✅ | ✗ | ✗ |
| **Criar/editar/excluir Catálogos** | ✅ | ✅ | ✗ | ✗ |
| **Configurar Parâmetros** | ✅ | ✅ | ✗ | ✗ |
| **Visualizar Configurações (somente leitura)** | ✅ | ✅ | ✅ | ✅ |
| **Acessar sidebar "Configurações"** | ✅ | ✅ | ✗ | ✗ |

`UsuarioInternoFGR` e `Board` não veem o item "Configurações" na sidebar. A rota `/machinery-link/configuracoes` redireciona com `HTTP 403` se tentada diretamente.

---

## 10. Responsividade

| Breakpoint | Comportamento |
|---|---|
| **≥ 1280px** | Tabs horizontais + tabelas com todas as colunas |
| **1024–1279px** | Tabs horizontais com scroll; colunas de tabela reduzidas |
| **< 1024px** | Sidebar collapsa; tabs viram accordion; formulários em tela cheia |
