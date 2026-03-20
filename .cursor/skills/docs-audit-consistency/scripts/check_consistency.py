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


def main() -> int:
    checks = [
        ("Arquivos obrigatorios", check_required_files),
        ("Redirecionamento de monoliticos", check_monolith_redirects),
        ("Links quebrados", check_broken_links),
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
