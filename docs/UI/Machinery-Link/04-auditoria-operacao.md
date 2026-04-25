# Tela: Auditoria e Histórico Operacional

**Aplicação:** Machinery Link (Módulo)
**Device:** Desktop (≥ 1280px)
**Design System:** [UI-DESIGN.md](../UI-DESIGN.md)

**Rastreio PRD:** `REQ-JOR-005`, `REQ-FUNC-009`, `REQ-FUNC-011`, `REQ-FUNC-014`, `REQ-ACE-004`, `REQ-ACE-010`
→ SPEC: [`docs/SPEC/07-design-ui-logica.md` §1.3](../../SPEC/07-design-ui-logica.md)
→ SPEC: [`docs/SPEC/03-fila-scoring-estados-sla.md`](../../SPEC/03-fila-scoring-estados-sla.md)
→ SPEC: [`docs/SPEC/04-rbac-permissoes.md`](../../SPEC/04-rbac-permissoes.md)

---

## 1. Objetivo

Registro completo e imutável do histórico operacional da obra. Consolida todas as demandas encerradas (`CONCLUIDA`, `CANCELADA`, `NAO_EXECUTADA`, `RETORNADA`) e exibe a trilha de auditoria com ator, justificativa e timestamp para cada evento gerencial — conforme exige `REQ-ACE-004`. Permite exportação para análise de cobertura e SLA. Acesso restrito a perfis gerenciais; `Board` acessa em modo somente leitura.

---

## 2. Layout

```
┌────────────────────────────────────────────────────────────────────────────┐
│  APP SHELL — TOP BAR                                                       │
│  Logo FGR Ops   [Machinery Link]    [Obra: Site Alpha ▾]    [👤 Admin ▾]  │
├────────┬───────────────────────────────────────────────────────────────────┤
│        │  BREADCRUMB: FGR Ops > Machinery Link > Auditoria                 │
│  SIDE  ├──────────────────────────────────────────────────────────────────┤
│  BAR   │  TOP TOOLBAR                                                      │
│        │  ┌──────────────┐ ┌──────────┐ ┌──────────┐ ┌────────────────┐  │
│  ┌──┐  │  │ 📅 Período ▾ │ │ Setor  ▾ │ │ Estado ▾ │ │ 🔍 Buscar...  │  │
│  │📋│  │  └──────────────┘ └──────────┘ └──────────┘ └────────────────┘  │
│  │Fi│  │  [Dia anterior ☐]  [Apenas com justificativa ☐]   [⬇ Exportar]  │
│  │la│  ├──────────────────────────────────────────────────────────────────┤
│  └──┘  │                                                                  │
│        │  TABS                                                            │
│  ┌──┐  │  [Histórico de Demandas ●]  [Trilha de Auditoria]  [Rollover]   │
│  │📊│  ├──────────────────────────────────────────────────────────────────┤
│  │Da│  │                                                                  │
│  │sh│  │  TABELA DE DEMANDAS ENCERRADAS                                   │
│  └──┘  │  ┌──────┬──────────┬───────────┬──────────┬────────┬──────────┐ │
│        │  │  ID  │  Estado  │  Serviço  │  Local   │Operador│  Fechado │ │
│  ┌──┐  │  ├──────┼──────────┼───────────┼──────────┼────────┼──────────┤ │
│  │📝│  │  │ #142 │ ✅ CONC. │ Escavação │ Q14/L2  │ José S.│ 14:32    │ │
│  │Au│  │  │ #140 │ ❌ CANC. │ Nivelam.  │ Q08/L5  │   —    │ 13:10    │ │
│  │di│  │  │ #138 │ 🔄 ROLL. │ Transporte│ Q02/L1  │   —    │ 07:55    │ │
│  │t │  │  └──────┴──────────┴───────────┴──────────┴────────┴──────────┘ │
│  └──┘  │                                                                  │
│        │  [< Anterior]                            5 de 12 pág. [Próxima >]│
└────────┴──────────────────────────────────────────────────────────────────┘
```

