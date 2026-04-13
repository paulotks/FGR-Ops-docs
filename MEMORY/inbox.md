# MEMORY/inbox.md — Tasks Documentais Pendentes

> Claude lê este arquivo no início de cada sessão e sugere qual task atacar.
> Formato: `- [ ]` pendente | `- [x]` concluído

---

## Pendências Ativas

*(Nenhuma pendência crítica no baseline de 2026-04-09 — auditoria global resolvida)*

### Acompanhamento

- [ ] Verificar se `REQ-ACE-007` precisa de seção explícita em `SPEC/00-visao-arquitetura.md` ou se a cobertura arquitetural base é suficiente (marcado como "parcial" na auditoria)
- [ ] Confirmar se `REQ-SCO-GAT-001…004` (gatilhos de promoção Fase 1→2) estão cobertos em `SPEC/05-backlog-mvp-glossario.md` ou se precisam de seção dedicada
- [ ] Avaliar se `SPEC/08-api-contratos.md` precisa de atualização após DEC-009 e DEC-010 (exigeTransporte + modelo Maquinario)

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

## Achados Históricos Resolvidos

Todos os 37 achados da auditoria global (2026-03-26) foram resolvidos.
Detalhe em: [docs/audit/output/global/consolidated-global.json](../docs/audit/output/global/consolidated-global.json)

## Tasks detectadas em 2026-04-09

- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:206:- **Contexto:** A revisão do item 1 do TODO de correções PRD/SPEC (2026-04-09) identificou que `PAUSADA` havia sido introduzido em `SPEC/07` sem ter transições formais definidas em `SPEC/03`. A opção era: (A) remover `PAUSADA` do MVP e tratar como Fase 2, ou (B) mantê-lo no MVP formalizando as transições em `SPEC/03` e abrindo `REQ-FUNC-011`.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:216:- **Achados resolvidos:** TODO-correcoes-prd item 1b (transições de `PAUSADA` em SPEC/03).

## Tasks detectadas em 2026-04-09

- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:206:- **Contexto:** A revisão do item 1 do TODO de correções PRD/SPEC (2026-04-09) identificou que `PAUSADA` havia sido introduzido em `SPEC/07` sem ter transições formais definidas em `SPEC/03`. A opção era: (A) remover `PAUSADA` do MVP e tratar como Fase 2, ou (B) mantê-lo no MVP formalizando as transições em `SPEC/03` e abrindo `REQ-FUNC-011`.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:216:- **Achados resolvidos:** TODO-correcoes-prd item 1b (transições de `PAUSADA` em SPEC/03).

## Tasks detectadas em 2026-04-09

- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:206:- **Contexto:** A revisão do item 1 do TODO de correções PRD/SPEC (2026-04-09) identificou que `PAUSADA` havia sido introduzido em `SPEC/07` sem ter transições formais definidas em `SPEC/03`. A opção era: (A) remover `PAUSADA` do MVP e tratar como Fase 2, ou (B) mantê-lo no MVP formalizando as transições em `SPEC/03` e abrindo `REQ-FUNC-011`.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:216:- **Achados resolvidos:** TODO-correcoes-prd item 1b (transições de `PAUSADA` em SPEC/03).

## Tasks detectadas em 2026-04-09

- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:206:- **Contexto:** A revisão do item 1 do TODO de correções PRD/SPEC (2026-04-09) identificou que `PAUSADA` havia sido introduzido em `SPEC/07` sem ter transições formais definidas em `SPEC/03`. A opção era: (A) remover `PAUSADA` do MVP e tratar como Fase 2, ou (B) mantê-lo no MVP formalizando as transições em `SPEC/03` e abrindo `REQ-FUNC-011`.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:216:- **Achados resolvidos:** TODO-correcoes-prd item 1b (transições de `PAUSADA` em SPEC/03).
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:228:- **Contexto:** O item 2 do TODO de correções PRD/SPEC (2026-04-09) exigia definir o papel da entidade `Rua` no domínio: (A) descritiva sem impacto operacional, (B) participante do algoritmo de adjacência, ou (C) entidade de agrupamento puramente visual.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:240:- **Achados resolvidos:** TODO-correcoes-prd item 2 (papel da entidade `Rua`).

## Tasks detectadas em 2026-04-09

- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:206:- **Contexto:** A revisão do item 1 do TODO de correções PRD/SPEC (2026-04-09) identificou que `PAUSADA` havia sido introduzido em `SPEC/07` sem ter transições formais definidas em `SPEC/03`. A opção era: (A) remover `PAUSADA` do MVP e tratar como Fase 2, ou (B) mantê-lo no MVP formalizando as transições em `SPEC/03` e abrindo `REQ-FUNC-011`.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:216:- **Achados resolvidos:** TODO-correcoes-prd item 1b (transições de `PAUSADA` em SPEC/03).
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:228:- **Contexto:** O item 2 do TODO de correções PRD/SPEC (2026-04-09) exigia definir o papel da entidade `Rua` no domínio: (A) descritiva sem impacto operacional, (B) participante do algoritmo de adjacência, ou (C) entidade de agrupamento puramente visual.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:240:- **Achados resolvidos:** TODO-correcoes-prd item 2 (papel da entidade `Rua`).
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:251:- **Contexto:** O item 3 do TODO de correções PRD/SPEC (2026-04-09) identificou que a permissão `machinery:demanda:cancel` (condição [4]: autoria + estado `PENDENTE`) estava autorizada no RBAC mas sem representação documentada na UI de campo do empreiteiro em `SPEC/07`.
- [ ] /c/dev/FGR-Ops-Requisitos/docs/audit/decisions-log.md:257:- **Achados resolvidos:** TODO-correcoes-prd item 3 (fluxo de cancelamento do Empreiteiro na UI).

## Tasks detectadas em 2026-04-09

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

## Tasks detectadas em 2026-04-10

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

## Tasks detectadas em 2026-04-10

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

## Tasks detectadas em 2026-04-10

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

## Tasks detectadas em 2026-04-10

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

## Tasks detectadas em 2026-04-10

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

## Tasks detectadas em 2026-04-10

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

## Tasks detectadas em 2026-04-10

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

## Tasks detectadas em 2026-04-13

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

## Tasks detectadas em 2026-04-13

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

## Tasks detectadas em 2026-04-13

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
