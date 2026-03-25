# Movimentação de concreto — empreiteiro para lote adjacente

Narrativa operacional: empreiteiro em frente de obra (concretando laje) solicita Munck para movimentar concreto restante **no mesmo contexto da obra** (mesma quadra, lote adjacente). Informa **origem** e **destino** na malha (Quadra/Lote): neste exemplo, origem Quadra 04 Lote 02 e destino Quadra 04 Lote 03. O motor de distribuição incorpora a demanda e reordena a fila do operador elegível.

**PRD fonte:** [../PRD/02-jornada-usuario.md](../PRD/02-jornada-usuario.md) (REQ-JOR-001 — material e destino em movimentação; nota sobre massas)

**Módulos SPEC relacionados:** [00-visao-arquitetura — D6 política PIN](../SPEC/00-visao-arquitetura.md#politica-autenticacao-senha), [01-modulos-plataforma](../SPEC/01-modulos-plataforma.md), [03-fila-scoring-estados-sla](../SPEC/03-fila-scoring-estados-sla.md)

**REQ-\* cobertos:** REQ-JOR-001, REQ-JOR-002, REQ-JOR-003, REQ-JOR-004

---

## Sequência (empreiteiro → sistema → operador Munck)

```mermaid
sequenceDiagram
    autonumber
    participant E as Empreiteiro
    participant App as App Machinery Link (PWA)
    participant API as FGR-OPS API
    participant M as Motor distribuição<br/>REQ-JOR-002 / REQ-JOR-003
    participant O as Operador Munck

    Note over E,App: Empreiteiro na obra, concretando laje no Lote 02 · Quadra 04
    E->>App: Login com utilizador + PIN (perfil campo)
    App->>API: Autenticação (/auth/pin)
    API-->>App: Sessão JWT válida

    E->>App: Solicitar demanda
    Note over E,App: Origem obrigatória: Quadra/Lote onde precisa do serviço<br/>ex.: Quadra 04 · Lote 02 — SetorOperacional derivado
    E->>App: Serviço Movimentação + Maquinário Munck
    E->>App: Material Concreto
    E->>App: Destino da movimentação: Quadra 04 · Lote 03<br/>(mesma quadra, lote adjacente)
    E->>App: Submeter solicitação

    App->>API: Criar demanda (POST /demandas)
    API-->>App: Demanda PENDENTE criada

    M->>M: Hard filter por setor e compatibilidade máquina-serviço
    M->>M: Score W_adj, W_srv, W_mat + ordenação FIFO em empate
    M-->>O: Fila do operador elegível atualizada<br/>(pré-ordenação; destaque se MAXIMA)
```

## Visão compacta (flowchart)

```mermaid
flowchart TD
    subgraph Login["Autenticação campo — SPEC D6"]
        L1[Utilizador + PIN no PWA Machinery Link]
    end

    subgraph REQ_JOR_001["REQ-JOR-001 — Pedido de movimentação"]
        P1[Solicitar demanda]
        P2[Origem Quadra 04 · Lote 02 — Setor derivado]
        P3[Serviço Movimentação · Munck · Material Concreto]
        P4[Destino Quadra 04 · Lote 03 — malha Core]
        P5[Submeter]
        P1 --> P2 --> P3 --> P4 --> P5
    end

    subgraph Motor["REQ-JOR-002 · REQ-JOR-003"]
        T[Triagem jurisdição logística]
        S[Scoring e ordenação da fila]
    end

    subgraph REQ_JOR_004["REQ-JOR-004 — Operador"]
        Q[Fila pré-ordenada atualizada]
    end

    L1 --> P1
    P5 --> T --> S --> Q
```

---

## Critérios de aceite relacionados (PRD)

- [REQ-ACE-003](../PRD/05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-005](../PRD/05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)

-> SPEC: [../SPEC/00-visao-arquitetura.md#politica-autenticacao-senha](../SPEC/00-visao-arquitetura.md#politica-autenticacao-senha)
-> SPEC: [../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp](../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#visao-do-motor-operacional](../SPEC/03-fila-scoring-estados-sla.md#visao-do-motor-operacional)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)
