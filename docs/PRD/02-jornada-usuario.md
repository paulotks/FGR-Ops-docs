# Jornada do usuário

Esta seção descreve o fluxo operacional principal do módulo Machinery Link, da abertura da demanda até a auditoria administrativa posterior.

-> FLOW: [../flows/00-jornada-principal.md](../flows/00-jornada-principal.md) — diagrama Mermaid de ponta a ponta (REQ-JOR-001 a REQ-JOR-005)

## Fluxo principal

### `REQ-JOR-001` Requisição inicial pelo Empreiteiro

O `Empreiteiro` acessa o aplicativo móvel, autentica-se (caso não esteja autenticado) e solicita maquinário seguindo o fluxo descrito abaixo.

#### Localização da demanda

O empreiteiro informa obrigatoriamente a localização onde necessita do serviço, selecionando:

- **Quadra e Lote** da malha espacial do Core (opção padrão), ou
- **Local Externo** da obra (Portaria, Pulmão, Garagem, entre outros cadastrados por obra).

A interface deve oferecer alternância simples entre os dois modos de localização para facilitar o preenchimento. O `SetorOperacional` é derivado automaticamente da localização selecionada, ancorando o pedido ao contexto logístico que alimenta o filtro de jurisdição e o fator de adjacência no motor de score.

#### Seleção de serviço e maquinário

O empreiteiro seleciona o serviço desejado a partir de uma lista nomeada e o maquinário correspondente. A seleção é mutuamente filtrável: escolher um serviço restringe os maquinários disponíveis àqueles do mesmo `TipoMaquinario`, e vice-versa (conforme `TipoMaquinario` → `Servico` e `TipoMaquinario` → `Maquinario`).

#### Material e destino

O empreiteiro pode selecionar um **Material** do catálogo (ex.: Grunt, Concreto). Este campo é sempre opcional e, quando preenchido, alimenta o `fator_material` no motor de score.

O campo **Destino** (Quadra/Lote) tem duas modalidades:

- **Obrigatório** quando o serviço selecionado possui `exigeTransporte = true`. Neste caso, o empreiteiro deve:
  - Informar **Quadra e Lote de destino** (diferente ou igual à origem), **ou**
  - Marcar **Transporte Interno**, indicando que o deslocamento ocorre no mesmo Quadra/Lote de origem. O sistema preenche automaticamente `destinoQuadraId = quadraId` e `destinoLoteId = loteId`.
- **Opcional** nos demais serviços. Quando preenchido, contextualiza operações de movimentação.

> **Serviços com `exigeTransporte`:** São os serviços cadastrados com a flag de transporte marcada (ex.: Movimentação, Carregamento, Descarga). O empreiteiro deve sempre informar para onde o material ou equipamento será deslocado. Para deslocamentos no mesmo ponto de origem (ex.: içar material no próprio lote), o empreiteiro utiliza a opção **Transporte Interno**.

