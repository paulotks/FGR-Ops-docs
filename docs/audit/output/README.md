# Saídas por módulo (`ANALISAR Mxx`)

Diretório sugerido para guardar os resultados consolidados de cada auditoria.

## Estrutura recomendada

- `docs/audit/output/M01/consolidated.json`
- `docs/audit/output/M01/traceability.csv`
- `docs/audit/output/M01/traceability-stub.md`

Repetir o mesmo padrão para `M02` ... `M07`.

Use os templates em `docs/audit/templates/` como base de preenchimento.

## Consolidação global após FINALIZAR

Quando todos os módulos desejados tiverem `consolidated.json`:

- Executar: `powershell -ExecutionPolicy Bypass -File docs/audit/scripts/merge-consolidated-json.ps1`
- Resultado: `docs/audit/output/global/consolidated-global.json`

O JSON global agrega todos os `consolidated_json` por módulo e soma os totais do `executive_summary`.

[Voltar ao README de auditoria](../README.md)
