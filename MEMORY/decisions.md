# MEMORY/decisions.md — Espelho de Decisões Táticas

> Este arquivo NÃO substitui `docs/audit/decisions-log.md` — ele é um espelho leve das decisões mais relevantes para sessões recentes.
> Fonte canônica: [docs/audit/decisions-log.md](../docs/audit/decisions-log.md)

---

## Decisões Ativas (relevantes para o MVP)

### DEC-001 — Comportamento híbrido de `operadorAlocadoId`
- **Contexto:** `operadorAlocadoId` pode sobrepor hard filters em alocação manual (AdminOperacional/UsuarioInternoFGR)
- **Decisão:** Comportamento híbrido — motor automático como padrão, alocação manual como exceção auditável
- **Consequências:** Motor de fila continua obrigatório; alocação manual fora de zona deve ter alerta visual (não-MVP)
- **Link canônico:** [decisions-log.md#dec-001](../docs/audit/decisions-log.md#dec-001--regra-zero-vs-filtros-operadoralocadoid)

### DEC-002 — Cancelamento automático por estouro de SLA
- **Contexto:** `PENDENTE_APROVACAO` → auto-encerramento no fim do expediente parametrizável por obra
- **Decisão:** Auto-aprovação sem intervenção humana; trilha auditável obrigatória com origem, ator, timestamp
- **Consequências:** Visão de revisão pós-facto para UsuarioInternoFGR/AdminOperacional no dia seguinte
- **Link canônico:** [decisions-log.md#dec-002](../docs/audit/decisions-log.md#dec-002--cancelamento-automático-vs-revisão-administrativa)

### DEC-009 — `exigeTransporte` reintroduzido no MVP
- **Contexto:** Flag na entidade `Servico` torna origem→destino obrigatório na criação da Demanda
- **Decisão:** Flag reintroduzida — quando ativo, campos de transporte são mandatórios no form de abertura
- **Consequências:** Impacta modelo de dados (`Servico`), API de criação de Demanda e lógica do form frontend
- **Link canônico:** [decisions-log.md#dec-009](../docs/audit/decisions-log.md#dec-009--reintrodução-de-exigetransporte-no-mvp)

### DEC-010 — Modelo de cadastro de TipoMaquinario e Maquinario
- **Contexto:** Refinamento do modelo de entidades para telas de cadastro MVP
- **Decisão:** TipoMaquinario (nome, descrição); Maquinario (nome, empresaProprietaria, placa opcional)
- **Consequências:** CRUD APIs e permissões documentadas em SPEC/08-api-contratos.md e SPEC/04-rbac-permissoes.md
- **Link canônico:** [decisions-log.md#dec-010](../docs/audit/decisions-log.md#dec-010--modelo-de-cadastro-de-tipomaquinario-e-maquinario)

---

## Próxima DEC Disponível: DEC-011
