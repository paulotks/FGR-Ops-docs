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
