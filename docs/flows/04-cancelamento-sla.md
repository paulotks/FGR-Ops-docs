# Cancelamento de demanda em campo e alertas de SLA

Fluxo visual do cancelamento direto pelo Operador e dos alertas de SLA por nível de prioridade.

**PRD fonte:** [../PRD/02-jornada-usuario.md](../PRD/02-jornada-usuario.md), [../PRD/05-criterios-aceite.md](../PRD/05-criterios-aceite.md)

**Módulos SPEC relacionados:** [03-fila-scoring-estados-sla](../SPEC/03-fila-scoring-estados-sla.md)

**REQ-* cobertos:** REQ-JOR-005, REQ-FUNC-009, REQ-ACE-006

**Decisões aplicadas:** DEC-019

---

## Fluxo principal — cancelamento direto pelo Operador

O estado intermediário `PENDENTE_APROVACAO` foi removido do MVP (DEC-019). O Operador pode cancelar diretamente uma demanda em `EM_ANDAMENTO`, registrando justificativa obrigatória.

```mermaid
flowchart TD
    EM["Demanda em EM_ANDAMENTO"]

    EM --> OP{"Operador precisa\ncancelar?"}

    OP -->|Não| EXEC["Continua execução normal"]
    OP -->|Sim| JUST["Operador preenche justificativa\n(obrigatória)"]

    JUST --> CANCELADA["Demanda → CANCELADA\n(transição direta)"]
    CANCELADA --> LOG["DemandaLog:\nator=Operador\ntimestamp\nmotivo"]
    LOG --> FILA["Operador disponível para\npróxima tarefa da fila"]
```

## Alertas de SLA por nível de prioridade

```mermaid
flowchart LR
    subgraph SLA_MAX["SLA MÁXIMA — 15 min"]
        M1["WebSocket DEMAND_QUEUED + SLA_ALERT → Admin + Operador"]
        M2["Escalação SLA_ESCALATION para SuperAdmin após +5 min"]
        M1 --> M2
    end

    subgraph SLA_ELV["SLA ELEVADA — 45 min"]
        E1["WebSocket SLA_ALERT → AdminOperacional"]
        E2["Escalação SLA_ESCALATION para SuperAdmin após +15 min"]
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

- [REQ-ACE-006](../PRD/05-criterios-aceite.md#cancelamento-de-demanda-em-execucao-pelo-operador)

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca](../SPEC/03-fila-scoring-estados-sla.md#sla-de-atendimento-e-governanca)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)