---

## 3. Componentes

### 3.1 Sidebar (Navegação do Módulo)

Herda do App Shell. Item **Auditoria** ativo:

| Item | Ícone | Rota | Perfis |
|---|---|---|---|
| **Fila de Demandas** | 📋 | `/machinery-link/fila` | AdminOperacional, UsuarioInternoFGR |
| **Dashboard** | 📊 | `/machinery-link/dashboard` | AdminOperacional, UsuarioInternoFGR, Board |
| **Auditoria** | 📝 | `/machinery-link/auditoria` | AdminOperacional, UsuarioInternoFGR, Board |
| **Operadores** | 👷 | `/machinery-link/operadores` | AdminOperacional, UsuarioInternoFGR |

### 3.2 Top Toolbar

| Elemento | Tipo | Descrição |
|---|---|---|
| **Período** | Date range picker | Filtra por `encerradoEm` — padrão: dia atual |
| **Setor** | Dropdown multi-select | Filtra por `SetorOperacional` |
| **Estado** | Dropdown | CONCLUIDA, CANCELADA, NAO_EXECUTADA, RETORNADA |
| **Busca** | Input text | Busca por ID, serviço ou operador |
| **Dia anterior** | Checkbox | Filtra demandas com `rolloverDe` preenchido (badge "Dia anterior") |
| **Apenas com justificativa** | Checkbox | Filtra demandas com entrada de log gerencial |
| **Exportar** | Botão secundário | Exporta tabela filtrada em CSV/Excel |

**Permissão de exportação:** `machinery:demanda:export` → SuperAdmin, Board, AdminOperacional, UsuarioInternoFGR.

### 3.3 Tabs de Conteúdo

| Tab | Conteúdo |
|---|---|
| **Histórico de Demandas** | Tabela de demandas encerradas com filtros |
| **Trilha de Auditoria** | Log de eventos gerenciais com ator e justificativa |
| **Rollover** | Demandas redistribuídas do dia anterior por expediente |

---

### 3.4 Tab: Histórico de Demandas

Tabela paginada (20 itens/página) de todas as demandas no estado terminal.

| Coluna | Largura | Conteúdo |
|---|---|---|
| **ID** | `80px` | `#142` — clicável para detalhe |
| **Estado** | `130px` | Badge colorido com ícone |
| **Serviço** | `flex` | Nome do serviço + tipo de maquinário |
| **Localização** | `150px` | Quadra/Lote ou Local Externo |
| **Operador** | `150px` | Nome (ou `—` se cancelada sem execução) |
| **Empreiteiro** | `150px` | Nome do solicitante |
| **Duração** | `100px` | Tempo total entre abertura e encerramento |
| **Fechado em** | `130px` | Timestamp + data |
| **Ações** | `60px` | Ícone 👁 para expandir trilha do registro |

**Cores por estado:**

| Estado | Badge | Borda esquerda da linha |
|---|---|---|
| `CONCLUIDA` | Verde ✅ | `--status-success` |
| `CANCELADA` | Vermelho ❌ | `--status-danger` |
| `NAO_EXECUTADA` | Cinza ⏸ | `--color-neutral` |
| `RETORNADA` (histórico) | Laranja 🔄 | `--status-warning` |

**Badge "Dia anterior":** demandas com `rolloverDe` preenchido exibem badge compacto `#tag` azul em cinza claro (`--status-info-bg`) junto ao ID.

---

### 3.5 Tab: Trilha de Auditoria

Log cronológico reverso de **todos** os eventos registrados em `DemandaLog` com justificativa gerencial (`REQ-ACE-004`).

