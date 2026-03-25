#!/usr/bin/env python3
from __future__ import annotations

import re
import unicodedata
from pathlib import Path


ROOT = Path(__file__).resolve().parents[4]

FILES_TO_CHECK = [
    ROOT / "FGR-OPS-SPEC.md",
    ROOT / "PRD-FGR-OPS.md",
    ROOT / "docs" / "audit" / "decisions-log.md",
]

LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
HEADING_RE = re.compile(r"^\s{0,3}#{1,6}\s+(.+?)\s*$", re.MULTILINE)
CUSTOM_ANCHOR_RE = re.compile(r"\{#([A-Za-z0-9_-]+)\}")
REQ_ID_RE = re.compile(r"REQ-[A-Z]+-\d+")
MERMAID_BLOCK_RE = re.compile(r"```mermaid\s*\n(.*?)```", re.DOTALL | re.IGNORECASE)


def slugify_anchor(text: str) -> str:
    text = text.strip().lower()
    text = unicodedata.normalize("NFD", text)
    text = "".join(ch for ch in text if unicodedata.category(ch) != "Mn")
    text = re.sub(r"[^a-z0-9 _-]", "", text)
    text = re.sub(r"[ ]+", "-", text)
    text = re.sub(r"-{2,}", "-", text)
    return text.strip("-")


def extract_anchors(markdown_content: str) -> set[str]:
    anchors: set[str] = set()
    for heading in HEADING_RE.findall(markdown_content):
        custom = CUSTOM_ANCHOR_RE.search(heading)
        if custom:
            anchors.add(custom.group(1).lower())
            heading = CUSTOM_ANCHOR_RE.sub("", heading).strip()
        slug = slugify_anchor(heading)
        if slug:
            anchors.add(slug)
    return anchors


def parse_link(link_text: str, base_file: Path) -> tuple[Path | None, str | None]:
    link_text = link_text.strip()
    if link_text.startswith(("http://", "https://", "mailto:")):
        return None, None
    if link_text.startswith("#"):
        return base_file, link_text[1:]
    if "#" in link_text:
        path_part, fragment = link_text.split("#", 1)
    else:
        path_part, fragment = link_text, ""
    target = (base_file.parent / path_part).resolve()
    return target, fragment or None


def link_exists(link_text: str, base_file: Path) -> bool:
    target_file, fragment = parse_link(link_text, base_file)
    if target_file is None:
        return True
    if not target_file.exists():
        return False
    if target_file.is_dir():
        readme_candidate = target_file / "README.md"
        if readme_candidate.exists():
            target_file = readme_candidate
        elif fragment is None:
            return True
        else:
            return False
    if fragment is None:
        return True

    try:
        content = target_file.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return False
    anchors = extract_anchors(content)
    return slugify_anchor(fragment) in anchors or fragment.lower() in anchors


def check_required_files() -> list[str]:
    errors: list[str] = []
    for path in FILES_TO_CHECK:
        if not path.exists():
            errors.append(f"Arquivo obrigatorio ausente: {path.relative_to(ROOT)}")
    return errors


def check_monolith_redirects() -> list[str]:
    errors: list[str] = []
    expected_links = {
        ROOT / "FGR-OPS-SPEC.md": ["docs/SPEC/_index.md"],
        ROOT / "PRD-FGR-OPS.md": ["docs/PRD/_index.md"],
    }
    for file_path, required in expected_links.items():
        if not file_path.exists():
            continue
        content = file_path.read_text(encoding="utf-8", errors="replace")
        for must_have in required:
            if must_have not in content:
                errors.append(
                    f"{file_path.relative_to(ROOT)} sem referencia obrigatoria para {must_have}"
                )
    return errors


def check_broken_links() -> list[str]:
    errors: list[str] = []
    markdown_files = list((ROOT / "docs").rglob("*.md")) + [
        ROOT / "FGR-OPS-SPEC.md",
        ROOT / "PRD-FGR-OPS.md",
    ]

    for md_file in markdown_files:
        if not md_file.exists():
            continue
        content = md_file.read_text(encoding="utf-8", errors="replace")
        for match in LINK_RE.finditer(content):
            link = match.group(1).strip()
            if not link_exists(link, md_file):
                errors.append(
                    f"Link quebrado em {md_file.relative_to(ROOT)} -> {link}"
                )
    return errors


def _index_prd_req_ids() -> set[str]:
    """Todos os REQ-* mencionados em docs/PRD (texto bruto; verificacao leve)."""
    prd_dir = ROOT / "docs" / "PRD"
    found: set[str] = set()
    if not prd_dir.is_dir():
        return found
    for md in sorted(prd_dir.rglob("*.md")):
        try:
            text = md.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        found.update(REQ_ID_RE.findall(text))
    return found


def check_mermaid_req_refs_in_flows() -> list[str]:
    """
    Verificacao leve: REQ-* citados dentro de blocos ```mermaid em docs/flows/
    devem aparecer em algum ficheiro sob docs/PRD/.
    """
    errors: list[str] = []
    flows_dir = ROOT / "docs" / "flows"
    if not flows_dir.is_dir():
        return errors

    prd_req_ids = _index_prd_req_ids()
    if not prd_req_ids:
        return errors

    reported: set[tuple[str, str]] = set()

    for md_file in sorted(flows_dir.glob("*.md")):
        try:
            content = md_file.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        rel = md_file.relative_to(ROOT)
        for block_match in MERMAID_BLOCK_RE.finditer(content):
            block = block_match.group(1)
            block_body_start = block_match.start(1)
            for req_match in REQ_ID_RE.finditer(block):
                rid = req_match.group(0)
                if rid in prd_req_ids:
                    continue
                key = (str(rel), rid)
                if key in reported:
                    continue
                reported.add(key)
                pos = block_body_start + req_match.start()
                line_no = content.count("\n", 0, pos) + 1
                errors.append(
                    f"{rel}: linha ~{line_no}: {rid} em mermaid nao encontrado em docs/PRD/"
                )
    return errors


def main() -> int:
    checks = [
        ("Arquivos obrigatorios", check_required_files),
        ("Redirecionamento de monoliticos", check_monolith_redirects),
        ("Links quebrados", check_broken_links),
        ("REQ-* em mermaid (docs/flows)", check_mermaid_req_refs_in_flows),
    ]

    all_errors: list[str] = []
    for name, check in checks:
        errors = check()
        if errors:
            print(f"[FALHA] {name}: {len(errors)}")
            for err in errors:
                print(f"  - {err}")
            all_errors.extend(errors)
        else:
            print(f"[OK] {name}")

    if all_errors:
        print(f"\nResultado: {len(all_errors)} inconsistencia(s) encontrada(s).")
        return 1

    print("\nResultado: consistencia valida.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
