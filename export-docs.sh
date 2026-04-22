#!/usr/bin/env bash
# export-docs.sh — Exporta a documentação FGR-OPS para HTML via Pandoc
# Uso: bash export-docs.sh
# Requisito: pandoc instalado no PATH

set -e

OUT_DIR="./export"
TMP_DIR="./export/.tmp-docs"
DATE=$(date +%Y-%m-%d)

mkdir -p "$OUT_DIR" "$TMP_DIR"

# ---------------------------------------------------------------------------
# CSS corporativo — visual limpo, idêntico ao da visão executiva
# ---------------------------------------------------------------------------
cat > "$TMP_DIR/docs-style.css" << 'ENDCSS'
:root {
  --brand-dark:   #0d2137;
  --brand-mid:    #1a4e8c;
  --brand-light:  #2563a8;
  --accent:       #e85d04;
  --bg-alt:       #f5f8fc;
  --border:       #dde3ea;
  --text:         #1a1a2e;
  --muted:        #555;
}

* { box-sizing: border-box; }

body {
  font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
  font-size: 15px;
  line-height: 1.75;
  color: var(--text);
  max-width: 960px;
  margin: 0 auto;
  padding: 2.5em 3em;
}

header {
  border-bottom: 3px solid var(--accent);
  margin-bottom: 2em;
  padding-bottom: 1em;
}

nav#TOC {
  background: var(--bg-alt);
  border-left: 4px solid var(--brand-mid);
  border-radius: 4px;
  padding: 1.2em 1.8em;
  margin-bottom: 2.5em;
}
nav#TOC ul { margin: 0.3em 0; padding-left: 1.4em; }
nav#TOC a { color: var(--brand-mid); text-decoration: none; }
nav#TOC a:hover { text-decoration: underline; }

h1 {
  font-size: 2em;
  color: var(--brand-dark);
  border-bottom: 3px solid var(--accent);
  padding-bottom: 0.3em;
  margin-top: 1.8em;
}
h2 {
  font-size: 1.4em;
  color: var(--brand-mid);
  border-left: 4px solid var(--accent);
  padding-left: 0.7em;
  margin-top: 2em;
}
h3 {
  font-size: 1.1em;
  color: var(--brand-light);
  margin-top: 1.5em;
}
h4 { color: var(--muted); font-size: 1em; text-transform: uppercase; letter-spacing: 0.03em; }

table {
  width: 100%;
  border-collapse: collapse;
  margin: 1.4em 0;
  font-size: 0.93em;
}
thead th {
  background: var(--brand-mid);
  color: white;
  padding: 0.6em 1em;
  text-align: left;
  font-weight: 600;
}
tbody td {
  padding: 0.55em 1em;
  border-bottom: 1px solid var(--border);
  vertical-align: top;
  word-break: break-word;
  overflow-wrap: break-word;
}
tbody tr:nth-child(even) td { background: var(--bg-alt); }

blockquote {
  border-left: 4px solid var(--accent);
  margin: 1.2em 0;
  padding: 0.8em 1.2em;
  background: var(--bg-alt);
  color: var(--muted);
  border-radius: 0 4px 4px 0;
}

code {
  background: #eef2f7;
  border-radius: 3px;
  padding: 0.15em 0.4em;
  font-size: 0.88em;
  font-family: "Consolas", "Courier New", monospace;
  color: var(--brand-dark);
}
pre code {
  display: block;
  padding: 0.8em 1em;
  overflow-x: auto;
  line-height: 1.5;
}
pre {
  background: #eef2f7;
  border-radius: 4px;
  border-left: 4px solid var(--brand-mid);
  margin: 1em 0;
  overflow-x: auto;
}

ul, ol { padding-left: 1.6em; margin: 0.6em 0; }
li { margin-bottom: 0.3em; }

a { color: var(--brand-mid); }

@media print {
  body { padding: 0; font-size: 11px; }
  h2 { page-break-before: always; }
  nav#TOC { page-break-after: always; }
  table { font-size: 10px; }
  thead th, tbody td { padding: 0.35em 0.6em; }
  @page { margin: 2cm; }
}
ENDCSS

# ---------------------------------------------------------------------------
# Limpeza do diretório temporário ao sair
# ---------------------------------------------------------------------------
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Ordem lógica de leitura dos documentos
PRD_FILES=(
  "docs/PRD/_index.md"
  "docs/PRD/00-visao-escopo.md"
  "docs/PRD/01-usuarios-rbac.md"
  "docs/PRD/02-jornada-usuario.md"
  "docs/PRD/03-requisitos-funcionais.md"
  "docs/PRD/04-requisitos-nao-funcionais.md"
  "docs/PRD/05-criterios-aceite.md"
  "docs/PRD/06-metricas-riscos.md"
)

SPEC_FILES=(
  "docs/SPEC/_index.md"
  "docs/SPEC/00-visao-arquitetura.md"
  "docs/SPEC/01-modulos-plataforma.md"
  "docs/SPEC/02-modelo-dados.md"
  "docs/SPEC/03-fila-scoring-estados-sla.md"
  "docs/SPEC/04-rbac-permissoes.md"
  "docs/SPEC/05-backlog-mvp-glossario.md"
  "docs/SPEC/06-definicoes-complementares.md"
  "docs/SPEC/07-design-ui-logica.md"
  "docs/SPEC/08-api-contratos.md"
)

PANDOC_META=(
  --metadata title="FGR-OPS Machinery Link — Documentação Completa"
  --metadata author="FGR Incorporações"
  --metadata date="$DATE"
  --standalone
  --toc
  --toc-depth=3
)

export_html() {
  echo "Gerando HTML..."
  pandoc \
    "${PRD_FILES[@]}" "${SPEC_FILES[@]}" \
    "${PANDOC_META[@]}" \
    --to html5 \
    --css "$TMP_DIR/docs-style.css" \
    --self-contained \
    --output "$OUT_DIR/FGR-OPS-Docs-$DATE.html"
  echo "  -> $OUT_DIR/FGR-OPS-Docs-$DATE.html"
}

export_html

echo ""
echo "Exportação concluída. Arquivos em: $OUT_DIR/"
