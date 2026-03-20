# Matriz de Rastreabilidade

Matriz global de rastreio entre os requisitos do PRD e os modulos da SPEC.

## Como ler

- `REQ / grupo`: faixa de IDs ou agrupamento funcional mantido no PRD.
- `PRD`: modulo funcional onde o requisito e mantido.
- `SPEC`: modulo tecnico principal que cobre o requisito.
- `Notas`: observacoes sobre cobertura, transversalidade ou dependencias.

## Matriz global

| REQ / grupo | PRD | SPEC | Notas |
|-------------|-----|------|-------|
| `REQ-CTX-*`, `REQ-OBJ-*`, `REQ-SCO-*` | [PRD/00-visao-escopo.md](PRD/00-visao-escopo.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Contexto, objetivos, escopo MVP/Fase 2 e alinhamento arquitetural base. |
| `REQ-SCO-F2-*`, `REQ-SCO-GAT-*` | [PRD/00-visao-escopo.md](PRD/00-visao-escopo.md) | [SPEC/05-backlog-mvp-glossario.md](SPEC/05-backlog-mvp-glossario.md) | Delimitacao do backlog, itens adiados e gatilhos de promocao. |
| `REQ-RBAC-*` | [PRD/01-usuarios-rbac.md](PRD/01-usuarios-rbac.md) | [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md) | Perfis, escopos de acesso, bypass cross-tenant e matrizes de permissao. |
| `REQ-JOR-001` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md) | Cobertura da abertura de demandas e fronteiras do modulo operacional. |
| `REQ-JOR-002`, `REQ-JOR-003` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Triagem por jurisdicao e score operacional. |
| `REQ-JOR-004`, `REQ-JOR-005` | [PRD/02-jornada-usuario.md](PRD/02-jornada-usuario.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Execucao em campo, alocacao manual e auditoria administrativa. |
| `REQ-FUNC-001`, `REQ-FUNC-002` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Maquina de estados, filtros eliminatorios e regras de fila. |
| `REQ-FUNC-003` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Cadastro de maquinario, ajudantes, operadores e entidades operacionais. |
| `REQ-FUNC-004` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Expediente, assistencia offline, checkpoint manual e rastreabilidade de ajudantes. |
| `REQ-FUNC-005` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Agrupamento e criacao multipla. |
| `REQ-FUNC-006`, `REQ-FUNC-007`, `REQ-FUNC-008`, `REQ-FUNC-009` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Agendamentos, cronometros, destaque visual e tratamento de cancelamentos. |
| `REQ-FUNC-010` | [PRD/03-requisitos-funcionais.md](PRD/03-requisitos-funcionais.md) | [SPEC/01-modulos-plataforma.md](SPEC/01-modulos-plataforma.md), [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Modelagem espacial, adjacencias e suporte ao motor de score. |
| `REQ-NFR-001`, `REQ-NFR-003` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Monorepo, stack base, backend e decisoes arquiteturais. |
| `REQ-NFR-002` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Experiencia PWA mobile-first, conectividade e operacao offline. |
| `REQ-NFR-004` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/02-modelo-dados.md](SPEC/02-modelo-dados.md) | Persistencia relacional e isolamento multi-tenant. |
| `REQ-NFR-005`, `REQ-NFR-006`, `REQ-NFR-007` | [PRD/04-requisitos-nao-funcionais.md](PRD/04-requisitos-nao-funcionais.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | JWT, refresh tokens, rate limiting e politicas de autenticacao. |
| `REQ-ACE-001`, `REQ-ACE-008` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/04-rbac-permissoes.md](SPEC/04-rbac-permissoes.md) | Isolamento RBAC e auditoria cross-tenant. |
| `REQ-ACE-002`, `REQ-ACE-003`, `REQ-ACE-004`, `REQ-ACE-005`, `REQ-ACE-006` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md) | Aceites ligados a estados, score, alocacao manual, UI e cancelamentos. |
| `REQ-ACE-007` | [PRD/05-criterios-aceite.md](PRD/05-criterios-aceite.md) | [SPEC/00-visao-arquitetura.md](SPEC/00-visao-arquitetura.md) | Seguranca de token; cobertura marcada como alinhada a arquitetura base. |
| `REQ-MET-*` | [PRD/06-metricas-riscos.md](PRD/06-metricas-riscos.md) | [SPEC/03-fila-scoring-estados-sla.md](SPEC/03-fila-scoring-estados-sla.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Medicao de SLA, atendimento e operacao em campo. |
| `REQ-RISK-*` | [PRD/06-metricas-riscos.md](PRD/06-metricas-riscos.md) | [SPEC/05-backlog-mvp-glossario.md](SPEC/05-backlog-mvp-glossario.md), [SPEC/06-definicoes-complementares.md](SPEC/06-definicoes-complementares.md) | Riscos de rollout, conectividade e limites do MVP. |

## Resultados da auditoria PRD ↔ SPEC

Resumo agregado de 7 modulos auditados (gerado em 2026-03-20).

| Metrica | Valor |
|---------|-------|
| Total achados | 37 |
| Bloqueantes | 7 |
| Importantes | 28 |
| Menores | 2 |
| Coberto | 35 |
| Parcial | 21 |
| Nao coberto | 8 |

Detalhes por modulo e JSON global em [docs/audit/output/global/consolidated-global.json](audit/output/global/consolidated-global.json).

---

### Auditoria M01 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `SPEC-M01-001` - `REQ-SCO-003` sem cobertura localizavel nas SPECs revistas do modulo (`docs/SPEC/00-visao-arquitetura.md` + complemento `docs/SPEC/05-backlog-mvp-glossario.md`).
- **Importantes**
  - `PRD-M01-001` - referencias locais do PRD dispersam a evidencia do modulo para SPECs fora da paridade core declarada.
  - `PRD-M01-002` - secoes de Fase 2 e gatilhos dependem da matriz global para localizar a SPEC secundaria.
  - `SPEC-M01-002` - `REQ-SCO-GAT-001..004` nao aparecem na SPEC secundaria `docs/SPEC/05-backlog-mvp-glossario.md`.
  - `SPEC-M01-003` - `REQ-SCO-F2-005` nao foi localizado na lista de backlog tecnico adiado.
  - `SPEC-M01-004` - `REQ-OBJ-004` / `REQ-SCO-004` ficam apenas parcialmente cobertos em `docs/SPEC/00-visao-arquitetura.md`.
- **Resumo de cobertura**
  - `Coberto`: 13
  - `Parcial`: 4
  - `Nao coberto`: 6

---

### Auditoria M02 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - Nenhum bloqueio PRD↔SPEC identificado no modulo.
- **Importantes**
  - `PRD-M02-001` - o PRD nao explicita se `Empreiteiro` e `Operador de Maquinario` podem consultar cadastros auxiliares alem das proprias demandas, expediente e fila.
  - `SPEC-M02-001` - a matriz tecnica abre leituras de contexto para `Empreiteiro` e `Operador` sem justificar como esse acesso continua aderente ao escopo restrito descrito no PRD.
- **Resumo de cobertura**
  - `Coberto`: 4
  - `Parcial`: 2
  - `Nao coberto`: 0

---

### Auditoria M03 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - Nenhum bloqueio PRD↔SPEC identificado no modulo.
- **Importantes**
  - `PRD-M03-001` - o PRD nao fixa se a localizacao inicial da demanda usa entidade espacial estruturada do Core, checkpoint manual ou campo livre.
  - `SPEC-M03-001` - `01-modulos-plataforma` cobre a abertura da demanda, mas nao explicita a captura da localizacao de trabalho no momento da requisicao.
  - `SPEC-M03-002` - `03-fila-scoring-estados-sla` cobre prioridade maxima, Regra Zero e empilhamento, mas nao transforma em contrato textual a exigencia de UI sem bloqueio e de fila estrita do operador.
  - `SPEC-M03-003` - `03-fila-scoring-estados-sla` introduz aprovacao automatica de cancelamento apos 24 horas sem justificar essa decisao no contexto do PRD.
- **Resumo de cobertura**
  - `Coberto`: 2
  - `Parcial`: 3
  - `Nao coberto`: 0

---

### Auditoria M04 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `CROSS-M04-001` - conflito PRD↔SPEC entre o filtro estrito de jurisdicao/compatibilidade (`REQ-FUNC-002`) e a `Regra Zero` de alocacao manual por `operadorAlocadoId` (`REQ-FUNC-006`).
- **Importantes**
  - `PRD-M04-001` - os apontadores `-> SPEC` do PRD nao refletem toda a cobertura exigida pela matriz do M04, sobretudo em `02-modelo-dados.md` e `06-definicoes-complementares.md`.
  - `PRD-M04-002` - o PRD nao fixa a precedencia entre filtro logistico estrito e alocacao manual explicita.
  - `SPEC-M04-001` - `03-fila-scoring-estados-sla` escolhe um bypass manual amplo na `Regra Zero` sem esclarecer se os hard filters continuam obrigatorios.
  - `SPEC-M04-002` - `01-modulos-plataforma` e `02-modelo-dados` nao fecham o contrato funcional de agrupamento/bulk pedido por `REQ-FUNC-005`.
  - `SPEC-M04-003` - `06-definicoes-complementares` nao localiza explicitamente o calculo/persistencia de `tempoExecucaoMs`.
  - `SPEC-M04-004` - `03-fila-scoring-estados-sla` cobre destaque visual de prioridade `MAXIMA`, mas nao explicita UI nao bloqueante nem preservacao das restantes demandas.
- **Resumo de cobertura**
  - `Coberto`: 6
  - `Parcial`: 4
  - `Nao coberto`: 0

---

### Auditoria M05 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `SPEC-M05-002` - `00-visao-arquitetura` nao especifica os criterios minimos da politica de palavra-passe de `REQ-NFR-007`, nem o bloqueio de reutilizacao das ultimas 3 credenciais.
- **Importantes**
  - `SPEC-M05-001` - `00-visao-arquitetura` cobre thresholds de rate limiting, mas nao fecha endpoints exatos, `HTTP 429` e bloqueio temporario de 15 minutos exigidos por `REQ-NFR-006`.
  - `SPEC-M05-003` - `02-modelo-dados` cobre isolamento por `obraId` e auditabilidade transacional, mas deixa parcial a rastreabilidade consistente dos recursos operacionais pedida por `REQ-NFR-004`.
- **Resumo de cobertura**
  - `Coberto`: 4
  - `Parcial`: 2
  - `Nao coberto`: 1

---

### Auditoria M06 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `CROSS-M06-001` - `REQ-ACE-003` diverge entre o cenario do PRD, que faz a jurisdicao/logistica superar a preferencia manual, e a SPEC, que preserva a `Regra Zero` para `operadorAlocadoId`.
  - `CROSS-M06-002` - `REQ-ACE-006` exige revisao administrativa antes do encerramento definitivo, mas `03-fila-scoring-estados-sla` aprova cancelamentos automaticamente apos 24 horas sem decisao humana.
- **Importantes**
  - `PRD-M06-001` - `REQ-ACE-007` continua apenas como pendente de migracao em `05-criterios-aceite`, sem criterio testavel nem cenario de aceite.
  - `PRD-M06-002` - o PRD usa "preferencia manual de operador" em `REQ-ACE-003` sem ligar explicitamente o termo a `operadorAlocadoId` ou a outro mecanismo tecnico.
  - `SPEC-M06-001` - `03-fila-scoring-estados-sla` resolve `REQ-ACE-003` a favor do bypass manual sem justificar a convivencia com o cenario de aceite.
  - `SPEC-M06-002` - `03-fila-scoring-estados-sla` destaca prioridade `MAXIMA`, mas nao explicita que as restantes demandas permanecem visiveis e rolaveis na UI mobile de `REQ-ACE-005`.
  - `SPEC-M06-003` - `03-fila-scoring-estados-sla` introduz aprovacao automatica apos 24 horas em `REQ-ACE-006`, adicionando comportamento nao antecipado pelo criterio de aceite.
- **Resumo de cobertura**
  - `Coberto`: 4
  - `Parcial`: 4
  - `Nao coberto`: 0

---

### Auditoria M07 - bloco para `docs/traceability.md`

- **Bloqueantes**
  - `CROSS-M07-001` - `REQ-MET-002` aponta no PRD para `01-modulos-plataforma`, mas a paridade oficial e a matriz global de M07 distribuem metricas e riscos por `02`, `03`, `05` e `06`, deixando sem fonte tecnica canonica o indicador de adocao e engajamento.
  - `SPEC-M07-002` - os SPEC revistos nao definem a fonte do denominador "operadores ativos na folha da quinzena" nem o contrato analitico necessario para verificar `REQ-MET-002`.
- **Importantes**
  - `PRD-M07-001` - `REQ-MET-002` usa no PRD uma referencia cruzada para `01-modulos-plataforma` fora do conjunto de paridade oficial de M07.
  - `PRD-M07-002` - `REQ-RISK-001` identifica o risco de governanca da taxonomia operacional, mas nao explicita a mitigacao esperada apesar do titulo "Riscos e mitigacoes".
  - `SPEC-M07-001` - `02-modelo-dados` nao fecha atributos ou eventos canonicos para calcular `Horas Disponiveis` versus `Horas em Operacao` em `REQ-MET-001`.
  - `SPEC-M07-003` - `05-backlog-mvp-glossario` define a taxonomia espacial, mas nao traduz `REQ-RISK-001` em fluxo tecnico de governanca, validacao ou auditoria cadastral.
- **Resumo de cobertura**
  - `Coberto`: 2
  - `Parcial`: 2
  - `Nao coberto`: 1

---

## Referencias

- [README dos docs](README.md)
- [Indice mestre PRD](PRD/_index.md)
- [Indice mestre SPEC](SPEC/_index.md)
- [JSON global consolidado](audit/output/global/consolidated-global.json)
