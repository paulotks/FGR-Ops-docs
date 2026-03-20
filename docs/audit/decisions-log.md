# Decisions Log — Fase 0 (Triagem de produto)

Este registo centraliza as decisões de produto necessárias antes das correções de PRD/SPEC das fases seguintes.

## Como usar

- `Data`: data da decisão (AAAA-MM-DD).
- `Participantes`: nomes ou papéis que tomaram a decisão.
- `Decisão`: opção escolhida (A/B/C... ou texto curto).
- `Justificação`: racional de negócio e impacto esperado.
- `Achados resolvidos`: IDs marcados como resolvidos após aplicação e re-auditoria.
- `Estado`: `Pendente` até decisão formal; depois `Decidido`.

---

## DEC-001 — Regra Zero vs filtros (`operadorAlocadoId`)

-- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operações, Stakeholders de Negócio
- **Contexto:** definir se `operadorAlocadoId` sobrepõe hard filters ou se deve respeitá-los.
- **Opções em análise:**
  - A) `operadorAlocadoId` sobrepõe hard filters.
  - B) `operadorAlocadoId` respeita hard filters.
  - C) Comportamento híbrido condicionado por estado/regra.
- **Decisão:** C) Comportamento híbrido. Em criação manual por `AdminOperacional`/`UsuarioInternoFGR`, `operadorAlocadoId` pode direcionar demanda para qualquer operador, inclusive fora da zona, como exceção explícita e auditável. Essa alocação sobrepõe as regras automáticas de distribuição/elegibilidade (jurisdição, proximidade e balanceamento), mas não remove o motor de priorização da fila.
- **Justificação:** O motor automático continua como padrão de eficiência operacional. A alocação manual permanece como exceção de gestão para cenários reais de operação. A ordem da fila do operador é usada como organização recomendada de atendimento e não como bloqueio rígido de execução, permitindo ajustes operacionais em campo (ex.: despacho por rádio), com rastreabilidade.
- **Nota MVP:** Na tela de alocação do `UsuarioInternoFGR`, deve existir alerta visual indicando operadores fora da zona definida no momento da seleção. Esta feature é importante para usabilidade e redução de erro, mas não é prioridade para o MVP.
- **Achados resolvidos:** `CROSS-M04-001`, `CROSS-M06-001`, `SPEC-M04-001`, `SPEC-M06-001`, `PRD-M04-002`, `PRD-M06-002`
- **Aplicação (Fase 1.1 — 2026-03-20):**
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-002` qualificado como fluxo automático com excepção explícita para `operadorAlocadoId`; `REQ-FUNC-006` documenta modelo híbrido e ordem recomendada.
  - `PRD/05-criterios-aceite.md`: `REQ-ACE-003` reescrito com terminologia canónica (`operadorAlocadoId`), dois cenários Gherkin (adjacência vs alocação manual; excepção auditável fora da zona).
  - `SPEC/03-fila-scoring-estados-sla.md`: Regra Zero documenta DEC-001, Hard Filter explicita isenção para alocação manual, nota de rastreio alinhada, regra de conflito actualizada.
  - Artefactos regenerados: `M04/consolidated.json`, `M04/traceability.csv`, `M04/traceability-stub.md`, `M06/consolidated.json`, `M06/traceability.csv`, `M06/traceability-stub.md`.

## DEC-002 — Cancelamento automático vs revisão administrativa

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operações, Logística, Stakeholders de Negócio
- **Contexto:** alinhar política para cancelamento/revisão (auto-aprovação em 24h vs revisão humana).
- **Opções em análise:**
  - A) Auto-aprovação em 24h sem intervenção humana.
  - B) Revisão administrativa obrigatória antes de cancelamento.
  - C) Modelo misto com critérios de exceção.
- **Decisão:** A) Auto-aprovação sem intervenção humana, com encerramento por estouro de SLA no fim do expediente da obra. O horário de expediente é parametrizável por obra (ex.: 06h-17h), e cada obra pode manter a própria janela operacional.
- **Justificação:** A decisão privilegia fluidez operacional e redução de backlog administrativo, centralizando o encerramento automático no marco de fim de expediente de cada obra em vez de prazo fixo absoluto. O processo mantém governança por exigir rastreabilidade explícita do motivo de encerramento por SLA estourado e visibilidade gerencial para revisão no dia útil seguinte.
- **Nota MVP:** O cancelamento automático deve gravar trilha auditável obrigatória com origem "estouro de SLA no fim do expediente", ator de sistema e timestamp. `UsuarioInternoFGR`/`AdminOperacional` devem ter visão dedicada no dia seguinte para revisão pós-facto e ação corretiva/operacional quando necessário.
- **Achados resolvidos:** `CROSS-M06-002`, `SPEC-M03-003`, `SPEC-M06-003`
- **Aplicação (Fase 1.2 — 2026-03-20):**
  - `PRD/05-criterios-aceite.md`: `REQ-ACE-006` reescrito — título da secção actualizado para "Cancelamento de demandas em campo e encerramento por SLA"; requisito reformulado para auto-encerramento por estouro de SLA no fim do expediente parametrizável por obra; 3 cenários Gherkin: transição para `PENDENTE_APROVACAO`, encerramento automático no fim do expediente, revisão pós-facto no dia útil seguinte.
  - `SPEC/03-fila-scoring-estados-sla.md`: Fluxo `PENDENTE_APROVACAO` actualizado — prazo de 24h substituído por encerramento no fim do expediente da obra (parametrizável); trilha auditável obrigatória com campos `origem`, `ator`, `timestamp`, `motivo`; visão dedicada de revisão pós-facto para `UsuarioInternoFGR`/`AdminOperacional`; referência a DEC-002.
  - Referências cruzadas corrigidas em `PRD/02-jornada-usuario.md`, `PRD/03-requisitos-funcionais.md`, `SPEC/01-modulos-plataforma.md` e `SPEC/03-fila-scoring-estados-sla.md` (novo anchor da secção).
  - Artefactos regenerados: `M03/consolidated.json`, `M03/traceability.csv`, `M03/traceability-stub.md`, `M06/consolidated.json`, `M06/traceability.csv`, `M06/traceability-stub.md`.

## DEC-003 — Fonte canónica para `REQ-MET-002`

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operacoes, Engenharia, Dados/BI, Stakeholders de Negocio
- **Contexto:** definir onde fica o contrato analítico canónico de "operadores ativos na folha da quinzena".
- **Opções em análise:**
  - A) PRD como fonte canónica; SPEC referencia implementação.
  - B) SPEC como contrato canónico técnico; PRD aponta para SPEC.
  - C) Contrato dividido por camadas (PRD definição de negócio, SPEC definição operacional).
- **Decisão:** C) Contrato dividido por camadas. O PRD fica como fonte canonica da intencao de negocio da metrica (`REQ-MET-002`), enquanto a SPEC fica como fonte canonica do contrato operacional de medicao (formula, denominador, regras de elegibilidade, janela temporal e evidencias auditaveis).
- **Justificação:** A arquitetura tatica exige separacao clara de responsabilidades entre camada de negocio e camada operacional. Esta decisao preserva legibilidade para stakeholders e garante precisao tecnica para implementacao e auditoria, eliminando a ambiguidade atual da trilha PRD->SPEC e fechando a lacuna do denominador "operadores ativos na folha da quinzena".
- **Nota MVP:** Criar secao unica na SPEC para `REQ-MET-002` com definicao formal do denominador, regra de janela da quinzena, timezone, criterios de inclusao/exclusao, politica de deduplicacao por operador e artefato de validacao. Atualizar o PRD para referenciar explicitamente essa secao.
- **Achados resolvidos:** `CROSS-M07-001`, `SPEC-M07-002`, `PRD-M07-001`
- **Aplicação (Fase 1.5 — 2026-03-20):**
  - `SPEC/06-definicoes-complementares.md`: Adicionada secção "Contrato analítico `REQ-MET-002` — Adoção e engajamento operacional" com sete subsecções: Fórmula (numerador = operadores distintos com pelo menos 1 acção; denominador = operadores activos na folha da quinzena), Janela temporal da quinzena (Q1: 1-15, Q2: 16-fim do mês, timezone `America/Sao_Paulo`), Critérios de inclusão/exclusão (tabela com 6 cenários: admissão, desligamento, transferência, férias/licença), Política de deduplicação (contagem única por `User.id`+`obraId`, timestamp de origem offline), Fonte do denominador e integração (contrato mínimo com RH/folha: endpoint, payload, reconciliação quinzenal), Artefato de validação (tabela com 7 campos auditáveis, acessível via painel administrativo). `REQ-MET-002` adicionado ao rastreio PRD do ficheiro.
  - `PRD/06-metricas-riscos.md`: Referência SPEC de `REQ-MET-002` corrigida — apontava para `01-modulos-plataforma.md#modulo-machinery-link-mvp` (fora da paridade oficial de M07); agora aponta para `06-definicoes-complementares.md#contrato-analitico-req-met-002`.
  - Artefactos regenerados: `M07/consolidated.json`, `M07/traceability.csv`, `M07/traceability-stub.md`.

