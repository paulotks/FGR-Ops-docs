# Jornada principal — Machinery Link

Fluxo visual do percurso descrito no PRD, da requisição do empreiteiro à auditoria administrativa.

**PRD fonte:** [../PRD/02-jornada-usuario.md](../PRD/02-jornada-usuario.md)

**Módulos SPEC relacionados:** [01-modulos-plataforma](../SPEC/01-modulos-plataforma.md), [02-modelo-dados](../SPEC/02-modelo-dados.md), [03-fila-scoring-estados-sla](../SPEC/03-fila-scoring-estados-sla.md)

**REQ-* cobertos:** REQ-JOR-001, REQ-JOR-002, REQ-JOR-003, REQ-JOR-004, REQ-JOR-005

---

## Visão de ponta a ponta

```mermaid
flowchart TD
    subgraph REQ_JOR_001["REQ-JOR-001 — Empreiteiro"]
        A1[Autenticação no app móvel]
        A2[Localização: Quadra/Lote ou Local Externo]
        A3[SetorOperacional derivado automaticamente]
        A4[Serviço e maquinário mutuamente filtráveis]
        A5[Material e destino opcionais]
        A6[Descrição complementar e submissão]
        A1 --> A2 --> A3 --> A4 --> A5 --> A6
    end

    A6 --> B

    B["REQ-JOR-002 — Triagem por jurisdição logística<br/>Filtro eliminatório por Setor Operacional"]

    B --> C

    C["REQ-JOR-003 — Priorização dinâmica<br/>Motor de score: W_adj, W_srv, W_mat"]

    subgraph REQ_JOR_004["REQ-JOR-004 — Execução em campo"]
        D1[Operador: fila estrita pré-ordenada no Expediente]
        D2[Destaque visual para prioridade máxima]
        D3[AdminOperacional: alocação manual sem bloquear UI]
        D1 --- D2
        D1 --- D3
    end

    C --> D1

    D1 --> E{Alteração forçada, cancelamento<br/>ou devolução à fila?}

    E -->|Não| F[Fim do fluxo operacional normal]
    E -->|Sim| G["REQ-JOR-005 — Auditoria administrativa<br/>Justificativa + DemandaLog"]

    G --> F
```

## Subfluxo — requisição inicial (detalhe REQ-JOR-001)

```mermaid
flowchart LR
    L1[Modo localização: malha Core ou Local Externo] --> L2[Catálogo: TipoMaquinario → Maquinario → Servico]
    L2 --> L3{Material / destino preenchidos?}
    L3 -->|Sim| L4[fator_material e contexto movimentação]
    L3 -->|Não| L5[Demanda simples ou DemandaGrupo]
    L4 --> L5
```

---

## Critérios de aceite relacionados (PRD)

- [REQ-ACE-003](../PRD/05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-004](../PRD/05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](../PRD/05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](../PRD/05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)

-> SPEC: [../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp](../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)
-> SPEC: [../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link](../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento](../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)
