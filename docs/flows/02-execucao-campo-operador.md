# Execução em campo — Operador de Maquinário

Fluxo visual do turno do operador: check-in, atendimento da fila, pausa e conclusão.

**PRD fonte:** [../PRD/02-jornada-usuario.md](../PRD/02-jornada-usuario.md)

**Módulos SPEC relacionados:** [03-fila-scoring-estados-sla](../SPEC/03-fila-scoring-estados-sla.md), [07-design-ui-logica](../SPEC/07-design-ui-logica.md)

**REQ-* cobertos:** REQ-JOR-004, REQ-FUNC-006, REQ-FUNC-007, REQ-FUNC-008, REQ-ACE-004, REQ-ACE-005

---

## Ciclo completo do turno

```mermaid
flowchart TD
    subgraph INICIO["Início de turno"]
        C1[App abre tela de check-in bloqueante]
        C2[Operador confirma check-in na base]
        C3["Checkpoint Manual registado\n(SetorOperacional + timestamp)"]
        C1 --> C2 --> C3
    end

    C3 --> F1

    subgraph FILA["REQ-JOR-004 — Fila do operador"]
        F1["Motor recalcula fila do operador\n(score descendente, FIFO para empate)"]
        F2{"Demanda com prioridade MÁXIMA?"}
        F3["REQ-ACE-005 — Destaque visual:\nborda pulsante + cor de alerta no topo"]
        F4["Card da próxima demanda visível\n(Local, Serviço, Empreiteiro solicitante)"]
        F1 --> F2
        F2 -->|Sim| F3 --> F4
        F2 -->|Não| F4
    end

    F4 --> A1

    subgraph ATENDIMENTO["REQ-FUNC-006 — Execução da demanda"]
        A1["Operador: 'Iniciar Deslocamento'\nDemanda → EM_ANDAMENTO"]
        A2["Operador: 'Cheguei ao Local'"]
        A3{"Interrupção necessária?"}
        A4["Operador: 'Pausar'\nRegistar MOTIVO obrigatório"]
        A5["Demanda → PAUSADA\nFila recalcula próximas tarefas"]
        A6["Operador: retomar ou aguardar decisão gerencial"]
        A7["Operador: 'Concluir'\nDemanda → CONCLUIDA"]
        A1 --> A2 --> A3
        A3 -->|Sim| A4 --> A5 --> A6 --> A3
        A3 -->|Não| A7
    end

    A7 --> P1

    subgraph POS["Pós-conclusão"]
        P1["Card sai da view ativa"]
        P2["Histórico atualiza numeração de meta diária"]
        P3["Motor regressa a FILA para próxima demanda"]
        P1 --> P2 --> P3
    end

    P3 --> F1
```

## Subfluxo — solicitação de cancelamento pelo operador

```mermaid
sequenceDiagram
    actor Op as Operador
    participant SM as Máquina de Estados
    participant Ger as AdminOperacional/UsuarioInternoFGR
    participant Log as DemandaLog

    Op->>SM: solicitar_cancelamento (justificativa obrigatória)
    SM-->>Op: Demanda → PENDENTE_APROVACAO
    Note over Op: Operador liberado para próxima tarefa da fila
    SM->>Ger: Notificação no Approval Inbox

    alt Decisão gerencial antes do fim do expediente
        Ger->>SM: aprovar_cancelamento
        SM-->>Log: origem, ator, timestamp, motivo
        SM-->>Op: Toast "Demanda #ID cancelada"
    else Sem decisão até fim do expediente [DEC-002]
        SM->>SM: estouro_sla_fim_expediente
        SM-->>Log: origem=estouro_sla_fim_expediente, ator=SISTEMA
        Note over Ger: Visão de revisão pós-facto no dia útil seguinte
    end
```

---

## Critérios de aceite relacionados (PRD)

- [REQ-ACE-004](../PRD/05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](../PRD/05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](../PRD/05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda](../SPEC/03-fila-scoring-estados-sla.md#maquina-de-estados-da-demanda)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao](../SPEC/03-fila-scoring-estados-sla.md#fluxo-detalhado-pendente_aprovacao)
-> SPEC: [../SPEC/07-design-ui-logica.md#12-mobile-do-operador-execucao-no-campo](../SPEC/07-design-ui-logica.md#12-mobile-do-operador-execucao-no-campo)