## DEC-004 — Política de palavra-passe `REQ-NFR-007`

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operações, Segurança, Engenharia, Stakeholders de Negócio
- **Contexto:** fixar critérios mínimos da política de palavra-passe e local de documentação canónica.
- **Opções em análise:**
  - A) Definir critérios mínimos em PRD e detalhe técnico em SPEC.
  - B) Definir política completa em SPEC e manter PRD de alto nível.
  - C) Definir política completa em PRD e referenciar SPEC apenas para implementação.
- **Decisão:** A) Definir critérios mínimos em PRD e detalhe técnico em SPEC, com política segmentada por perfil. Para perfis de Campo (`Empreiteiro` e `Operador`), adotar autenticação simplificada no app mobile (`Usuário + PIN`) com controles compensatórios de segurança. Para perfis Administrativos/Suporte (demais perfis), manter política de palavra-passe forte conforme `REQ-NFR-007` (mínimo de 8 caracteres, classes obrigatórias e bloqueio de reutilização das últimas 3).
- **Justificação:** A segmentação equilibra usabilidade operacional em campo e segurança corporativa nos perfis de retaguarda. O PRD permanece como fonte dos critérios mínimos e da regra por perfil, enquanto a SPEC torna-se fonte canónica do contrato técnico de autenticação (fluxos, lockout, rate limiting por endpoint/perfil, auditoria e gestão de sessão), fechando a lacuna bloqueante identificada em `SPEC-M05-002`.
- **Nota MVP:** Para login de Campo com `Usuário + PIN`, implementar no mínimo: limite de tentativas com bloqueio temporário progressivo, resposta de erro não enumerável, trilha auditável de autenticação e política de sessão curta. A SPEC deve explicitar os parâmetros operacionais.
- **Achados resolvidos:** `SPEC-M05-002`
- **Aplicação (Fase 1.4 — 2026-03-20):**
  - `SPEC/00-visao-arquitetura.md`: Adicionada ADR D6 (Política de Autenticação e Palavra-passe — segmentação por perfil) com três subsecções: 6.1 Perfis de Campo (Empreiteiro, Operador) com autenticação simplificada por Usuário+PIN (lockout progressivo, sessão curta de 12h, trilha auditável, troca a cada 90 dias, hash bcrypt); 6.2 Perfis Administrativos/Suporte com palavra-passe forte (8 caracteres mínimos, 4 classes obrigatórias, bloqueio de reutilização das últimas 3, lockout de 15 min, troca a cada 180 dias); 6.3 Regras transversais (rate limiting por endpoint/perfil, gestão de sessão com idle timeout de 30 min para campo, tabela `AuthAuditLog`). Princípios arquitecturais (§1) actualizados para referenciar D6.
  - `PRD/04-requisitos-nao-funcionais.md`: `REQ-NFR-007` actualizado — título alterado para "Política de autenticação segmentada por perfil"; texto reformulado para documentar dois grupos (Campo: Usuário+PIN com controlos compensatórios; Administrativo: palavra-passe forte); referência SPEC apontada para novo anchor `#politica-autenticacao-senha`.
  - Artefactos regenerados: `M05/consolidated.json`, `M05/traceability.csv`, `M05/traceability-stub.md`.

