# Jornada do utilizador

Esta secção descreve o fluxo operacional principal do módulo Machinery Link, da abertura da demanda até à auditoria administrativa posterior.

## Fluxo principal

### `REQ-JOR-001` Requisicao inicial pelo Empreiteiro

O `Empreiteiro` autentica-se no portal, informa a localizacao em que esta a trabalhar e solicita maquinario indicando o servico requerido. O fluxo deve permitir a criacao de demandas simples e tambem modelos agrupados de demandas dependentes.

-> SPEC: [../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp](../SPEC/01-modulos-plataforma.md#modulo-machinery-link-mvp)

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
- [REQ-ACE-006](05-criterios-aceite.md#aprovacao-administrativa-para-cancelamentos-de-operadores)
