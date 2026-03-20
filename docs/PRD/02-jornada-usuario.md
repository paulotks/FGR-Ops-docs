# Jornada do utilizador

Esta secção descreve o fluxo operacional principal do módulo Machinery Link, da abertura da demanda até à auditoria administrativa posterior.

## Fluxo principal

### `REQ-JOR-001` Requisicao inicial pelo Empreiteiro

O `Empreiteiro` acede ao aplicativo movel, autentica-se (caso nao esteja autenticado) e solicita maquinario seguindo o fluxo descrito abaixo.

#### Localizacao da demanda

O empreiteiro informa obrigatoriamente a localizacao onde necessita do servico, selecionando:

- **Quadra e Lote** da malha espacial do Core (opcao padrao), ou
- **Local Externo** da obra (Portaria, Pulmao, Garagem, entre outros cadastrados por obra).

A interface deve oferecer alternancia simples entre os dois modos de localizacao para facilitar o preenchimento. O `SetorOperacional` e derivado automaticamente da localizacao selecionada, ancorando o pedido ao contexto logistico que alimenta o filtro de jurisdicao e o fator de adjacencia no motor de score.

#### Selecao de servico e maquinario

O empreiteiro seleciona o servico desejado a partir de uma lista nomeada e o maquinario correspondente. A selecao e mutuamente filtravel: escolher um servico restringe os maquinarios disponiveis e vice-versa, conforme o vinculo operacional do catalogo (`TipoMaquinario` -> `Maquinario` -> `Servico`).

#### Material e destino (opcionais)

O empreiteiro pode selecionar um **Material** do catalogo (ex.: Grunt, Concreto) e informar um **Destino** (Quadra/Lote diferente da localizacao de origem). Ambos os campos sao opcionais. Quando preenchido, o material alimenta o `fator_material` no motor de score; o destino contextualiza servicos de movimentacao.

> **Nota sobre movimentacao de massas:** Servicos de movimentacao de materiais como Grunt, Concreto e similares constituem demandas para que o operador de maquinas desloque a massa ja existente no local de obra (tipicamente armazenada em caixa d'agua na frente do lote). Exemplos: "subir grunt para laje da casa", "descer massa", "levar para o lote ao lado". O empreiteiro informa a localizacao de origem (Quadra/Lote), seleciona servico (ex.: Movimentacao), equipamento (ex.: Munck), opcionalmente o material e o destino, e detalha a operacao no campo de descricao. Nao se trata de pedido de fornecimento de material externo — o material ja se encontra na frente de obras.

> **Entrega formal de material (pos-MVP):** Um fluxo estruturado de entrega de material a partir de origens externas (centrais de concreto, usinas, etc.) podera ser implementado em fase posterior, reaproveitando o catalogo de materiais e a infraestrutura de localizacao ja existentes. Ver itens adiados em [../SPEC/05-backlog-mvp-glossario.md](../SPEC/05-backlog-mvp-glossario.md#itens-adiados-para-fase-2).

#### Complemento e submissao

O empreiteiro pode adicionar uma descricao complementar (campo livre, recomendado para servicos de movimentacao) e submete a solicitacao. O fluxo deve permitir a criacao de demandas simples e tambem de lotes agrupados via `DemandaGrupo` para rastreabilidade, sem orquestracao de execucao.

-> SPEC: [../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp](../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp)
-> SPEC: [../SPEC/02-modelo-dados.md#entidades-principais](../SPEC/02-modelo-dados.md#entidades-principais)

### `REQ-JOR-002` Triagem por jurisdicao logistica

Antes de qualquer atribuicao, a plataforma executa um filtro eliminatorio por `Setor Operacional`. Uma demanda aberta numa determinada area apenas pode ser considerada para maquinarios e operadores compativeis com esse contexto logistico e com a compatibilidade maquina-servico exigida.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-JOR-003` Priorizacao dinamica da fila

Depois da triagem, as demandas elegiveis entram no motor de score da fila. A classificacao utiliza pesos configuraveis por obra (`W_adj=50`, `W_srv=30`, `W_mat=20`) e considera:

- `fator_adjacencia`, derivado do checkpoint manual e do contexto logistico da maquina.
- `fator_servico`, derivado do catalogo, com saltos de prioridade `Normal`, `Elevada` e `Maxima`.
- `fator_material`, derivado de risco critico ou perecibilidade.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score](../SPEC/03-fila-scoring-estados-sla.md#regra-zero-hard-filter-destaque-e-score)

### `REQ-JOR-004` Execucao em campo e operacoes dinamicas

O `Operador` acede ao aplicativo dentro do seu `Expediente`, visualizando a sua fila estrita, preordenada automaticamente e sem bloquear a interface. Demandas de prioridade maxima devem surgir no topo com destaque visual. Em paralelo, o `AdminOperacional` pode realizar alocacao manual imediata de um operador especifico a uma demanda, empilhando tarefas sem interromper a execucao em curso.

-> SPEC: [../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link](../SPEC/01-modulos-plataforma.md#capacidades-operacionais-do-machinery-link)
-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento](../SPEC/03-fila-scoring-estados-sla.md#regra-de-conflito-alocacao-manual-sobre-demanda-em_andamento)

### `REQ-JOR-005` Auditoria administrativa obrigatoria

Demandas sujeitas a alteracao forcada, cancelamento ou devolucao a fila devem passar por um estadio obrigatorio de auditoria. Toda a alteracao administrativa relevante precisa de justificativa e de registo persistente em `DemandaLog`.

-> SPEC: [../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas](../SPEC/03-fila-scoring-estados-sla.md#auditoria-administrativa-e-justificativas)

## Critérios de aceite relacionados

- [REQ-ACE-003](05-criterios-aceite.md#jurisdicao-logistica-sobre-preferencias-no-score)
- [REQ-ACE-004](05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)
