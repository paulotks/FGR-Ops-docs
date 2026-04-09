# SPEC Authoring Skill

Acionado quando: redação ou atualização de seções SPEC, adição de novos módulos técnicos, documentação de decisões arquiteturais.

## Protocolo

1. **Antes de escrever qualquer seção SPEC**, leia o módulo PRD correspondente e anote todos os `REQ-IDs` relevantes
2. **Toda seção nova** deve começar com o bloco `**Rastreio PRD:**` listando os `REQ-xxx` cobertos
3. **Para cada decisão arquitetural** tomada ao escrever, registre em `docs/audit/decisions-log.md` como `DEC-NNN` (próximo disponível: DEC-011)
4. **Atualize `docs/traceability.md`** antes de considerar a seção estável — verifique se o mapeamento PRD ↔ SPEC está correto
5. **Use `.agent/skills/`** apenas como referência para entender patterns arquiteturais — nunca copie código para dentro da SPEC
6. **Diagramas sempre em Mermaid**, armazenados em `docs/flows/` e linkados por path relativo da seção correspondente
7. **Cross-links bidirecionais:** após criar/atualizar seção SPEC, volte ao PRD correspondente e adicione `→ SPEC: path#anchor`
8. **Verificação final:** rode `/audit` — zero findings CRITICAL antes de marcar seção como estável

## Template de Seção SPEC

```markdown
## [Nome da Seção]

**Rastreio PRD:** REQ-FUNC-NNN, REQ-NFR-NNN, ...

[Conteúdo da seção]

### Decisões Arquiteturais Relevantes

- **DEC-NNN:** [título] — [link para decisions-log.md#dec-nnn]
- **D1–D7:** [referência ao ADR aplicável]
```

## Checklist de Qualidade (por seção)

- [ ] `**Rastreio PRD:**` presente com todos os REQ-IDs cobertos
- [ ] `docs/traceability.md` atualizado com esta seção
- [ ] Cross-link adicionado no PRD correspondente (`→ SPEC: path#anchor`)
- [ ] Decisões táticas registradas como `DEC-NNN`
- [ ] Diagramas Mermaid em `docs/flows/` se aplicável
- [ ] Glossário atualizado se novo conceito de domínio introduzido