> **Entrega formal de material (pós-MVP):** Um fluxo estruturado de entrega de material a partir de origens externas (centrais de concreto, usinas, etc.) com `PontoOrigem` fixo e pré-preenchimento automático de origem poderá ser implementado em fase posterior. Ver itens adiados em [../SPEC/05-backlog-mvp-glossario.md](../SPEC/05-backlog-mvp-glossario.md#itens-adiados-para-fase-2).

#### Complemento e submissão

O empreiteiro pode adicionar uma descrição complementar (campo livre, recomendado para serviços de movimentação) e submete a solicitação. O fluxo deve permitir a criação de demandas simples e também de lotes agrupados via `DemandaGrupo` para rastreabilidade, sem orquestração de execução.

-> SPEC: [../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp](../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)

#### Acompanhamento e cancelamento de demanda própria

Após a submissão, o empreiteiro acessa a lista de chamadas ativas para acompanhar o estado das suas demandas. Enquanto uma demanda estiver em `PENDENTE`, o empreiteiro pode cancelá-la diretamente pelo card, informando obrigatoriamente uma justificativa. Demandas em `EM_ANDAMENTO` ou em estados terminais (`CONCLUIDA`, `CANCELADA`) não permitem cancelamento pelo empreiteiro.

-> SPEC: [../SPEC/07-design-ui-logica.md](../SPEC/07-design-ui-logica.md) (seção 1.1 — Cancelamento de demanda própria em `PENDENTE`)

### `REQ-JOR-002` Triagem por jurisdição logística

Antes de qualquer atribuição, a plataforma executa um filtro eliminatório por `Setor Operacional`. Uma demanda aberta numa determinada área apenas pode ser considerada para maquinários e operadores compatíveis com esse contexto logístico e com a compatibilidade máquina-serviço exigida.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-JOR-003` Priorização dinâmica da fila

Depois da triagem, as demandas elegíveis entram no motor de score da fila. A classificação utiliza pesos configuráveis por obra (`W_adj=50`, `W_srv=30`, `W_mat=20`) e considera:

- `fator_adjacencia`, derivado do checkpoint manual e do contexto logístico da máquina.
- `fator_servico`, derivado do catálogo, com saltos de prioridade `Normal`, `Elevada` e `Maxima`.
- `fator_material`, derivado de risco crítico ou perecibilidade.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-JOR-004` Execução em campo e operações dinâmicas

O `Operador` acessa o aplicativo dentro do seu `Expediente`, visualizando a sua fila estrita, preordenada automaticamente e sem bloquear a interface. Demandas de prioridade máxima devem surgir no topo com destaque visual. Em paralelo, o `AdminOperacional` pode realizar alocação manual imediata de um operador específico a uma demanda, empilhando tarefas sem interromper a execução em curso.

#### Comportamento de notificação por estado da fila

Quando uma nova demanda chega a um operador com fila vazia, o sistema dispara notificação multi-sensorial (pop-up + alerta sonoro + vibração) para garantir percepção mesmo sem tela ativa. Quando a fila já possui demandas, a entrada é silenciosa e reordenada pelo motor de score.

#### Ciclo inter-dias: rollover e retomada no check-in

Demandas não concluídas até o fim do expediente não são encerradas automaticamente. Em vez disso:

- Demandas em `PENDENTE` rolam para o dia seguinte com o campo `rolloverDe` preenchido com a data do dia, operadorId limpo e SLA agendado para reset no `expedienteInicio` do dia seguinte.
- Demandas em `EM_ANDAMENTO` ou `PAUSADA` são devolvidas automaticamente pelo Sistema via transição `devolver_fim_expediente → RETORNADA → PENDENTE` (gatilho duplo: checkout do operador ou worker `expedienteFim`). O log registra ator `SISTEMA` e justificativa "Devolução automática por fim de expediente".
- No dia seguinte, operadores que fazem check-in recebem as demandas redistribuídas conforme compatibilidade de maquinário (hard filter + scoring normal). A experiência do operador é transparente: demandas com `rolloverDe` aparecem na fila como demandas normais, sem estado especial.
- O painel admin exibe indicador visual (badge "Dia anterior") para demandas redistribuídas, sem notificação especial.

> **Decisão aplicada:** DEC-025 (2026-04-20) — Rollover e redistribuição de demandas entre dias. Supersede parcialmente DEC-002 (auto-encerramento por SLA removido; alertas e escalação mantidos). Ver [`docs/audit/decisions-log.md#dec-025`](../audit/decisions-log.md#dec-025).

→ SPEC: [../SPEC/03-fila-scoring-estados-sla.md](../SPEC/03-fila-scoring-estados-sla.md) (máquina de estados, worker expedienteFim, rollover PENDENTE)
→ SPEC: [../SPEC/06-definicoes-complementares.md](../SPEC/06-definicoes-complementares.md) (campo rolloverDe, reset de SLA inter-dias)

-> SPEC: [../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link](../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento](../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento)
-> SPEC: [../SPEC/07-design-ui-logica.md#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa](../SPEC/07-design-ui-logica.md#notificacao-de-nova-demanda-fila-vazia-vs-fila-ativa) (UX completa)
-> SPEC: [../SPEC/06-definicoes-complementares.md#regras-de-deduplicacao-e-estado-visual](../SPEC/06-definicoes-complementares.md#regras-de-deduplicacao-e-estado-visual) (mecânica técnica)

### `REQ-JOR-005` Auditoria administrativa obrigatória

Demandas sujeitas a alteração forçada, cancelamento ou devolução à fila devem passar por um estágio obrigatório de auditoria. Toda a alteração administrativa relevante precisa de justificativa e de registro persistente em `DemandaLog`.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)

## Critérios de aceite relacionados

- [REQ-ACE-003](05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-004](05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)
- [REQ-ACE-010](05-criterios-aceite.md#rollover-e-redistribuicao-de-demandas-entre-dias)

