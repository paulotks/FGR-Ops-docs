#!/usr/bin/env bash
# export-exec.sh — Exporta visão executiva do FGR-OPS (gestores, board, stakeholders não técnicos)
# Conteúdo: objetivos, perfis de usuário, jornadas, regras de negócio, métricas e riscos
# Excluído: arquitetura técnica, modelo de dados, contratos de API, NFRs, critérios de aceite QA
#
# Uso: bash export-exec.sh
# Requisito: pandoc instalado no PATH

set -e

OUT_DIR="./export"
TMP_DIR="./export/.tmp-exec"
DATE=$(date +%Y-%m-%d)

mkdir -p "$OUT_DIR" "$TMP_DIR"

# ---------------------------------------------------------------------------
# Arquivos fonte para visão executiva (ordem lógica de leitura)
# Critério de seleção: o que um gestor/board precisa entender do sistema
# ---------------------------------------------------------------------------
EXEC_FILES=(
  "docs/PRD/00-visao-escopo.md"
  "docs/PRD/01-usuarios-rbac.md"
  "docs/PRD/02-jornada-usuario.md"
  "docs/PRD/03-requisitos-funcionais.md"
  "docs/SPEC/03-fila-scoring-estados-sla.md"
  "docs/SPEC/04-rbac-permissoes.md"
  "docs/SPEC/07-design-ui-logica.md"
  "docs/PRD/06-metricas-riscos.md"
)

# ---------------------------------------------------------------------------
# Pré-processamento: remove ruído técnico irrelevante para gestores
#   - Marcadores REQ-XXX-NNN inline (ex: **REQ-FUNC-001** ou `REQ-RBAC-002`)
#   - Links cruzados → SPEC: ...
#   - Blocos **Rastreio PRD:**
#   - Links Markdown para arquivos SPEC internos (mantém o texto do link)
#   - Linhas com apenas -> FLOW: ou -> SPEC:
# ---------------------------------------------------------------------------
preprocess() {
  local src="$1"
  local dst="$2"
  sed \
    -e 's/\*\*REQ-[A-Z]*-[0-9]*\*\*[[:space:]]*/  /g' \
    -e 's/`REQ-[A-Z]*-[0-9]*`[[:space:]]*/  /g' \
    -e 's/REQ-[A-Z]*-[0-9]*[[:space:]]*/  /g' \
    -e '/^[[:space:]]*->[[:space:]]*SPEC:/d' \
    -e '/^[[:space:]]*->[[:space:]]*FLOW:/d' \
    -e '/\*\*Rastreio PRD:\*\*/d' \
    -e 's/(DEC-[0-9]*)//g' \
    -e 's/\[\([^]]*\)\](\.\.\/SPEC\/[^)]*)/\1/g' \
    "$src" \
  | awk '/Lacuna 1/{skip=1; next} skip && /^## /{skip=0} !skip' \
  > "$dst"
}

PROCESSED_FILES=()
for f in "${EXEC_FILES[@]}"; do
  base=$(basename "$f")
  dst="$TMP_DIR/$base"
  preprocess "$f" "$dst"
  PROCESSED_FILES+=("$dst")
done

# ---------------------------------------------------------------------------
# CSS executivo — visual limpo, corporativo, adequado para impressão/apresentação
# ---------------------------------------------------------------------------
cat > "$TMP_DIR/exec-style.css" << 'ENDCSS'
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
  max-width: 920px;
  margin: 0 auto;
  padding: 2.5em 3em;
}

/* Cabeçalho do documento */
header {
  border-bottom: 3px solid var(--accent);
  margin-bottom: 2em;
  padding-bottom: 1em;
}

/* Sumário */
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

/* Headings */
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

/* Tabelas */
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

/* Blocos de destaque */
blockquote {
  border-left: 4px solid var(--accent);
  margin: 1.2em 0;
  padding: 0.8em 1.2em;
  background: var(--bg-alt);
  color: var(--muted);
  border-radius: 0 4px 4px 0;
}

/* Código inline — raramente aparece, mas formatamos discretamente */
code {
  background: #eef2f7;
  border-radius: 3px;
  padding: 0.15em 0.4em;
  font-size: 0.88em;
  font-family: "Consolas", "Courier New", monospace;
  color: var(--brand-dark);
}

/* Listas */
ul, ol { padding-left: 1.6em; margin: 0.6em 0; }
li { margin-bottom: 0.3em; }

/* Links */
a { color: var(--brand-mid); }

/* Rodapé de página na impressão */
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
# Metadados Pandoc comuns
# ---------------------------------------------------------------------------
PANDOC_META=(
  --metadata title="FGR-OPS Machinery Link — Visão Executiva"
  --metadata subtitle="Plataforma de Operações de Maquinário Pesado — MVP"
  --metadata author="FGR Incorporações"
  --metadata date="$DATE"
  --standalone
  --toc
  --toc-depth=2
)

# ---------------------------------------------------------------------------
# Exportação HTML
# ---------------------------------------------------------------------------
export_html() {
  echo "Gerando HTML executivo..."
  pandoc \
    "${PROCESSED_FILES[@]}" \
    "${PANDOC_META[@]}" \
    --to html5 \
    --css "$TMP_DIR/exec-style.css" \
    --self-contained \
    --output "$OUT_DIR/FGR-OPS-Executivo-$DATE.html"
  echo "  -> $OUT_DIR/FGR-OPS-Executivo-$DATE.html"
}

# ---------------------------------------------------------------------------
# Limpeza do diretório temporário ao sair
# ---------------------------------------------------------------------------
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

export_html

echo ""
echo "Exportação executiva concluída. Arquivos em: $OUT_DIR/"
