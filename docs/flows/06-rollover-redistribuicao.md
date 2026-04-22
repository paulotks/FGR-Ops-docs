# Fluxo — Rollover e Redistribuição de Demandas entre Dias

**Rastreio PRD:** `REQ-FUNC-014` (→ [`docs/PRD/03-requisitos-funcionais.md`](../PRD/03-requisitos-funcionais.md))  
**SPEC:** [`docs/SPEC/03-fila-scoring-estados-sla.md`](../SPEC/03-fila-scoring-estados-sla.md), [`docs/SPEC/06-definicoes-complementares.md`](../SPEC/06-definicoes-complementares.md)  
**DEC:** DEC-025

**REQ cobertos:** REQ-FUNC-014, REQ-ACE-010

---

## 1. Fluxo de fim de expediente

```mermaid
sequenceDiagram
    participant W as Worker expedienteFim
    participant S as Sistema
    participant D as Demanda
    participant L as DemandaLog

    Note over W: Fim do expediente da obra (ou checkout do operador)

    rect rgb(255, 230, 230)
        Note over W,L: Fase 1 — Devolução forçada
        W->>D: Localiza demandas EM_ANDAMENTO / PAUSADA
        loop Para cada demanda ativa
            W->>S: devolver_fim_expediente (ator: SISTEMA)
            S->>D: EM_ANDAMENTO / PAUSADA → RETORNADA
            S->>L: Log {ação: devolver_fim_expediente, justificativa: "Devolução automática por fim de expediente"}
            S->>D: RETORNADA → PENDENTE (transicao_automatica)
        end
    end

    rect rgb(255, 255, 210)
        Note over W,L: Fase 2 — Rollover de PENDENTE
        W->>D: Localiza demandas PENDENTE sem conclusão
        loop Para cada demanda pendente
            W->>D: Preenche rolloverDe = hoje
            W->>D: Limpa operadorId = null
            W->>D: Agenda reset de SLA para expedienteInicio do dia seguinte
            W->>L: Log {ação: rollover, ator: SISTEMA, dados: {rolloverDe, operadorAnteriorId}}
        end
    end

    Note over W: Resultado: todas as demandas não concluídas estão PENDENTE com rolloverDe preenchido
```

---

## 2. Fluxo de check-in e redistribuição no dia seguinte

```mermaid
sequenceDiagram
    participant O as Operador
    participant S as Sistema
    participant P as Pipeline de distribuição
    participant D as Demanda (rollover)

    O->>S: check-in (início do expediente)
    S->>P: Acionar pipeline de distribuição para o operador
    P->>D: Localiza demandas PENDENTE com rolloverDe (e novas do dia)
    P->>P: Hard filter: TipoMaquinario compatível, disponibilidade
    P->>P: Scoring: score = (W_adj×adjacency) + (W_srv×service_priority) + (W_mat×material_risk)
    P-->>S: Lista de demandas ordenadas por score (FIFO em empates)
    S-->>O: Fila de demandas disponíveis (rollover + novas, tratados como PENDENTE normais)

    Note over O,D: Operador inicia demanda normalmente — rolloverDe é somente rastreio
```

---

## 3. Interação com operador que não fez checkout (offline)

```mermaid
sequenceDiagram
    participant O as Operador (offline)
    participant W as Worker expedienteFim
    participant S as Sistema

    Note over O: Operador saiu sem fazer checkout
    Note over W: Worker executa ao fim do expediente

    W->>S: Localiza demandas EM_ANDAMENTO/PAUSADA sem checkout
    S->>S: devolver_fim_expediente para cada demanda do operador offline
    S->>S: EM_ANDAMENTO/PAUSADA → RETORNADA → PENDENTE (ator: SISTEMA)
    Note over S: Garante que NENHUMA demanda ativa sobreviva ao fim do expediente
```

---

## 4. Diagrama de estados — incremental (Plano 1, DEC-025)

```mermaid
stateDiagram-v2
    [*] --> PENDENTE : criar
    [*] --> AGENDADA : criar_com_data

    AGENDADA --> PENDENTE : transicao_temporal
    AGENDADA --> PENDENTE : antecipar
    AGENDADA --> CANCELADA : cancelar

    PENDENTE --> EM_ANDAMENTO : iniciar
    PENDENTE --> CANCELADA : cancelar

    EM_ANDAMENTO --> CONCLUIDA : concluir
    EM_ANDAMENTO --> PAUSADA : pausar
    EM_ANDAMENTO --> RETORNADA : devolver
    EM_ANDAMENTO --> RETORNADA : devolver_fim_expediente
    EM_ANDAMENTO --> CANCELADA : cancelar

    PAUSADA --> EM_ANDAMENTO : retomar
    PAUSADA --> RETORNADA : devolver_fim_expediente

    RETORNADA --> PENDENTE : transicao_automatica

    CONCLUIDA --> [*]
    CANCELADA --> [*]
```

> **Diferenças em relação ao diagrama pré-DEC-025:**  
> `+ EM_ANDAMENTO → RETORNADA : devolver_fim_expediente`  
> `+ PAUSADA → RETORNADA : devolver_fim_expediente`  
> *(Diagrama final com Plano 2 — ver `SPEC/03-fila-scoring-estados-sla.md`)*

---

→ PRD: [`REQ-FUNC-014`](../PRD/03-requisitos-funcionais.md)  
→ SPEC: [`SPEC/03-fila-scoring-estados-sla.md`](../SPEC/03-fila-scoring-estados-sla.md) (transições, SLA)  
→ SPEC: [`SPEC/06-definicoes-complementares.md`](../SPEC/06-definicoes-complementares.md) (worker, rolloverDe, reset SLA)  
→ ACE: [`REQ-ACE-010`](../PRD/05-criterios-aceite.md)
