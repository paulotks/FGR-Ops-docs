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

- **Estado:** Decidido *(Superseded por DEC-019 — 2026-04-13; o fluxo de `PENDENTE_APROVACAO` e `SolicitacaoCancelamento` foi removido do MVP)*
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

## DEC-005 — Localizacao obrigatoria, locais externos e ponto de origem (`REQ-JOR-001`)

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Operacoes, Stakeholders de Negocio
- **Contexto:** Alinhar o modelo de localizacao da solicitacao do empreiteiro com a realidade operacional de obras de condominios horizontais, infraestrutura e casas. O requisito original definia `Quadra`/`Lote` como opcionais e nao distinguia servicos de execucao local de servicos de transporte de material.
- **Opcoes em analise:**
  - A) Manter Quadra/Lote opcionais; localizacao generica.
  - B) Tornar Quadra/Lote obrigatorios; criar entidade para locais externos; tipificar servicos de transporte.
  - C) Modelo generico de "ponto de localizacao" sem distincao.
- **Decisao:** B) Localizacao obrigatoria com dois modos. O empreiteiro seleciona obrigatoriamente **Quadra/Lote** ou **Local Externo** (Portaria, Pulmao, Garagem, etc.). O `SetorOperacional` e derivado automaticamente. A filtragem mutua entre Servico e Maquinario melhora a UX ao restringir opcoes invalidas. *(Nota: o escopo de transporte de material — `exigeTransporte`, `PontoOrigem` — foi subsequentemente revisto por DEC-006 e adiado para pos-MVP.)*
- **Justificacao:** A obrigatoriedade de Quadra/Lote reflete o fluxo real do empreiteiro em campo. Locais como Portaria, Pulmao e Garagem precisam ser endereçaveis no sistema sem pertencer a malha de Quadra/Lote. A filtragem mutua entre Servico e Maquinario melhora a UX ao restringir opcoes invalidas.
- **Nota MVP:** A UX deve oferecer alternancia simples entre Quadra/Lote e Local Externo na interface de solicitacao.
- **Aplicacao (2026-03-20):**
  - `PRD/02-jornada-usuario.md`: `REQ-JOR-001` reescrito — localizacao obrigatoria (Quadra/Lote ou Local Externo), `SetorOperacional` derivado, filtragem mutua Servico/Maquinario, material e destino opcionais, descricao complementar recomendada para movimentacao.
  - `SPEC/01-modulos-plataforma.md`: Capacidade #1 (Solicitacao) actualizada para reflectir novo fluxo com dois modos de localizacao, material e destino opcionais.
  - `SPEC/02-modelo-dados.md`: Adicionada entidade `LocalExterno`; `Demanda` expandida com atributos de localizacao (`localTipo`), material e destino opcionais, e `descricaoAdicional`. `REQ-JOR-001` adicionado ao rastreio PRD.

## DEC-006 — Revisao do escopo de transporte de material no MVP (`REQ-JOR-001`)

- **Estado:** Decidido
- **Data:** 2026-03-20
- **Participantes:** Produto, Logistica de campo, Operacoes
- **Contexto:** Validacao de campo com auxiliar de Logistica revelou que o fluxo real de movimentacao de massas (Grunt, Concreto, etc.) difere do modelo de entrega de material desenhado em DEC-005. Na pratica, o empreiteiro nao solicita massas como pedido de material externo — os materiais ja se encontram na frente de obras, tipicamente em caixa d'agua dentro ou na frente do lote. As demandas sao para o operador de maquinas **movimentar** a massa existente (ex.: subir grunt para laje, descer massa, levar para lote ao lado). O fluxo actual no sistema legado utiliza: Servico=Movimentacao, Equipamento=Munck, Material=Grunt, Localizacao=Quadra/Lote de origem, Destino=Quadra de Destino (geralmente interno ao lote), Descricao=texto livre.
- **Opcoes em analise:**
  - A) Manter `exigeTransporte`, `PontoOrigem` e fluxo de entrega formal no MVP.
  - B) Adiar o fluxo de entrega formal para pos-MVP; no MVP tratar movimentacao de massas como demanda regular com material e destino opcionais e descricao em texto livre.
  - C) Remover completamente o conceito de entrega de material do roadmap.
- **Decisao:** B) Adiar entrega formal de material para pos-MVP. No MVP, servicos de movimentacao de massas sao tratados como demandas regulares: o empreiteiro informa localizacao (Quadra/Lote ou Local Externo), seleciona servico e equipamento com filtragem mutua, opcionalmente seleciona material (para `fator_material`) e informa destino (Quadra/Lote), e detalha a operacao no campo de descricao. As entidades `PontoOrigem`, a flag `exigeTransporte` no `Servico` e os campos polimorficos de origem na `Demanda` ficam adiados para Fase 2, onde poderao ser reaproveitados para um servico de entrega de material de origem externa.
- **Justificacao:** O material (massas, grunt, concreto) ja se encontra na frente de obras e nao precisa de logistica de entrega no MVP. O fluxo real e de movimentacao local, adequadamente atendido pelo formulario existente com descricao em texto livre. A implementacao de entrega formal de material (`PontoOrigem`, `exigeTransporte`) nao e inutil — e reaproveitavel em fase posterior para cenarios de entrega de material de origens externas (centrais, usinas) — mas adiciona complexidade desnecessaria ao MVP.
- **Nota MVP:** A UI do empreiteiro permanece com o fluxo simples: localizacao + servico/equipamento + material (opcional) + destino (opcional) + descricao.
- **Aplicacao (2026-03-20):**
  - `PRD/02-jornada-usuario.md`: `REQ-JOR-001` revisto — subsecao "Servicos com transporte de material" substituida por "Material e destino (opcionais)" com nota sobre movimentacao de massas e adiamento de entrega formal; descricao complementar recomendada para movimentacao.
  - `SPEC/01-modulos-plataforma.md`: Capacidade #1 simplificada — removidas referencias a `exigeTransporte` e `PontoOrigem`; material e destino descritos como opcionais.
  - `SPEC/02-modelo-dados.md`: Removida entidade `PontoOrigem`; removidos `exigeTransporte` e `pontoOrigemPadraoId` do `Servico`; `Demanda` simplificada (removidos campos polimorficos de origem; mantidos `materialId` e `destinoQuadraId`/`destinoLoteId` como opcionais).
  - `SPEC/06-definicoes-complementares.md`: `PontoOrigem` removido da tabela de rastreabilidade.
  - `SPEC/05-backlog-mvp-glossario.md`: Adicionado item "Entrega formal de material" aos adiamentos para Fase 2.

## DEC-009 — Reintrodução de `exigeTransporte` no MVP e modelo de cadastro de Serviços

- **Estado:** Decidido
- **Data:** 2026-03-26
- **Participantes:** Produto, Operações
- **Contexto:** Revisão de requisitos identificou quatro lacunas no modelo de `Servico`: (1) ausência do campo `descricao`; (2) vínculo incorreto de `Servico` com instância `Maquinario` em vez de `TipoMaquinario` — inconsistência entre modelo ER e contrato de API; (3) ausência da flag `exigeTransporte`, que havia sido adiada em DEC-006 por estar acoplada ao fluxo de entrega formal de material externo (`PontoOrigem`); (4) ausência de regra para destino obrigatório em serviços de transporte.
- **Opções em análise:**
  - A) Manter `exigeTransporte` adiado (DEC-006) e tratar transporte apenas via descrição livre.
  - B) Reintroduzir `exigeTransporte` no MVP com escopo restrito a transporte interno da obra (sem `PontoOrigem`), vinculado ao cadastro de `Servico`.
- **Decisão:** B) `exigeTransporte` reintroduzido no MVP com escopo distinto do que foi adiado em DEC-006. A flag indica que o serviço envolve deslocamento de material ou equipamento **dentro da obra** (não entrega de material externo). Quando `exigeTransporte = true`, a abertura de demanda exige destino (`destinoQuadraId` + `destinoLoteId`) ou declaração de **Transporte Interno** (`transporteInterno = true`), onde destino = origem. `PontoOrigem` e entrega formal de material externo permanecem adiados para Fase 2.
- **Justificação:** A necessidade operacional de rastrear para onde o material ou equipamento será deslocado é real no MVP e não depende de `PontoOrigem`. A separação entre "transporte interno à obra" (MVP) e "entrega de material de origem externa" (Fase 2) elimina a ambiguidade de DEC-006 sem aumentar o escopo da entrega.
- **Achados resolvidos:** Lacunas identificadas na revisão de 2026-03-26: `descricao` ausente em `Servico`, vínculo `Servico.maquinarioId` incorreto, `exigeTransporte` ausente, comportamento de destino obrigatório não documentado.
- **Aplicação (2026-03-26):**
  - `SPEC/02-modelo-dados.md`: Entidade `Servico` atualizada — adicionados `descricao` e `exigeTransporte`; FK alterada de `maquinarioId` → `tipoMaquinarioId`. Entidade `Demanda` atualizada — adicionado `transporteInterno`; `destinoQuadraId`/`destinoLoteId` documentados como condicionalmente obrigatórios. Diagrama ER e relacionamentos corrigidos: `TipoMaquinario ||--o{ Servico` substitui `Maquinario ||--o{ Servico`.
  - `PRD/02-jornada-usuario.md`: `REQ-JOR-001` atualizado — seção "Material e destino" documenta obrigatoriedade condicional e opção de Transporte Interno.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-003` expandido com campos mínimos do cadastro de `Servico` e vínculo com `TipoMaquinario`.
  - `SPEC/08-api-contratos.md`: CRUD de serviços adicionado (`POST`, `PATCH`, `DELETE /obras/:id/servicos`); `GET /obras/:id/servicos` atualizado com `exigeTransporte`; `CreateDemandaDto` atualizado com `transporteInterno` e validação condicional; erro `DEM-005` adicionado.

## DEC-010 — Modelo de cadastro de TipoMaquinario e Maquinario

- **Estado:** Decidido *(campo `empresaProprietaria` parcialmente supersedido por DEC-016 — 2026-04-10; substituído por `proprietarioTipo` + `empreiteiraId`)*
- **Data:** 2026-03-26
- **Participantes:** Produto, Operações
- **Contexto:** Revisão dos requisitos de maquinário definiu dois fluxos de cadastro explícitos: (1) tela de tipos de maquinário e (2) tela de maquinários individuais vinculados ao tipo. O modelo existente apresentava lacunas: `TipoMaquinario` sem `descricao`; `Maquinario` sem campo `nome` e com `propriedade` como enum `FGR/Terceiro` insuficiente para identificar a empresa proprietária; campo `porte` no tipo sem uso funcional no MVP.
- **Decisão:** Revisão do modelo para o MVP mínimo funcional:
  - `TipoMaquinario`: adicionar `descricao` (obrigatório); remover `porte` (adiado para Fase 2, sem uso no MVP).
  - `Maquinario`: adicionar `nome` (obrigatório); substituir `propriedade` (enum FGR/Terceiro) por `empresaProprietaria` (texto livre, obrigatório); manter `placa` como campo opcional.
- **Justificação:** O campo `nome` é necessário para exibição no formulário de abertura de demanda (seleção de maquinário). `empresaProprietaria` como texto livre suporta tanto máquinas da FGR quanto de terceiros com identificação nominal da empresa. `placa` permanece para rastreio de máquinas com registro veicular. `porte` não tem impacto funcional no MVP (não influencia score, filtros ou SLA) e pode ser reintroduzido em fase posterior.
- **Aplicação (2026-03-26):**
  - `SPEC/02-modelo-dados.md`: Entidade `TipoMaquinario` — adicionado `descricao`, removido `porte`. Entidade `Maquinario` — adicionado `nome`, substituído `propriedade` por `empresaProprietaria`. Diagrama ER e narrativa atualizados.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-003` expandido com campos explícitos de `TipoMaquinario` e `Maquinario`, menção às telas dedicadas e à filtragem mútua.
  - `SPEC/08-api-contratos.md`: CRUD de `TipoMaquinario` adicionado (`GET /tipos-maquinario`, `POST`, `PATCH`, `DELETE`); CRUD de `Maquinario` completado (`POST`, `PATCH`, `DELETE /obras/:id/maquinarios`); `GET /obras/:id/maquinarios` atualizado com novos campos.
  - `SPEC/04-rbac-permissoes.md`: Permissões `machinery:tipo-maquinario:*` adicionadas.

## DEC-007 — Stack de frontend web: Angular 20 (PWA)

- **Estado:** Superseded por DEC-021 (2026-04-16)
- **Data:** 2026-03-25
- **Participantes:** Produto, Engenharia, Arquitetura
- **Contexto:** alinhar documentacao canonica de plataforma a uma stack de frontend moderna e estavel, substituindo referencias legadas a Next.js e evitando roadmap de Fase 2 prescriptivo em React Native quando a decisao de canal movel ainda e aberta.
- **Opcoes em analise:**
  - A) Manter Next.js como referencia no PRD/SPEC.
  - B) Adotar **Angular** major **20** como baseline do cliente web (`apps/web`), com PWA mobile-first e nota de validacao de patch **20.x** no momento da implementacao.
  - C) Outro framework SPA sem consolidacao de versao.
- **Decisao:** B) **Angular** major **20** como linha estavel do frontend web no monorepo; **baseline canónica** major 20; validar o patch mais recente da serie **20.x** antes de fixar dependencias de build. PWA e requisitos de conectividade/offline permanecem os de `REQ-NFR-002`; roadmap de Fase 2 para experiencia movel nativa permanece deliberadamente neutro quanto a framework (ver SPEC).
- **Justificacao:** Centraliza a versao alvo nos artefactos PRD/SPEC, remove inconsistencia com uma stack ja descontinuada na decisao actual e separa a escolha de framework web da eventual decisao de canal nativo em Fase 2.
- **Nota MVP:** Nenhuma alteracao de escopo funcional; apenas alinhamento de plataforma e documentacao.
- **Achados resolvidos:** *(n/a — decisao arquitectural documental)*
- **Aplicacao (2026-03-25):**
  - `PRD/04-requisitos-nao-funcionais.md`: `REQ-NFR-002` actualizado para Angular 20 com baseline e nota de patch 20.x.
  - `SPEC/00-visao-arquitetura.md`: `apps/web`, principios mobile-first e ADR **D7** alinhados a Angular 20; roadmap Fase 2 sem prescricao de React Native.
  - `docs/traceability.md`: linha `REQ-NFR-002` actualizada com referencia a DEC-007 e D7.

## DEC-008 — Paradigma Zoneless e Signals como padrão de reatividade (Angular 20)

- **Estado:** Superseded por DEC-021 (2026-04-16)
- **Data:** 2026-03-26
- **Participantes:** Produto, Engenharia, Arquitetura
- **Contexto:** Após fixar Angular 20 como baseline (DEC-007), alinhar o padrão de reatividade do frontend para garantir performance adequada na fila de demandas em tempo real e nos indicadores de SLA.
- **Opções em análise:**
  - A) Manter Zone.js como padrão de detecção de mudanças do Angular.
  - B) Adoptar paradigma Zoneless com Signals como unidade primária de estado reativo.
  - C) Abordagem híbrida com Zone.js para componentes existentes e Signals apenas em novos.
- **Decisão:** B) Paradigma **Zoneless** com **Signals** como padrão de reatividade para todos os componentes novos. Coleções de demandas modeladas como `signal<Demand[]>`; RxJS mantido apenas onde a semântica de stream for estritamente necessária (ex.: WebSocket, debounce de input).
- **Justificação:** A reordenação contínua da fila de demandas requer renderização sem *flicker* e sem custo de detecção de mudanças por árvore completa. O paradigma Zoneless com Signals elimina o overhead do Zone.js e reduz ciclos de detecção desnecessários, garantindo responsividade adequada nos dashboards de SLA e nas filas do operador mobile.
- **Achados resolvidos:** *(n/a — decisão arquitectural documental)*
- **Aplicação (2026-03-26):**
  - `docs/SPEC/07-design-ui-logica.md`: §3 documenta implementação Zoneless (`providedIn: 'root'`), Signals para coleções de demandas, Reactive Forms com Zod/Valibot e componente `ActionButton` com guard RBAC integrado.

## DEC-011 — Estado `PAUSADA` na máquina de estados da Demanda (MVP)

- **Estado:** Decidido
- **Data:** 2026-04-09
- **Participantes:** Produto, Operações
- **Contexto:** A revisão do item 1 do TODO de correções PRD/SPEC (2026-04-09) identificou que `PAUSADA` havia sido introduzido em `SPEC/07` sem ter transições formais definidas em `SPEC/03`. A opção era: (A) remover `PAUSADA` do MVP e tratar como Fase 2, ou (B) mantê-lo no MVP formalizando as transições em `SPEC/03` e abrindo `REQ-FUNC-011`.
- **Opções em análise:**
  - A) Remover `PAUSADA` do MVP — simplifica a máquina de estados; pausa seria Fase 2.
  - B) Manter `PAUSADA` no MVP — atende necessidade operacional real de campo; requer formalização das transições e novo REQ.
- **Decisão:** B) Manter `PAUSADA` no MVP. Adicionar transições `EM_ANDAMENTO → PAUSADA` (ação `pausar`, Operador, justificativa obrigatória) e `PAUSADA → EM_ANDAMENTO` (ação `retomar`, Operador) à máquina de estados canônica de `SPEC/03`. Criar `REQ-FUNC-011` no PRD.
- **Justificação:** Operadores em campo precisam pausar demandas por razões operacionais legítimas (aguardar material, interferência de outro equipamento, intervalo obrigatório). Sem `PAUSADA`, seriam forçados a concluir falsamente ou devolver a demanda à fila geral, distorcendo métricas e perdendo a vinculação. O estado `PAUSADA` preserva o vínculo operador-demanda e mantém rastreabilidade auditável com motivo obrigatório.
- **Restrições MVP:**
  - SLA continua correndo durante `PAUSADA` (sem suspensão de timer).
  - Sem limite de tempo de pausa definido no MVP.
  - Motor de fila trata o equipamento como momentaneamente indisponível para novas atribuições automáticas enquanto houver demanda `PAUSADA`.
