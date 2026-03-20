# Auditoria PRD ↔ SPEC

Fluxo interativo para auditar módulos `M01` a `M07` com base nos índices oficiais e na matriz global de rastreabilidade.

## Artefactos deste diretório

- [Etapa 0 — Mapeamento M01–M07](step0-module-mapping.md)
- [Etapa 1 — Execução por módulo (`ANALISAR Mxx`)](step1-per-module-audit.md)
- [Template JSON consolidado](templates/consolidated-audit.template.json)
- [Template CSV de rastreabilidade](templates/traceability.template.csv)
- [Template de stub para `docs/traceability.md`](templates/traceability-stub.template.md)
- [Script de merge global](scripts/merge-consolidated-json.ps1)

## Fluxo rápido

1. Ler [step0-module-mapping.json](step0-module-mapping.json) e escolher um módulo.
   - Usar o objeto `Mxx` para identificar `prd_path`, `spec_primary`, `spec_secondary` e `note`.
2. Executar a etapa por módulo conforme [step1-per-module-audit.md](step1-per-module-audit.md).
   - Ler primeiro o PRD do módulo.
   - Ler depois cada SPEC em iterações separadas, sem fundir dois ficheiros na mesma leitura.
3. Gerar um único pacote de saída por `Mxx`:
   - `consolidated_json`
   - `traceability_csv`
   - `traceability_stub_markdown`
4. Repetir para o próximo módulo ou finalizar.
5. Após `FINALIZAR`, consolidar todos os módulos já auditados:
   - `powershell -ExecutionPolicy Bypass -File docs/audit/scripts/merge-consolidated-json.ps1`
   - Saída padrão: `docs/audit/output/global/consolidated-global.json`

## Etapa 1 por módulo

Para cada comando `ANALISAR Mxx`, seguir sempre a mesma sequência operacional:

1. Localizar o módulo em [step0-module-mapping.json](step0-module-mapping.json).
   - Ler `prd_path`.
   - Ler cada entrada de `spec_primary`.
   - Se existirem entradas em `spec_secondary`, tratá-las como leituras adicionais obrigatórias.
2. Executar a auditoria conforme [step1-per-module-audit.md](step1-per-module-audit.md).
   - PRD primeiro, com achados `PRD-Mxx-nnn`.
   - SPEC depois, um ficheiro por vez, com achados `SPEC-Mxx-nnn`.
   - Cross-check final PRD vs SPEC, com conflitos `CROSS-Mxx-nnn`.
3. Preencher os templates em [docs/audit/templates/](templates/).
   - [consolidated-audit.template.json](templates/consolidated-audit.template.json)
   - [traceability.template.csv](templates/traceability.template.csv)
   - [traceability-stub.template.md](templates/traceability-stub.template.md)
4. Gerar os três artefactos finais do módulo.
   - `consolidated_json`
   - `traceability_csv`
   - `traceability_stub_markdown`

## Estrutura sugerida de saída

Guardar cada pacote do módulo em `docs/audit/output/Mxx/`:

- `docs/audit/output/Mxx/consolidated.json`
- `docs/audit/output/Mxx/traceability.csv`
- `docs/audit/output/Mxx/traceability-stub.md`

O `consolidated_json` deve referenciar o mapeamento de origem, listar os ficheiros revistos e resumir PRD, SPEC, cross-check, perguntas bloqueantes e resumo executivo num único objeto.

## Convenções de IDs de achados

- PRD: `PRD-Mxx-001`
- SPEC: `SPEC-Mxx-001`
- Cross-check bloqueante: `CROSS-Mxx-001`

[Voltar ao README dos docs](../README.md)
