# MEMORY/inbox.md — Tasks Documentais Pendentes

> Claude lê este arquivo no início de cada sessão e sugere qual task atacar.
> Formato: `- [ ]` pendente | `- [x]` concluído

---

## Pendências Ativas

*(Nenhuma pendência crítica no baseline de 2026-04-09 — auditoria global resolvida)*

### Acompanhamento

- [x] Verificar se `REQ-ACE-007` precisa de seção explícita em `SPEC/00-visao-arquitetura.md`. VERIFICADO 2026-04-17: ADR D3 (JWT + rotação + revogação jti Redis) e D6 (PIN + palavra-passe + idle timeout) cobrem diretamente os 3 cenários Gherkin de REQ-ACE-007. Cobertura arquitetural base é suficiente. Traceability já aponta SPEC/00 + SPEC/08.
- [x] Confirmar se `REQ-SCO-GAT-001…004` estão cobertos em `SPEC/05-backlog-mvp-glossario.md`. VERIFICADO 2026-04-17: todos os 4 presentes na tabela "Critérios de promoção para Fase 2" e no bloco `Rastreio PRD:` de SPEC/05. Nenhuma seção adicional necessária.
- [x] Avaliar se `SPEC/08-api-contratos.md` precisa de atualização após DEC-009 e DEC-010. VERIFICADO 2026-04-17: `exigeTransporte` (DEC-009), `proprietarioTipo` e `empreiteiraId` (DEC-016 supersedendo DEC-010) já presentes em SPEC/08; `empresaProprietaria` ausente (corretamente). Nenhuma atualização necessária.

## Doc Review Batch 2026-04-16 → recuperação sequencial 2026-04-17

Batch paralelo de 17 workers Sonnet bateu rate limit 2026-04-16; 15 units executadas sequencialmente pelo main-agent (Opus) em 2026-04-16..17. Ver `MEMORY/doc-review/_batch-status-2026-04-16.md` para histórico.

**Reviews completos (17/17):**

- [x] [doc-review/prd-00-visao-escopo] PRD/00 — Visão & Escopo — 0 critical, 1 warning, 3 info
- [x] [doc-review/prd-01-usuarios-rbac] PRD/01 — Usuários & RBAC — 0 critical, 1 warning, 4 info
- [x] [doc-review/prd-02-jornada-usuario] PRD/02 — Jornada do Usuário — 0 critical, 3 warning, 6 info
- [x] [doc-review/prd-03-requisitos-funcionais] PRD/03 — Req. Funcionais — **1 critical**, 3 warning, 4 info
- [x] [doc-review/prd-04-requisitos-nao-funcionais] PRD/04 — Req. Não-Funcionais — ver arquivo
- [x] [doc-review/prd-05-criterios-aceite] PRD/05 — Critérios de Aceite — 0 critical, 3 warning, 4 info
- [x] [doc-review/prd-06-metricas-riscos] PRD/06 — Métricas & Riscos — ver arquivo
- [x] [doc-review/spec-00-visao-arquitetura] SPEC/00 — Visão & Arquitetura — **2 critical**, 2 warning, 4 info
- [x] [doc-review/spec-01-modulos-plataforma] SPEC/01 — ver arquivo
- [x] [doc-review/spec-02-modelo-dados] SPEC/02 — Modelo de Dados — 0 critical, 2 warning, 5 info
- [x] [doc-review/spec-03-fila-scoring-estados-sla] SPEC/03 — ver arquivo
- [x] [doc-review/spec-04-rbac-permissoes] SPEC/04 — RBAC — 0 critical, 3 warning, 4 info
- [x] [doc-review/spec-05-backlog-mvp-glossario] SPEC/05 — ver arquivo
- [x] [doc-review/spec-06-definicoes-complementares] SPEC/06 — ver arquivo
- [x] [doc-review/spec-07-design-ui-logica] SPEC/07 — ver arquivo
- [x] [doc-review/spec-08-api-contratos] SPEC/08 — API Contratos — **3 critical**, 4 warning, 6 info
- [x] [doc-review/cross-traceability-decisions] Cross-cutting — **1 critical**, 4 warning, 5 info

**Total cross-repositório:** 7 critical · ~30 warning · ~55 info

### Ações prioritárias consolidadas (ordenadas)

