# Modelo de dados

**Rastreio PRD:** `REQ-FUNC-003`, `REQ-FUNC-004`, `REQ-FUNC-006`, `REQ-FUNC-007`, `REQ-FUNC-010`, `REQ-NFR-004`, `REQ-MET-001`

Este modulo consolida as entidades principais do dominio, as relacoes entre recursos operacionais e as regras de integridade que sustentam o isolamento por obra e a rastreabilidade do Machinery Link.

## Entidades principais

- **Core**: `User`, `Role` e `Obra`.
- **Organizacao espacial**: `SetorOperacional` (macro-jurisdicao alocavel), `Quadra`, `Lote`, `Rua` e `LoteAdjacencia`, usados para inferir proximidade e restringir o motor de fila.
- **Operacional**: `Empreiteira`.
- **Maquinario e recursos**:
  - `TipoMaquinario`: categoria generica que define capacidades base, como escavadeira ou motoniveladora.
  - `Maquinario`: a maquina fisica, com `placa`, `propriedade` (`FGR` ou `Terceiro`), `porte` e vinculo obrigatorio a `TipoMaquinario`.
  - `Ajudante`: recurso humano vinculado a obra sem credencial propria.
  - `Operador`: utilizador com perfil `OPERADOR`, vinculado em relacao N:M aos `TipoMaquinario` que esta autorizado a operar.
- **Catalogo**:
  - `Servico`: atividade executada, vinculada operacionalmente ao `Maquinario`, seguindo a hierarquia `TipoMaquinario` -> `Maquinario` -> `Servico`.
  - `Material`.
- **Transacional**: `Demanda` como aggregate root, `DemandaGrupo` e `DemandaLog`.
- **Expediente**: `RegistroExpediente`, que formaliza a relacao temporal entre `Operador`, `Maquina` e, opcionalmente, `Ajudante`.

No check-in do inicio de expediente, o operador deve:

1. Selecionar explicitamente a maquina que vai operar, filtrada pelos `TipoMaquinario` autorizados no seu perfil.
2. Selecionar o ajudante ativo, quando existir.

O sistema permite troca de ajudante durante o turno atraves de registos cronologicos em `TurnoAjudante`.

## Relacionamentos e regras de integridade

- **Heranca de servicos**: embora `TipoMaquinario` sugira servicos compativeis, o vinculo operacional efetivo e feito no nivel da instancia `Maquinario`.
- **Escopo de tenant**: toda entidade tenant-scoped contem obrigatoriamente `obraId`.
- **Soft-delete**: `Demanda`, `Maquinario` e `Empreiteira` nunca sao purgados fisicamente; o sistema utiliza `deletadoEm` para preservar historico.
- **Auditabilidade transacional**: qualquer manipulacao, avanco, cancelamento ou alteracao da `Demanda` gera escrita nao destrutiva em `DemandaLog`.
- **Atributos temporais da demanda** (`REQ-FUNC-007`): a `Demanda` persiste obrigatoriamente `iniciadoEm` (timestamp de transicao para `EM_ANDAMENTO`), `finalizadoEm` (timestamp de transicao para `CONCLUIDA`) e `tempoExecucaoMs` (campo calculado como `finalizadoEm - iniciadoEm` em milissegundos, persistido no momento da conclusao). Em cenarios offline, os timestamps de origem do dispositivo prevalecem sobre os de sincronizacao (conforme estrategia PWA em [06-definicoes-complementares.md](06-definicoes-complementares.md#estrategia-pwa-offline)).

### Medicao canonica de tempo operacional (`REQ-MET-001`)

Para suportar o indicador de tempo ocioso definido no PRD, o modelo de dados expoe os seguintes atributos e derivacoes:

- **Horas Disponiveis**: soma de `(RegistroExpediente.fimExpediente - RegistroExpediente.inicioExpediente)` para cada expediente do operador/maquina no periodo de medicao. Apenas expedientes com `inicioExpediente` e `fimExpediente` preenchidos sao contabilizados.
- **Horas em Operacao**: soma de `tempoExecucaoMs` de todas as `Demandas` com estado terminal `CONCLUIDA` vinculadas ao mesmo operador/maquina no periodo, convertida para horas.
- **Consulta de referencia**: `(Horas Disponiveis - Horas em Operacao) / Horas Disponiveis` por `obraId`, operador e periodo. O resultado alimenta o painel de metricas acessivel a `AdminOperacional` e `SuperAdmin`.

## Lacunas resolvidas no modelo

- **Ajudantes**: a rastreabilidade e resolvida no nivel de `TurnoAjudante` e derivada por intersecao temporal com a execucao da demanda.
- **Agendamentos**: `Demanda.dataAgendada` passa a existir como atributo proprio, com transicao controlada via shadow-queue para `PENDENTE` 60 minutos antes do horario-alvo.
- **Servicos dinamicos**: ficam formalmente adiados para a Fase 2 por ausencia de especificacao relacional madura para exclusao mutua e dependencias simultaneas.

## Relacao com outros modulos

- O pipeline de elegibilidade e score que consome `SetorOperacional`, `LoteAdjacencia`, `Servico` e `Material` esta detalhado em [03-fila-scoring-estados-sla.md](03-fila-scoring-estados-sla.md).
- As definicoes complementares de `dataAgendada`, `ServicoDinamico` e rastreabilidade de ajudantes estao detalhadas em [06-definicoes-complementares.md](06-definicoes-complementares.md).
