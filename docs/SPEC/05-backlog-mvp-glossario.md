# Backlog MVP e glossario

**Rastreio PRD:** `REQ-SCO-F2-001`, `REQ-SCO-F2-002`, `REQ-SCO-F2-003`, `REQ-SCO-F2-004`, `REQ-SCO-F2-005`, `REQ-SCO-F2-006`, `REQ-SCO-GAT-001`, `REQ-SCO-GAT-002`, `REQ-SCO-GAT-003`, `REQ-SCO-GAT-004`, `REQ-RISK-001`

Este modulo consolida o backlog tecnico fora do escopo imediato do MVP e o glossario base usado ao longo da documentacao modular.

## Backlog MVP

### Escopo delimitado

O MVP contempla exclusivamente o modulo `Machinery Link`. Capacidades como `Almoxarifado`, rastreamento `IoT`, aplicacoes nativas (`App Store` e `Google Play`) e a entidade `ServicoDinamico` ficam formalmente adiadas para uma Fase 2, preservando o foco no go-live operacional.

### Itens adiados para Fase 2

- **Telemetria e IoT**: dependem de hardware homologado e maturidade adicional na observabilidade de campo.
- **Modulo de Almoxarifado**: permanece fora do MVP para evitar alargar o dominio operacional nesta entrega.
- **Aplicacoes nativas**: o MVP permanece em `PWA`; mobile nativo fica condicionado a necessidades tecnicas futuras.
- **Migracao de dados legados e roteirizacao geocolocada** (`REQ-SCO-F2-005`): a importacao de historico operacional de sistemas anteriores e a roteirizacao em mapas geocolocados ficam fora do MVP. A migracao depende de mapeamento de esquemas legados por obra e validacao de integridade com o modelo canonico do FGR-OPS; a roteirizacao depende de integracao com servico de mapas e maturidade da malha espacial em producao.
- **ServicoDinamico**: adiado por falta de regras maduras para exclusao mutua, sincronismo e dependencias multiplas entre frentes.
- **Entrega formal de material** (`PontoOrigem`, `exigeTransporte`): fluxo estruturado de entrega de material a partir de origens externas fixas (centrais de concreto, usinas, etc.) com tipificacao de servicos de transporte, campos obrigatorios de origem/destino/material e pre-preenchimento automatico da origem. No MVP, servicos de movimentacao de massas (Grunt, Concreto, etc.) sao tratados como demandas regulares com material e destino opcionais e descricao em texto livre, pois o material ja se encontra na frente de obras (DEC-006).

### Criterios de promocao para Fase 2

A transicao de itens adiados para desenvolvimento activo ocorre mediante gatilhos explicitos, alinhados com os criterios definidos no PRD.

| ID | Item | Gatilho de promocao |
| :--- | :--- | :--- |
| `REQ-SCO-GAT-001` | Telemetria e IoT | Estabilizacao de 95% na acuracia do Checkpoint Manual por 3 meses consecutivos **E** viabilizacao de contrato de hardware homologado pela FGR. |
| `REQ-SCO-GAT-002` | Modulo de Almoxarifado | Consolidacao da taxonomia de Materiais no Machinery Link atingindo 500+ registos unicos activos em ambiente produtivo. |
| `REQ-SCO-GAT-003` | Aplicativos Nativos | Necessidade tecnica comprovada de acesso a APIs de hardware (Bluetooth/NFC) ou requisito de seguranca da informacao que inviabilize o PWA. |
| `REQ-SCO-GAT-004` | Servicos Dinamicos | Registo de 20%+ de demandas devolvidas por erro de exclusao mutua ("deadlocks operacionais") onde o agrupamento passivo via `DemandaGrupo` se prove insuficiente. |

> Nota: a avaliacao dos gatilhos e responsabilidade conjunta de Produto e Operacoes, com revisao trimestral documentada.

### Governanca da taxonomia espacial (`REQ-RISK-001`)

O motor de fila depende da coerencia cadastral de `SetorOperacional`, `Quadra`, `Lote`, `Rua` e respectivas adjacencias. Para mitigar o risco de degradacao da atribuicao automatica por inconsistencias cadastrais, o MVP deve implementar as seguintes regras tecnicas de governanca:

1. **Validacao na criacao/edicao**: ao criar ou alterar entidades espaciais, o sistema valida integridade referencial (ex.: `Lote` pertence a `Quadra` existente na mesma obra, adjacencias nao referenciam entidades de obras distintas).
2. **Auditoria cadastral**: toda criacao, edicao ou exclusao logica de entidades espaciais gera entrada em `DemandaLog` (ou log dedicado) com `userId`, `timestamp`, valores antigos/novos e `obraId`.
3. **Restricao de exclusao**: entidades espaciais referenciadas por demandas activas (`PENDENTE`, `EM_ANDAMENTO`, `AGENDADA`) nao podem ser excluidas logicamente ate a conclusao ou cancelamento das demandas vinculadas.
4. **Relatorio de consistencia**: o painel administrativo deve disponibilizar relatorio consultivo que identifique `Lotes` sem adjacencia definida, `Quadras` vazias e `SetoresOperacionais` sem operador vinculado, acessivel a `AdminOperacional` e `SuperAdmin`.

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
