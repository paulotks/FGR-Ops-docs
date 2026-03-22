# Jornada do usuário

Esta seção descreve o fluxo operacional principal do módulo Machinery Link, da abertura da demanda até a auditoria administrativa posterior.

## Fluxo principal

### `REQ-JOR-001` Requisição inicial pelo Empreiteiro

O `Empreiteiro` acessa o aplicativo móvel, autentica-se (caso não esteja autenticado) e solicita maquinário seguindo o fluxo descrito abaixo.

#### Localização da demanda

O empreiteiro informa obrigatoriamente a localização onde necessita do serviço, selecionando:

- **Quadra e Lote** da malha espacial do Core (opção padrão), ou
- **Local Externo** da obra (Portaria, Pulmão, Garagem, entre outros cadastrados por obra).

A interface deve oferecer alternância simples entre os dois modos de localização para facilitar o preenchimento. O `SetorOperacional` é derivado automaticamente da localização selecionada, ancorando o pedido ao contexto logístico que alimenta o filtro de jurisdição e o fator de adjacência no motor de score.

#### Seleção de serviço e maquinário

O empreiteiro seleciona o serviço desejado a partir de uma lista nomeada e o maquinário correspondente. A seleção é mutuamente filtrável: escolher um serviço restringe os maquinários disponíveis e vice-versa, conforme o vínculo operacional do catálogo (`TipoMaquinario` -> `Maquinario` -> `Servico`).

#### Material e destino (opcionais)

O empreiteiro pode selecionar um **Material** do catálogo (ex.: Grunt, Concreto) e informar um **Destino** (Quadra/Lote diferente da localização de origem). Ambos os campos são opcionais. Quando preenchido, o material alimenta o `fator_material` no motor de score; o destino contextualiza serviços de movimentação.

> **Nota sobre movimentação de massas:** Serviços de movimentação de materiais como Grunt, Concreto e similares constituem demandas para que o operador de máquinas desloque a massa já existente no local de obra (tipicamente armazenada em caixa d'água na frente do lote). Exemplos: "subir grunt para laje da casa", "descer massa", "levar para o lote ao lado". O empreiteiro informa a localização de origem (Quadra/Lote), seleciona serviço (ex.: Movimentação), equipamento (ex.: Munck), opcionalmente o material e o destino, e detalha a operação no campo de descrição. Não se trata de pedido de fornecimento de material externo — o material já se encontra na frente de obras.

> **Entrega formal de material (pós-MVP):** Um fluxo estruturado de entrega de material a partir de origens externas (centrais de concreto, usinas, etc.) poderá ser implementado em fase posterior, reaproveitando o catálogo de materiais e a infraestrutura de localização já existentes. Ver itens adiados em [../SPEC/05-backlog-mvp-glossario.md](../SPEC/05-backlog-mvp-glossario.md#itens-adiados-para-fase-2).

#### Complemento e submissão

O empreiteiro pode adicionar uma descrição complementar (campo livre, recomendado para serviços de movimentação) e submete a solicitação. O fluxo deve permitir a criação de demandas simples e também de lotes agrupados via `DemandaGrupo` para rastreabilidade, sem orquestração de execução.

-> SPEC: [../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp](../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)

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

-> SPEC: [../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link](../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento](../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento)

### `REQ-JOR-005` Auditoria administrativa obrigatória

Demandas sujeitas a alteração forçada, cancelamento ou devolução à fila devem passar por um estágio obrigatório de auditoria. Toda a alteração administrativa relevante precisa de justificativa e de registro persistente em `DemandaLog`.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)

## Critérios de aceite relacionados

- [REQ-ACE-003](05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-004](05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)

