# Modulos da plataforma

**Rastreio PRD:** `REQ-JOR-001`, `REQ-JOR-004`, `REQ-FUNC-003`, `REQ-FUNC-004`, `REQ-FUNC-005`, `REQ-FUNC-010`

Este modulo consolida as fronteiras de responsabilidade entre o `Core` da plataforma e o `Machinery Link`, explicando onde vivem os dados compartilhados, os fluxos operacionais e as dependencias entre contextos.

## Fronteiras de dominio

- O `Core` concentra identidade, organizacao da obra e estruturas espaciais reutilizaveis por modulos presentes e futuros.
- O `Machinery Link` concentra o ciclo operacional de solicitacao, despacho, execucao e expediente de maquinarios pesados.
- Regras de fila, score, estados e SLA pertencem ao modulo operacional e estao detalhadas em [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md).

## Modulo Core

### Responsabilidade

Fundacao da plataforma contendo dados compartilhados entre todos os submodulos futuros.

### Atores envolvidos

- `SuperAdmin`
- `Board`
- `AdminOperacional`

### Capacidades principais

- Gestao de `Obras`.
- Cadastro de `Usuarios`.
- Atribuicao de `Perfis` (`Roles`) em relacao com setores e escopos de obra.
- Manutencao da malha espacial operacional (`SetorOperacional`, `Quadra`, `Lote`, `Rua`, adjacencias).
- Disponibilizacao de catalogos e metadados usados pelo motor operacional.

## Modulo Machinery Link (MVP)

### Responsabilidade

Gerir o ciclo de vida completo e estrito de solicitacoes, filas, agrupamentos e expedientes de maquinarios pesados.

### Atores envolvidos

- `Empreiteiro` como solicitante.
- `Operador` como executor via mobile.
- `UsuarioInternoFGR` e `AdminOperacional` como gestores da obra.
- `SuperAdmin` para suporte e governanca transversal.

### Capacidades operacionais do Machinery Link

1. **Solicitacao**: abertura de demandas simples, agrupadas, em lote multiplo e programacoes agendadas. Na abertura, o `Empreiteiro` informa obrigatoriamente a localizacao de trabalho seleccionando a entidade espacial do Core — `SetorOperacional` e, opcionalmente, `Quadra` e `Lote` — que ancora o pedido ao contexto logistico. Esta seleccao alimenta o hard filter de jurisdicao e o fator de adjacencia do motor de score (`REQ-JOR-001`).
2. **Agrupamento e criacao multipla**: o frontend permite agrupar sequencias de servicos com logica estrutural partilhada (mesmo local, mesmo tipo de maquinario) e submeter um payload bulk que gera demandas independentes a partir da mesma experiencia de formulario. Cada demanda gerada pelo bulk recebe ID proprio, participa individualmente do pipeline de fila e pode ser concluida ou cancelada de forma autonoma. A relacao logica entre demandas do mesmo lote e preservada em `DemandaGrupo` para rastreabilidade, sem implicar orquestracao de execucao (`REQ-FUNC-005`).
3. **Gestao da fila**: distribuicao transparente filtrada por setores, jurisdicao logistica e score.
4. **Execucao**: fluxo de campo para assumir, concluir, devolver ou contestar tarefas via maquina de estados.
5. **Expediente**: controlo de inicio e fim da jornada operacional do maquinario, com maquina e ajudante ativos.
6. **Operacoes dinamicas**: alocacao manual, empilhamento nao destrutivo e trilha de auditoria obrigatoria.

## Dependencias sobre o Core

- O `Machinery Link` depende do `Core` para conhecer `Obra`, `User`, `Role` e o recorte tenant-scoped.
- O filtro logistico usa entidades espaciais mantidas no `Core`, como `SetorOperacional`, `Quadra`, `Lote`, `Rua` e relacoes de adjacencia.
- O catalogo de `Tipos de Maquinario`, `Maquinarios`, `Servicos` e autorizacoes do `Operador` determina elegibilidade de atendimento.
- O `RegistroExpediente` combina referencias do `Core` com o estado operacional corrente para definir contexto de execucao.

## Critérios de aceite suportados

- [REQ-ACE-004](../PRD/05-criterios-aceite.md#audit-log-com-justificativa-em-modificacoes-gerenciais)
- [REQ-ACE-005](../PRD/05-criterios-aceite.md#destaque-visual-de-prioridade-maxima-na-ui-mobile)
- [REQ-ACE-006](../PRD/05-criterios-aceite.md#cancelamento-de-demandas-em-campo-e-encerramento-por-sla)
