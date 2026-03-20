# Etapa 1 — Execução por módulo (`ANALISAR Mxx`)

Este guia operacional define como auditar cada módulo `Mxx` do fluxo PRD ↔ SPEC.

## Objetivo por iteração

Para cada comando `ANALISAR Mxx`, produzir um pacote único com:

1. `consolidated_json`
2. `traceability_csv`
3. `traceability_stub_markdown` (bullets para colar em `docs/traceability.md`)

## Entrada obrigatória

- [step0-module-mapping.json](step0-module-mapping.json)
- Ficheiro PRD do módulo (`prd_path`)
- Um ou mais ficheiros SPEC (`spec_primary` e, quando aplicável, `spec_secondary`)

## Sequência obrigatória (por módulo)

1. **Ler PRD do módulo**
   - Auditar só o PRD nesta leitura.
   - Registar achados com IDs `PRD-Mxx-nnn`.
2. **Ler SPEC primário**
   - Auditar só o SPEC nesta leitura.
   - Registar achados com IDs `SPEC-Mxx-nnn`.
3. **Se houver 1:N, repetir leitura por cada SPEC adicional**
   - Uma leitura separada por ficheiro (`spec_primary` extra e `spec_secondary`).
   - Nunca fundir dois SPEC numa única leitura.
4. **Cross-check PRD vs SPEC**
   - Cruzar `REQ-*` do PRD com cobertura na SPEC.
   - Classificar por requisito: `Coberto`, `Parcial`, `Não coberto`.
   - Registar conflitos bloqueantes com IDs `CROSS-Mxx-nnn`.
5. **Perguntas bloqueantes**
   - Se houver ambiguidade crítica ou bloqueio de interpretação, levantar **uma pergunta objetiva por vez**.
   - Estrutura recomendada: opções `A/B/C/D`.
   - Após resposta, preencher `decision_by_user` e `user_choice`.
6. **Consolidação final do módulo**
   - Gerar o objeto JSON consolidado.
   - Gerar CSV de rastreabilidade.
   - Gerar stub markdown para atualização da matriz global.

## Checklist de auditoria (PRD e SPEC)

Aplicar o mesmo checklist em todas as leituras:

- Contradições internas
- Lacunas bloqueantes
- Ambiguidades de interpretação
- Inconsistências de nomenclatura
- Decisões sem justificativa explícita
- Referências cruzadas incompletas
- Campos em aberto (pendências)

> Regra: identificar problemas; não propor correções durante a coleta de achados.

## Regras de evidência

- Cada achado deve incluir `localizacao` com:
  - ficheiro
  - secção/cabeçalho
  - linha aproximada
- Usar `INFORMACAO_NAO_LOCALIZADA` apenas quando a informação realmente não existir no ficheiro lido.

## Contrato de saída

Usar os templates em `docs/audit/templates/`:

- [consolidated-audit.template.json](templates/consolidated-audit.template.json)
- [traceability.template.csv](templates/traceability.template.csv)
- [traceability-stub.template.md](templates/traceability-stub.template.md)

## Convenção de severidade

- `bloqueante`: impede validação de requisito ou gera conflito direto PRD↔SPEC.
- `importante`: não bloqueia a leitura, mas afeta consistência, rastreio ou aceite.
- `menor`: ruído documental sem impacto imediato de cobertura.

[Voltar ao README de auditoria](README.md)