- [x] **CRITICAL:** Abrir `DEC-024` — escala canônica de pesos de score (0-100 vs 0.0-1.0; soma=100/1.0 obrigatória?). RESOLVIDO 2026-04-17 via DEC-024 (escala 0-100, sem soma obrigatória); SPEC/08 atualizado.
- [x] **CRITICAL:** `PRD/03` linha 32 — remover `empresaProprietaria` obrigatório; substituir por `proprietarioTipo` + `empreiteiraId` (DEC-010/DEC-016). RESOLVIDO 2026-04-17.
- [x] **CRITICAL:** `SPEC/00` linha 118 — substituir `DemandaAcao` por `DemandaLog`; remover "Terceiro" por "EMPREITEIRA". RESOLVIDO 2026-04-17.
- [x] **CRITICAL:** `SPEC/08` linha 1251 — corrigir anchor quebrado (Angular supersedido por DEC-021). RESOLVIDO 2026-04-17 — anchor `{#3-componentes-chave-padroes-react}` adicionado em SPEC/07; link atualizado em SPEC/08.
- [x] **CRITICAL:** `SPEC/08` linha 34 — remover menção a "Valibot" (stack usa só zod). RESOLVIDO 2026-04-17.
- [x] Reduzir triplicação de UX de pop-up em PRD/02, PRD/03, SPEC/06, SPEC/07 (`prd-02` WARNING-003, `prd-03` WARNING-002). RESOLVIDO 2026-04-17: PRD/02 e PRD/03 colapsados para intenção de negócio; âncoras explícitas adicionadas em SPEC/06 e SPEC/07; REQ-FUNC-013 adicionado ao Rastreio PRD de SPEC/06. OpsX arquivado.
- [x] `SPEC/04` — remover bloco fantasma `solicitacao-cancelamento` (DEC-019); compactar notas `[1..7]`; renomear "Lacuna 1/2". RESOLVIDO 2026-04-17: bloco substituído por comment, notas [6]→[5]/[7]→[6], headings renomeados + nota de auditoria; âncoras em PRD/01 atualizadas; bullet obsoleto de Decisões de design marcado ~~riscado~~.
- [x] `SPEC/02` — definir comportamento de `tempoExecucaoMs` em CANCELADA/RETORNADA; definir "shadow-queue". RESOLVIDO 2026-04-17: comportamento de tempoExecucaoMs em CANCELADA/RETORNADA documentado; shadow-queue definida inline com referência a NestJS @Cron + SPEC/06.
- [x] `PRD/05` — mover REQ-ACE-007 para sequência correta; remover menção IndexedDB. RESOLVIDO 2026-04-17: REQ-ACE-007 movido para posição 7 (entre ACE-006 e ACE-008); menção ao IndexedDB substituída por referência neutra a SPEC/06.
- [x] `traceability.md` — adicionar SPEC/08 em linhas 34, 38, 39; criar linha dedicada para REQ-FUNC-013. RESOLVIDO 2026-04-17: SPEC/08 adicionado em REQ-NFR-005/006, REQ-ACE-009, REQ-ACE-007; REQ-FUNC-013 expandido com SPEC/06 + SPEC/08.
- [x] `decisions-log.md` — adicionar marcação "Superseded por" em DEC-002 (↔DEC-019) e DEC-010 (↔DEC-016 parcial). RESOLVIDO 2026-04-17: notas de supersessão adicionadas inline no campo Estado de cada DEC.

---

## Como Usar

Quando Claude detectar ambiguidade, TBD/TODO em documento estável, ou finding de `/audit`, adicionar aqui:

```
- [ ] [arquivo:linha] Descrição do problema — Ação sugerida
```

Quando resolvido:
```
- [x] [arquivo:linha] Descrição — RESOLVIDO em YYYY-MM-DD via DEC-NNN ou commit hash
```

---

## Tasks detectadas em 2026-04-17

- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:206:- **Contexto:** A revisão do item 1 do TODO de correções PRD/SPEC (2026-04-09) identificou que `PAUSADA` havia sido introduzido em `SPEC/07` sem ter transições formais definidas em `SPEC/03`. A opção era: (A) remover `PAUSADA` do MVP e tratar como Fase 2, ou (B) mantê-lo no MVP formalizando as transições em `SPEC/03` e abrindo `REQ-FUNC-011`.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:216:- **Achados resolvidos:** TODO-correcoes-prd item 1b (transições de `PAUSADA` em SPEC/03).
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:228:- **Contexto:** O item 2 do TODO de correções PRD/SPEC (2026-04-09) exigia definir o papel da entidade `Rua` no domínio: (A) descritiva sem impacto operacional, (B) participante do algoritmo de adjacência, ou (C) entidade de agrupamento puramente visual.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:240:- **Achados resolvidos:** TODO-correcoes-prd item 2 (papel da entidade `Rua`).
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:251:- **Contexto:** O item 3 do TODO de correções PRD/SPEC (2026-04-09) identificou que a permissão `machinery:demanda:cancel` (condição [4]: autoria + estado `PENDENTE`) estava autorizada no RBAC mas sem representação documentada na UI de campo do empreiteiro em `SPEC/07`.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:257:- **Achados resolvidos:** TODO-correcoes-prd item 3 (fluxo de cancelamento do Empreiteiro na UI).
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:270:- **Contexto:** O item 4 do TODO de correções PRD/SPEC (2026-04-09) identificou que o PRD/SPEC descrevia cadastros e perfis sem deixar claro **onde** cada responsabilidade vive: FGR Ops (plataforma multi-módulo futura) vs Machinery Link (módulo operacional entregue no MVP). O Machinery Link hoje é sistema standalone; no MVP ele é re-platformado como primeiro módulo do FGR Ops. Sem essa separação explícita, a sequência de setup inicial de uma obra ficava ambígua quanto a quem executa cada passo e em qual aplicação.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:282:  - Empreiteira (passo #13) e LocalExterno (passo #9) são citados na sequência canônica mas têm entidade e contratos CRUD pendentes de formalização nos itens 6 e 7 do TODO-correcoes-prd.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:283:- **Achados resolvidos:** TODO-correcoes-prd item 4 (sequência de setup inicial de uma obra).
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:287:  - `TODO-correcoes-prd.md`: item 4 marcado como `[x]`.