---

## Fase 2 — Correcoes de achados importantes

As correcoes abaixo nao exigiram decisao de produto nova; derivam directamente dos achados da auditoria e das decisoes ja tomadas na Fase 0.

### Fase 2.1 — SPEC/03-fila-scoring-estados-sla.md (UI nao bloqueante)

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M03-002`, `SPEC-M04-004`, `SPEC-M06-002`
- **Correcao:** Passo 3 (Destaque Visual de Prioridade Maxima) expandido para explicitar contrato de experiencia da fila do operador: UI nao bloqueante, demandas restantes visiveis e rolaveis na UI mobile. `REQ-JOR-004` adicionado a linha de rastreio PRD.

### Fase 2.2 — SPEC/00-visao-arquitetura.md (Checkpoint Manual + Rate Limiting)

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M01-004`, `SPEC-M05-001`
- **Correcao SPEC-M01-004:** Seccao Arquitetura Tatica (DDD) expandida para explicitar Checkpoint Manual como mecanismo de localizacao declarada sem GPS/IoT, posicao neutra na primeira demanda do turno e relacao com `REQ-OBJ-004`/`REQ-SCO-004`.
- **Correcao SPEC-M05-001:** ADR de Rate Limiting expandida com contrato normativo conforme `REQ-NFR-006`: endpoints exactos (`/auth/login`, `/auth/pin`, `POST /demandas`, `POST /demandas/bulk`), `HTTP 429 Too Many Requests` com `Retry-After`, bloqueio temporario de 15 minutos por IP ou utilizador.