- **Achados resolvidos:** TODO-correcoes-prd item 1b (transições de `PAUSADA` em SPEC/03).
- **Aplicação (2026-04-09):**
  - `SPEC/03-fila-scoring-estados-sla.md`: `PAUSADA` adicionado ao diagrama Mermaid com transições `pausar` e `retomar`; linhas correspondentes inseridas na tabela de transições; seção "Fluxo detalhado `PAUSADA`" criada com regras de vínculo, SLA, DemandaLog e comportamento do motor de fila; `REQ-FUNC-011` adicionado ao bloco de Rastreio PRD.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-011` já registrado (nota DEC-011 pendente atualizada como decidida na data acima).

---

## DEC-012 — Papel e posição hierárquica da entidade `Rua` no modelo espacial

- **Estado:** Decidido
- **Data:** 2026-04-09
- **Participantes:** Produto, Operações
- **Contexto:** O item 2 do TODO de correções PRD/SPEC (2026-04-09) exigia definir o papel da entidade `Rua` no domínio: (A) descritiva sem impacto operacional, (B) participante do algoritmo de adjacência, ou (C) entidade de agrupamento puramente visual.
- **Opções em análise:**
  - A) `Rua` como dado descritivo livre em `Quadra` (campo texto, sem entidade própria) — sem FK, sem impacto no motor de fila.
  - B) `Rua` como entidade filha de `Quadra` — FK `ruaId` em `Quadra` — hierarquia Quadra → Rua.
  - C) `Rua` como entidade de agrupamento de `Quadras` — FK `ruaId` em `Quadra` — hierarquia Rua → Quadra.
- **Decisão:** C) `Rua` é entidade de agrupamento **pai de `Quadra`**: uma `Rua` contém múltiplas `Quadras`; `Quadra` carrega `ruaId` (FK nullable). No MVP, `Rua` é **descritiva** — não participa do algoritmo de adjacência nem do score de fila. Sua função primária é referência visual para o usuário localizar máquinas e evitar colisões entre equipamentos.
- **Justificação:** O exemplo operacional "o posto da Quadra X e da Quadra Y estão na Rua Z" prova que a relação correta é `Rua ||--o{ Quadra`, não o inverso. Tratar `Rua` como texto livre (opção A) perderia a capacidade de filtragem e visualização agrupada; tratar como filha de `Quadra` (opção B) inverteria a hierarquia espacial. A opção C reflete a realidade de campo: uma rua de obra tem múltiplas quadras (blocos) às suas margens. O `ruaId` ser nullable preserva compatibilidade com obras que ainda não mapearam ruas. Participação no algoritmo de adjacência fica adiada para Fase 2.
- **Restrições MVP:**
  - `ruaId` é **nullable** em `Quadra` — obra pode funcionar sem ruas cadastradas.
  - `Rua` **não** altera `fator_adjacencia` nem qualquer peso do motor de score no MVP.
  - `Rua` **não** tem permissões RBAC dedicadas no MVP — gerenciada pelo mesmo perfil que gerencia `Quadra` (`AdminOperacional`).
  - Fase 2: avaliar uso de `Rua` como critério de adjacência intermediária (máquinas na mesma rua = `fator_adjacencia` 0.5 por padrão).
- **Achados resolvidos:** TODO-correcoes-prd item 2 (papel da entidade `Rua`).
- **Aplicação (2026-04-09):**
  - `SPEC/02-modelo-dados.md`: entidade `Rua` adicionada ao diagrama ER com campos `id`, `nome`, `obraId`; `ruaId` (nullable) adicionado a `Quadra`; relação `Rua ||--o{ Quadra : "contém"` e `Obra ||--o{ Rua : "contém"` inseridas; texto da seção "Organização espacial" atualizado com papel descritivo de `Rua` no MVP.

---

## DEC-013 — Fluxo de cancelamento de demanda própria pelo Empreiteiro na UI mobile

- **Estado:** Decidido
- **Data:** 2026-04-09
- **Participantes:** Produto, Operações
- **Contexto:** O item 3 do TODO de correções PRD/SPEC (2026-04-09) identificou que a permissão `machinery:demanda:cancel` (condição [4]: autoria + estado `PENDENTE`) estava autorizada no RBAC mas sem representação documentada na UI de campo do empreiteiro em `SPEC/07`.
- **Opções em análise:**
  - A) Botão "Cancelar" direto no card sem justificativa — mais rápido, sem fricção, porém sem trilha auditável.
  - B) Botão "Cancelar" no card + modal com campo de justificativa obrigatória.
- **Decisão:** B) Botão "Cancelar" exibido no card da demanda em `PENDENTE` + Modal de Confirmação com campo de justificativa obrigatório (mínimo 10 caracteres). O botão não é renderizado para demandas em outros estados ou de autoria de terceiros.
- **Justificação:** A justificativa obrigatória alinha-se à exigência de trilha auditável de `REQ-ACE-006` e ao padrão já adotado para outros fluxos de cancelamento no sistema (operadores via `SolicitacaoCancelamento`, admins). Evita cancelamentos acidentais por toque inadvertido e cria registro rastreável para revisão administrativa posterior.
- **Achados resolvidos:** TODO-correcoes-prd item 3 (fluxo de cancelamento do Empreiteiro na UI).
- **Aplicação (2026-04-09):**
  - `SPEC/07-design-ui-logica.md`: subseção "Cancelamento de demanda própria em `PENDENTE`" adicionada em 1.1 com fluxo detalhado; tabela State-to-UI Mapping expandida com coluna do Empreiteiro; `REQ-ACE-006` adicionado ao bloco Rastreio PRD.
  - `PRD/02-jornada-usuario.md`: subseção "Acompanhamento e cancelamento de demanda própria" adicionada em `REQ-JOR-001` com cross-link para SPEC/07.
  - `docs/traceability.md`: `REQ-ACE-006` e `REQ-JOR-001` atualizados para incluir `SPEC/07` como cobertura adicional.

---

## DEC-014 — Fronteira FGR Ops (plataforma) vs Machinery Link (módulo) e sequência de bootstrapping de obra

- **Estado:** Decidido
- **Data:** 2026-04-09
- **Participantes:** Produto, Operações, Arquitetura
- **Contexto:** O item 4 do TODO de correções PRD/SPEC (2026-04-09) identificou que o PRD/SPEC descrevia cadastros e perfis sem deixar claro **onde** cada responsabilidade vive: FGR Ops (plataforma multi-módulo futura) vs Machinery Link (módulo operacional entregue no MVP). O Machinery Link hoje é sistema standalone; no MVP ele é re-platformado como primeiro módulo do FGR Ops. Sem essa separação explícita, a sequência de setup inicial de uma obra ficava ambígua quanto a quem executa cada passo e em qual aplicação.
- **Opções em análise:**
  - A) Tratar tudo dentro do Machinery Link e ignorar a camada FGR Ops no MVP — mais simples, porém cria dívida arquitetural ao introduzir o segundo módulo (almoxarifado, IoT).
  - B) Introduzir novos perfis específicos para FGR Ops (`AdminSistemaFGROps`, `DiretorGlobal`) — formaliza a camada, mas cascateia novos `REQ-RBAC-*` e duplica conceitos já cobertos por `SuperAdmin` e `Board`.
  - C) Manter os perfis atuais e formalizar arquiteturalmente que `SuperAdmin` e `Board` operam na camada FGR Ops (plataforma), enquanto `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` e `Operador` operam na camada Machinery Link (módulo).
- **Decisão:** C) Formalização de duas camadas sem criação de novos perfis. A camada **FGR Ops** (plataforma, cross-tenant) é responsável pelo cadastro de `Obra`, provisão de usuários e ativação de módulos — operada por `SuperAdmin` (papel funcional: "Administrador do Sistema FGR Ops") e `Board` (papel funcional: "Diretor / Gerente de Obra Global"). A camada **Machinery Link** (módulo, tenant-scoped) concentra todos os cadastros operacionais internos à obra e o ciclo de vida de `Demanda` — operada por `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` e `Operador`. O roteamento de login é dual: `SuperAdmin` e `Board` passam pelo shell FGR Ops (seleção de obra → hub de módulos habilitados); os demais perfis entram diretamente na aplicação do módulo. A sequência canônica de 18 passos de bootstrapping fica documentada em `SPEC/01-modulos-plataforma.md#bootstrapping-de-obra`.
- **Justificação:** Os perfis `SuperAdmin` (cross-tenant, único com `core:obra:create`) e `Board` (cross-tenant, estritamente leitura) já existiam na matriz RBAC e cumpriam exatamente o papel de camada de plataforma — não havia ganho em duplicá-los. A decisão reusa a matriz RBAC atual sem quebrar cobertura de auditoria e esclarece o modelo mental para leitores do SPEC. O acesso direto dos perfis de campo ao módulo evita fricção em smartphone (`REQ-NFR-002`, `REQ-OBJ-005`), enquanto o shell FGR Ops fica reservado para os perfis que realmente precisam de visão cross-obra ou cross-módulo. A sequência canônica de bootstrapping com regras de integridade ("obra elegível para criação de demandas apenas quando X, Y, Z estão presentes") destrava a futura implementação do backend ao definir claramente as pré-condições operacionais.
- **Restrições MVP:**
  - Apenas um módulo exibido no hub FGR Ops: `Machinery Link`. O shell é construído para suportar N módulos futuros, mas a lista é hardcoded no MVP.
  - Toggle binário de ativação: uma obra tem ou não tem Machinery Link ativo; não há configuração fina de features no nível plataforma.
  - Painel executivo dedicado para `Board` (com cruzamento de dados entre obras: horas de maquinário, engajamento de operadores, etc.) fica na **Fase 2** como módulo futuro do FGR Ops.
  - Nenhum novo `REQ-RBAC-*` é criado; a matriz de permissões existente já cobre integralmente as duas camadas.
  - Empreiteira (passo #13) e LocalExterno (passo #9) são citados na sequência canônica mas têm entidade e contratos CRUD pendentes de formalização nos itens 6 e 7 do TODO-correcoes-prd.
- **Achados resolvidos:** TODO-correcoes-prd item 4 (sequência de setup inicial de uma obra).
- **Aplicação (2026-04-09):**
  - `SPEC/01-modulos-plataforma.md`: nova seção `## Bootstrapping de obra` com subseções (Arquitetura de duas camadas, Fluxo de autenticação e roteamento, Sequência canônica de cadastros, Regras de integridade, Delimitação FGR Ops ↔ Machinery Link MVP). Bloco Rastreio PRD expandido com `REQ-RBAC-001..003`, `REQ-SCO-001..004`.
  - `docs/traceability.md`: linha de `REQ-SCO-*` e `REQ-RBAC-*` enriquecida com referência à nova seção de bootstrapping.
  - `TODO-correcoes-prd.md`: item 4 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-014; "Próxima disponível" atualizada para DEC-015.

## DEC-015 — FK `setorOperacionalId` em `Quadra` e não-conflito com `Rua`

- **Estado:** Decidido
- **Data:** 2026-04-10
- **Participantes:** Produto, Arquitetura
- **Contexto:** O item 5 do TODO de correções PRD/SPEC (2026-04-09) identificou que o ER de `SPEC/02-modelo-dados.md` não registrava a FK `setorOperacionalId` em `Quadra`, embora o texto de `SPEC/08` e o campo `Demanda.setorOperacionalId` já mencionassem que o setor é derivado automaticamente do `quadraId`. Antes de adicionar a FK era necessário verificar se haveria conflito com a entidade `Rua` (que também agrupa `Quadras`) ou com a relação `SetorOperacional`.
- **Opções em análise:**
  - A) `setorOperacionalId` vai em `Rua`, e `Quadra` herda o setor via join através de `ruaId` — reduz redundância, mas impede obras sem ruas cadastradas de funcionar.
  - B) `setorOperacionalId` vai em `Quadra` diretamente — simétrico ao padrão de `LocalExterno`; `Rua` permanece puramente descritiva e nullable.
  - C) `SetorOperacional` agrupa `Ruas` (não `Quadras`) — exige criar FK em `Rua` e reformular toda a hierarquia espacial.
- **Decisão:** B) `setorOperacionalId` é adicionado diretamente em `Quadra`, como campo obrigatório e não-nulo (com validação de mesma `obraId`). `Rua` não recebe `setorOperacionalId`; mantém-se como agrupador visual opcional (nullable), sem papel no motor de fila (DEC-012). A `Demanda` continua derivando `setorOperacionalId` automaticamente a partir do `quadraId` escolhido — sem input manual do usuário.
- **Justificação:** `Quadra` é a unidade operacional primária de onde o motor de fila obtém a jurisdição de setor. `LocalExterno` já usa o mesmo padrão (FK direta). `Rua` é puramente descritiva no MVP (DEC-012) e seu `ruaId` é nullable em `Quadra`, portanto não pode ser veículo de herança de setor sem criar dependência obrigatória — o que quebraria obras sem ruas cadastradas. A opção B mantém consistência arquitetural, preserva o padrão nullable de `ruaId` e não exige nenhuma alteração na hierarquia espacial existente.
- **Achados resolvidos:** TODO-correcoes-prd item 5 (FK `setorOperacionalId` em `Quadra` no ER).
- **Aplicação (2026-04-10):**
  - `SPEC/02-modelo-dados.md`: campo `setorOperacionalId` adicionado à entidade `Quadra` no diagrama Mermaid; relação `SetorOperacional ||--o{ Quadra : "jurisdição"` adicionada ao ER; regra de integridade documentada na seção "Relacionamentos e regras de integridade".
  - `TODO-correcoes-prd.md`: item 5 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-015; "Próxima disponível" atualizada para DEC-016.

## DEC-016 — Empreiteira global, vínculo Empreiteiro ↔ Empreiteira e modelo de propriedade de Maquinario

- **Estado:** Decidido
- **Data:** 2026-04-10
- **Participantes:** Produto, Arquitetura
- **Contexto:** O item 6 do TODO de correções PRD/SPEC (2026-04-09) exigia formalizar três aspectos inter-relacionados: (a) como o usuário `Empreiteiro` fica vinculado à entidade `Empreiteira`; (b) como o `Maquinario` registra sua propriedade (FGR ou terceirizada); (c) qual é o escopo de `Empreiteira` — por obra ou global. Adicionalmente, foi analisada a necessidade de um vínculo permanente `Maquinario → Operador`.
- **Opções em análise:**
  - Vínculo Empreiteiro: FK `empreiteiraId` diretamente em `User` vs entidade de perfil separada.
  - Propriedade de Maquinario: (A) FK nullable `empreiteiraId` onde `null = FGR`; (B) discriminador explícito `proprietarioTipo` + `empreiteiraId` nullable.
  - Operador em Maquinario: (A) `operadorPadraoId` FK permanente; (B) vínculo apenas via `RegistroExpediente` (dinâmico).
  - Escopo Empreiteira: (A) tenant-scoped (com `obraId`); (B) global (sem `obraId`), reutilizável entre obras e módulos.
- **Decisão:**
  1. **Vínculo Empreiteiro ↔ Empreiteira:** `empreiteiraId` (UUID nullable) adicionado diretamente ao `User`. Campo obrigatório quando `perfil = Empreiteiro`, nulo para os demais perfis. O vínculo é estabelecido pelo `AdminOperacional` na criação do usuário (payload documentado em `SPEC/08`).
  2. **Propriedade de Maquinario:** Opção B — `proprietarioTipo: enum(FGR, EMPREITEIRA)` (obrigatório) + `empreiteiraId: uuid | null` (obrigatório quando `proprietarioTipo = EMPREITEIRA`, nulo quando `FGR`). Campo `empresaProprietaria` (texto livre, DEC-010) removido e supersedido por este modelo estruturado.
  3. **Operador em Maquinario:** Opção B — sem `operadorPadraoId`. O vínculo entre `Maquinario` e `Operador` é sempre dinâmico, gerenciado via `RegistroExpediente` por expediente. Um `operadorPadraoId` permanente criaria inconsistência quando o operador muda de máquina no turno.
  4. **Escopo de Empreiteira:** Global (sem `obraId`). `Empreiteira` é entidade de catálogo reutilizável entre obras e futuros módulos (almoxarifado, IoT etc.). Campos adicionados ao MVP: `cnpj` (opcional; chave única global quando informado, preparado para futura obrigatoriedade), `telefone`, `email`, `responsavel`, `endereco`. A associação implícita a uma obra é derivada via `User` com `perfil = Empreiteiro` e `obraId` correspondente. Relação explícita N:M `Empreiteira ↔ Obra` adiada para Fase 2.
- **Justificação:** FK direta em `User` evita entidade de perfil desnecessária para o MVP. O discriminador `proprietarioTipo` elimina a ambiguidade semântica entre "pertence à FGR" e "sem proprietário definido" que ocorreria com `empreiteiraId = null` sem discriminador. Escopo global preserva integridade referencial quando a mesma construtora terceirizada participar de múltiplas obras — CNPJ como chave única global impede duplicatas semânticas e prepara o terreno para futura reutilização cross-módulo (D4 se aplica internamente ao módulo, mas o catálogo de parceiros de negócio é naturalmente global). O vínculo `Maquinario → Operador` via `RegistroExpediente` é suficiente para relatórios e fila, sem criar rigidez operacional.
- **Achados resolvidos:** TODO-correcoes-prd item 6 (vínculo Empreiteiro ↔ Empreiteira).
- **Aplicação (2026-04-10):**
  - `SPEC/02-modelo-dados.md`: `Empreiteira` promovida a global (removido `obraId`, adicionados `cnpj`/`telefone`/`email`/`responsavel`/`endereco`); `User` recebe `empreiteiraId` nullable; `Maquinario` recebe `proprietarioTipo` + `empreiteiraId`, remove `empresaProprietaria`; relações e regras de integridade atualizadas.
  - `SPEC/08-api-contratos.md`: nova seção CRUD `Empreiteira` (`/empreiteiras`); payloads de criação e atualização de `Maquinario` atualizados; `empreiteiraId` adicionado ao payload de criação de usuário `Empreiteiro`.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-012` criado — CRUD de `Empreiteira` e vínculo com `User (Empreiteiro)`.
  - `docs/PRD/_index.md`, `docs/traceability.md`: atualizados com `REQ-FUNC-012`.
  - `TODO-correcoes-prd.md`: item 6 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-016; "Próxima disponível" atualizada para DEC-017.

---

## DEC-017 — Canal WebSocket como mecanismo único de notificação em tempo real no MVP

- **Data:** 2026-04-10
- **Contexto:** SPEC/03 referenciava "UI push de alta prioridade" e "UI push normal" para os níveis de SLA `MAXIMA` e `ELEVADA`, sem definir o canal técnico. O item 11 do TODO de correções do PRD exigia a especificação do mecanismo — tecnologia, payload, deduplicação e escalação.
- **Decisão:**
  1. **Transporte:** WebSocket (`wss://`) via NestJS Gateway — único canal de eventos em tempo real para o MVP. Não haverá Web Push API (notificações nativas de sistema operacional) nesta fase.
  2. **Justificativa:** WebSocket já era mencionado em SPEC/06 para o sinal `INVALIDATE_QUEUE`. Unificar todos os eventos em um único gateway reduz a complexidade de infraestrutura. Web Push exigiria VAPID keys, service worker de push dedicado e gestão de subscrições por dispositivo — overhead desnecessário para um MVP em que o operador mantém o PWA aberto durante o expediente.
  3. **Eventos canônicos definidos:**
     - `DEMAND_QUEUED` — nova demanda entra na fila do operador (operadores)
     - `SLA_ALERT` — SLA vencido, disparado uma única vez no `slaVencimentoEm` (operadores)
     - `INVALIDATE_QUEUE` — invalida cache local da fila (operadores + admins)
     - `SLA_ESCALATION` — escalação após +5 min (`MAXIMA`) ou +15 min (`ELEVADA`) sem ação (admins + SuperAdmin)
     - `DEMAND_STATUS_CHANGED` — qualquer transição de estado de demanda (admins)
  4. **Deduplicação:** `SLA_ALERT` disparado uma única vez por demanda; estado visual de SLA vencido persiste até transição de estado. `SLA_ESCALATION` não é deduplicado — cada etapa de escalação gera evento distinto.
  5. **Escalação para SuperAdmin:** via mesmo canal WebSocket. Email ou canal externo adiados para Fase 2.
  6. **Vibração PWA:** `DEMAND_QUEUED` com `prioridade = MAXIMA` aciona API Vibration (`[200, 100, 200]`).
  7. **Degradação:** queda do WebSocket ativa o banner offline existente; fila permanece visível via cache stale; reconexão com back-off exponencial (1 s → 2 s → 4 s, máximo 30 s) seguida de reidratação via `GET /operadores/:id/fila`.
- **Achados resolvidos:** TODO-correcoes-prd item 11.
- **Aplicação (2026-04-10):**
  - `SPEC/06-definicoes-complementares.md`: nova seção `## Mecanismo de notificação em tempo real` com transporte, autenticação, envelope, payloads por evento, regras de deduplicação e degradação graceful.
  - `SPEC/03-fila-scoring-estados-sla.md`: tabela de SLA atualizada — "Canal principal" agora nomeia os eventos WebSocket e referencia SPEC/06; "Mecanismo" atualizado para `Event-driven (WebSocket, DEC-017)`.
  - `TODO-correcoes-prd.md`: item 11 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-017; "Próxima disponível" atualizada para DEC-018.

---

## DEC-018 — Remoção da integração RH/Folha; denominador de REQ-MET-002 via sistema

- **Estado:** Decidido
- **Data:** 2026-04-10
- **Contexto:** O item 12 do TODO de correções do PRD requeria definir o contrato de integração com o sistema de RH/Folha da FGR para alimentar o denominador de `REQ-MET-002` (adoção e engajamento operacional). Após revisão de escopo, decidiu-se que essa integração está fora do MVP.
- **Decisão:**
  1. A integração com sistema externo de RH/Folha é removida do escopo do MVP.
  2. O denominador de `REQ-MET-002` (`operadores_cadastrados_quinzena`) passa a ser calculado diretamente a partir dos operadores cadastrados e ativos no sistema FGR-OPS para a obra (`User` com perfil `OPERADOR`, `deletadoEm IS NULL`, criados antes ou no último dia da quinzena).
  3. A subsecção "Fonte do denominador e integração" em SPEC/06 é removida. O artefato de validação renomeia `total_folha` → `total_cadastrados`.
  4. O campo `operadoresNaFolha` no contrato de `GET /relatorios/sla` (SPEC/08) é renomeado para `operadoresCadastrados`.
  5. Integração com RH/Folha poderá ser endereçada numa fase futura como módulo independente do FGR-OPS.
- **Justificativa:** Reduzir acoplamento externo no MVP. O denominador baseado no cadastro interno é suficiente para medir adoção em obras-piloto; refinamento com folha de pagamento pode ser adicionado na Fase 2 sem quebra de contrato.
- **Achados resolvidos:** TODO-correcoes-prd item 12.
- **Aplicação (2026-04-10):**
  - `SPEC/06-definicoes-complementares.md`: denominador atualizado; subsecção "Fonte do denominador e integração" removida; `total_folha` → `total_cadastrados` na tabela do artefato de validação.
  - `SPEC/08-api-contratos.md`: `operadoresNaFolha` → `operadoresCadastrados` em `GET /relatorios/sla`.
  - `PRD/06-metricas-riscos.md`: `REQ-MET-002` — referência à "folha da quinzena" substituída por "operadores cadastrados e ativos no sistema".
  - `TODO-correcoes-prd.md`: item 12 marcado como `[x]`.
  - `CLAUDE.md`: "Última decisão registrada" atualizada para DEC-018; "Próxima disponível" atualizada para DEC-019.

---

## DEC-019 — Remoção de `SolicitacaoCancelamento` e do estado `PENDENTE_APROVACAO`

- **Estado:** Decidido
- **Data:** 2026-04-13
- **Participantes:** Produto, Operações, Stakeholders de Negócio
- **Contexto:** Reunião com os interessados do projeto determinou que o fluxo de solicitação de cancelamento com aprovação gerencial é complexidade desnecessária para o MVP. O Operador de campo precisa poder encerrar demandas de forma direta quando necessário, sem depender de uma janela de aprovação administrativa.
- **Opções em análise:**
  - A) Manter `SolicitacaoCancelamento` e `PENDENTE_APROVACAO` como especificado em DEC-002.
  - B) Remover o estado intermediário; o Operador cancela a demanda em `EM_ANDAMENTO` diretamente, com justificativa obrigatória, transitando para `CANCELADA`.
