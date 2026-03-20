# Backlog MVP e glossario

**Rastreio PRD:** `REQ-SCO-F2-001`, `REQ-SCO-F2-002`, `REQ-SCO-F2-003`, `REQ-SCO-F2-004`, `REQ-SCO-F2-005`, `REQ-SCO-F2-006`, `REQ-RISK-001`

Este modulo consolida o backlog tecnico fora do escopo imediato do MVP e o glossario base usado ao longo da documentacao modular.

## Backlog MVP

### Escopo delimitado

O MVP contempla exclusivamente o modulo `Machinery Link`. Capacidades como `Almoxarifado`, rastreamento `IoT`, aplicacoes nativas (`App Store` e `Google Play`) e a entidade `ServicoDinamico` ficam formalmente adiadas para uma Fase 2, preservando o foco no go-live operacional.

### Itens adiados para Fase 2

- **Telemetria e IoT**: dependem de hardware homologado e maturidade adicional na observabilidade de campo.
- **Modulo de Almoxarifado**: permanece fora do MVP para evitar alargar o dominio operacional nesta entrega.
- **Aplicacoes nativas**: o MVP permanece em `PWA`; mobile nativo fica condicionado a necessidades tecnicas futuras.
- **ServicoDinamico**: adiado por falta de regras maduras para exclusao mutua, sincronismo e dependencias multiplas entre frentes.

## Glossario tecnico

- **Machinery Link**: modulo MVP dedicado ao fluxo requisicao-execucao das maquinas.
- **Setor Operacional (Jurisdicao Logistica)**: filtro primario geografico ou contextual que ancora operadores e maquinas a limites restritos, suprimindo demandas fora do seu contexto de trabalho.
- **Checkpoint Manual**: calculo de proximidade sem IoT/GPS que infere a localizacao atual da maquina. No inicio do expediente, a localizacao e neutra (`Fora da Obra`) e o checkpoint so passa a influenciar a adjacencia apos a primeira conclusao do turno.
- **Arquitetura Tatica (DDD)**: separacao entre regras puras do dominio operacional e a infraestrutura tecnologica, como `NestJS`, `SQL Server` e `Prisma`.
- **DemandaLog**: trilha auditavel que registra transicoes, justificativas e eventos relevantes da `Demanda`.
- **AGENDADA**: estado inicial de uma demanda programada para o futuro, invisivel ao operador ate a janela de ativacao.
- **dataAgendada**: atributo temporal que define o momento exato do atendimento solicitado e governa a transicao para `PENDENTE` 60 minutos antes do horario-alvo.
- **AuditLogCrossTenant**: log especializado para registar acessos privilegiados de `SuperAdmin` e `Board` que transcendem o isolamento por obra.
- **TurnoAjudante**: registo cronologico associado ao `RegistroExpediente` que mapeia a relacao temporal entre ajudante e par operador-maquina.
- **recalcular_fila**: acao administrativa que forca a atualizacao imediata de scores pendentes numa obra com base nos pesos atuais.
- **SolicitacaoCancelamento**: entidade transacional que formaliza o pedido de interrupcao de um servico em `EM_ANDAMENTO`, exigindo justificativa e aprovacao gerencial.
