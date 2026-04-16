# Doc-Review Skill

Orquestradora automática de validação de documentação PRD/SPEC do FGR-OPS.

## O que faz

Quando um arquivo PRD ou SPEC é alterado, invoca as 3 skills de validação em sequência:

1. **requirements-analysis** — Valida novos requisitos, gaps e ambiguidades
2. **architecture-review** — Questiona decisões técnicas e coerência arquitetural
3. **tech-stack-validator** — Garante que tecnologias não estão ultrapassadas

Consolida findings em um relatório e propõe ações.

## Como usar

### Manual (sob demanda)
```
/doc-review docs/PRD/03-requisitos-funcionais.md
```

### Automático (via hook)
Configurado em `.claude/settings.json`:
- Dispara ao salvar `docs/PRD/**/*.md` ou `docs/SPEC/**/*.md`
- Invoca `/doc-review [file] auto`
- Consolida em `MEMORY/inbox.md`

### Detecção automática
```
/doc-review auto
```
Detecta arquivos alterados no git e processa.

## Output

Cada execução gera:
- **Relatório consolidado** com findings das 3 skills
- **Entradas em `MEMORY/inbox.md`** com ações propostas
- **Sugestões de correção** no SPEC/PRD
- **Atualização de `traceability.md`** se necessário

## Fluxo interno

```
user altera docs/PRD/03-*.md
       ↓
[Hook dispara] → /doc-review auto
       ↓
detecta arquivo alterado
       ↓
├─→ /requirements-analysis [file]
├─→ /architecture-review [file]
└─→ /tech-stack-validator [file]
       ↓
consolida outputs
       ↓
gera relatório + atualiza inbox
```

## Configuração

### Em `.claude/settings.json`

```json
{
  "hooks": {
    "onFileSaved": [
      {
        "patterns": [
          "docs/PRD/**/*.md",
          "docs/SPEC/**/*.md"
        ],
        "command": "npx claude /doc-review ${file} auto",
        "debounce": 3000
      }
    ]
  }
}
```

**Flags:**
- `auto` — modo não-interativo, consolida em inbox
- (sem flag) — modo interativo, exibe findings em tempo real
- `--no-update-inbox` — não atualiza MEMORY/inbox.md
- `--write-spec` — propõe mudanças inline em arquivos

## Exemplo de execução

```bash
/doc-review docs/SPEC/03-fila-scoring-estados-sla.md auto

→ Analisando SPEC/03...
→ /requirements-analysis detectou 2 gaps
→ /architecture-review questionou 1 decisão
→ /tech-stack-validator validou stack (OK)
→ Consolidado em MEMORY/inbox.md
→ ✅ Pronto para revisão
```

## Próximos passos

1. Configurar hook em `.claude/settings.json` (execute `/update-config`)
2. Testar com: `/doc-review docs/PRD/00-visao-escopo.md`
3. Revisar outputs em `MEMORY/inbox.md`