### Fase 2.3 — SPEC/05-backlog-mvp-glossario.md (Backlog, Gatilhos, Governanca)

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M01-002`, `SPEC-M01-003`, `SPEC-M07-003`
- **Correcao SPEC-M01-002:** Adicionada seccao "Criterios de promocao para Fase 2" com tabela cobrindo `REQ-SCO-GAT-001..004`. Linha de rastreio PRD actualizada.
- **Correcao SPEC-M01-003:** Adicionado item explicito para `REQ-SCO-F2-005` (migracao de dados legados e roteirizacao geocolocada) na lista de itens adiados.
- **Correcao SPEC-M07-003:** Adicionada seccao "Governanca da taxonomia espacial (`REQ-RISK-001`)" com 4 regras tecnicas: validacao referencial, auditoria cadastral, restricao de exclusao e relatorio de consistencia.

### Fase 2.4 — SPEC/01-modulos-plataforma.md + SPEC/02-modelo-dados.md

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M03-001`, `SPEC-M04-002`, `SPEC-M04-003`, `SPEC-M07-001`
- **Correcao SPEC-M03-001:** Capacidade #1 (Solicitacao) expandida para explicitar captura obrigatoria de localizacao de trabalho (`SetorOperacional`, opcionalmente `Quadra`/`Lote`) no momento da abertura da demanda.
- **Correcao SPEC-M04-002:** Adicionada capacidade #2 (Agrupamento e criacao multipla) com contrato funcional explicito: payload bulk, demandas independentes, `DemandaGrupo` para rastreio.
- **Correcao SPEC-M04-003:** Adicionada especificacao de `tempoExecucaoMs` como campo calculado (`finalizadoEm - iniciadoEm`) persistido na conclusao. Timestamps offline prevalecem.
- **Correcao SPEC-M07-001:** Adicionada seccao "Medicao canonica de tempo operacional (`REQ-MET-001`)" com definicoes de Horas Disponiveis, Horas em Operacao e consulta de referencia.

### Fase 2.5 — SPEC/06-definicoes-complementares.md (Rastreabilidade)

- **Data:** 2026-03-20
- **Achados resolvidos:** `SPEC-M05-003`
- **Correcao:** Adicionada seccao "Politica de rastreabilidade dos recursos operacionais (`REQ-NFR-004`)" com tabela uniforme de auditabilidade para todas as entidades operacionais, regras transversais de `ResourceAuditLog` e politica de soft-delete.

### Fase 2.6 — Ficheiros PRD (referencias cruzadas)

- **Data:** 2026-03-20
- **Achados resolvidos:** `PRD-M01-001`, `PRD-M01-002`, `PRD-M02-001`, `PRD-M03-001`, `PRD-M04-001`, `PRD-M06-001`, `PRD-M07-002`
- **PRD-M01-001:** Apontadores SPEC adicionados em `REQ-OBJ-003`, `REQ-OBJ-004`, `REQ-SCO-003`, `REQ-SCO-004` de `PRD/00-visao-escopo.md`.
- **PRD-M01-002:** Apontadores SPEC adicionados nas seccoes Fora do Escopo e Criterios de Promocao para `05-backlog-mvp-glossario.md`.
- **PRD-M02-001:** `PRD/01-usuarios-rbac.md` actualizado — `REQ-RBAC-005` e `REQ-RBAC-006` explicitam leitura de contexto auxiliar para Empreiteiro e Operador.
- **PRD-M03-001:** `PRD/02-jornada-usuario.md` — `REQ-JOR-001` agora especifica seleccao de `SetorOperacional` (obrigatorio) e `Quadra`/`Lote` (opcional).
- **PRD-M04-001:** `PRD/03-requisitos-funcionais.md` — apontadores SPEC adicionados para `REQ-FUNC-003`, `REQ-FUNC-004`, `REQ-FUNC-005`, `REQ-FUNC-007`, `REQ-FUNC-010`.
- **PRD-M06-001:** `PRD/05-criterios-aceite.md` — `REQ-ACE-007` migrado para seccao "Seguranca de token e gestao de sessao" com 3 cenarios Gherkin (expiracao/renovacao, invalidacao por logout, deteccao de reuso).
- **PRD-M07-002:** `PRD/06-metricas-riscos.md` — `REQ-RISK-001` agora inclui mitigacao explicita com responsavel, validacao, auditoria, restricao de exclusao e relatorio. Apontador SPEC actualizado.

