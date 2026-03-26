# Fila, score e triagem automática

Fluxo visual do pipeline de distribuição de demandas: filtros eliminatórios, scoring multivalorado e ordenação final da fila do operador.

**PRD fonte:** [../PRD/02-jornada-usuario.md](../PRD/02-jornada-usuario.md), [../PRD/03-requisitos-funcionais.md](../PRD/03-requisitos-funcionais.md)

**Módulos SPEC relacionados:** [03-fila-scoring-estados-sla](../SPEC/03-fila-scoring-estados-sla.md), [01-modulos-plataforma](../SPEC/01-modulos-plataforma.md)

**REQ-* cobertos:** REQ-JOR-002, REQ-JOR-003, REQ-FUNC-001, REQ-FUNC-002, REQ-ACE-002, REQ-ACE-003

---

## Pipeline completo de distribuição

```mermaid
flowchart TD
    E["Evento de fila\n(nova demanda / conclusão / início de expediente)"]

    E --> R0

    subgraph REGRA0["Regra Zero — Alocação Manual (DEC-001)"]
        R0{"operadorAlocadoId\npreenchido?"}
        R0A["Atribuição direta ao operador indicado\n(sobrepõe filtros automáticos)"]
        R0B["Gera registo auditável\nse fora do SetorOperacional"]
        R0 -->|Sim| R0A --> R0B
    end

    R0B --> SCORE
    R0 -->|Não| HF

    subgraph HF["REQ-JOR-002 — Hard Filter (Filtros Eliminatórios)"]
        HF1{"SetorOperacional\ncorresponde ao operador?"}
        HF2{"Equipamento/Serviço\ncompatível?"}
        HF3["Demanda eliminada da fila elegível\ndeste operador"]
        HF1 -->|Não| HF3
        HF1 -->|Sim| HF2
        HF2 -->|Não| HF3
        HF2 -->|Sim| DEST
    end

    subgraph DEST["Destaque Visual — REQ-FUNC-008 / REQ-ACE-005"]
        D1{"fator_servico = MAXIMA?"}
        D2["Demanda destacada no topo:\nborda pulsante + cor de alerta"]
        D3["Fila restante visível e rolável abaixo\n(UI não bloqueante — REQ-JOR-004)"]
        D1 -->|Sim| D2 --> D3
        D1 -->|Não| SCORE
        D3 --> SCORE
    end

    subgraph SCORE["REQ-JOR-003 — Scoring Multivalorado"]
        S1["score = W_adj×fator_adj + W_srv×fator_srv + W_mat×fator_mat"]
        S2["W_adj=50 · W_srv=30 · W_mat=20\n(configuráveis por obra — AdminOperacional)"]
        S3["fator_adj: 1.0 adjacente / mesma quadra 0.5\n/ quadra dif. máq.pequena 0.0 / quadra dif. máq.grande -1.0"]
        S4["fator_srv: Normal=0.0 · Elevada=1.0 · Máxima=2.0"]
        S5["fator_mat: Normal=0.0 · Crítico/Perecível=1.0"]
        S1 --- S2
        S1 --- S3
        S1 --- S4
        S1 --- S5
    end

    SCORE --> ORD

    subgraph ORD["Ordenação Final"]
        O1["Renderização decrescente por score"]
        O2["Desempate: FIFO cronológico"]
        O3["Fila final entregue ao operador"]
        O1 --> O2 --> O3
    end
```

## Regra de conflito — nova demanda com operador em execução

```mermaid
flowchart LR
    NA["Nova demanda alocada manualmente\npara operador com EM_ANDAMENTO ativo"]
    NA --> NC["Demanda corrente não é interrompida"]
    NA --> NE["Nova demanda entra na fila e participa\ndo pipeline de score normalmente"]
    NA --> NS["Operador notificado da nova carga"]
    NC --> FIM["Operador conclui tarefa atual\nantes de assumir a seguinte"]
    NE --> FIM
    NS --> FIM
```

## Governança dos pesos

```mermaid
flowchart LR
    G1["AdminOperacional altera W_adj / W_srv / W_mat\n(intervalo 0–100 por obra — tenant-scoped)"]
    G2["Demandas já na fila mantêm score calculado"]
    G3["Recálculo no próximo evento de fila"]
    G4["Ou forçado via recalcular_fila no painel"]
    G5["Alteração regista em DemandaLog:\nvalores antigos/novos, userId, timestamp"]
    G1 --> G2
    G1 --> G3 --> G4
    G1 --> G5
```

---

## Critérios de aceite relacionados (PRD)

- [REQ-ACE-002](../PRD/05-criterios-aceite.md#maquina-de-estados-bloqueio-de-bypass-pos-conclusao)
- [REQ-ACE-003](../PRD/05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#governanca-de-pesos-e-auditoria](../SPEC/03-fila-scoring-estados-sla.md#governanca-de-pesos-e-auditoria)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento](../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento)
