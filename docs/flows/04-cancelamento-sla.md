# Cancelamento e encerramento por SLA

Fluxo visual da solicitação de cancelamento em campo, timeout de SLA no fim do expediente e revisão pós-facto administrativa.

**PRD fonte:** [../PRD/02-jornada-usuario.md](../PRD/02-jornada-usuario.md), [../PRD/05-criterios-aceite.md](../PRD/05-criterios-aceite.md)

**Módulos SPEC relacionados:** [03-fila-scoring-estados-sla](../SPEC/03-fila-scoring-estados-sla.md)

**REQ-* cobertos:** REQ-JOR-005, REQ-FUNC-008, REQ-FUNC-009, REQ-ACE-006

**Decisões aplicadas:** DEC-002

---

## Fluxo principal — PENDENTE_APROVACAO e encerramento

```mermaid
flowchart TD
    EM["Demanda em EM_ANDAMENTO"]

    EM --> OP{"Operador precisa\ncancelar?"}

    OP -->|Sim| SC["solicitar_cancelamento\n(justificativa obrigatória)"]
    OP -->|Não| EXEC["Continua execução normal"]

    SC --> PA["Demanda → PENDENTE_APROVACAO\n(holding state gerencial)"]
    PA --> LIB["Operador liberado para próxima\ntarefa da fila"]
    PA --> GER["Notificação no Approval Inbox\ndo AdminOperacional / UsuarioInternoFGR"]

    subgraph DECISAO["Janela de decisão gerencial"]
        GER --> DEC{"Decisão antes do\nfim do expediente?"}
        DEC -->|"Aprovar cancelamento"| APR["Demanda → CANCELADA\nDemandaLog: ator, timestamp, motivo"]
        DEC -->|"Rejeitar cancelamento"| REJ["Demanda → EM_ANDAMENTO\nVinculada ao mesmo operador\nTopo da fila do operador"]
        DEC -->|"Sem decisão até fim do expediente\n[DEC-002]"| TIMEOUT
    end

    subgraph TIMEOUT["Encerramento automático por SLA"]
        T1["Sistema: estouro_sla_fim_expediente"]
        T2["Demanda → CANCELADA (auto)"]
        T3["DemandaLog:\norigem=estouro_sla_fim_expediente\nator=SISTEMA\ntimestamp\nmotivo"]
        T1 --> T2 --> T3
    end

    T3 --> REVISAO
    APR --> FIM["Fim do fluxo"]
    REJ --> EXEC

    subgraph REVISAO["Revisão pós-facto (dia útil seguinte)"]
        R1["UsuarioInternoFGR / AdminOperacional\nacessa visão dedicada"]
        R2["Listagem de cancelamentos automáticos do dia anterior"]
        R3["Ação corretiva/operacional quando necessária"]
        R1 --> R2 --> R3
    end
```

## Alertas de SLA por nível de prioridade

```mermaid
flowchart LR
    subgraph SLA_MAX["SLA MÁXIMA — 15 min"]
        M1["UI push alta prioridade → Admin + Operador"]
        M2["Escalação para SuperAdmin após +5 min"]
        M1 --> M2
    end

    subgraph SLA_ELV["SLA ELEVADA — 45 min"]
        E1["UI push normal → AdminOperacional"]
        E2["Escalação para SuperAdmin após +15 min"]
        E1 --> E2
    end

    subgraph SLA_NOR["SLA NORMAL — 120 min"]
        N1["Badge no dashboard → AdminOperacional"]
        N2["Polling a cada 10 min"]
        N3["Apenas log auditável (sem escalação)"]
        N1 --> N2 --> N3
    end
```

> **Nota agendamentos:** para demandas com `dataAgendada`, o marco zero do SLA é `dataAgendada` (T-0), não a transição antecipada para `PENDENTE` (T-60). Se o atendimento ocorrer antes de `dataAgendada`, o tempo de atendimento é considerado zero.

---

## Critérios de aceite relacionados (PRD)

- [REQ-ACE-006](../PRD/05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao](../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca](../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)