---

## Correções directas (sem decisão de produto pendente)

### Fase 1.3 — Cobertura de `REQ-SCO-003` (`SPEC-M01-001`)

- **Data:** 2026-03-20
- **Tipo:** Lacuna documental — gap de cobertura SPEC sem ambiguidade de produto.
- **Contexto:** O PRD define `REQ-SCO-003` (Gestão de Recursos: Cadastro de Maquinário e Ajudantes) e aponta para `SPEC/02-modelo-dados.md`, que já documenta as entidades. Contudo, o SPEC primário do M01 (`SPEC/00-visao-arquitetura.md`) não referenciava `REQ-SCO-003` nem mencionava os atributos de cadastro, ficando sem cobertura localizável no escopo de auditoria do módulo.
- **Correcção aplicada:**
  - `SPEC/00-visao-arquitetura.md` §Arquitetura Tática (DDD): adicionado `REQ-SCO-003` ao rastreio PRD; texto expandido para documentar cadastro de `Maquinario` (placa, TipoMaquinario, Servico vinculado, propriedade FGR/Terceiro) e `Ajudante` (recurso humano sem credencial própria), com referência cruzada a `02-modelo-dados.md`.
- **Artefactos regenerados:** `M01/consolidated.json`, `M01/traceability.csv`, `M01/traceability-stub.md`.
- **Achado resolvido:** `SPEC-M01-001` (bloqueante → resolvido)

---

## Fase 3 — Correcção de achados menores e revalidação global

### Fase 3.1 — Nomenclatura e justificativa de leitura de contexto (M02)

- **Data:** 2026-03-20
- **Tipo:** Correcção documental — nomenclatura inconsistente e decisão de design sem justificativa.
- **Achados resolvidos:** `PRD-M02-002`, `SPEC-M02-002`, `SPEC-M02-001`
- **Correcções aplicadas:**
  - **PRD-M02-002 (menor):** `PRD/01-usuarios-rbac.md` — adicionada nota de nomenclatura na secção "Princípios de autorização do produto" fixando `Operador de Maquinário` (nome completo na matriz base) e `Operador` (nome curto) como sinónimos oficiais do perfil `REQ-RBAC-006`.
  - **SPEC-M02-002 (menor):** `SPEC/04-rbac-permissoes.md` — adicionada nota de nomenclatura na secção "Perfis de acesso" e anotação `(sinónimo: Operador de Maquinário)` no item 6 da lista de perfis, alinhando terminologia com o PRD.
  - **SPEC-M02-001 (importante):** `SPEC/04-rbac-permissoes.md` — adicionada decisão de design na secção "Decisões de design" justificando a permissão de leitura (`read`) em recursos de contexto para `Empreiteiro` e `Operador`: estritamente funcional, aderente a `REQ-RBAC-005` e `REQ-RBAC-006`, limitada ao tenant da obra atribuída, sem bypass cross-tenant nem capacidade de mutação ou exportação.
- **Artefactos regenerados:** `M02/consolidated.json`, `M02/traceability.csv`, `M02/traceability-stub.md`.

### Fase 3.2 — Revalidação global

- **Data:** 2026-03-20
- **Resultado:** Todos os 37 achados resolvidos (7 bloqueantes, 28 importantes, 2 menores). Cobertura: 62 requisitos cobertos, 2 parciais (M01), 0 não cobertos. Risco geral: baixo.
- **Artefactos regenerados:** `consolidated-global.json`, `traceability.md`.