```
┌──────────────────────────────────────────────────────────────────────────┐
│  📝 TRILHA DE AUDITORIA                                                  │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │ 14:45 · Demanda #142 · CANCELADA → CANCELADA                       │ │
│  │ Ator: Admin João Silva (AdminOperacional)                           │ │
│  │ Justificativa: "Maquinário em manutenção não programada"            │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │ 07:55 · Demanda #138 · EM_ANDAMENTO → RETORNADA                    │ │
│  │ Ator: SISTEMA (worker expedienteFim)                                │ │
│  │ Justificativa: "Fim de expediente — rollover automático"            │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

| Coluna | Conteúdo |
|---|---|
| **Timestamp** | `HH:mm` + data completa no tooltip |
| **Demanda** | ID clicável |
| **Transição** | `ESTADO_ANTERIOR → ESTADO_NOVO` |
| **Ator** | Nome + perfil (ou `SISTEMA` para workers automáticos) |
| **Justificativa** | Texto completo da justificativa registrada |

**Eventos exibidos:** cancelamentos administrativos, devoluções (`devolver`), alocações manuais (Blindagem), pausas com justificativa, rollover por fim de expediente.

---

### 3.6 Tab: Rollover

Visão consolidada dos fechamentos de expediente com detalhe do rollover inter-dias (`REQ-FUNC-014`, `REQ-ACE-010`).

| Coluna | Conteúdo |
|---|---|
| **Data do Expediente** | Dia em que ocorreu o fechamento |
| **Demandas PENDENTE** | Contagem mantidas no rollover (SLA resetado para D+1) |
| **Demandas EM_ANDAMENTO** | Contagem devolvidas via `devolver_fim_expediente` |
| **Total Rolado** | Total de demandas redistribuídas |
| **Detalhes** | Link para filtrar "Dia anterior" no Histórico de Demandas |

---

## 4. Painel de Detalhe da Demanda (Drawer)

Clicar no ícone 👁 ou no ID abre um `Sheet` (drawer lateral) com o histórico completo de uma demanda.

```
┌──────────────────────────────────────────────┐
│  DEMANDA #142                          [✕]   │
│  Serviço: Escavação de Fundação               │
│  Maquinário: Retroescavadeira                 │
│  Local: Quadra 14 / Lote 2                    │
│  Empreiteiro: Carlos Mendes                   │
│  ─────────────────────────────────────────── │
│  LINHA DO TEMPO                               │
│  ● 10:15 PENDENTE          (abertura)         │
│  ● 10:42 EM_ANDAMENTO      (José S. iniciou)  │
│  ● 14:22 PAUSADA           (hidráulica)       │
│  ● 14:45 CANCELADA         (João — admin)     │
│  ─────────────────────────────────────────── │
│  Duração total: 4h30min                       │
└──────────────────────────────────────────────┘
```

---

## 5. RBAC — Controle de Acesso

| Ação | AdminOperacional | UsuarioInternoFGR | Board | SuperAdmin |
|---|---|---|---|---|
| **Visualizar histórico** | ✅ | ✅ | ✅ (somente leitura) | ✅ |
| **Visualizar trilha de auditoria** | ✅ | ✅ | ✅ (somente leitura) | ✅ |
| **Exportar** | ✅ | ✅ | ✅ | ✅ |
| **Filtrar por "Dia anterior"** | ✅ | ✅ | ✅ | ✅ |

`Board` não visualiza o botão de exportação se a permissão cruzada não for necessária; a renderização usa o hook `usePermission('machinery:demanda:export')`.

---

## 6. Estados da Tela

| Estado | Comportamento |
|---|---|
| **Sem demandas no período** | Ilustração + mensagem: _"Nenhuma demanda encerrada no período selecionado."_ |
| **Carregando** | Skeleton nas linhas da tabela (5 linhas placeholder) |
| **Erro de rede** | Banner inline: _"Falha ao carregar histórico. Tente novamente."_ + botão retry |
| **Exportação em andamento** | Botão com spinner + _"Gerando arquivo…"_ |

---

## 7. Responsividade

| Breakpoint | Comportamento |
|---|---|
| **≥ 1280px** | Tabela completa com todas as colunas |
| **1024–1279px** | Colunas Duração e Empreiteiro ocultadas; demais com scroll |
| **< 1024px** | Sidebar collapsa; tabela compacta com 4 colunas; detalhe em modal |