- **Decisão:** B) Remoção do estado `PENDENTE_APROVACAO` e da entidade `SolicitacaoCancelamento`. A ação `cancelar` em `EM_ANDAMENTO` passa a ser exclusiva do `Operador` vinculado, com justificativa obrigatória registrada em `DemandaLog`. A transição é direta para `CANCELADA`.
- **Justificação:** O fluxo de aprovação gerencial de cancelamento criava latência operacional indesejada: o Operador ficava bloqueado aguardando decisão administrativa antes de retornar à fila. A simplificação mantém a rastreabilidade via `DemandaLog` (obrigatório: ator, timestamp, motivo) sem bloquear o fluxo de campo. Perfis administrativos (`AdminOperacional`, `SuperAdmin`) podem cancelar demandas em qualquer estado de fila via a ação `cancelar` já existente.
- **Supersede:** DEC-002 (que estabelecia o estado `PENDENTE_APROVACAO` e o fluxo de aprovação automática por SLA de expediente).
- **Achados resolvidos:** Simplificação de fluxo operacional.
- **Aplicação (2026-04-13):**
  - `SPEC/03-fila-scoring-estados-sla.md`: Diagrama de estados atualizado — removidas transições `EM_ANDAMENTO → PENDENTE_APROVACAO → CANCELADA/EM_ANDAMENTO`; adicionada transição `EM_ANDAMENTO → CANCELADA : cancelar` (Operador, justificativa obrigatória). Tabela de transições por perfil atualizada. Seção "Fluxo detalhado PENDENTE_APROVACAO" removida.
  - `SPEC/04-rbac-permissoes.md`: Linhas `machinery:demanda:cancel-request` e `machinery:solicitacao-cancelamento:*` marcadas como `—` (entidade removida). Nota de rodapé `[5]` removida. Seção de permissões condicionadas ao estado da demanda atualizada.
  - `SPEC/07-design-ui-logica.md`: Linha `PENDENTE_APROVACAO` removida do mapeamento state-to-UI.
  - `SPEC/08-api-contratos.md`: Enum `status` atualizado — `PENDENTE_APROVACAO` removido.
  - `SPEC/05-backlog-mvp-glossario.md`: `SolicitacaoCancelamento` movida para itens removidos do MVP.
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-009` reescrito — cancelamento direto do Operador com justificativa.
  - `PRD/05-criterios-aceite.md`: `REQ-ACE-006` reescrito — fluxo direto de cancelamento; remoção dos cenários de `PENDENTE_APROVACAO`.

---

## DEC-020 — Atualização do escopo e permissões do perfil `UsuarioInternoFGR` (`REQ-RBAC-004`)

- **Estado:** Decidido
- **Data:** 2026-04-13
- **Participantes:** Produto, Operações, Stakeholders de Negócio
- **Contexto:** O perfil `UsuarioInternoFGR` precisava de redefinição clara de personas e capacidades. Identificaram-se três problemas: (a) personas não estavam documentadas; (b) o perfil possuía poderes de cancelamento e redistribuição de demandas que são responsabilidade exclusiva do `AdminOperacional`; (c) o perfil não tinha acesso mobile para criação de demandas.
- **Decisão:**
  1. **Personas**: `UsuarioInternoFGR` abrange Gerentes, Engenheiros e Encarregados de Obra.
  2. **Interface web**: acesso ao mesmo painel que `AdminOperacional` no módulo Machinery-Link, com visibilidade total (leitura), mas sem capacidade de cancelar ou redistribuir demandas, nem gerir cadastros operacionais (usuários, maquinários, tipos de serviços).
  3. **Interface mobile**: acesso ao aplicativo com view equivalente ao `Empreiteiro` — pode criar demandas, mas sem pré-seleção de operador (`operadorAlocadoId` é exclusivo do `AdminOperacional` e `SuperAdmin`).
  4. **Permissões removidas**: `cancel` e `allocate` em `demanda` e `demanda-grupo`; `criar_com_data` (agendamentos); `antecipar`; `cancelar` em `AGENDADA`; `devolver` em `EM_ANDAMENTO`; `allocate` em `PENDENTE`.
  5. **Permissões mantidas**: `create` (cria demandas simples → PENDENTE), `read`/`export` em todos os recursos, `update` em `demanda` (correções de metadados), `update` em `AGENDADA` — **removido** (não pode gerir agendamentos alheios).
- **Justificação:** A distinção entre `AdminOperacional` e `UsuarioInternoFGR` deve ser clara: o Admin tem poder de gestão operacional pleno; o Interno tem poder de visibilidade e criação de demandas, mas não de interferir no fluxo de execução alheio. Isso reduz risco de erro operacional por perfis com menos contexto de gestão.
- **Supersede parcialmente:** DEC-001 (sobre a menção de `UsuarioInternoFGR` na criação com `operadorAlocadoId` — essa capacidade passa a ser exclusiva de `AdminOperacional` e `SuperAdmin`).
- **Aplicação (2026-04-13):**
  - `PRD/01-usuarios-rbac.md`: `REQ-RBAC-004` atualizado com personas, interface dual (web + mobile), restrições explícitas.
  - `SPEC/04-rbac-permissoes.md`: Perfil #4 reescrito; matrix atualizada (`cancel`, `allocate` → ✗ para `UsuarioInternoFGR` em demanda e demanda-grupo); estado da demanda (Lacuna 2) atualizado.
  - `SPEC/03-fila-scoring-estados-sla.md`: Tabela de transições por perfil atualizada — `UsuarioInternoFGR` removido de `criar_com_data`, `antecipar`, `cancelar` (AGENDADA e PENDENTE), `allocate` (PENDENTE), `devolver` (EM_ANDAMENTO).
  - `PRD/03-requisitos-funcionais.md`: `REQ-FUNC-006` — `operadorAlocadoId` na criação restrito a `AdminOperacional` e `SuperAdmin`.

---

## DEC-021 — Stack de frontend web: Vite + React 19 (PWA), Tailwind + shadcn/ui

- **Estado:** Decidido
- **Data:** 2026-04-16
- **Participantes:** Produto, Engenharia, Arquitetura
- **Contexto:** A stack de frontend definida em DEC-007 (Angular 20) e DEC-008 (Zoneless/Signals) foi revisitada à luz de três constraints reais que não tinham sido ponderados conjuntamente na decisão original: (a) compromisso de roadmap para aplicativo mobile em React Native (Expo), (b) equipe composta por desenvolvedor solo com experiência básica em React e sem experiência em Angular profundo nem em React Native, (c) infraestrutura de deploy fornecida pela FGR é Windows Server com IIS e PM2, sem opção de ambiente serverless/Edge. A combinação Angular web + React Native mobile obriga o dev solo a sustentar dois mental models de frontend incompatíveis. Next.js foi considerado como alternativa em React, mas descartado porque várias de suas features diferenciais (ISR, middleware Edge, otimização de imagens, Server Actions) assumem ambiente Vercel-like e funcionam parcialmente ou não funcionam em Windows/IIS — pagar a taxa de framework sem receber a contraparte.
- **Opções em análise:**
  - A) Manter Angular 20 + NestJS conforme DEC-007 e manter React Native como segunda stack separada na Fase 2.
  - B) Migrar para Expo Router universal (React Native Web) com a mesma codebase web+mobile.
  - C) Migrar para Next.js 15 (App Router) + NestJS com export estático.
  - D) Migrar para **Vite + React 19** (SPA com export estático) + NestJS + ecossistema React moderno (TanStack Router, TanStack Query, react-hook-form, zod, Zustand) + **Tailwind CSS + shadcn/ui** como design system + **vite-plugin-pwa** (Workbox) para PWA.
- **Decisão:** D) **Vite + React 19** como stack de frontend web do monorepo (`apps/web`). Ecossistema: **TanStack Router** (roteamento type-safe), **TanStack Query** (data fetching / cache / invalidation), **react-hook-form + zod** (formulários e validação), **Zustand** (estado cliente), **Tailwind CSS + shadcn/ui** (design system — componentes copiados para o repo, não dependência runtime), **vite-plugin-pwa** (Service Worker/Workbox — aderente a `REQ-NFR-002` e estratégia PWA offline de `SPEC/06`). Backend NestJS, banco SQL Server + Prisma, cache/auth Redis + JWT e monorepo Turborepo + pnpm permanecem inalterados (DEC-022 formaliza o deploy e DEC-023 formaliza a preparação para mobile React Native).
- **Justificação:** A reutilização de mental model, bibliotecas (TanStack Query, zod, react-hook-form) e tipos entre web e futuro mobile RN é o maior multiplicador de produtividade disponível para dev solo. Angular não oferece essa reutilização. Vite entrega build estático que é servido nativamente pelo IIS sem Node em path de resposta — simpler e mais aderente à infra Windows do que Next.js. Tailwind + shadcn/ui (copy-paste ownership, sem dependência runtime) equilibra independência com produtividade, evitando o custo de escrever do zero primitivas de acessibilidade (focus trap, keyboard nav, ARIA) em pura Sass. Opção B (Expo universal) foi descartada por obrigar dev a aprender React Native antes de qualquer entrega web, com risco alto de não-entrega; pode ser revisitada no futuro se o mobile se tornar prioridade imediata. Opção C (Next.js) foi descartada pelo acoplamento a Vercel para features diferenciais e pela ausência de benefício (app interno autenticado, sem SEO, sem SSR obrigatório).
- **Supersede:** DEC-007 (Angular 20 como baseline) e DEC-008 (Zoneless/Signals como paradigma de reatividade). Ambas passam ao estado *Superseded*; permanecem no log por imutabilidade append-only.
- **Restrições MVP:**
  - Export estático obrigatório (`vite build` gera pasta `dist/` servível pelo IIS sem runtime Node no frontend).
  - PWA via `vite-plugin-pwa` — estratégias de cache e Service Worker aderentes ao `SPEC/06` (Cache First para fila, Offline Queue para transacionais, Network Only para expedientes de outros dias).
  - Componentes shadcn/ui são **copiados para o repositório** (CLI add); não há dependência runtime do pacote "shadcn-ui".
  - TanStack Router preferido a React Router pela tipagem estrita e pela geração de rotas type-safe (alinhado ao compartilhamento com backend via `packages/types`).
- **Achados resolvidos:** *(n/a — decisão arquitectural documental que revê DEC-007/DEC-008 à luz de novos constraints não-contemplados na decisão original.)*
- **Aplicação (2026-04-16):**
  - `PRD/04-requisitos-nao-funcionais.md`: `REQ-NFR-002` atualizado — Angular 20 → React 19 + Vite; menção a Tailwind + shadcn/ui; remoção das notas de patch 20.x; referência a DEC-021.
  - `SPEC/00-visao-arquitetura.md`: §2 Visão Macro atualizada (nova stack em `apps/web`, `apps/mobile` previsto para Fase 2, packages compartilhados); ADR **D7** revista com conteúdo Vite + React; nota em **D1** sobre reuso mobile.
  - `SPEC/07-design-ui-logica.md`: frontmatter, intro e §3 reescritos para padrões React (Hooks, Zustand, react-hook-form+zod, Tailwind+shadcn/ui, `ActionButton` React com hook RBAC).
  - `SPEC/_index.md`: resumo da linha 07 atualizado.
  - `SPEC/08-api-contratos.md`: linha 11 atualizada (Angular 20 → React 19).
  - `docs/traceability.md`: linha `REQ-NFR-002` atualizada com nova stack e referências DEC-021/022/023.
  - `docs/tests/plano-testes.md`: linha 149 atualizada.
  - `CLAUDE.md`: target stack e ADR D7 atualizados; próxima DEC disponível = DEC-024.

---

## DEC-022 — Infraestrutura de deploy: Windows Server + IIS + PM2

- **Estado:** Decidido
- **Data:** 2026-04-16
- **Participantes:** Produto, Arquitetura, Infraestrutura (FGR)
- **Contexto:** A FGR disponibiliza exclusivamente **Windows Server** com **IIS** e **PM2** como infraestrutura operacional; não há opção de hospedagem serverless, Edge, Linux ou containers gerenciados. A stack anterior (Angular + NestJS) não tinha a arquitetura de deploy formalizada em documentação SPEC/INFRA. Com a mudança de stack (DEC-021), foi necessário também formalizar como o novo stack web (Vite + React, export estático) e o backend (NestJS) coexistem na infraestrutura Windows, evitando anti-padrões (ex.: uso de `iisnode`, abandonado desde 2018).
- **Opções em análise:**
  - A) IIS servindo tanto estáticos quanto Node via `iisnode`.
  - B) PM2 puro expondo NestJS diretamente à internet.
  - C) **IIS como reverse proxy + servidor de estáticos; PM2 como process manager do NestJS em loopback.**
- **Decisão:** C) Arquitetura em duas camadas sobre a mesma máquina Windows:
  1. **IIS (porta 443, HTTPS, certificado Windows)** — serve os arquivos estáticos do `apps/web` (saída do `vite build`) diretamente do sistema de arquivos; aplica URL Rewrite com **Application Request Routing (ARR)** para reverse-proxy de `/api/*` e `/ws` → `http://localhost:3000` (NestJS). Terminação TLS, compressão, HTTP/2, caching e headers de segurança são responsabilidade do IIS. Fallback SPA: toda rota não-correspondida a arquivo serve `index.html`.
  2. **PM2 (via `pm2-windows-service`)** — gerencia o processo NestJS (`apps/api/dist/main.js`) em `localhost:3000` (loopback only, nunca exposto diretamente). Responsável por auto-restart em crash, logs rotativos, zero-downtime reload, inicialização no boot do Windows via `pm2 startup` + `pm2 save`. Cluster mode opcional conforme carga.
- **Justificação:** IIS é excelente a servir estáticos (HTTP/2, caching, compressão, Windows auth opcional) e a terminar TLS com certificados Windows. Node é ótimo a servir APIs dinâmicas mas mal gerenciador de TLS/estáticos em produção. Separar responsabilidades evita anti-padrões: `iisnode` está abandonado desde ~2018 com memory leaks em cargas reais; PM2 puro perderia os benefícios nativos do IIS. Loopback-only no NestJS reduz superfície de ataque — só a porta 443 é exposta. A arquitetura é independente de stack de frontend (vale para Vite+React ou qualquer futura SPA estática).
- **Restrições MVP:**
  - NestJS nunca exposto diretamente à internet; porta 3000 em loopback apenas.
  - Deploy do frontend = `pnpm --filter web build` → copiar pasta `dist/` para diretório raiz do site IIS.
  - Deploy do backend = `pnpm --filter api build` + `pm2 reload fgr-ops-api` (zero-downtime).
  - Logs centralizados em `C:\logs\fgr-ops-api\` com rotação por PM2.
  - Configuração do IIS (`web.config`, URL Rewrite rules, ARR) e do PM2 (`ecosystem.config.js`) documentados em `docs/INFRA.md`.
  - WebSocket (`/ws`) proxy com upgrade preservado — requer IIS 8.5+ com WebSocket Protocol feature habilitada.
- **Achados resolvidos:** *(n/a — decisão arquitectural documental sobre infra.)*
- **Aplicação (2026-04-16):**
  - `SPEC/00-visao-arquitetura.md`: referência à arquitetura de deploy adicionada à ADR D7 revista (DEC-021 e DEC-022).
  - `docs/INFRA.md`: reescrita incluindo nova seção "Deploy em Windows Server + IIS + PM2" com passo a passo (habilitar ARR, criar rewrite rules, instalar `pm2-windows-service`, `ecosystem.config.js`, layout de pastas).
  - `docs/traceability.md`: nota em `REQ-NFR-002` referenciando DEC-022.

---

## DEC-023 — Preparação do monorepo para aplicativo mobile React Native (Expo) via packages compartilhados

- **Estado:** Decidido
- **Data:** 2026-04-16
- **Participantes:** Produto, Arquitetura
- **Contexto:** O roadmap prevê um aplicativo mobile em **React Native (Expo)** após a estabilização do web MVP. Sem preparação estrutural no monorepo, haveria risco de duplicação de lógica (schemas zod, tipos, chamadas de API, regras de domínio) entre `apps/web` e `apps/mobile`, perdendo o principal ganho de produtividade possível para um desenvolvedor solo (reutilização cross-stack). A decisão de stack web em React (DEC-021) abre caminho natural para compartilhamento via packages.
- **Opções em análise:**
  - A) Não preparar monorepo agora; adicionar `apps/mobile` quando chegar o momento, sem compartilhamento.
  - B) Expo Router universal (mesma codebase web+mobile via React Native Web) — ponderado e descartado em DEC-021.
  - C) **Monorepo preparado com packages compartilhados `packages/types`, `packages/schemas`, `packages/api-client`, `packages/domain` que `apps/web` consome desde já e `apps/mobile` futuramente consumirá.**
- **Decisão:** C) Packages compartilhados como ponte entre web e mobile:
  1. **`packages/types`** — Tipos TypeScript derivados do NestJS (DTOs, enums de domínio, respostas de API). Fonte única de verdade para contratos.
  2. **`packages/schemas`** — Validações **zod** (login, criação de demanda, transições de estado, payloads de check-in). Reutilizáveis em React web e React Native.
  3. **`packages/api-client`** — Funções tipadas de chamada HTTP que consomem `types` e validam respostas via `schemas`. Agnóstico a ambiente (funciona em Node, browser, React Native).
  4. **`packages/domain`** — Regras puras de domínio (cálculo de score, transições de estado, cálculo de SLA, validação de agrupamento de demandas). Sem dependências de framework.
- **Justificação:** Preparar estrutura agora tem custo baixíssimo (criação de pastas + `pnpm-workspace.yaml` + configuração do Turborepo) e destrava ganho enorme quando o mobile entrar. `apps/mobile` (Expo) consumirá os mesmos 4 packages sem duplicação — 70% do valor de uma solução universal (Opção B) sem pagar o custo de aprender React Native antes de entregar o web. Estrutura também beneficia `apps/web` imediatamente: evita importação cross-app desorganizada e reforça separação de camadas DDD (domínio puro em `packages/domain`, infra em `apps/api`).
- **Restrições MVP:**
  - `apps/mobile` **não** é criado no MVP — apenas a estrutura de packages é preparada e consumida por `apps/web`.
  - `packages/domain` **não** deve importar de `apps/api` nem conhecer infra (Prisma, HTTP, Redis). Contém apenas lógica pura.
  - `packages/api-client` usa `fetch` nativo (padrão em Node 18+, browser e React Native) — sem dependência em axios, garantindo portabilidade.
  - Tipos do Prisma (`apps/api/prisma/schema.prisma`) **não** são exportados diretamente para `packages/types` (acoplamento indesejado). Em vez disso, DTOs explícitos em `packages/types` são mantidos em paridade manual com schema via code review.
- **Achados resolvidos:** *(n/a — decisão arquitectural documental.)*
- **Aplicação (2026-04-16):**
  - `SPEC/00-visao-arquitetura.md`: §2 Visão Macro atualizada listando packages compartilhados com propósito; nota em ADR **D1** referenciando DEC-023 e preparação para mobile RN.
  - `docs/INFRA.md`: estrutura do monorepo ilustra os 4 packages e `apps/mobile` previsto como comentário.
  - `docs/traceability.md`: nota em `REQ-NFR-002` referenciando DEC-023 (preparação mobile).

---

## DEC-024 — Escala canônica dos pesos de score da fila (0–100, sem soma obrigatória)

- **Estado:** Decidido
- **Data:** 2026-04-17
- **Participantes:** Produto, Arquitetura
- **Contexto:** A auditoria de 2026-04-16 identificou conflito entre a escala de pesos adotada em `SPEC/03`, `PRD/02` e `CLAUDE.md` (inteiros `50/30/20`, intervalo `[0, 100]`, sem obrigação de soma) e a escala adotada em `SPEC/08` (decimais `0.5/0.3/0.2`, intervalo `[0.0, 1.0]`, soma exatamente `1.0`). As duas representações são matematicamente equivalentes mas criam ambiguidade nos contratos de API e na validação backend.
- **Opções em análise:**
  - A) Escala decimal `[0.0, 1.0]` com `soma = 1.0` obrigatória — facilita normalização automática, mas conflita com a maioria dos documentos existentes e exige conversão para o intervalo intuitivo de percentuais.
  - B) **Escala inteira `[0, 100]` sem obrigação de soma total** — alinhada com `SPEC/03` (fonte autoritativa do motor de fila), `PRD/02`, `CLAUDE.md` e representação intuitiva de "percentual de influência". Soma não obrigatória permite obra operar com pesos desbalanceados (ex.: `W_adj=100, W_srv=0, W_mat=0`) sem penalização.
- **Decisão:** B) Escala canônica `[0, 100]` (inteiros), sem obrigação de soma. Padrões: `W_adj = 50`, `W_srv = 30`, `W_mat = 20`. Validação de API recusa valores fora do intervalo `[0, 100]`; não valida soma.
- **Justificação:** `SPEC/03` é a fonte de verdade do motor de priorização (3 documentos vs 1 em conflito). A escala `[0, 100]` é imediatamente legível como "percentual de influência" para `AdminOperacional` sem tradução mental. A ausência de obrigação de soma total dá flexibilidade operacional — obras com maquinário todo local podem zerar `W_mat` sem redistribuir manualmente. A validação de intervalo `[0, 100]` é suficiente para prevenir configurações inválidas.
- **Achados resolvidos:** `cross-traceability-decisions-review.md` CRITICAL-001 · `spec-08-api-contratos-review.md` CRITICAL-002.
- **Aplicação (2026-04-17):**
  - `SPEC/08-api-contratos.md`: campos `pesoAdjacencia/pesoServico/pesoMaterial` alterados para `number (0–100)`; nota de validação atualizada (sem soma obrigatória); erro `400` renomeado para "peso fora do intervalo [0, 100]"; defaults atualizados para `50/30/20`.
  - `CLAUDE.md`: "Última: DEC-023 · Próxima: **DEC-024**" → atualizar para "Última: DEC-024 · Próxima: **DEC-025**" (feito inline).

## DEC-025 — Rollover e redistribuição de demandas entre dias

- **Estado:** Decidido
- **Data:** 2026-04-20
- **Participantes:** Produto, Operações
- **Contexto:** Demandas não finalizadas até o fim do expediente precisam persistir para o dia seguinte e ser redistribuídas conforme operadores fazem check-in, respeitando compatibilidade de maquinário. DEC-002 previa auto-encerramento por estouro de SLA, comportamento que conflita com este requisito.
- **Supersede parcialmente:** DEC-002 — parte de auto-encerramento por SLA estourado é removida; alertas e escalação de SLA permanecem.
- **Decisões:**
  - Q1) DEC-002 supersedido na parte de auto-encerramento; alertas/escalação SLA mantidos.
  - Q2) Estado no rollover: `PENDENTE` com campo `rolloverDe: date` para rastreio — sem novo estado.
  - Q3) SLA mantido integralmente (alertas, escalação, timers, badges), **sem auto-encerramento**. SLA **reseta** no dia seguinte (marco zero = início do expediente).
  - Q4) Escopo redistribuição: hard filter completo + scoring normal — pipeline padrão de distribuição.
  - Q5) `EM_ANDAMENTO`/`PAUSADA` no fim do expediente: devolução forçada via `RETORNADA` existente (ator=SISTEMA); gatilho duplo: checkout do operador + worker `expedienteFim`.
  - Q6) `AGENDADA` vencida segue mecanismo T-60min vigente; se já transitou para `PENDENTE`, rola normalmente. *(Nota: supersedida pelo Plano 2/DEC-026, que substitui T-60 por aceite explícito com expiração T-1h → `NAO_EXECUTADA`.)*
  - Q7) Sem notificação especial; indicador visual no painel admin para demandas redistribuídas.
- **Justificação:** O rollover preserva a continuidade operacional sem criar estados artificiais. O reset de SLA no dia seguinte garante que o operador que assumir a demanda tenha o tempo completo para executá-la, evitando demandas já "vencidas" na fila logo no início do expediente.
- **Novos identificadores:** REQ-FUNC-014 (rollover + redistribuição + devolução forçada), REQ-ACE-010 (critérios de aceite do rollover).
- **Aplicação:** Plano 1 — ver `novos-requisitos/plano-1-rollover.md`.

## DEC-026 — Modelo de aceite explícito para demandas agendadas

- **Estado:** Decidido
- **Data:** 2026-04-20
- **Participantes:** Produto, Operações
- **Contexto:** O modelo atual de shadow-queue com transição automática `AGENDADA → PENDENTE` T-60min antes do horário-alvo é invisível ao operador e não permite gestão explícita. A área solicita modelo de aceite com pop-up, aba dedicada e expiração automática.
- **Supersede mecanismo T-60 de DEC-002.**
- **Decisões:**
  - Q1) Broadcast por **TipoMaquinario** — sem filtro de setor; operador pode estar em qualquer lugar da obra.
  - Q2) Recusa não remove — demanda permanece na aba "Demandas Agendadas". Log registra `RECUSADA` / `ACEITA_POR_OUTRO` por operador.
  - Q3) `operadorAlocadoId` **bypassa** o fluxo de aceite (alinhado com DEC-001).
  - Q4) Fechar pop-up = **adiar decisão** (sem registro de recusa).
  - Q5) Operador **não pode aceitar** mais de uma demanda no mesmo slot horário.
  - Q9) Janela de conflito de aceite **configurável por obra**.
  - Q10) Requisitos de UI para tela de gestão no painel admin incluídos como REQ-IDs nesta iteração.
- **Justificação:** Aceite explícito dá ao operador ciência e responsabilidade sobre demandas agendadas. A aba dedicada substitui o posicionamento progressivo na fila (desnecessário com aceite explícito). A expiração T-1h → `NAO_EXECUTADA` cria estado terminal auditável para demandas sem aceite.
- **Aplicação:** Plano 2 — ver `novos-requisitos/plano-2-agendadas.md`.

## DEC-027 — UsuarioInternoFGR cria agendamentos com aprovação prévia

- **Estado:** Decidido
- **Data:** 2026-04-20
- **Participantes:** Produto, Operações
- **Contexto:** DEC-020 definiu o escopo do `UsuarioInternoFGR`. O fluxo de criação de demandas agendadas por esse perfil requer aprovação do admin antes de ativar a demanda, criando um estado intermediário.
- **Supersede parcialmente:** DEC-020 — estende o modelo de aprovação para agendamentos desse perfil.
- **Decisões:**
  - Q7) **Novo estado `AGUARDANDO_APROVACAO`** — agendamentos do `UsuarioInternoFGR` nascem nesse estado até aprovação do AdminOp/SuperAdmin. Rejeição leva a `CANCELADA`.
- **Justificação:** O fluxo de aprovação prévia mantém controle administrativo sobre agendamentos de perfis não-operacionais, evitando demandas agendadas não revisadas entrando no sistema.
- **Aplicação:** Plano 2 — ver `novos-requisitos/plano-2-agendadas.md`.

## DEC-028 — Novo estado terminal `NAO_EXECUTADA`

- **Estado:** Decidido
- **Data:** 2026-04-20
- **Participantes:** Produto, Operações
- **Contexto:** Demandas agendadas que expiram sem aceite de nenhum operador não têm destino auditável no modelo atual (acabavam somente em `CANCELADA`, perdendo rastreio de causa).
- **Decisões:**
  - Demandas agendadas sem aceite até **T-1h** antes da `dataAgendada` transitam para `NAO_EXECUTADA` (estado terminal).
  - Log registra status por operador: `RECUSADA` (recusou explicitamente) ou `NAO_RESPONDIDA` (adiou/ignorou).
- **Justificação:** `NAO_EXECUTADA` distingue claramente demandas canceladas por decisão administrativa de demandas expiradas sem resposta operacional, permitindo relatórios de taxa de cobertura de agendamentos.
- **Aplicação:** Plano 2 — ver `novos-requisitos/plano-2-agendadas.md`.

## DEC-029 — Solicitação de cancelamento pelo operador para demandas agendadas

- **Estado:** Decidido
- **Data:** 2026-04-20
- **Participantes:** Produto, Operações
- **Contexto:** DEC-019 definiu que o operador não pode cancelar demandas diretamente. Para demandas agendadas, onde o operador fez aceite explícito, é necessário um fluxo de solicitação de cancelamento com aprovação administrativa.
- **Complementa:** DEC-019 (sem contradição — dualidade intencional).
- **Decisões:**
  - Q6) Operador **solicita** cancelamento → AdminOp recebe no painel e decide (aprova ou rejeita). Admin cancela diretamente com motivo obrigatório.
  - Q8) Fluxo de solicitação de cancelamento aplica-se **apenas a demandas agendadas** (demandas normais mantêm DEC-019).
  - Q11) Dualidade de cancelamento (direto para normais, solicitação para agendadas) é **intencional** — nova DEC complementa DEC-019.
- **Justificação:** O fluxo de solicitação preserva a integridade operacional (operador não cancela unilateralmente) mas reconhece que, em demandas agendadas, o operador fez comprometimento explícito e pode ter motivos legítimos para solicitar descomprometimento.
- **Aplicação:** Plano 2 — ver `novos-requisitos/plano-2-agendadas.md`.

## DEC-030 — Rota de login separada para Empreiteiro e Operador (PWA campo)

- **Estado:** Decidido
- **Data:** 2026-04-25
- **Participantes:** Produto, Engenharia
- **Contexto:** FGR Ops é destinado exclusivamente a funcionários da FGR. Empreiteiro e Operador não acessam o shell FGR Ops. D6 impõe autenticação por PIN de 6 dígitos para perfis de campo, incompatível com o formulário email + senha forte do portal FGR Ops. O PWA `manifest.json` exige entrypoint separado para que o "Add to Home Screen" instale o app correto com ícone e nome adequados. No futuro, o Empreiteiro poderá ter um portal multi-app para navegar entre serviços disponíveis; a separação de rota antecipa essa arquitetura sem overhead no MVP.
- **Opções em análise:**
  - A) Portal unificado com bifurcação de UX por perfil detectada após e-mail (exibe PIN ou campo de senha conforme perfil).
  - B) Rota de login separada para campo (`/app`) — PIN-first, mobile-optimized — independente do portal FGR Ops (`/`).
- **Decisão:** B) Rota separada. O portal FGR Ops (`/`) autentica funcionários FGR (`SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`) via email + senha forte. O login campo (`/app`) autentica `Empreiteiro` e `Operador` via email + PIN 6 dígitos, com UX mobile-first e PWA manifest próprio.
- **Justificação:** UX de autenticação fundamentalmente diferente (PIN vs senha) inviabiliza portal único sem bifurcação condicional — que introduziria complexidade desnecessária. Rotas separadas permitem: (i) manifest PWA correto por aplicação; (ii) UX de campo otimizada para toque em smartphone; (iii) evolução independente (ex.: portal Empreiteiro multi-app em Fase 2) sem afetar o portal corporativo.
- **Aplicação:**
  - `docs/SPEC/01-modulos-plataforma.md`: seção "Fluxo de autenticação e roteamento de entrada" atualizada — três pontos de entrada explicitados com rotas e perfis.
  - `docs/UI/FGR-Ops/01-login-portal.md`: escopo exclusivo para funcionários FGR documentado.
  - `docs/UI/FGR-Ops/02-app-shell-hub.md`: Empreiteiro e Operador removidos do shell; perfis canônicos corrigidos.
  - `docs/UI/Machinery-Link/00-login-campo.md`: criado — portal PWA campo (PIN-first, mobile-first).

---

## DEC-031 — Telas de configuração operacional pertencem ao escopo do Machinery Link

- **Estado:** Decidido
- **Data:** 2026-04-25
- **Participantes:** Produto, Arquitetura
- **Contexto:** Durante a prototipação das telas MVP faltantes (`implementation_plan.md`), as telas "Configurações da Obra" (malha espacial, catálogos, parâmetros) e "Gestão de Acessos" (empreiteiras, operadores, empreiteiros, ajudantes) foram inicialmente posicionadas em `docs/UI/FGR-Ops/`. Verificação contra DEC-014 e SPEC/01 §"Delimitação de responsabilidades" revelou que ambas operam sobre entidades `tenant-scoped` (`obraId` obrigatório) e são executadas pelo `AdminOperacional` — perfil que opera exclusivamente dentro do módulo Machinery Link, não no shell cross-tenant do FGR Ops.
- **Opções em análise:**
  - A) Manter as telas em `docs/UI/FGR-Ops/` com acesso cross-tenant para `AdminOperacional`.
  - B) Mover as telas para `docs/UI/Machinery-Link/` como parte do escopo tenant-scoped do módulo.
- **Decisão:** B) Telas `07-configuracoes-obra.md` e `08-gestao-acessos.md` pertencem ao módulo Machinery Link (`docs/UI/Machinery-Link/`), acessíveis via sidebar do módulo nas rotas `/machinery-link/configuracoes` e `/machinery-link/acessos`. O `AdminOperacional` gerencia apenas a obra à qual está vinculado; o `SuperAdmin` acessa qualquer obra (cross-tenant, via middleware D5).
- **Justificação:** DEC-014 (2026-04-09) formaliza que cadastros operacionais internos — incluindo malha espacial, catálogos, parâmetros, empreiteiras e operadores — são responsabilidade exclusiva do Machinery Link (tenant-scoped). A tela de CRUD de Obras e ativação de módulos (`docs/UI/FGR-Ops/03-crud-obras.md`) permanece no FGR Ops por ser cross-tenant e exclusiva do `SuperAdmin`. Separar as responsabilidades na UI reflete fielmente a separação arquitetural já definida.
- **Aplicação:**
  - `docs/UI/Machinery-Link/07-configuracoes-obra.md`: criado — malha espacial (Setores, Quadras, Lotes, Adjacências, Locais Externos), catálogos (TipoMaquinario, Servico, Maquinario, Material) e parâmetros operacionais (expediente, pesos de fila).
  - `docs/UI/Machinery-Link/08-gestao-acessos.md`: criado — Empreiteiras, Empreiteiros (PIN), Operadores (PIN + habilitações), Ajudantes.
  - `docs/UI/FGR-Ops/03-crud-obras.md`: criado — CRUD de Obras e toggle de ativação do Machinery Link (SuperAdmin only).
  - `docs/UI/Machinery-Link/03-dashboard-supervisor.md` §3.1: sidebar atualizada com "Configurações" (⚙) e "Acessos" (👥).
  - `docs/UI/FGR-Ops/02-app-shell-hub.md` §6: navegação do Machinery Link atualizada com todos os itens de sidebar.
  - `docs/UI/UI-DESIGN.md` §7: índice de telas atualizado com as 6 novas telas MVP.
  - `docs/traceability.md`: referências UI adicionadas nas linhas `REQ-RBAC-*`, `REQ-FUNC-006/009`, `REQ-FUNC-013`, `REQ-ACE-002-006`, `REQ-NFR-002`.

---

## DEC-032 — Política de versões do ambiente local — Node 24, pnpm 10, Memurai, SQL Express

- **Estado:** Decidido
- **Data:** 2026-04-27
- **Participantes:** Engenharia
- **Contexto:** O `INFRA.md` (escrito em 2026-04) especificava Node 20 LTS, pnpm 9.x e Redis 7.x (Linux) como pré-requisitos. Na auditoria do ambiente local de bootstrap (2026-04-27) constatou-se: Node v24.15.0 já instalado, pnpm 10.33.2 já instalado, Memurai 4.2.2 (compatível com Redis API 7.4.7) já instalado e em execução como serviço Windows, SQL Server Express 2019 com instância nomeada `SQLEXPRESS` em execução. O time é pequeno (1 dev) e a produção é Windows Server (DEC-022).
- **Opções em análise:**
  - A) Downgrade para Node 20 LTS e pnpm 9 (seguir INFRA.md à letra).
  - B) Adotar versões já instaladas (Node 24, pnpm 10) e atualizar INFRA.md.
  - C) Tornar Node 20 e 24 ambos suportados via `.nvmrc` + matrix CI.
- **Decisão:** B) Adotar Node 24 LTS, pnpm 10 e Memurai (Redis para Windows) como baseline oficial do FGR-Ops. SQL Server Express 2019 com instância nomeada `SQLEXPRESS` é aceito para desenvolvimento local — `DATABASE_URL` deve usar o formato `sqlserver://localhost\\SQLEXPRESS;database=fgrops_dev;...` ao invés da porta 1433 padrão. Turborepo instalado via dual-install (global para CLI + `devDependency` no root para pinning). Pinagem reforçada via `packageManager: "pnpm@10.x"` e `engines: { "node": ">=24" }` no `package.json` raiz.
- **Justificativa:** 1) Paridade dev/prod: Memurai é o build oficial do Redis para Windows e a produção é Windows Server — usar Memurai em dev elimina a divergência que aparece só no deploy. 2) Node 24 entrou em LTS em 2025-10 e tem suporte completo de NestJS 10+, Vite 5+, React 19 e Prisma; não há razão técnica para downgrade. 3) pnpm 10 fixa o lockfile em `lockfileVersion: '10.0'`; `packageManager` no root garante que Corepack force a versão correta em qualquer máquina. 4) Turbo dual-install: CLI global conveniente + `devDep` faz pinning por repo (global defere automaticamente para a versão local quando presente). 5) SQL Express com instância nomeada exige connection string específica; documentar evita debug desnecessário.
- **SPECs/REQ-IDs afetados:** `INFRA.md §1`, `INFRA.md §3`, `INFRA.md §4`
- **Aplicação (2026-04-28):**
  - `docs/INFRA.md §1`: tabela dev local — Node.js 20 LTS → **24 LTS**, pnpm 9.x → **10.x**, Redis 7.x → **Memurai 4.x**; Turborepo com nota de dual-install; instância nomeada SQL Express adicionada; tabela produção alinhada.
  - `docs/INFRA.md §3`: `DATABASE_URL` atualizado para instância nomeada (`localhost\\SQLEXPRESS`); `.env` separado por app (ver DEC-033).
  - `docs/INFRA.md §4`: instrução de bootstrap atualizada com nota de Turborepo dual-install.

---

## DEC-033 — Pipeline Turborepo — `.env` por app, `cache: false` explícito em `dev`, `test` vs `test:integration`

- **Estado:** Decidido
- **Data:** 2026-04-28
- **Participantes:** Engenharia
- **Contexto:** Bootstrap do monorepo Turborepo (Fase 1.1). Três decisões de configuração precisam ser fixadas antes de criar `turbo.json`, `package.json` raiz e os `.env`: (a) **Localização do `.env`** — `INFRA.md §3` exemplificava um único `.env` na raiz misturando segredos de backend e variáveis `VITE_*` do front. (b) **Cache do `turbo dev`** — comportamento implícito de tasks `persistent`. (c) **Dependência do target `test`** — `packages/domain` roda Vitest sobre TS fonte direto, sem precisar de artefato compilado.
- **Opções em análise:**
  - A) `.env` único na raiz · cache implícito · `test` depende de `build`.
  - B) `.env` por app · `"cache": false` explícito · `test` independente; integration manual.
  - C) `.env` por app · `"cache": false` explícito · `test` rápido + `test:integration` separado — **ESCOLHIDO**.
- **Decisão:** (a) **`.env` por app**: cada app gerencia seu próprio `.env`/`.env.example` (`apps/api/.env`, `apps/web/.env`). Não há `.env` na raiz. (b) **`"cache": false` explícito** em todas as tasks `dev` no `turbo.json`. (c) **Dois targets de teste**: `test` (sem dependências — loop TDD rápido contra TS fonte) e `test:integration` (depende de `build` e `^build` — para testes que precisam do dist/Prisma client). `turbo run test` é o default; CI roda ambos.
- **Justificativa:** (a) Isola `JWT_SECRET` (server-only) de `VITE_API_BASE_URL` (browser-exposto); `apps/mobile` futuro (DEC-023) reutiliza o padrão. (b) Custo zero — Turbo já tem o comportamento por padrão; `"cache": false` explícito documenta a intenção e protege contra marcação acidental. (c) Ciclo red-green-refactor de `packages/domain` precisa ser sub-segundo; forçar `test → build` compilaria 6+ packages antes de cada execução.
- **SPECs/REQ-IDs afetados:** `INFRA.md §2`, `INFRA.md §3`, `INFRA.md §6`
- **Aplicação (2026-04-28):**
  - `docs/INFRA.md §2`: estrutura do monorepo — `.env` removido da raiz; `.env`/`.env.example` por app sob `apps/api/` e `apps/web/`; `package.json` raiz anotado com `engines` + `packageManager`.
  - `docs/INFRA.md §3`: seção reestruturada em subseções `apps/api/.env.example` e `apps/web/.env.example`; separação explícita de segredos backend vs variáveis `VITE_*`.
  - `docs/INFRA.md §6`: target `test:integration` documentado separadamente de `test`; semântica de cada target explicada.

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
- **PRD-M03-001:** `PRD/02-jornada-usuario.md` — `REQ-JOR-001` agora especifica seleccao de `SetorOperacional` (obrigatorio) e `Quadra`/`Lote` (opcional). *(Nota: subsequentemente actualizado por DEC-005 — Quadra/Lote tornados obrigatorios, Local Externo introduzido, SetorOperacional derivado. Revisto por DEC-006 — entrega formal de material adiada para pos-MVP; movimentacao de massas como demanda regular.)*
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

---

## DEC-034 — Linha divisória DDD Tático vs Transaction Script

- **Estado:** Decidido
- **Data:** 2026-04-29
- **Participantes:** Engenharia, Arquitetura
- **Contexto:** O design document (2026-04-28) formalizou uma abordagem híbrida: aggregates ricos para núcleo comportamental, Transaction Script para catálogos. Sem uma ADR explícita, há risco de devs futuros "padronizarem tudo como aggregate" (cerimônia desnecessária) ou "simplificarem tudo como CRUD" (invariantes da Demanda espalhadas em service-methods de centenas de linhas). A linha divisória precisa ser critérios concretos, não julgamento individual.
- **Opções em análise:**
  - A) Tudo como aggregate (DDD puro): rejeitada — cerimônia desproporcional para CRUDs, risco de anemic domain model nos aggregates simples.
  - B) Tudo como Transaction Script: rejeitada — invariantes da Demanda explodem em service-methods; auditoria fica opcional.
  - C) Critério subjetivo caso a caso: rejeitada — inconsistência entre devs, sem referência para code review.
  - D) Critérios objetivos ≥2 de 4 (adotada): previsível, auditável em PR, extensível para novos módulos.
- **Decisão:** Usar Aggregate Rico (DDD Tático) quando a entidade satisfaz ≥2 dos critérios: (1) máquina de estados com ≥3 estados e transições condicionais por perfil; (2) invariantes de negócio que devem ser blindadas estruturalmente (não apenas por validação em service); (3) auditoria estrutural obrigatória via Domain Events (não log opcional); (4) reuso garantido em outro app/contexto (ex: mobile). Caso contrário: Transaction Script + Prisma direto. Entidades aggregate no MVP: `Demanda`, `RegistroExpediente`, `Usuario` (auth/PIN). Entidades Transaction Script no MVP: `TipoMaquinario`, `Material`, `Servico`, `Empreiteira`, `Ajudante`, `SetorOperacional`, `Quadra`/`Lote`/`Rua`.
- **Justificativa:** Os 9 estados × 6 perfis × ~10 ações da Demanda criam combinatória que explode em service-methods sem aggregate. A auditoria regulatória (`DemandaLog`) não pode depender de "lembrar de logar" — Domain Events tornam-na estrutural. Os CRUDs de catálogo têm ciclo de vida trivial (criar/editar/soft-delete) sem invariantes interdependentes; adicionar aggregate neles seria cerimônia sem retorno. O critério de ≥2 evita tanto falsos positivos quanto falsos negativos.
- **SPECs/REQ-IDs afetados:** `SPEC/02`, `SPEC/03`, `SPEC/04`, `docs/superpowers/specs/2026-04-28-arquitetura-fgr-ops-design.md`

---

## DEC-035 — Biblioteca Result/Either para erros de domínio previsíveis

- **Estado:** Decidido
- **Data:** 2026-04-29
- **Participantes:** Engenharia
- **Contexto:** O design document define Result/Either como padrão para erros de domínio previsíveis (transição inválida, operador não autorizado), com exceptions reservadas para falhas de infra. Três opções foram consideradas: implementação custom mínima, neverthrow (biblioteca npm), e ts-results. O Plano 01 de implementação (packages/domain bootstrap) já criou `Result.ts` custom como ponto de partida.
- **Opções em análise:**
  - A) neverthrow (npm): API rica, bem mantida, tipagem excelente — descartada pela dependência transitiva no mobile e pela API excessiva para o MVP.
  - B) ts-results (npm): mais simples que neverthrow, inspirado em Rust — descartada pelos mesmos motivos de dependência + overhead de aprendizado sem ganho real sobre custom.
  - C) Custom mínima em `packages/domain/shared/Result.ts` (adotada): zero dependência, API controlada, suficiente para MVP, reavaliável na Fase 2.
- **Decisão:** Adotar implementação custom mínima em `packages/domain/shared/Result.ts`. A API expõe: `Result<T, E>`, `ok(value)`, `err(error)`, `isOk()`, `isErr()`, e `map`/`mapErr` para encadeamento. Sem dependência externa no `packages/domain` — o package deve permanecer zero-dependency além de TypeScript.
- **Justificativa:** `packages/domain` é compartilhado entre `api` (NestJS) e `mobile` (Expo/React Native futura). Adicionar neverthrow ou ts-results cria dependência transitiva que pode conflitar com tree-shaking do bundler mobile. A API necessária no MVP (ok/err/map) é trivial de implementar (~40 linhas) e elimina o risco de breaking changes de versão de biblioteca externa. neverthrow tem API rica (match, andThen, orElse) — útil mas desnecessária para o escopo do MVP; pode ser reavaliada na Fase 2 se a custom se mostrar insuficiente.
- **SPECs/REQ-IDs afetados:** `SPEC/00`, `docs/superpowers/specs/2026-04-28-arquitetura-fgr-ops-design.md`

---

## DEC-036 — Estratégia Outbox — tabela única vs uma por bounded context

- **Estado:** Decidido
- **Data:** 2026-04-29
- **Participantes:** Engenharia, Arquitetura
- **Contexto:** O padrão Domain Events + Outbox foi escolhido para garantir auditoria estrutural (`DemandaLog`), entrega de eventos para WebSocket Gateway e métricas sem acoplamento direto entre domínio e infra. A decisão pendente é a topologia da tabela Outbox: uma tabela global `OutboxEvent` ou uma tabela por bounded context (ex: `MachineryOutbox`, `AuthOutbox`). No MVP há um bounded context dominante (Machinery/Demanda) com volume de eventos estimado baixo.
- **Opções em análise:**
  - A) Uma tabela por bounded context: isolamento físico, particionamento natural — descartada para MVP por overhead de migrations e monitoring sem volume que justifique.
  - B) Tabela única `OutboxEvent` com campo `boundedContext` (adotada): simples, rastreável, split futuro possível sem mudança de contrato.
  - C) Sem Outbox (log direto em transaction): descartada — perde garantia de entrega e acopla domínio à infra de log.
- **Decisão:** Tabela única `OutboxEvent` com campo `boundedContext` (string enum) para identificação lógica e roteamento pelo dispatcher. Schema mínimo: `id` (UUID), `boundedContext`, `eventType`, `aggregateId`, `obraId`, `payload` (JSON), `createdAt`, `processedAt` (nullable), `retries`. O dispatcher filtra por `boundedContext` para rotear para handlers corretos. Particionamento por tabela será reavaliado se o volume ultrapassar 10k eventos/dia ou se surgir um segundo bounded context ativo com ciclo de vida independente.
- **Justificativa:** No MVP há 1 bounded context dominante com volume de eventos baixo. Tabela única simplifica migrations, o dispatcher, o monitoring e o rollback. O campo `boundedContext` garante separação lógica suficiente e permite split físico futuro sem mudança de contrato de publisher ou subscriber. Uma tabela por BC adicionaria 2–3 tabelas extras com overhead de JOIN em monitoring e sem nenhum benefício de isolamento real neste volume. O campo `obraId` na tabela Outbox garante que o multi-tenancy é rastreável mesmo em eventos assíncronos.
- **SPECs/REQ-IDs afetados:** `SPEC/03`, `SPEC/06`, `docs/superpowers/specs/2026-04-28-arquitetura-fgr-ops-design.md`

---

## DEC-037 — Organização de packages/domain — por bounded context vs por aggregate

- **Estado:** Decidido
- **Data:** 2026-04-29
- **Participantes:** Engenharia
- **Contexto:** `packages/domain` é o pacote puro compartilhado entre `api` e `mobile` (Fase 2). Precisa ser organizado de forma que devs encontrem código rapidamente, bounded contexts não vazem entre si, e o pacote escale para Fase 2 sem refatoração destrutiva. Duas topologias foram consideradas: pastas por aggregate funcional (`demanda/`, `fila/`, `sla/`) vs pastas por bounded context formal (`machinery/`, `auth/`, `catalog/`).
- **Opções em análise:**
  - A) Por bounded context formal (`domain/machinery/`, `domain/auth/`): separação DDD estrita — descartada para MVP por indireção desnecessária com único BC dominante.
  - B) Por aggregate/sub-domínio funcional sem prefixo BC (adotada): navegável, flat, refatorável quando Fase 2 introduzir segundo BC real.
  - C) Flat sem subpastas (tudo em `domain/`): descartada — não escala além de 5–6 arquivos.
- **Decisão:** Organizar por aggregate/sub-domínio funcional, sem prefixo de bounded context no MVP. Estrutura: `domain/demanda/`, `domain/fila/`, `domain/sla/`, `domain/expediente/`, `domain/shared/`. A pasta `shared/` contém os primitivos compartilhados por todos os aggregates: `Result.ts`, `DomainEvent.ts`, `AggregateRoot.ts`. Quando a Fase 2 introduzir um segundo bounded context real (ex: RH, Financeiro), a migração para `domain/machinery/demanda/` + `domain/rh/...` é cirúrgica — mover pastas + atualizar barrel imports.
- **Justificativa:** No MVP com um único bounded context dominante, adicionar uma camada de pasta `machinery/demanda/` seria indireção sem valor — todo o código comportamental está no mesmo BC. A estrutura flat por aggregate é mais navegável para um time pequeno e reduz o caminho de import. A migração futura para subpastas por BC é mecânica (`sed` + `tsc --noEmit` para confirmar) e não exige mudança de lógica. O custo de não fazer agora é zero; o custo de fazer prematuramente é paths mais longos, confusão em onboarding e barrel exports aninhados desnecessários.
- **SPECs/REQ-IDs afetados:** `SPEC/00`, `docs/superpowers/specs/2026-04-28-arquitetura-fgr-ops-design.md`

---

## DEC-038 — Outbox: adiar implementação no MVP (amenda DEC-036)

- **Estado:** Decidido
- **Data:** 2026-05-26
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** DEC-036 (2026-04-29) decidiu o **desenho** do Outbox (tabela única `OutboxEvent` com `boundedContext`), mas não definiu **quando** implementar. Surgiu a premissa, herdada de outra sessão, de implementá-lo antes do 1º slice ML (§2.6) com o argumento de "destravar §2.4/§2.5/§2.10 e preparar a Fase 2 (`ml-worker` separado)". A validação dos fatos do projeto contradiz a premissa: (a) §2.4 são Transaction Script sem aggregate — não emitem domain events; (b) `DemandaLog` (obrigatório por SPEC/03 a cada transição) mora no mesmo SQL Server e fica atômico via `prisma.$transaction([update, demandaLog.createMany])`; (c) WebSocket emit (`INVALIDATE_QUEUE`, `DEMAND_QUEUED`, `DEMAND_STATUS_CHANGED`) é best-effort por desenho explícito do SPEC/06 (graceful degradation via reconnect com back-off 1s/2s/4s/30s + re-fetch da fila); (d) `SLA_ALERT` "uma única vez" vem de job timer, não de transição de aggregate — idempotência via flag/timestamp na linha. Custo estimado de implementar agora: 1–2 sprints (migration + repository + adapter + dispatcher + polling SQL-Server-aware sem `SKIP LOCKED` + idempotência + retry + handlers + monitoring + testes). Benefício imediato: zero.
- **Opções em análise:**
  - A) Implementar Outbox antes do §2.6 conforme premissa herdada — descartada: custo alto, zero benefício imediato, nenhum requisito atual do MVP é desbloqueado.
  - B) `prisma.$transaction([demanda.update, demandaLog.createMany])` + `EventEmitter2` post-commit fire-and-forget para handlers in-process (WebSocket, métricas) (adotada): atende SPEC/03 (atomicidade do log) e SPEC/06 (best-effort + reconnect) sem nova infra; domain layer não muda; Outbox vira decorator dentro da `$transaction` quando reabrir.
  - C) Sem `EventEmitter2`, side-effects inline no handler — descartada: acopla web sync à infra de notificação, transação longa, viola separação prescrita pela arquitetura tática §6.
- **Decisão:** Adiar a implementação do Outbox. Manter o desenho da DEC-036 inalterado para uso futuro. No §2.6, `DemandaRepository.save(aggregate)` usa `prisma.$transaction` cobrindo `Demanda` + `DemandaLog`, depois publica eventos no `EventEmitter2` global do NestJS (handlers in-process consomem). `aggregate.clearEvents()` ocorre após `commit`, antes do publish. O domínio (`packages/domain`) não muda — eventos seguem POJOs puros.
- **Gatilhos de reabertura:** (1) `ml-worker` separado vira prioridade; (2) surge 1º consumidor cross-service que exige at-least-once (webhook, fila externa, TSDB); (3) auditoria externa passa a exigir log de emissão; (4) volume > ~10k eventos/dia (limiar da própria DEC-036); (5) ordenação total entre consumidores vira requisito.
- **Justificativa:** O MVP não tem nenhum consumidor que exija at-least-once persistido. SPEC/06 já desenha o caminho de recuperação para WebSocket perdido (reconnect + re-fetch). `DemandaLog` é o único consumidor crítico e é coberto por tx atômica no mesmo DB. A introdução do Outbox depois é cirúrgica: o repository ganha uma `createMany` adicional na mesma `$transaction` e o dispatcher passa a ler dela — interface do domínio inalterada. O custo de não fazer agora é zero (engenharia tática); o custo de fazer prematuramente é 1–2 sprints sem ROI, mais uma nova superfície de falha operacional (dispatcher travado, eventos acumulando, dead-letter sem monitoramento).
- **ADR local relacionado:** `memory/decisions/2026-05-26-adiar-outbox-em-favor-eventemitter2.md` (no repo de código `fgr-ops`)
- **SPECs/REQ-IDs afetados:** `SPEC/03` (DemandaLog atomicidade), `SPEC/06` (WebSocket best-effort + reconnect), `docs/superpowers/specs/2026-04-28-arquitetura-fgr-ops-design.md` §6

---

## DEC-039 — Adicionar perfil TOWER_OPERATOR à matriz RBAC (SPEC/04)

- **Estado:** Decidido
- **Data:** 2026-06-10
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** A Slice 1 do MVP introduziu o perfil `TOWER_OPERATOR` ao enum `Perfil` (`packages/types`). A adição foi TS-only: a coluna `User.perfil` é `NVarChar(40)` livre, sem enum DB nem CHECK; não há consumidor exaustivo (`Record`/`switch`) no `apps/api`; a claim JWT `perfil` não é validada contra conjunto fechado. O e2e (`rbac.e2e-spec.ts`) confirma que um token `TOWER_OPERATOR` chega ao `PerfilGuard` e recebe `403` (não `401`) em rotas admin-only. Porém, a matriz de permissões em `SPEC/04` listava apenas `SuperAdmin`, `Board`, `AdminOperacional`, `UsuarioInternoFGR`, `Empreiteiro` e `Operador` — `TOWER_OPERATOR` ficou sem linha, criando spec drift (sem fonte autoritativa para auditar as permissões do novo perfil). Achado RBAC-001 da auditoria 2026-06-03/07; aplicado no lote de reconciliação SPEC↔código da Onda 3 (regra 15: amendment no mesmo PR).
- **Decisão:** Adicionar `TOWER_OPERATOR` à matriz de permissões por recurso em `SPEC/04`. Permissões iniciais conservadoras (Slice 1): **leitura** de catálogos globais e contexto de obra como os demais perfis autenticados (`GET /tipos-maquinario`, `GET /obras/:id/fila`); **nenhuma escrita** em catálogos (`POST`/`PATCH`/`DELETE /tipos-maquinario` e demais permanecem `ADMIN_OPERACIONAL` + `SUPER_ADMIN`). Tenant-scoped por `obraId` (como `Operador`/`Empreiteiro`, **sem** bypass cross-tenant). O conjunto exato de leituras de Demanda/Fila será refinado quando a tela da torre sair de placeholder.
- **Justificativa:** `SPEC/04` é a fonte autoritativa da matriz RBAC; manter `TOWER_OPERATOR` fora dela vira conhecimento tácito e o débito cresce a cada endpoint novo. A política escrita-só-admin já está implementada e testada (`SPEC/08` §5 + e2e); documentar em `SPEC/04` fecha o loop código↔spec exigido por `REQ-RBAC-001…006`. Leitura-apenas inicial evita over-granting antes de a UX da torre estar definida — ampliar depois é mais seguro que restringir.
- **Nota de numeração:** Ratifica o rascunho `MEMORY/decision-drafts/DEC-038-draft.md` (2026-06-02), renumerado para DEC-039 por colisão: o número DEC-038 já havia sido consumido pela entrada "Outbox: adiar implementação no MVP" (2026-05-26) e este log é append-only.
- **SPECs/REQ-IDs afetados:** `SPEC/04` (04-rbac-permissoes), `REQ-RBAC-001`, `REQ-RBAC-006`, `REQ-FUNC-003`

## DEC-040 — `TOWER_OPERATOR` pode criar Demanda no MVP (carve-out, amenda DEC-039)

- **Estado:** Ativo
- **Data:** 2026-06-16
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** A Slice 3 / T3.3 (`REQ-FUNC-005`, PR #31) implementou `POST /demandas` concedendo `machinery:demanda:create` ao perfil `TOWER_OPERATOR` (controller `@Perfis(...)` + specification de domínio `PodeCriarDemanda`). O code review (2026-06-16) detectou divergência **spec-vs-spec**: o design do MVP-reduzido (`docs/superpowers/specs/2026-05-26-mvp-15-julho-escopo-reduzido-design.md`, L110 e L183) lista `TowerOp` como criador de Demanda (`Demanda.criar → PENDENTE` e `POST /demandas`), mas a `SPEC/04` canônica (linha `machinery:demanda:create` + subseção `TOWER_OPERATOR` da DEC-039: *"Nenhuma escrita: create/update/delete/export → ✗ em todos os recursos"*) e a `SPEC/03` (tabela de transições, linha `criar`) **não** o autorizavam. O PR original amendou apenas a `SPEC/08`, deixando `SPEC/04` e `SPEC/03` contradizendo o código (regra 15 parcialmente insatisfeita). A própria DEC-039 já previa que as permissões do `TOWER_OPERATOR` seriam refinadas *"quando a tela da torre sair de placeholder"*.
- **Decisão:** O `TOWER_OPERATOR` **pode criar Demanda** via `POST /demandas` (estado inicial sempre `PENDENTE`, contrato free-text do MVP; **sem** `dataAgendada`). É um **carve-out cirúrgico** de `machinery:demanda:create` que **amenda a DEC-039** — a regra "nenhuma escrita" do perfil passa a ter essa exceção única. Demais escritas seguem **proibidas**: `update`/`delete`/`export` → ✗ em todos os recursos; escritas de catálogo permanecem restritas a `AdminOperacional` + `SuperAdmin`. Reconciliação aplicada no **mesmo PR** (regra 15): `SPEC/04` (subseção `TOWER_OPERATOR` reescrita + nota de rodapé `[8]` na linha `machinery:demanda:create` + linha `[*] create` da matriz de estado) e `SPEC/03` (linha `criar` → `PENDENTE`). A **coluna dedicada** do `TOWER_OPERATOR` na matriz de recursos **não** é adicionada agora (evitaria preencher ~100 linhas, a maioria ✗) — fica para a slice da tela da Torre / Kanban (Slice 6), que traz os demais verbos do perfil (`alocar`, `reordenar`, `devolver`, kanban read).
- **Justificativa:** O design do MVP-reduzido (2026-05-26) é a fonte de escopo canônica do MVP-15jul e o pivot estratégico central: o `TOWER_OPERATOR` é o **novo perfil humano que substitui a complexidade algorítmica** (scoring por adjacência/material/serviço) — ele cria e distribui a fila manualmente no Kanban. Negar-lhe o `create` contradiria a razão de existir do perfil. A DEC-039 declarou as permissões como placeholder conservador a refinar; este DEC é esse refinamento para a capacidade de criar Demanda. Ratificar agora (vs. reverter e re-adicionar na Slice 6) evita churn de código (controller + specification + testes) e mantém o código de T3.3 estável. O carve-out cirúrgico (em vez da coluna completa) evita over-granting antes de a UX da Torre estar definida — ampliar depois é mais seguro que restringir (mesma filosofia da DEC-039). Paulo ratificou explicitamente a direção em 2026-06-16.
- **SPECs/REQ-IDs afetados:** `SPEC/04` (04-rbac-permissoes), `SPEC/03` (03-fila-scoring-estados-sla), `REQ-FUNC-005`, `REQ-RBAC-001`, `REQ-RBAC-006`, `REQ-FUNC-003`

---

## DEC-041 — Ajudante adiado para Fase 2 (fora do MVP-15jul)

- **Estado:** Ativo
- **Data:** 2026-06-18 (ratificada 2026-06-19, pós-merge do PR #35 `cf67931`)
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** O aggregate `RegistroExpediente` continha maquinaria de ajudante: VO `TurnoAjudante`, evento `AjudanteTrocado`, método `trocarAjudante`, campo `ajudanteId` em `ExpedienteAberto`/input, getters `ajudanteAtualId`/`turnosAjudante`. A `SPEC/06` descrevia rastreabilidade de ajudantes (sub-escopo de `REQ-FUNC-004` "Diário operacional de expediente") como parte do MVP, e os docs de planejamento (`fase-2-backend.md`, `fase-4-telas.md`) listavam check-in com seleção de ajudante e troca de ajudante durante turno. No T5.1 (Slice 5, PR #35 squash `cf67931`) toda essa maquinaria foi hard-deletada do domínio para enxugar a API pública do `RegistroExpediente`. Esta DEC formaliza o corte e propaga o deferral. **Nota:** o núcleo check-in/checkout de `REQ-FUNC-004` permanece no MVP (T5.2) — apenas a sub-parte de rastreabilidade de ajudante é adiada. `REQ-FUNC-006` (Demandas Agendadas: Aceite Explícito) **não** tem relação com ajudante.
- **Opções consideradas:**
  - A) Manter ajudante como `@deprecated` (código morto não-referenciado — pior signal-to-noise).
  - B) Hard-delete domínio + drop imediato das tabelas Prisma (migration arriscada, fora do escopo T5.1).
  - C) Hard-delete domínio + parking-lot DB (**ESCOLHIDA** — preserva dados, remove complexidade do aggregate).
- **Decisão:** Ajudante é cortado do MVP-15jul e adiado para a Fase 2. Footprint completo:
  - **Domínio (removido — T5.1, hard-delete; git preserva):** VO `TurnoAjudante`; evento `AjudanteTrocado`; método `trocarAjudante`; campo `ajudanteId` em `ExpedienteAberto` e no input de abertura; getters `ajudanteAtualId`/`turnosAjudante`.
  - **DB (parking-lot — Fase 2, NÃO dropado no T5.1):** model Prisma `Ajudante` (`catalogo.prisma`); model `TurnoAjudante` (`operacional.prisma`); relations `RegistroExpediente.turnosAjudante`/`Obra.ajudantes`; seed `Ajudante Demo` (`catalogo-module.ts`) + count (`main.ts`) ficam inócuos. Dropar = migration separada com risco de dados, fora do escopo de T5.1.
  - **Requisito:** sub-escopo de `REQ-FUNC-004` (rastreabilidade de ajudantes) → adiado p/ Fase 2; núcleo check-in/checkout permanece no MVP (T5.2).
  - **UX:** check-in sem seleção de ajudante; sem tela de troca de ajudante na UI Operador.
- **Justificativa:** No MVP-15jul o Operador trabalha sozinho na máquina; o rastreio de ajudante (turnos, troca em pleno turno, vínculo ajudante↔demanda por interseção temporal) não entrega valor no MVP e adiciona superfície de domínio + tabelas + UI sem caso de uso ativo. A maquinaria estava estruturalmente entrelaçada no aggregate (`trocarAjudante` opera sobre `_turnosAjudante`, construído do `ajudanteId` do input) → mantê-la como `@deprecated` deixaria código morto não-referenciado (pior signal-to-noise que deletar). `dev-todo/fase-2-backend.md` já lista "Ajudante" como parking-lot pós-MVP e nenhuma slice do roadmap depende dela. Git preserva tudo para a Fase 2. Precedentes: DEC-019 (`SolicitacaoCancelamento` removida do MVP via DEC do glossário) e o padrão de deprecate-park do T3.2/PR #29.
- **Follow-up (rastreado em `dev-todo/fase-2-backend.md`):** marcado no PR #35 — `SPEC/08` (contratos `POST /operadores/:id/ajudante`, CRUD `/obras/:id/ajudantes`, OPR-006/007), `SPEC/05` (glossário), `SPEC/06` (banner rastreabilidade). **Pendente p/ follow-up** — `SPEC/02` (modelo de dados), `SPEC/04` (matriz RBAC `machinery:ajudante:*`), `SPEC/01` (catálogo #17), `PRD/00·03` (REQ-SCO-003/005, REQ-FUNC-004 prosa), `UI/Machinery-Link/08` (aba "Ajudantes").
- **Nota de numeração:** `draft_decision` auto-atribuiu DEC-038 ao rascunho, mas DEC-038 já é "Outbox: adiar implementação" (log append-only) — número correto = **DEC-041** (contador `fgr-ops-docs/CLAUDE.md`). Colisão recorrente (mesmo padrão da DEC-039). Ratifica `MEMORY/decision-drafts/DEC-041-draft.md` (removido neste commit, espelhando o tratamento do DEC-038-draft em `7c11a84`). **Watch-item resolvido:** a lane irmã Slice 4 (worktree `../Fgr-Ops-slice4`) partia de um estado "próxima DEC-041" — esta ratificação reivindica o número; Slice 4 usa **DEC-042+** (o contador no `fgr-ops-docs/CLAUDE.md` da branch slice-4 fica stale e reconcilia no merge dela).
- **SPECs/REQ-IDs afetados:** `REQ-FUNC-004` (sub-escopo ajudante), `SPEC/05-backlog-mvp-glossario`, `SPEC/06-definicoes-complementares`, `SPEC/08-api-contratos`

---

## DEC-042 — CPF como identificador de login de campo (`/auth/pin`) — amenda SPEC/08 §2/§4b/§8 (T4.1.2)

- **Estado:** Ativo
- **Data:** 2026-06-23 (ratificada pós-merge do PR #43 `8f6b9eb`)
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** A T4.1 (DEC tática `memory/decisions/2026-06-18-usuario-email-obrigatorio-e-soft-delete.md`) tornou `email` obrigatório para TODOS os perfis (divergência #1 vs SPEC/08 §4b), porque o `LoginPinHandler` resolvia o usuário de `POST /auth/pin` via `findByEmail(input.usuario)`. Paulo reverteu (e-mail volta a opcional nos perfis de campo OPERADOR/EMPREITEIRO), o que reabriu a questão de QUAL campo o `usuario` do `/auth/pin` resolve. Decidido em [ADR 0003](https://github.com/FGR-Incorporacoes-S-A/Fgr-Ops/blob/main/docs/adr/0003-pin-login-identifier-cpf.md) (Accepted, sign-off 2026-06-23): **CPF**. Eleger esse campo amenda o contrato de autenticação (Regra 15) → SPEC/08 amendada em §2, §4b e §8 (canônico = lado da implementação T4.1.2). Receita de implementação (o "como") em `memory/decisions/2026-06-23-t4.1.2-cpf-login-identifier.md`.
- **Opções consideradas:**
  - A) Login dedicado (username): campo artificial a mais para gerir/memorizar — rejeitado.
  - B) **CPF (ESCOLHIDA):** conhecido de cor, estável, sem campo novo a memorizar.
  - C) Telefone: menos estável, nem todo operador tem número fixo — rejeitado.
  - D) email OU cpf (fallback): ambiguidade de resolver = vetor de troca de login-id — rejeitado.
  - E) Unicidade per-obra: exigiria seletor de obra pré-autenticação no request — fora do MVP.
- **Decisão:** SPEC/08 amendada em três pontos (canônico = implementação T4.1.2):
  - **(§2 `POST /auth/pin`):** o campo `usuario` é o **CPF normalizado** (11 dígitos, com ou sem máscara — normalizado por `stripNonDigits`) para perfis de campo; o handler resolve por `findByCpf`, **NÃO** por `findByEmail` (que permanece em `POST /auth/login` administrativo). O `pinSchema.usuario` permanece `z.string().min(1)` — CPF malformado **não** é rejeitado pelo schema de login: cai no resolver → 401 genérico + lockout + audit (mascarado), preservando **DEC-004** (erro não-enumerável). A chave de lockout do PIN **normaliza o CPF** (variantes de máscara não burlam mais o lockout progressivo per-user — regressão de segurança pega+corrigida na review final, opus).
  - **(§4b `POST /usuarios`):** `cpf` **OBRIGATÓRIO** para OPERADOR e EMPREITEIRO (validado com dígito verificador via `cpfSchema` → 400 acionável na escrita); `email` **OPCIONAL** nesses dois perfis e **OBRIGATÓRIO** nos 5 perfis admin/mesa (`SUPER_ADMIN`, `BOARD`, `ADMIN_OPERACIONAL`, `USUARIO_INTERNO_FGR`, `TOWER_OPERATOR`). O contrato `Usuario.email` passa a `string | null` (`packages/types`). Unicidade do CPF é **GLOBAL** entre usuários ativos (índice filtrado `UX_User_cpf_active`, `WHERE deletadoEm IS NULL AND cpf IS NOT NULL`). CPF é **imutável** no MVP (`updateUsuarioSchema` não recebe cpf).
  - **(§8 códigos de erro):** novo **`USR-004`** = CPF já cadastrado para outro usuário ativo (409).
- **Justificativa:** ADR 0003 — CPF é conhecido de cor pelo operador (login PIN em device compartilhado de campo), não cria campo artificial novo e é estável. A **assimetria de validação login×escrita** preserva DEC-004 (no login, erro não-enumerável + lockout + audit obrigatórios) enquanto dá feedback de formulário (400 "CPF inválido") na escrita admin-facing. Unicidade **global** porque o `/auth/pin` não tem contexto de obra pré-autenticação (a obra vem da claim JWT, inexistente no momento do login) → o identificador precisa resolver sem tenant; per-obra exigiria seletor de obra no request (custo de contrato + FE, fora do MVP). **LGPD:** CPF (PII) é mascarado (`maskCpf` → `***.***.***-DD`) nas escritas de audit do `LoginPinHandler`. `/auth/login` e `findByEmail` ficam **intactos** (blast-radius confinado ao caminho de campo).
- **Follow-up (amenda de prosa SPEC/08 PENDENTE — `T4.1-SPEC`):** o PR #43 **não** editou a prosa de `fgr-ops-docs/docs/SPEC/08-api-contratos` (a branch foi BE-centric). Esta DEC é o **registro canônico** da divergência (Regra 15: divergência declarada, **não** silenciosa). Sincronizar a prosa de SPEC/08 §2/§4b/§8 (+ `traceability.md` se aplicável) com esta decisão fica como follow-up documental **T4.1-SPEC**, rastreado no roadmap. Pendência da slice T4.1.2 ainda aberta: **smoke manual FE** do render de `email` nullable em `apps/web/src/routes/ops/usuarios.tsx` (build-verified, não browser-smoked).
- **Nota de numeração:** `draft_decision` auto-atribuiu **DEC-038** ao rascunho, mas DEC-038 já é "Outbox: adiar implementação" (log append-only) → número correto = **DEC-042** (contador `fgr-ops-docs/CLAUDE.md`; reservado para a lane Slice 4 desde a ratificação da DEC-041 no T5.1). Mesma colisão recorrente das DEC-039/041. Ratifica `MEMORY/decision-drafts/DEC-038-draft.md` (**removido** neste commit, espelhando o tratamento dos drafts anteriores). Contador bumpado **DEC-042 → DEC-043**.
- **SPECs/REQ-IDs afetados:** `SPEC/08-api-contratos` (§2, §4b, §8), `REQ-RBAC-001`, `REQ-NFR-007`, `DEC-004`

---

## DEC-043 — `tiposMaquinarioIds` fora do `POST /usuarios` (staged p/ T4.2) + sync da prosa SPEC/08 §2/§4b/§8 (fecha T4.1-SPEC)

- **Estado:** Ativo
- **Data:** 2026-06-24
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** A T4.1 (PR #36) documentou em `memory/decisions/2026-06-18-usuario-email-obrigatorio-e-soft-delete.md` (§ "SPEC/08 §4b amendment") quatro divergências deliberadas vs SPEC/08 §4b, pendentes de publicação canônica (Regra 15). Estado na abertura desta DEC: **#1** (e-mail obrigatório p/ todos os perfis) foi **retirada** — revertida pela T4.1.2/DEC-042 (e-mail volta a opcional p/ `OPERADOR`/`EMPREITEIRO`); **#2** (`TOWER_OPERATOR` criável via `POST /usuarios`, credencial `password`) e **#4** (`BOARD` criável) já estavam canonizadas por DEC-039/DEC-040 (perfil `TOWER_OPERATOR` na matriz RBAC + carve-out de criar Demanda) e por DEC-042 (que enumera `TOWER_OPERATOR` e `BOARD` entre os 5 perfis admin/mesa do `POST /usuarios`); restava **#3** sem DEC própria. Em paralelo, a DEC-042 deixou explícito que a **prosa** de SPEC/08 §2/§4b/§8 não havia sido editada (PR #43 foi BE-centric) — follow-up documental **T4.1-SPEC**.
- **Opções consideradas:**
  - A) Nova DEC consolidando #2/#3/#4 — rejeitada: #2/#4 já têm registro canônico (DEC-039/040/042); reabri-los criaria dois registros sobrepostos (há histórico de colisão de numeração nas notas das DEC-039/041/042).
  - B) Nota inline no §4b citando apenas o memory file da T4.1, sem DEC — rejeitada: #3 ficaria sem número canônico, contra o pedido de "registrar como canônico".
  - C) **DEC-043 curta, escopada apenas a #3** (**ESCOLHIDA**), cross-referenciando DEC-042 p/ #2/#4, executada junto com a sincronização da prosa SPEC/08 §2/§4b/§8 (fechando T4.1-SPEC).
- **Decisão:** O campo `tiposMaquinarioIds` **não é aceito** no `POST /usuarios`. O `createUsuarioSchema` é um `discriminatedUnion` por `perfil` com cada branch `.strict()`; enviar `tiposMaquinarioIds` (ou qualquer campo fora do branch) resulta em **400** — rejeição, **não** strip silencioso (confirmado em `packages/schemas/src/core/usuario/create-usuario.schema.test.ts`, teste *"rejeita OPERADOR com tiposMaquinarioIds (campo é da T4.2, .strict)"*). A associação N:M `Operador ↔ TipoMaquinario` pertence ao cadastro de Operador (**T4.2 — Operador CRUD BE**), que a implementará com validação adequada. **Reconciliação de prosa aplicada no mesmo commit (Regra 15, fecha T4.1-SPEC):** SPEC/08 §2 (`usuario` do `/auth/pin` = CPF, resolve por `findByCpf`), §4b (`POST /usuarios`: enum de `perfil` inclui `TowerOperator`/`Board`; `cpf` obrigatório p/ campo; `email` nullable; remoção de `tiposMaquinarioIds` e do erro `422` associado; erros `USR-004` + CPF inválido) e §8 (`USR-004`). #2/#4 permanecem governados por DEC-039/040/042 — esta DEC **não** os re-decide, apenas sincroniza a redação.
- **Justificativa:** Isolar a associação N:M no cadastro de Operador (T4.2) mantém o `POST /usuarios` coeso (identidade + credencial + vínculo de tenant) e evita validação N:M parcial na escrita de Usuario. O `.strict()` torna o contrato auto-defensivo: clientes que enviarem o campo antigo recebem erro acionável em vez de ter dados descartados em silêncio. Uma DEC mínima (em vez de reabrir #2/#4) respeita o append-only do log e evita registros canônicos sobrepostos. Origem documentada no memory file da T4.1; comportamento confirmado contra os testes do schema (código vence, Regra 15).
- **SPECs/REQ-IDs afetados:** `SPEC/08-api-contratos` (§2, §4b, §8), `REQ-RBAC-001`, `REQ-FUNC-012`; relacionadas: `DEC-039`, `DEC-040`, `DEC-042`; staging: T4.2.

## DEC-044 — Operador criado só via `POST /operadores` (criação atômica de caminho único) — T4.2

- **Estado:** Ativo
- **Data:** 2026-06-25
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** A T4.2 (Operador CRUD BE) implementou o cadastro de Operador. Antes, um OPERADOR podia nascer por `POST /usuarios` (branch OPERADOR do `createUsuarioSchema`), deixando o **estado órfão representável**: um `User` perfil=OPERADOR sem a linha `Operador` (e sem autorizações N:M de `TipoMaquinario`). A DEC-043 já retirara `tiposMaquinarioIds` do `POST /usuarios` (staged p/ T4.2). Não havia precedente de `prisma.$transaction` interativa no código — um spike de gating (plano Task 1) foi rodado ANTES de implementar para provar que escritas tenant-scoped sobrevivem ao callback da tx interativa (store de tenant via AsyncLocalStorage). Arquitetura: Transaction Script (não-aggregate), BC ML-owned (`apps/api/src/machinery-link/operador/`), reusando um writer core tx-aware (`UsuarioWriter`) p/ os dois caminhos de escrita de User (Rule 4; ML→core, ADR 2026-05-22).
- **Opções consideradas:**
  - A) Manter o branch OPERADOR no `POST /usuarios` + criar a linha `Operador` num 2º passo/endpoint — rejeitada: o estado órfão continua alcançável entre os passos; viola a invariante de caminho único.
  - B) `POST /operadores` como ÚNICO criador, atômico (User+Operador+N:M numa tx), removendo o branch OPERADOR do `createUsuarioSchema` (**ESCOLHIDA**): o órfão deixa de ser representável por qualquer caminho de aplicação; hash do PIN fora da tx; `UsuarioWriter` é a fonte única de escrita de User.
  - C) Nested-create no model global User (fallback) — documentada como plano B caso o spike falhasse; NÃO usada (spike passou).
- **Decisão:** (i) Operador é criado **EXCLUSIVAMENTE** via `POST /operadores`, de forma **atômica**: `User(OPERADOR)` + `Operador` + N:M `OperadorTipoMaquinario` numa única `prisma.$transaction(async tx => …)`; o hash do PIN é computado **fora** da tx. (ii) Branch OPERADOR **removido** do `createUsuarioSchema` → `POST /usuarios {perfil:'OPERADOR'}` retorna **400** (discriminador inexistente); **supera** a parte de DEC-042/043 que tratava OPERADOR como criável via `/usuarios`. (iii) RBAC `machinery:operador:*` (já em SPEC/04, sem alteração): write (create/update/delete) = `ADMIN_OPERACIONAL`+`SUPER_ADMIN`; read = +`BOARD`/`USUARIO_INTERNO_FGR`; bypass `SUPER_ADMIN`/`BOARD`. (iv) Endpoints T4.2: `POST` (201, `OperadorView`), `GET` (200, envelope paginado `{data,total,page,limit}`, filtra `user.deletadoEm:null`), `GET /:id` (200; 404 cross-tenant/inexistente/soft-deletado), `PATCH /:id` (200, replace-whole-set idempotente das autorizações N:M), **`DELETE /:id`** (204, soft-delete). `OperadorView` mascara o CPF (LGPD) e **nunca** expõe `pinHash`. (v) **Reconciliação de rota:** `GET /operadores` (raiz) é a **lista de cadastro admin** (T4.2); a leitura operacional de disponibilidade de fila (antes mapeada na raiz com `?setorId=&turnoAtivo=`) move para a sub-rota `GET /operadores/disponiveis` (Slice 5/6, não implementada) — não sobrescreve a raiz. (vi) **Mecanismo de create:** PRIMÁRIO `$transaction` interativa — spike (regression guard `apps/api/test/operador-tenant-tx.spike.e2e-spec.ts`) provou que o store de tenant (ALS) sobrevive ao callback sob `ADMIN_OPERACIONAL` (write-direct) e `SUPER_ADMIN` bypass; um teste de rollback prova a atomicidade (falha FK mid-tx reverte User+Operador). Fallback nested-create inerte. (vii) **Multi-tenancy:** `Operador.obraId` é NOT NULL → `SUPER_ADMIN` deve informar `obraId` no body do create (ausente → **400 OPR-010**); `ADMIN_OPERACIONAL` é forçado ao próprio tenant (ignora o body). Reads com barreira de tenant explícita (AND `obraId` além do `$extends`, padrão T5.3) + fail-closed. (viii) **DELETE:** soft-delete do `User(OPERADOR)` (UPDATE `deletadoEm`) delegando a `UsuarioService.remove` — fonte única da política (Rule 4): guard de dependências ativas (inclui **expediente aberto → 409**), hierarquia, sem hard-delete (preserva histórico). (ix) **Error codes:** `OPR-008` (404, tipoMaquinario inexistente, validado antes da tx), `OPR-009` (409, backstop `Operador.userId @unique`), `OPR-010` (400, `SUPER_ADMIN` sem `obraId`). `RBAC-003` padronizado **403** em todo o feature (não reusado p/ o 400 do create) — alinhado a SPEC/08 §1.
- **Justificativa:** Tornar o estado órfão **não-representável por caminho de aplicação** é a razão central: com o branch OPERADOR fora do `/usuarios` e o create atômico, não há janela em que um User OPERADOR exista sem `Operador`. O spike-antes-de-implementar eliminou o risco do mecanismo primário (sem precedente de tx interativa tenant-scoped) e virou regression guard; o teste de rollback converte a atomicidade de "confiar no Prisma" p/ "verificado". `UsuarioWriter` como fonte única (Rule 4) garante a MESMA semântica de unicidade de CPF (pre-check + P2002→USR-004) e e-mail (→USR-001) nos dois caminhos. O DELETE reusa a política de `UsuarioService.remove` em vez de duplicá-la. `RBAC-003`/`OPR-010` separam autorização (403) de input ausente (400) — o FE mapeia código→comportamento de forma determinística (achado de review T4.2). **Rastreabilidade:** o REQ próprio do cadastro de Operador é **`REQ-RBAC-001`** (Gestão de Acessos — provisão de Operadores com PIN e habilitações; critérios via SPEC/04 + `UI/Machinery-Link/08-gestao-acessos.md`), com `REQ-RBAC-005`/`006`; o cadastro **habilita** `REQ-FUNC-001`/`002` (alocação/execução). A tag `REQ-FUNC-012` que aparece nos commits/PR da T4.2 é da família CRUD `/usuarios` e é **Empreiteira-scoped** ("CRUD de Empreiteira") — citada por associação, **não** é o driver do cadastro de Operador (nota registrada na SPEC/08 §4).
- **SPECs/REQ-IDs afetados:** `SPEC/08-api-contratos` (§4 nova seção write contract `/operadores` POST/GET/`:id`/PATCH/**DELETE** + reconciliação `GET /operadores` [admin] vs `/operadores/disponiveis` [fila]; §4b drop OPERADOR do enum de `perfil`; §8 `OPR-008`/`OPR-009`/`OPR-010`); `SPEC/04-rbac-permissoes` (`machinery:operador:*` — já presente, verificado, sem alteração); **`REQ-RBAC-001`** (primary), `REQ-RBAC-005`, `REQ-RBAC-006`; habilita `REQ-FUNC-001`/`REQ-FUNC-002`; relacionadas: `DEC-042`, `DEC-043` (supera a parte OPERADOR-via-`/usuarios`).
- **Nota de numeração:** **DEC-044 confirmado livre** — `get_decision` verificado em 2026-06-25 (índice termina em DEC-043). A colisão recorrente do contador (DEC-038 nas DEC-039/041/042) **NÃO** recorre aqui. Contador bumpado **DEC-044 → DEC-045** no `fgr-ops-docs/CLAUDE.md`. Rascunho `MEMORY/decision-drafts/DEC-044-draft.md` ratificado por esta entrada.

---

## DEC-045 — T9.1 + T9.2 — reconciliação SPEC/08 §5 espacial (Rua + hard-delete + adjacência pós-MVP + 422 do PATCH de Quadra; **estendido p/ LocalExterno na T9.2**)

- **Estado:** Ativo
- **Data:** 2026-06-29
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** A slice T9.1 (PR #54 `dbf14e4`) implementou o CRUD HTTP da malha espacial Rua → Quadra → Lote (Core-owned, `apps/api/src/core/espacial/`). Ao confrontar a implementação com a SPEC/08 §5 surgiram quatro divergências **deliberadas** que exigem reconciliação por Regra 15 (SPEC = contrato vivo, lado canônico = código): (1) a §5 não documentava endpoints de `Rua` (o modelo existia descritivo/nullable, DEC-012; a T9.1 deu-lhe CRUD completo); (2) os headers de `DELETE` de setor/quadra/lote diziam *soft-delete*, mas o código sempre fez **hard-delete** (precedente ADR 2026-05-21, confirmado: `prisma.{setor,quadra,lote,rua}.delete()/deleteMany()`, sem `deletadoEm`); (3) a §8 não atribuía código de domínio ao `422` do `PATCH` de Quadra com FK de outra obra; (4) os endpoints de adjacência de Lote (REC-003/REC-004) estavam listados como ativos, mas a adjacência foi adiada para pós-MVP (design D1: `LoteAdjacencia @deprecated`, sem CRUD).
- **Opções consideradas:**
  - A) Amendar a prosa de SPEC/08 §5/§8 ao que a T9.1 implementou + registrar este DEC (PR de docs separado, não-bloqueante) — **ESCOLHIDA**.
  - B) Mudar o código para casar com a SPEC vigente (soft-delete, sem Rua) — REJEITADA: contradiz ADR 2026-05-21 e o escopo do design T9.1.
  - C) Deixar a divergência sem documentar — REJEITADA: viola Regra 15 (divergência silenciosa = bug de documentação).
- **Decisão:** Reconciliar SPEC/08 §5/§8 ao contrato real da T9.1: **(1)** ADICIONAR a seção de `Rua` (`/obras/:id/ruas`): `GET` lista com envelope paginado `{data:[{id,nome}],total,page,limit}` (Regra 19, coleção espacial unbounded); `POST`/`GET :id`/`PATCH` retornam shape completo `{id,nome,obraId,criadoEm,atualizadoEm}`; unique `(obraId,nome)` → `UX_Rua_obraId_nome`; erros `400` / `404 TEN-001` / `409 REC-001` (nome duplicado) / `409 REC-002` (possui quadras — guard por `_count` + fallback FK `P2003` na janela TOCTOU). **(2)** CORRIGIR *soft-delete* → **hard-delete** nos headers de setor/quadra/lote + `409 REC-002` quando houver dependentes. **(3)** DOCUMENTAR o `422` do `PATCH` de Quadra (FK cross-obra) como `UNPROCESSABLE_ENTITY` **sem código §8** (espelha o precedente do check-in de Operador, §4); o `POST` com FK fora da obra permanece `404 TEN-001`. **(4)** MARCAR os três endpoints de adjacência como **pós-MVP / parking-lot** (D1); `REC-003`/`REC-004` ficam reservados. Mapeamento de códigos confirmado em `packages/types/src/error-codes.ts`: `DUPLICADO=REC-001`, `DEPENDENCIAS_ATIVAS=REC-002`, `NAO_ENCONTRADO=TEN-001`. `Lote` é modelo herdado: escopo por `quadraId` validado-na-obra, nunca `where obraId`. **ITEM EM ABERTO (decisão de Paulo):** normalizar a validação de FK de Quadra para `404 TEN-001` em create **e** patch (removendo a assimetria 404/422)? Até decidir, o MVP honra a SPEC vigente (`422` no patch) — registrado em §5.
- **Justificativa:** Regra 15 — divergência deliberada da SPEC é amendada no mesmo fluxo declarando o lado canônico. Hard-delete segue o precedente ADR 2026-05-21 e o comportamento real de `SetorOperacional`. Adjacência adiada = design D1 (auto-allocator MVP é *least-loaded*, sem adjacency scoring). O `422` sem código novo evita inventar `REC-*` fora da matriz §8 e reusa o precedente `UNPROCESSABLE_ENTITY` do check-in. `Rua` usa envelope paginado por ser coleção espacial unbounded (Regra 19), diferente do array puro legado de `SetorOperacional`.
- **Extensão T9.2 (2026-06-30) — `LocalExterno` (PR #58 `e458f55`, `core:local-externo:*`):** a slice T9.2 implementou o CRUD HTTP de `LocalExterno` sob `apps/api/src/core/espacial/` (espelha o `Quadra` da T9.1). As mesmas divergências deliberadas da família espacial se aplicam, agora reconciliadas em SPEC/08 §5 (seção `locais-externos`): **(1) hard-delete** — `DELETE` header corrigido de *soft-delete* → **hard-delete**; `409 REC-002` quando há demandas vinculadas (`LocalExterno` **não** tem `deletadoEm`; guard por `_count.demandas` + fallback FK `P2003` race-safe na janela TOCTOU). **(2) unicidade por OBRA** — `@@unique([obraId, nome])` (`UX_LocalExterno_obraId_nome`) → `409 REC-001`; corrige a prosa antiga "nome duplicado **no mesmo setor**" (a unicidade é por obra inteira, consistente com Rua/Setor). **(3) `tipo` = string livre** (`z.string().trim().min(1).max(100)`, NÃO enum; ex. ilustrativos PORTARIA/PULMAO/GARAGEM/OUTRO; espelha `Servico.categoria`, sem CHECK). **(4) FK cross-entity DEC-015** — `setorOperacionalId` validado na obra: create→`404 TEN-001` / patch→`422 UNPROCESSABLE_ENTITY` (mesma assimetria de Quadra). Diferença de implementação vs. Quadra (não afeta contrato): `LocalExterno` tem **uma só** FK cross-entity, então o catch de `P2003` a **nomeia diretamente** (`fkNotFound('setorOperacionalId', mode)`), sem o helper neutro `fkRace` que a Quadra precisou por ter duas FKs. Tenant-scoping é **direto** (`LocalExterno` tem coluna `obraId` própria, como `Quadra`/`Setor`, ≠ `Lote` herdado). Verificado por unit (7) + e2e (17, incl. PATCH-nome-dup→409 REC-001) + gate de integração na main mergeada (build/lint/unit/integration 284 verdes, CI #58 verde). **Sem novo número de DEC** (extensão in-place da família espacial DEC-045; contador permanece em DEC-046).
- **Nota de numeração:** o `draft_decision` auto-atribuiu **DEC-038** ao rascunho (`MEMORY/decision-drafts/DEC-038-draft.md`) — mesma colisão recorrente do contador vista nas DEC-039/041/042/044 (DEC-038 já é "Outbox: adiar implementação"). Número canônico = **DEC-045** (contador `fgr-ops-docs/CLAUDE.md`, confirmado livre pelo tail append-only do log que termina em DEC-044; o índice MCP `fgr-docs` está stale em DEC-037 e **não** foi usado para aferir disponibilidade). Rascunho **removido** neste commit (espelha o tratamento dos drafts anteriores). Contador bumpado **DEC-045 → DEC-046**.
- **SPECs/REQ-IDs afetados:** `SPEC/08-api-contratos` (§5 seção `Rua` nova + soft→hard-delete em setor/quadra/lote + nota do `422` no `PATCH` de Quadra + adjacência pós-MVP; **T9.2: §5 `locais-externos` soft→hard-delete + `409 REC-002` + unicidade por obra `REC-001` + `tipo` string livre + FK DEC-015 404/422**; §8 `REC-003`/`REC-004` reservados); `core:rua:*`, `core:quadra:*`, `core:lote:*`, **`core:local-externo:*`**; **`REQ-RBAC-001`**; relacionadas: `DEC-012` (Rua descritiva/nullable), `DEC-015` (Quadra/LocalExterno→Setor FK), ADR 2026-05-21 (hard-delete de catálogo).

---

## DEC-046 — Contrato `GET /obras/:obraId/prontidao` (checklist de prontidão de obra — Slice 4.5)

- **Estado:** Ativo
- **Data:** 2026-06-22 (decisão da T4.5.1; **aplicada ao log em 2026-07-03**)
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** A shell FGR-Ops (Slice 4.5) precisa de um checklist de prontidão por obra para `SUPER_ADMIN`/`BOARD` decidirem se uma obra está operacional. `SPEC/08` não tinha esse endpoint (fatiado da T4.5.1 para registro documental na T4.5.4, Regra 15). O endpoint foi **implementado e mergeado na T4.5.1** (PR #39, `REQ-SCO-001`) como read-side ML-owned em `apps/api/src/machinery-link/prontidao/`.
- **Decisão:** Registrar em `SPEC/08` o contrato: `GET /api/v1/obras/:obraId/prontidao` → `200 ProntidaoObra = { pronta: boolean, requisitos: Array<{ chave: ChaveRequisitoProntidao, ok: boolean }> }`, onde `ChaveRequisitoProntidao ∈ { setorOperacional, quadra, lote, tipoMaquinario, servico, maquinarioAtivo, operadorHabilitado }` (**7 chaves**; fonte única `REQUISITOS_PRONTIDAO` em `@fgr-ops/types`; Zod `prontidaoObraSchema` em `@fgr-ops/schemas/prontidao`). `pronta = true` sse todos os 7 requisitos `ok`. RBAC `@Perfis(SUPER_ADMIN, BOARD, ADMIN_OPERACIONAL)`. A obra é resolvida pelo `:obraId` do **PATH (autoritativo)** via `ObraResolver` → `404 TEN-001` quando `ADMIN_OPERACIONAL` tenta outra obra; o header `X-Tenant-Obra-Id` **NÃO** é injetado em `/obras/*` (precedência path × header). `401` sem token; `403` fora do RBAC. **Divergência deliberada de `SPEC/01`:** o critério #18 (parâmetros operacionais — `expedienteInicio/Fim`, pesos `W_adj`/`W_srv`/`W_mat`) é **ADIADO** (sem persistência hoje: `Obra` = `id`/`nome`/`timestamps`; `PesosObra` é VO com default 50/30/20). `tipoMaquinario` e `servico` são catálogos **GLOBAIS** (sem `obraId`) — presença vale para todas as obras ([ADR 0002](https://github.com/FGR-Incorporacoes-S-A/Fgr-Ops/blob/main/docs/adr/0002-bounded-context-catalogos-machinery-link.md)); os outros 5 requisitos são por-obra.
- **Justificativa:** Read-side **ML-owned** ([ADR 0002](https://github.com/FGR-Incorporacoes-S-A/Fgr-Ops/blob/main/docs/adr/0002-bounded-context-catalogos-machinery-link.md)): os critérios são o que o Machinery-Link precisa para operar; lê Core (espacial) + ML (catálogos/operador), dependência `ML → core` legal. Os params operacionais (#18) não têm persistência no MVP, logo são **adiados em vez de mockados** — quando uma slice ML construir a persistência, acrescenta-se a 8ª chave. Registrar a divergência de `SPEC/01` em `SPEC/08` honra a **Regra 15** (SPEC é contrato vivo; divergência deliberada documentada, não silenciosa). Já coberto por **e2e 5/5** (RBAC + tenant + pronta/incompleta) desde a T4.5.1.
- **Follow-up (Regra 15 — sync de prosa `SPEC/08` PENDENTE):** esta DEC é o **registro canônico** da decisão da T4.5.1; a **prosa** de `SPEC/08` ainda **não** documenta o endpoint (grep 2026-07-03: zero menções a "prontidão" em `SPEC/`). Sincronizar `SPEC/08` com este contrato (seção `prontidao` + nota da divergência de `SPEC/01` #18 adiado) fica como follow-up documental, mesmo padrão da `T4.1-SPEC` da DEC-042. `traceability.md` **não** muda agora: `REQ-SCO-001` já é coberto pela linha de grupo `REQ-SCO-*` (→ PRD/00 + SPEC/00/01); a cobertura adicional em `SPEC/08` entra junto com a amenda de prosa acima.
- **Nota de numeração:** o rascunho `MEMORY/decision-drafts/DEC-038-draft.md` foi auto-numerado **DEC-038** pelo `draft_decision` — **mesma colisão recorrente** do contador vista nas DEC-039/041/042/044/045 (DEC-038 já é "Outbox: adiar implementação"; índice MCP `fgr-docs` stale em DEC-037, **não** usado para aferir disponibilidade). Número canônico = **DEC-046** (contador `fgr-ops-docs/CLAUDE.md`, confirmado livre pelo tail append-only do log que termina em DEC-045). **Aplicação fora de ordem cronológica:** o rascunho é da T4.5.1 (2026-06-22), *anterior* às DEC-042→045 (23–29/jun) já aplicadas; como o log é **append-only por ordem de aplicação**, DEC-046 recebe o próximo número livre apesar da data de decisão mais antiga (por isso a data desta entrada é menor que a da entrada acima — não é erro). Rascunho **removido** neste passo (espelha o tratamento dos drafts anteriores). Contador bumpado **DEC-046 → DEC-047**.
- **SPECs/REQ-IDs afetados:** `SPEC/08-api-contratos` (nova seção `prontidao` — **prosa pendente**, ver follow-up), `SPEC/01-modulos-plataforma` (critério #18 adiado — divergência declarada), `REQ-SCO-001`; `machinery:` read-side `prontidao`; relacionadas: `DEC-014` (bootstrapping/prontidão de obra — camada FGR Ops), [ADR 0002](https://github.com/FGR-Incorporacoes-S-A/Fgr-Ops/blob/main/docs/adr/0002-bounded-context-catalogos-machinery-link.md) (catálogos globais ML-owned).

---

## DEC-047 — Obra no path + shell unificada `/machinery-link/$obra` + botão "← FGR Ops" (supersede o dropdown de troca de obra no top bar, SPEC/07 §3.1/§4)

- **Estado:** Ativo
- **Data:** 2026-07-03
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** O FE do Machinery Link tinha **duas shells** — `/admin/*` (catálogo/config, home de `ADMIN_OPERACIONAL`/`USUARIO_INTERNO_FGR`) e `/machinery-link/*` (só a tela Operadores) — e a obra ativa era **estado implícito** (dropdown de troca no top bar p/ cross-obra + `obraId` do JWT p/ tenant admin), **invisível na URL**. `SPEC/07`/`UI/FGR-Ops/02-app-shell-hub` §3.1 documentava um "Obra Selector" = dropdown no top bar e §4 a troca via dropdown. A slice de UI (REQ-RBAC-001..003) diverge disso **de propósito**: move a obra p/ o path e a troca p/ o `/ops` — divergência deliberada a reconciliar por Regra 15.
- **Opções consideradas:**
  - A) **Obra no path (`obraId`) + shell única + botão "← FGR Ops"** (**ESCOLHIDA**): URL linkável/testável por obra; guard de tenant centralizado no container; uma shell remove a duplicação `/admin` × `/machinery-link`.
  - B) Manter o dropdown de troca no top bar do módulo — REJEITADA: obra invisível na URL, não linkável, estado implícito espalhado entre dois containers.
  - C) **Slug** em vez de `obraId` no path — REJEITADA: exige lookup/unicidade de slug (mudança de BE/BD), fora do escopo FE-only desta slice.
- **Decisão:** **(i)** Uma árvore única sob **`/machinery-link/$obra`** (`obraId` no path, **não** slug); **`/admin` removido**; `ROUTE_BY_PERFIL` aponta ADMIN_OPERACIONAL/USUARIO_INTERNO_FGR → `/machinery-link`; `MACHINERY_LINK_PERFIS` = quarteto único (SUPER_ADMIN, BOARD, ADMIN_OPERACIONAL, USUARIO_INTERNO_FGR). **(ii)** O header do módulo mostra o **NOME** da obra ativa (read-only, derivado do `:obraId` do path) + botão **"← FGR Ops"** (só `OPS_PERFIS` = SUPER_ADMIN/BOARD) que volta ao `/ops`. **(iii)** A **troca de obra** vive no `/ops` (ObraSwitcher, intocado), **não** no top bar do módulo — capacidade preservada, relocada. **(iv)** **Guard de tenant** no `$obra.beforeLoad` (Rule 1/3): tenant admin com `params.obra ≠ user.obraId` → **redirect p/ a própria obra** — a UI **nem aparenta** cross-obra, mesmo com o BE já barrando o dado. **(v)** **Sync de storage** (`OBRA_STORAGE_KEY` → header `X-Tenant-Obra-Id`) **só p/ `OPS_PERFIS`**, gravado **antes** das queries filhas; tenant admin **não** grava (o BE deriva do JWT e a salvaguarda ignora o header p/ não-bypass). **(vi)** Estrutura interna **`/configuracoes`** (SPEC/07 §6 fiel — **escolha de Paulo, 2026-07-03**): catálogo/config sob `$obra/configuracoes/{maquinarios,tipos-maquinario,setores,ruas,quadras,locais-externos,servicos}`; `dashboard` e `operadores` no topo da obra. **FE-only** — zero mudança de BE/contrato/BD.
- **Justificativa:** obra na URL = **fonte de verdade única** (linkável, compartilhável, testável por obra); o param dirige `useActiveObraId`, eliminando o estado implícito. Guard de tenant **centralizado** num único `beforeLoad` (defense-in-depth sobre o BE, Rule 1/3) em vez de replicado por tela. Uma shell < duas: remove a duplicação `/admin` × `/machinery-link` e o split home/acesso (`ADMIN_PERFIS` some, funde no `MACHINERY_LINK_PERFIS`). **Regra 15:** a divergência de UI (dropdown → obra-no-path + botão) é reconciliada no MESMO fluxo — SPEC/07 §3.1/§4/§6 amendados + esta DEC declara o modelo **URL+botão** como canônico (supersede o dropdown do top bar) e a convergência do §6.
- **Nota de numeração:** contador `fgr-ops-docs/CLAUDE.md` em **DEC-047** (log append-only termina em DEC-046). Sem colisão de draft (DEC redigida direto, sem `draft_decision`). Contador bumpado **DEC-047 → DEC-048**.
- **SPECs/REQ-IDs afetados:** `UI/FGR-Ops/02-app-shell-hub` (§3.1 "Obra Selector" dropdown → **Nome da obra + botão "← FGR Ops"**; §4 troca de contexto via `/ops` + guard de tenant; §6 **convergência** — todas as telas ML sob `/machinery-link/{obraId}/*`, split `/admin/*` removido); `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-RBAC-003`; relacionadas: `DEC-046` (`ObraResolver` — `:obraId` do path autoritativo em `/obras/*`), `DEC-030` (auth/shell). **DEC tática espelho (code repo):** `memory/decisions/2026-07-03-obra-scoped-url-shell-ml.md`; spec de design `docs/superpowers/specs/2026-07-03-obra-scoped-url-shell-ml-design.md`.

---

## DEC-048 — Camada de navegação "Obra" (agnóstica de módulo) entre FGR Ops (plataforma) e módulos — gestão de usuário em 3 níveis (emenda a DEC-014)

- **Estado:** Ativo
- **Data:** 2026-07-04
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** `DEC-014` formalizou a fronteira Plataforma×Módulo (opção C) mas nunca decidiu **onde**, na navegação, ficam os usuários `AdminOperacional`/`UsuarioInternoFGR` — `SPEC/01` passo #3 os colocou na tela de plataforma (`/ops/usuarios`, Slice 4.5) por atalho de MVP, resultando numa listagem cross-tenant sem escopo de obra na UI. Não é bug de RBAC (o BE já escopa por `obraId`, bypass vs. forçado) — é lacuna de navegação/IA. O modelo mental correto é **Obra → Módulos habilitados → Usuários exclusivos do módulo**, com nível intermediário para usuários que atuam na obra como um todo.
- **Opções consideradas:**
  - A) Criar perfil novo "AdministradorObra" — REJEITADA: `ADMIN_OPERACIONAL` já é o admin da obra (single-obra, potencialmente multi-módulo); perfil novo duplicaria semântica sem ganho.
  - B) Filtro de obra na tela de plataforma (`/ops/usuarios?obra=`) — REJEITADA: mantém o nível errado; a obra continuaria estado implícito da tela em vez de nível de navegação.
  - C) **Nível de navegação "Obra" (`/obras/{obraId}`) entre plataforma e módulos, com gestão de usuário em 3 níveis** (**ESCOLHIDA**): reusa o guard de tenant validado em DEC-047; FE-only.
- **Decisão:** Introduzir o nível "Obra" (`/obras/{obraId}` — hub de módulos + usuários da obra), reaproveitando o guard DEC-047. Gestão de usuário passa a 3 níveis: **(i) Plataforma** — `/ops/usuarios` restringida a `SuperAdmin`/`Board` (aba "Usuários da plataforma", cross-tenant, sem `obraId`); **(ii) Obra** — `/obras/{obraId}/usuarios` gere `AdminOperacional`/`UsuarioInternoFGR` (multi-módulo dentro da obra, `obraId` derivado do path); **(iii) Módulo** — usuários exclusivos do módulo continuam no módulo (`DEC-031`): `Operador` em `/machinery-link/{obraId}/operadores` (existente), `TowerOperator` em `/machinery-link/{obraId}/tower-operators` (tela mínima nova), futuramente `Empreiteiro`. "Selecionar obra" no `/ops` leva ao hub (`/obras/{obraId}`); o header da shell de obra ganha link "Usuários da obra". Login de `AdminOperacional`/`UsuarioInternoFGR` **continua caindo direto no módulo** (atalho de `SPEC/01` mantido — hub fora do caminho crítico de login). As 3 telas usam `GET/POST /usuarios` genérico com filtro de perfil client-side (`listUsuariosQuerySchema.perfil` é singular; bypass escopa por `?obraId=`, não-bypass pelo JWT).
- **Não muda:** RBAC (`USUARIO_READ/WRITE_PERFIS`, `perfilPodeGerenciar`), schema Prisma, endpoints. Nenhum perfil novo.
- **Fora de escopo (registrado para não confundir com regressão):** perfil "gerente multi-obra" (subconjunto de obras, N:N `Usuario↔Obra`) — problema distinto, futura emenda própria a DEC-014; CRUD de `Empreiteira` + tela de `Empreiteiro` (gap pré-existente: não há endpoint de `Empreiteira` no BE — slice separada); ativação/config de módulo por obra (Fase 2 de DEC-014 — hub hardcoded com 1 card).
- **Justificativa:** o nível "Obra" materializa na navegação a fronteira que DEC-014 já definia conceitualmente, sem tocar autorização (que permanece 100% no BE). Reusar o guard DEC-047 evita novo mecanismo de tenant na UI. Restringir `/ops/usuarios` elimina a listagem cross-tenant sem escopo visível — precisão de IA, não de segurança.
- **Nota de numeração:** contador `fgr-ops-docs/CLAUDE.md` em **DEC-048** (log append-only termina em DEC-047). Sem colisão de draft (DEC redigida direto, MCP `draft_decision` indisponível na sessão). Contador bumpado **DEC-048 → DEC-049**.
- **SPECs/REQ-IDs afetados:** `SPEC/01-modulos-plataforma` (capacidades Core: provisão de plataforma vs. de obra; passo #3 do bootstrapping); `SPEC/04-rbac-permissoes` (subseção `TOWER_OPERATOR`: provisionamento na tela dedicada do módulo); `UI/FGR-Ops/02-app-shell-hub` (hub obra-scoped em `/obras/{obraId}`), `UI/FGR-Ops/03-crud-obras` (destino de "Selecionar obra"), novo `UI/FGR-Ops/04-hub-obra`; `traceability.md`; `REQ-RBAC-001`, `REQ-RBAC-002`, `REQ-RBAC-003`; relacionadas: `DEC-014` (emendada), `DEC-031`, `DEC-047` (guard reusado), `DEC-039`/`DEC-040` (TOWER_OPERATOR). **Spec de design (code repo):** `docs/superpowers/specs/2026-07-04-obra-modulo-usuarios-design.md`.

---

## DEC-049 — CPF + PIN como credencial canônica de acesso de campo (contrato de UI) — amenda parcial de DEC-030 + redesign visual das telas de campo (Operador/Empreiteiro/PIN)

- **Estado:** Ativo
- **Data:** 2026-07-13
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** `DEC-030` (2026-04-25) fixou a rota de login de campo separada do portal FGR Ops e descreveu a credencial como "email + PIN 6 dígitos". Em 2026-06-23, `DEC-042`/ADR 0003 já havia trocado o identificador de `/auth/pin` para **CPF** no lado do BE (T4.1.2), mas a UI spec `UI/Machinery-Link/00-login-campo.md` (§2/§3.1/§3.3/§4) permaneceu redigida com "Email/Matrícula", copy de erro "Email ou PIN incorretos" e botão `48px` — nunca reconciliada com o contrato de BE já em produção. O redesign visual das telas de campo (Operador `/operador`, Empreiteiro `/empreiteiro`, PIN `/auth/pin`), conforme protótipos Claude Design aprovados e implementado nesta rodada, entrega a UI de login já alinhada ao CPF (protótipo 1d) — reabrindo a divergência de UI spec × implementação (Regra 15) e, por tabela, o texto de `DEC-030` que ainda descreve "email + PIN" como a credencial. Esta rodada também **não** entregou o PWA separado (`manifest.json` próprio, `/app`) previsto em `DEC-030` — o redesign foi publicado nas rotas interinas do portal (`/auth/pin`, `/operador`, `/empreiteiro`); `apps/web` já é instalável (PWA único), mas o app de campo dedicado não foi criado nesta rodada.
- **Opções consideradas:**
  - A) Reescrever `DEC-030` in-place para "CPF + PIN" — REJEITADA: log é append-only (Regra 8 de `fgr-ops-docs/CLAUDE.md`); decisões vigentes não são editadas, apenas supersedidas/emendadas por nova DEC.
  - B) Nova DEC amendando **apenas** o ponto da credencial em `DEC-030` (mantendo o restante — rota separada, PWA como alvo — intocado/reafirmado) e sincronizando a UI spec de login no mesmo PR (**ESCOLHIDA**): fecha a divergência (Regra 15) sem reabrir o que já está estável (a separação de rota permanece correta e não é contestada).
  - C) Adiar a reconciliação da UI spec para uma slice futura de "PWA campo" — REJEITADA: deixaria a spec silenciosamente desatualizada frente ao código já implementado e mergeado, violando Regra 15 (divergência deliberada exige emenda no mesmo PR, não depois).
- **Decisão:** **(i)** **CPF + PIN de 6 dígitos é a credencial canônica de acesso de campo.** Esta DEC **supersede parcialmente `DEC-030`** no ponto específico "email + PIN" — o identificador de login de `Empreiteiro`/`Operador` é CPF (máscara `000.000.000-00`, `inputmode="numeric"`, dígito verificador validado no FE, normalizado para 11 dígitos no submit — mesma normalização anti-fragmentação de lockout já formalizada em `DEC-042`), não email. **(ii)** O restante de `DEC-030` — rota de login separada do portal FGR Ops e **PWA dedicado como alvo arquitetural** — fica **REAFIRMADO**, não contestado. **(iii)** Registra-se o **adiamento deliberado do PWA de campo** nesta rodada: o redesign visual (Operador/Empreiteiro/PIN) foi entregue nas **rotas interinas do portal** (`/auth/pin`, `/operador`, `/empreiteiro`) — `apps/web` já é instalável como PWA único, mas o `manifest.json`/entrypoint `/app` dedicado de `DEC-030` não foi criado; permanece backlog. **(iv)** `UI/Machinery-Link/00-login-campo.md` é amendada no mesmo PR: §3.1 (campo Email/Matrícula → CPF), §3.3 (botão `48px` → `56px`, protótipo 1d vence), §4 (copy de erro "Email ou PIN incorretos" → "Identificação ou PIN inválidos"), nota de status registrando a implementação interina em `/auth/pin`. `UI/Machinery-Link/01-mobile-empreiteiro.md` e `02-mobile-operador.md` recebem seção "Desvios do MVP (2026-07-13)" documentando as divergências de apresentação/DTO do redesign (header sem nomes, card com DTO enxuto D2, pausa/cancelamento por justificativa texto-livre, confirmação de encerrar turno adicionada, sem rollover pós-checkout, badges sem glifos/SLA).
- **Justificativa:** o BE (`DEC-042`) e a UI já convergem em CPF — manter a UI spec dizendo "email" seria uma spec conhecidamente errada, o oposto do que Regra 15 exige. Amendar só o ponto da credencial (em vez de reescrever `DEC-030` inteira) preserva a decisão de arquitetura ainda válida (rota separada, PWA como alvo) e deixa claro, para quem ler o log depois, exatamente qual fatia foi revista. Registrar o adiamento do PWA explicitamente evita que o silêncio sobre `/app` seja lido como "PWA cancelado" — é adiamento tático, não mudança de alvo.
- **Nota de numeração:** contador `fgr-ops-docs/CLAUDE.md` em **DEC-049** (log append-only termina em DEC-048). Sem colisão de draft (DEC redigida direto, MCP `draft_decision` indisponível na sessão). Contador bumpado **DEC-049 → DEC-050**.
- **SPECs/REQ-IDs afetados:** `UI/Machinery-Link/00-login-campo` (amendada — §3.1, §3.3, §4, nota de status), `UI/Machinery-Link/01-mobile-empreiteiro` (seção "Desvios do MVP" adicionada), `UI/Machinery-Link/02-mobile-operador` (seção "Desvios do MVP" adicionada); `REQ-RBAC-005`, `REQ-RBAC-006`, `REQ-JOR-001`, `REQ-JOR-004`; relacionadas: `DEC-030` (parcialmente supersedida no ponto da credencial; PWA-como-alvo reafirmado), `DEC-042` (CPF como identificador de BE — ponto de origem desta convergência de UI), `DEC-004` (PIN bcrypt/lockout progressivo — normalização de CPF preserva a chave de lockout).

---

## DEC-050 — Controle de expediente da obra (janela única + dias ativos + tolerância de hora extra) + worker `expedienteFim` in-process (sweep 1min, Regra A/B) — reconciliação de `SPEC/02`/`03`/`08` + `UI/07` (Tasks 1–18)

- **Estado:** Ativo
- **Data:** 2026-07-16 (brainstorm de design) / 2026-07-17 (reconciliação documental, Task 18)
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** `SPEC/08` já descrevia um `PATCH /obras/:id/configuracoes` com `expedienteInicio`/`expedienteFim` **e** pesos de fila (`pesoAdjacencia`/`pesoServico`/`pesoMaterial`) nunca implementados nesse endpoint; `SPEC/03` descrevia um worker `expedienteFim` só em prosa ("executa ao fim do expediente", sem mecanismo). O plano de implementação `docs/superpowers/specs/2026-07-16-expediente-obra-design.md` (Tasks 1–17, branch `feat/expediente-obra`) construiu o controle real: 4 campos de expediente **tudo-ou-nada** na `Obra` (VO `JanelaExpediente`, timezone fixo `America/Sao_Paulo`), check-in com confirmação fora da janela, checkout que devolve demandas ativas do operador e congela hora extra, listagem de gestão de turnos nova, e um worker cron in-process (`@nestjs/schedule`, [ADR 0006](https://github.com/FGR-Incorporacoes-S-A/Fgr-Ops/blob/main/docs/adr/0006-background-jobs-in-process-nestjs-schedule.md)) que faz sweep idempotente a cada minuto. Task 18 reconcilia `SPEC/02`/`03`/`08` e `UI/07` a essa implementação real (Regra 15).
- **Opções consideradas:**
  - A) Manter a SPEC como estava (pesos de fila configuráveis, worker sem mecânica) e deixar a implementação real documentada só em código/testes — REJEITADA: viola Regra 15 (SPEC é contrato vivo; divergência silenciosa = bug de documentação) e deixa o time sem referência de contrato para o FE consumir.
  - B) Reconciliar via amenda cirúrgica nos 4 arquivos afetados + esta DEC, mantendo os pesos de fila documentados como pós-MVP em vez de apagados (preserva a intenção original de design para quando adjacency entrar em Fase 2) — **ESCOLHIDA**.
  - C) Implementar a configuração de pesos agora, para casar com a SPEC antiga — REJEITADA: fora do escopo desta rodada (adjacency/scoring por peso é Fase 2, D1; o MVP usa allocator *least-loaded*); teria inflado a Task 18 (docs-only) com trabalho de produto.
- **Decisão:**
  - **(i) Janela única + dias ativos, tudo-ou-nada:** `Obra` ganha `expedienteInicio`/`expedienteFim` (`HH:MM`), `limiteHoraExtraMin` (tolerância de hora extra, minutos), `diasAtivos` (CSV de dias ISO 1–7). Os 4 campos são **tudo-ou-nada** no `PATCH /obras/:id/configuracoes` — todos `null` (desliga) ou todos preenchidos (liga); um subconjunto não-nulo é `422` sem código próprio. Validação de negócio (`inicio < fim`; `fim + tolerância` não cruza meia-noite; `diasAtivos` não vazio/sem duplicata) no VO `JanelaExpediente` (`packages/domain/src/core/obra/`). Novo `GET /obras/:id/configuracoes` (mesma shape). Os pesos de fila (`pesoAdjacencia`/`pesoServico`/`pesoMaterial`) **nunca foram implementados neste endpoint** e saem da prosa de `SPEC/08` — ficam fixos 50/30/20 (`SPEC/03`), configuráveis só em Fase 2.
  - **(ii) Cutoff com tolerância configurável:** o cutoff de um turno é `expedienteFim + limiteHoraExtraMin` do dia **local do check-in**; check-in após o cutoff do próprio dia usa o cutoff do dia seguinte (edge documentado em `SPEC/03`).
  - **(iii) Check-in fora da janela exige confirmação (`OPR-013`):** `POST /expediente/checkin` ganha `confirmarForaDaJanela?: boolean`. Fora da janela/dia inativo sem a flag ⇒ `422 OPR-013`. Com a flag ⇒ `201`, turno marcado `foraDaJanela = true` (persistido, informa a listagem de gestão).
  - **(iv) Hora extra congelada no encerramento:** `RegistroExpediente.minutosHoraExtra` é calculado (`JanelaExpediente.minutosHoraExtra`) e persistido no momento do encerramento — manual (`POST /expediente/checkout`) ou automático (worker, Regra A) — nunca recalculado depois. `encerradoPorSistema` distingue os dois casos.
  - **(v) Checkout devolve, não bloqueia:** `POST /expediente/checkout` devolve as demandas `EM_ANDAMENTO`/`PAUSADA` do operador (`devolver_fim_expediente`, ator SISTEMA, DEC-025) em vez de bloquear com `409` — supersede o comportamento "apenas encerra o turno" que `SPEC/08` descrevia como MVP. Response ganha `minutosHoraExtra`/`demandasDevolvidas`.
  - **(vi) Worker cron in-process, sweep Regra A/B:** `FimExpedienteWorker` (`@nestjs/schedule`, flag `FIM_EXPEDIENTE_CRON_ENABLED`) roda `ProcessarFimExpedienteUseCase.executarTick` a cada minuto. **Regra A** encerra turnos abertos com cutoff vencido. **Regra B** processa, por dia ativo pendente (marcador `Obra.fimExpedienteProcessadoEm`, `@db.Date`), a devolução de demandas ativas e o rollover de `PENDENTE` via `ExpedienteFimProcessManager` (domínio puro). Decisão de infra completa (por que in-process vs. fila, por que sem lock distribuído) em [ADR 0006](https://github.com/FGR-Incorporacoes-S-A/Fgr-Ops/blob/main/docs/adr/0006-background-jobs-in-process-nestjs-schedule.md) — esta DEC não a duplica, só referencia.
  - **(vii) `rolloverInicioSla` como `t0` do SLA (derivado no FE):** o worker persiste em `Demanda.rolloverInicioSla` o início do **próximo dia ativo** (`JanelaExpediente.proximoDiaAtivoInicio`, não necessariamente "o dia seguinte" se houver dias inativos). O FE deriva o `t0` de exibição do SLA como `rolloverInicioSla ?? criadoEm` (`prioridade-sla-chips.tsx`) — substitui a formulação antiga de `SPEC/03` ("SLA agendado para reset no `expedienteInicio` do dia seguinte"), que não sobrevivia a dias inativos no meio do intervalo.
  - **(viii) Nova listagem de gestão:** `GET /expedientes` (paginado `{data,total,page,limit}`, perfis `OPERADOR_READ_PERFIS`) lista turnos de todos os operadores da obra com hora extra, `encerradoPorSistema`, `foraDaJanela` — não existia contrato prévio em `SPEC/08`.
  - **(ix) Pesos da fila (`W_adj`/`W_srv`/`W_mat`) confirmados pós-MVP:** nem o endpoint nem a UI (`UI/07` §6) os expõem como configuráveis nesta rodada; mockup de `UI/07` atualizado para os 4 campos reais de expediente + switch tudo-ou-nada.
- **Justificativa:** Regra 15 — a SPEC deve descrever o que foi implementado, não o desenho anterior à construção real. Preservar os pesos de fila como "pós-MVP" (em vez de apagar sem nota) evita perder a intenção de design de Fase 2 (adjacency scoring) documentada desde `DEC-024`. `rolloverInicioSla` persistido (em vez de recalculado ad-hoc no FE) torna o `t0` do SLA correto mesmo com dias inativos configuráveis, que a formulação anterior não previa. Referenciar (não duplicar) o `ADR 0006` mantém a fonte única da decisão de infra do worker no lugar certo (ADR = decisão estrutural de build/runtime; DEC = decisão tática de contrato/domínio).
- **Colisão do código `OPR-012` — resolvida na mesma branch:** o check-in fora da janela (`POST /expediente/checkin`, item iii acima) originalmente reutilizava o código de erro `OPR-012`, já usado por "máquina fora dos tipos habilitados" (violação de cascata tipo→máquina, ADR 0004, `POST/PATCH /operadores`, `operador-error.codes.ts`/`MAQUINARIO_FORA_DOS_TIPOS`). Corrigido ainda na branch `feat/expediente-obra` (mesma Task 18): o erro de check-in foi renumerado para `OPR-013`, liberando `OPR-012` de volta para uso exclusivo da cascata de operador. `SPEC/08` §8 já reflete os dois códigos separados.
- **⚠️ Mistag de REQ-ID nos commits T1–T17 (não corrigido nesta Task):** todos os commits de implementação (branch `feat/expediente-obra`) usam o trailer `[REQ-FUNC-004][REQ-FUNC-008]`, herdado do spec de design `2026-07-16-expediente-obra-design.md`. `REQ-FUNC-008` no PRD (`docs/PRD/03-requisitos-funcionais.md`) é **"Prioridade máxima com destaque visual"** — um requisito de UI de fila, sem relação com expediente/worker. O requisito correto para rollover/worker de fim de expediente é **`REQ-FUNC-014`**, já usado corretamente em `traceability.md` (linha `REQ-FUNC-014`, DEC-025) para o mesmo conteúdo. Esta Task **não** propaga o mistag: `traceability.md` mapeia o conteúdo novo para `REQ-FUNC-004` (config de expediente, check-in/checkout, listagem de gestão) e `REQ-FUNC-014` (worker, marcador, `rolloverInicioSla`), não `REQ-FUNC-008`. O trailer do commit desta própria Task 18 mantém `[REQ-FUNC-004][REQ-FUNC-008]` por continuidade com os commits já mergeados de T1–T17 (corrigir um commit isolado não corrige os demais e divergiria da instrução explícita da task); a correção de fundo (retag em massa ou nota permanente) fica para Paulo decidir.
- **Nota de numeração:** contador `fgr-ops-docs/CLAUDE.md` em **DEC-050** (log append-only termina em DEC-049). Sem colisão de draft (DEC redigida direto, MCP `draft_decision` indisponível na sessão). Contador bumpado **DEC-050 → DEC-051**.
- **SPECs/REQ-IDs afetados:** `SPEC/02-modelo-dados` (ER: `Obra` + 5 campos de expediente/marcador, `RegistroExpediente` + 3 campos de sistema/hora-extra/janela, `Demanda.rolloverInicioSla`); `SPEC/03-fila-scoring-estados-sla` (mecânica do worker reescrita — Regra A/B, marcador, `rolloverInicioSla`; nota de SLA de rollover); `SPEC/08-api-contratos` (`GET` novo + `PATCH` reescrito de `/obras/:id/configuracoes`; `POST /expediente/checkin` com `confirmarForaDaJanela`/`OPR-013`; `POST /expediente/checkout` com devolução real; `GET /expedientes` novo); `UI/Machinery-Link/07-configuracoes-obra` (§6 reescrito); `REQ-FUNC-004`, `REQ-FUNC-014`; relacionadas: `DEC-024` (pesos de fila 50/30/20 — reafirmado, configuração adiada), `DEC-025` (devolver_fim_expediente/rollover — mecânica agora tem worker real), [ADR 0006](https://github.com/FGR-Incorporacoes-S-A/Fgr-Ops/blob/main/docs/adr/0006-background-jobs-in-process-nestjs-schedule.md) (worker in-process). **Spec de design (code repo):** `docs/superpowers/specs/2026-07-16-expediente-obra-design.md`.

---

## DEC-051 — SLA removido da UI; redefinição futura por Serviço (tempo de resolução)

- **Estado:** Ativo
- **Data:** 2026-07-17
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** durante o brainstorming da slice "Gestão Dashboard + Fila de demandas" (`docs/superpowers/specs/2026-07-17-gestao-dashboard-fila-design.md`), Paulo apontou que o SLA canônico de `SPEC/03` (§"SLA de atendimento e governança", níveis `MAXIMA`/`ELEVADA`/`NORMAL` 15/45/120 min) é um alvo de **início** de atendimento — mas o início de uma demanda depende da conclusão da demanda anterior na fila do operador, um fator fora do controle de quem está sendo medido. Exibir esse alvo na UI (countdown, "estourado") induz uma leitura injusta ("tenho 1h para atender") quando, na prática, o operador pode estar legitimamente ocupado com outra tarefa. As escalações `SLA_ALERT`/`SLA_ESCALATION` de `SPEC/06` nunca foram implementadas no código — não há regressão de funcionalidade, só de documentação/intenção de produto.
- **Opções consideradas:**
  - A) Manter o SLA na UI como estava (badges `SlaChip`/`PrioridadeSlaChips` com countdown por prioridade) — REJEITADA: perpetua uma métrica que o próprio Paulo julga não-acionável/injusta como está formulada (alvo de início, não de resolução).
  - B) Remover toda superfície de SLA da UI (campo e gestão) agora, registrar o racional e deixar redefinição futura em aberto como backlog pós-MVP (**ESCOLHIDA**): a `Demanda`/`Servico` já carregam `prioridade`/`rolloverInicioSla` no contrato — sem churn de schema; só a camada de apresentação muda.
  - C) Redefinir o SLA por Serviço (tempo de resolução) já nesta rodada — REJEITADA: fora de escopo da slice Gestão Dashboard+Fila (que é read-side/gestão de fila, não configuração de catálogo de Serviço); adiado para quando houver demanda de produto concreta.
- **Decisão:**
  1. Nenhuma superfície de UI exibe SLA (countdown, alvo 15/45/120, "estourado") — nem campo (telas de Operador/Empreiteiro, PR #89) nem gestão (dashboard/fila/kanban desta slice).
  2. Racional: o SLA de `SPEC/03` mede tempo até **início**, que não é controlável/justo como alvo individual — depende da ordem da fila e da carga do operador.
  3. Redefinição futura (pós-MVP), se necessária: SLA configurado **por Serviço**, medindo **tempo de resolução** (criação → conclusão), não tempo até início.
  4. No lugar do SLA: idade informativa ("aberta há X" / "em execução há X") sem semântica de violação. O badge de prioridade (`PrioridadeChip`) permanece — ordenação da fila é conceito separado de SLA.
  5. Os contratos read-side preservam `prioridade`/`rolloverInicioSla` em `DemandaResumoDto`/`FilaGestaoItemDto` (sem churn de schema); a UI não os consome mais para derivar SLA. O card "Tempo médio de resolução" do novo `GET /demandas/dashboard` usa `finalizadoEm − criadoEm` — é uma métrica histórica, não um alvo.
- **Justificativa:** remover uma métrica de UI que o produto considera mal-formulada (alvo não-controlável) é mais honesto do que mantê-la com semântica enganosa até uma redefinição futura estar pronta. Preservar os campos no contrato (em vez de removê-los do schema) evita churn de tipos/migração e mantém o dado disponível para quando o SLA-por-Serviço for desenhado. `SPEC/03` é marcada como "em revisão" (não apagada) para não perder a referência histórica dos níveis 15/45/120, já que a formulação pode ser reaproveitada (mudando só o que se mede — resolução em vez de início).
- **Nota de numeração:** contador `fgr-ops-docs/CLAUDE.md` em **DEC-051** (log append-only termina em DEC-050). Sem colisão de draft (DEC redigida direto, MCP `draft_decision` indisponível na sessão). Contador bumpado **DEC-051 → DEC-052**.
- **SPECs/REQ-IDs afetados:** `SPEC/03-fila-scoring-estados-sla` (§"SLA de atendimento e governança" marcada `EM REVISÃO`); `SPEC/08-api-contratos` (nota em `DemandaResumoDto`/`POST /demandas/:id/reordenar`: `rolloverInicioSla`/`prioridade` permanecem no contrato, UI não deriva SLA); `REQ-FUNC-009`, `REQ-FUNC-011`, `REQ-FUNC-013`; relacionadas: sub-decisão **D2** de `memory/decisions/2026-07-09-mvp-sem-motor-priorizacao-material-sla.md` (2026-07-09, SLA já diferido da UI — esta DEC supersede parcialmente: a remoção agora é decisão de produto, não adiamento). Decisão espelhada no code repo: `memory/decisions/2026-07-17-sla-removido-ui-redefinicao-por-servico.md`. **Spec de design (code repo):** `docs/superpowers/specs/2026-07-17-gestao-dashboard-fila-design.md`.

---

## DEC-052 — RBAC de `GET /obras/:obraId/prontidao` alargado para `TOWER_OPERATOR` (amenda DEC-046)

- **Estado:** Ativo
- **Data:** 2026-07-17
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** follow-up FUP-004 do PR #98 (Gestão Dashboard+Fila) levantou uma pergunta de produto pendente: `TOWER_OPERATOR` opera o dashboard de gestão lado a lado com `ADMIN_OPERACIONAL` (mesmo `DEMANDA_KANBAN_READ_PERFIS`), mas o RBAC original do checklist de prontidão (`DEC-046`, T4.5.1) só cobria `SUPER_ADMIN`/`BOARD`/`ADMIN_OPERACIONAL` — o FE já gateava o fetch por `PRONTIDAO_READ_PERFIS` especificamente para evitar o 403 previsível em `TOWER_OPERATOR`/`USUARIO_INTERNO_FGR`, então o perfil simplesmente não via o banner. Paulo confirmou (2026-07-17): `TOWER_OPERATOR` **deve** ver o banner.
- **Decisão:** `PRONTIDAO_READ_PERFIS` (`packages/types/src/perfis.ts`) passa a incluir `TOWER_OPERATOR`, alargando também o `@Perfis(...)` de `GET /obras/:obraId/prontidao` (`prontidao.controller.ts`, mesma fonte compartilhada BE/FE). `USUARIO_INTERNO_FGR` **permanece fora** — não pediu inclusão e não opera a fila. Demais termos de `DEC-046` (shape `ProntidaoObra`, tenant via path, divergência de `SPEC/01` #18) inalterados.
- **Justificativa:** `TOWER_OPERATOR` já é o perfil operacional do Kanban/fila de gestão (`DEMANDA_KANBAN_READ_PERFIS`); saber se a obra está pronta (setor/quadra/lote/catálogos/operador habilitado) é informação operacional direta desse papel, não administrativa — a exclusão original em `DEC-046` refletia o escopo estreito da T4.5.1 (shell FGR-Ops, `SUPER_ADMIN`/`BOARD` decidindo bootstrapping de obra), não uma restrição de produto deliberada para este perfil.
- **Nota de numeração:** contador `fgr-ops-docs/CLAUDE.md` em **DEC-052** (log append-only termina em DEC-051). Sem colisão de draft (DEC redigida direto, MCP `draft_decision` indisponível na sessão). Contador bumpado **DEC-052 → DEC-053**.
- **SPECs/REQ-IDs afetados:** `SPEC/08-api-contratos` (RBAC de `prontidao` — prosa desta seção segue **pendente** desde `DEC-046`, débito pré-existente não resolvido por esta DEC); `REQ-FUNC-009`; relacionadas: `DEC-046` (contrato original de `GET /obras/:obraId/prontidao`), `DEC-047` (shell `/machinery-link/$obra`, perfis que operam o módulo).

---

## DEC-053 — `operadorId?` no `POST /demandas` (pré-alocação manual da gestão)

- **Estado:** Ativo
- **Data:** 2026-07-15 (decisão tática, PR #95) · **registrada retroativamente no log em 2026-07-18**
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** o design da criação de Demanda pelas telas de gestão (`docs/superpowers/specs/2026-07-15-criar-demanda-gestao-design.md`, `REQ-FUNC-005`) precisa de pré-seleção de operador no formulário do Kanban. A Slice 9 (T9.4) havia **removido** `operadorAlocadoId` do contrato do `POST /demandas` de propósito (contrato estruturado do Empreiteiro: auto-alloc server-side + realocação via `POST /demandas/:id/alocar`). Esta decisão viveu como nota tática (`memory/decisions/2026-07-15-criar-demanda-gestao-operador-id.md`) e amendou `SPEC/08` inline (Regra 15), mas nunca entrou no log append-only — regularizada aqui.
- **Opções consideradas:**
  - A) FE encadear `POST /demandas` → `POST /demandas/:id/alocar` — REJEITADA: não-atômico, perpetua a janela do pendente "create↔alloc §8".
  - B) Reintroduzir `operadorId?` **parcialmente**, aceito SOMENTE para o trio de gestão, com persistência atômica — **ESCOLHIDA**.
  - C) Aceitar-e-ignorar o campo quando vindo de perfil sem direito — REJEITADA: esconde bug de integração; rejeição explícita é auditável.
- **Decisão:** `POST /demandas` reintroduz `operadorId?` opcional, aceito apenas para `DEMANDA_FILA_WRITE_PERFIS` (`TOWER_OPERATOR`/`ADMIN_OPERACIONAL`/`SUPER_ADMIN`). Enforcement no `CriarDemandaUseCase`: `403 RBAC-001` fail-fast + `404 TEN-001` (operador no tenant) antes de persistir. Persistência atômica `saveComAlocacao`: grava o create **e** o `DemandaLog` (`origem: 'manual_criacao'`, ator `USER`) na mesma `$transaction`, e **pula o auto-alloc**. Schema `criarDemandaGestaoSchema` (superset); `criarDemandaSchema` do Empreiteiro **inalterado** e segue rejeitando o campo via `strict`.
- **Justificativa:** o racional da remoção da Slice 9 era o **contrato do Empreiteiro** (campo inútil/perigoso para quem não aloca) — esse racional permanece, o Empreiteiro continua sem o campo. A gestão já tem `machinery:demanda:allocate` na matriz; criar+alocar num request só elimina a janela não-atômica do fluxo em duas chamadas. O caminho AUTO (`create → tryAllocate` pós-persist) segue não-atômico — pendente "create↔alloc §8", fora deste escopo.
- **Nota de numeração:** decisão anterior (2026-07-15) a `DEC-051`/`DEC-052` (2026-07-17); o número `DEC-053` é maior que a data por ser **registro retroativo** (2026-07-18) de uma decisão que só vivia em `memory/decisions/`. Contador `CLAUDE.md` bumpado `DEC-053 → DEC-054` neste mesmo lote.
- **SPECs/REQ-IDs afetados:** `SPEC/08-api-contratos` (`POST /demandas` — `operadorId?` + guards `403 RBAC-001`/`404 TEN-001`); `REQ-FUNC-005`; relacionadas: Slice 9 T9.4 (remoção original de `operadorAlocadoId`), `DEC-054` (compat operador↔tipo no mesmo caminho manual). **Nota tática (code repo):** `memory/decisions/2026-07-15-criar-demanda-gestao-operador-id.md`.

---

## DEC-054 — Compatibilidade operador ↔ tipo de maquinário na alocação manual (`422 DEM-013`)

- **Estado:** Ativo
- **Data:** 2026-07-16 (decisão tática, follow-up PR #95) · **registrada retroativamente no log em 2026-07-18**
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** o auto-allocator (`AutoAllocatorService`/`allocation-candidate.repository.ts`) hard-filtra candidatos por habilitação (`OperadorTipoMaquinario`), mas os dois caminhos **manuais** de alocação — `POST /demandas` com `operadorId` (gestão, `DEC-053`) e `POST /demandas/:id/alocar` — aceitavam qualquer operador do tenant sem validar compatibilidade. A alocação manual permitia o que a automática proíbe. Viveu como nota tática (`memory/decisions/2026-07-16-compat-operador-tipo-alocacao-manual.md`) + amendment de `SPEC/08`; regularizada aqui.
- **Opções consideradas:**
  - A) Enriquecer o DTO do Kanban (sem endpoint novo, sem request extra) + validar no BE nos dois write paths — **ESCOLHIDA**.
  - B) Endpoint dedicado de elegibilidade (ex.: `GET /demandas/:id/operadores-elegiveis`) — REJEITADA no MVP: mais preciso (dado fresco), mas exige request extra por seleção e um 2º contrato; fica como evolução futura (`cargaAtiva`). O `422 DEM-013` do BE já fecha a janela de staleness.
  - C) Override manual de incompatibilidade (permitir com aviso) — REJEITADA: contradiz a regra de habilitação que o auto-allocator já impõe.
- **Decisão:**
  1. `KanbanQueryService` enriquece `OperadorKanbanDto` (`tiposAutorizadosIds` + `tipoMaquinarioAtualId`) e `DemandaKanbanCardDto` (`tipoMaquinarioId`) — nas queries já existentes, zero query nova, zero N+1.
  2. Operador incompatível fica **visível porém desabilitado** no Combobox (hint muted "Não habilitado") — transparência + coerência com o auto-allocator. **Sem override manual.**
  3. BE valida nos dois write paths (defesa em profundidade contra snapshot stale do Kanban, polling 10s): `CriarDemandaUseCase` ramo gestão (`403 RBAC-001` → `404 TEN-001` → **`422 DEM-013`** → persistir); `AlocarDemandaUseCase` (após `404 TEN-001` + reconstituição, checa habilitação quando `demanda.tipoMaquinarioId !== null` → `422 DEM-013`).
  4. **Carve-out de tipo `null`** (demanda legado pré-Slice 9): sem check de habilitação — mesmo carve-out do auto-allocator.
  5. `422 DEM-013` segue o precedente de `DEM-010`. Backfill de `DEM-011`/`DEM-012` (reorder, `POST /demandas/:id/reordenar`) na tabela de códigos de `SPEC/08` — já existiam no código desde a Slice 6, tabela estava stale (corrigido de passagem).
- **Justificativa:** paridade entre alocação manual e automática (`REQ-FUNC-002`); a validação no BE (não só no FE via `disabled`) fecha a janela de staleness do Kanban. Reusar o range `DEM-0NN` mantém a taxonomia de erros de domínio de Demanda coesa.
- **Nota de numeração:** decisão de 2026-07-16, anterior a `DEC-051`/`DEC-052`; número > data por **registro retroativo** (2026-07-18). Contador `CLAUDE.md` bumpado `DEC-054 → DEC-055` neste lote.
- **SPECs/REQ-IDs afetados:** `SPEC/08-api-contratos` (`POST /demandas` + `POST /demandas/:id/alocar` ganham `422 DEM-013`; `GET /demandas/kanban` documenta `OperadorKanbanDto.tiposAutorizadosIds`/`tipoMaquinarioAtualId` e `DemandaKanbanCardDto.tipoMaquinarioId`; tabela de códigos ganha `DEM-011`/`DEM-012`/`DEM-013`); `REQ-FUNC-005`, `REQ-FUNC-002`; relacionadas: `DEC-053` (o `operadorId?` que este check valida), ADR 0004 (cascata tipo→máquina). **Nota tática (code repo):** `memory/decisions/2026-07-16-compat-operador-tipo-alocacao-manual.md`.

---

## DEC-055 — Material = texto livre no MVP (sem catálogo de materiais)

- **Estado:** Ativo
- **Data:** 2026-07-09 (ratificação D1) · **registrada retroativamente no log em 2026-07-18**
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** o MVP **ainda não tem o motor de priorização/score** (`score = 50/30/20`); sem ele não há o que alimentar com o material (o `fator_material`/`W_mat` só faz sentido com o score ligado). Ratificado no brief `dev-todo/2026-07-09-decisoes-a-ratificar-prototipos.md` (item **D1**). A sub-decisão **D2** do mesmo brief (SLA/prioridade fora da UI) foi absorvida e supersedida por `DEC-051` — esta DEC cobre apenas o material (D1). Viveu como nota tática (`memory/decisions/2026-07-09-mvp-sem-motor-priorizacao-material-sla.md`); regularizada aqui.
- **Opções consideradas:**
  - A) Criar catálogo/CRUD de materiais (dropdown estruturado) já no MVP — REJEITADA: sem motor de priorização, o catálogo não alimenta nada; complexidade sem retorno no MVP.
  - B) Material como **texto livre** no MVP, catálogo estruturado pós-MVP junto do motor de priorização — **ESCOLHIDA**.
- **Decisão:** `CriarDemandaDialog` mantém `<Input>` de texto livre para material, obrigatório quando `categoria === MOVIMENTACAO` (guard imperativo `DEM-007`/`DEM-008`). Persistência em `Demanda.materialTexto` (`NVarChar(255)`, shim MVP); a relação estruturada `material Material?` (`materialId`) permanece no schema mas não é usada pelo fluxo de criação do MVP. **Não** se cria catálogo/CRUD de materiais no MVP.
- **Justificativa:** Regra 15 — a spec de UI (`UI/Machinery-Link/01-mobile-empreiteiro.md` §4) descreve material como dropdown de catálogo; o canônico para o MVP é **este DEC** (texto livre). Os protótipos Claude Design **mostram** dropdown de material intencionalmente como *target state* (Paulo aprovou visualmente) — a implementação MVP não copia isso; quando o motor de priorização entrar (pós-MVP), o protótipo já é o alvo pronto.
- **Nota de numeração:** decisão de 2026-07-09, muito anterior às DEC-05x de julho; número `DEC-055` > data por **registro retroativo** (2026-07-18). Contador `CLAUDE.md` bumpado `DEC-055 → DEC-056` neste lote (fim deste lote retroativo).
- **SPECs/REQ-IDs afetados:** `SPEC/02-modelo-dados` (`Demanda.materialTexto` — shim texto-livre no ER); `UI/Machinery-Link/01-mobile-empreiteiro` (§4 material = texto livre no MVP, dropdown é target state); `REQ-FUNC-001`, `REQ-FUNC-005`; relacionadas: `DEC-005` (entrega formal de material, adiada pós-MVP), `DEC-051` (a sub-decisão D2/SLA irmã, agora decisão de produto). **Nota tática (code repo):** `memory/decisions/2026-07-09-mvp-sem-motor-priorizacao-material-sla.md`.

---

## DEC-056 — Checklist de prontidão removido do overview `/ops` (vive só no dashboard ML) — amenda DEC-046

- **Estado:** Ativo
- **Data:** 2026-07-18
- **Participantes:** Paulo (FGR), Engenharia
- **Contexto:** A T4.5.1 (DEC-046) implementou o checklist de prontidão de obra e a shell FGR-Ops o exibia **no card de cada obra do overview `/ops`** — badge "Pronta"/"Incompleta" + lista dos 7 requisitos + botão "Resolver" por requisito faltante. O card disparava uma query de prontidão **por obra** (`useQueries` → `GET /obras/:obraId/prontidao` para cada card). Em paralelo, a Gestão (PR #98, `DEC-052`) passou a exibir a prontidão como `BannerProntidao` no **dashboard do módulo Machinery Link** (`/machinery-link/$obra/dashboard`) — os mesmos 7 requisitos + "Resolver". Resultado: prontidão duplicada em dois lugares (overview `/ops` **e** dashboard ML), com o `/ops` emitindo N chamadas de prontidão só para pintar badges no overview de obras.
- **Decisão:** Remover o checklist de prontidão do overview `/ops` — badge, lista de requisitos, botão "Resolver" e o `useQueries` que disparava `GET /obras/:obraId/prontidao` por obra saem do `apps/web/src/routes/ops/index.tsx`. O card de `/ops` passa a mostrar **só** nome da obra + "Editar" (write-perfis) + "Selecionar obra". A prontidão passa a viver **exclusivamente** no `BannerProntidao` do dashboard ML (`DEC-052`). SUPER_ADMIN/BOARD **mantêm acesso** à prontidão pelo caminho card `/ops` → "Selecionar obra" → hub da obra (`/obras/$obra`, `DEC-048`) → "Acessar módulo" → dashboard ML: ambos estão em `MACHINERY_LINK_PERFIS` (chegam à shell ML) **e** em `PRONTIDAO_READ_PERFIS` (`[SUPER_ADMIN, BOARD, ADMIN_OPERACIONAL, TOWER_OPERATOR]`, veem o banner). Mudança **FE-only**: o contrato `GET /obras/:obraId/prontidao` (`DEC-046`/`SPEC/08`), o shape `ProntidaoObra`, os 7 requisitos e o RBAC do endpoint (`DEC-052`) ficam **inalterados** — só o consumo pelo `/ops` foi removido.
- **Justificativa:** A prontidão é informação **operacional** do módulo Machinery Link (o dashboard é onde se opera a obra), não do overview cross-obra do `/ops` (cujo papel é listar/selecionar/administrar obras). Exibi-la nos dois lugares duplicava UI e, no `/ops`, fazia N fetches de prontidão só para badges — custo sem dono claro. Concentrar no dashboard ML (onde `DEC-052` já a colocou) elimina a duplicação e o fan-out de queries, sem perder acesso para nenhum perfil que já a via. Regra 15: a T4.5.1 registrou a prontidão como capacidade da shell FGR-Ops; esta DEC ameda `DEC-046` declarando que a **exibição** dessa capacidade vive só no dashboard ML (o contrato do endpoint permanece o de `DEC-046`).
- **Nota de numeração:** contador `fgr-ops-docs/CLAUDE.md` em **DEC-056** (log append-only termina em DEC-055). Sem colisão de draft (DEC redigida direto; `draft_decision` auto-atribui número colidente — padrão dos DEC-050→055). Contador bumpado **DEC-056 → DEC-057**.
- **SPECs/REQ-IDs afetados:** `REQ-FUNC-009`; `SPEC/08-api-contratos` (contrato `prontidao` **inalterado** — só some um consumidor FE); `UI/FGR-Ops/02-app-shell-hub` (overview `/ops` sem badge/checklist de prontidão no card); relacionadas: `DEC-046` (contrato original + exibição no `/ops`, agora amendada), `DEC-052` (`BannerProntidao` no dashboard ML + RBAC `TOWER_OPERATOR`), `DEC-048` (card → hub da obra), `DEC-047` (shell `/machinery-link/$obra`). **Design (code repo):** `docs/superpowers/specs/2026-07-18-remover-prontidao-overview-ops-design.md`; plano `docs/superpowers/plans/2026-07-18-remover-prontidao-overview-ops.md`.
