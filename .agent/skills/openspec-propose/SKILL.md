---
name: openspec-propose
description: Propose a documentation change (requirements-first) under docs/changes/ with proposal.md, design.md, and tasks.md. Alias for /opsx:propose in FGR-Ops-Requisitos (no OpenSpec CLI).
license: MIT
compatibility: FGR-Ops-Requisitos docs/changes workflow; no openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

Propose a new documentation change. Create `docs/changes/<kebab-name>/` with:

- `proposal.md` (what and why; REQ inventory)
- `design.md` (how; concrete PRD/SPEC targets)
- `tasks.md` (documentation-only checklist)

When documentation is ready to land in PRD/SPEC/traceability, run `/opsx:apply`.

---

**Input**: The argument after `/opsx:propose` is the change name (kebab-case), **or** a description of **which requirement or PRD–SPEC specification gap** you want to address (not “what product code to build”).

**Guardrails**: Follow the skill **context-only-docs** (this repo is documentation-only). During **apply**, follow **docs-audit-consistency** (`.cursor/skills/docs-audit-consistency/SKILL.md`).

**Steps**

1. **If no input, ask for requirements focus**

   Use the **AskUserQuestion** tool (open-ended, no preset options), for example:
   > “What requirement or PRD–SPEC gap should we address?”

   Derive a kebab-case folder name (e.g. “onboarding notifications” → `onboarding-notificacoes`).

   **IMPORTANT**: Do not proceed without a clear requirements focus.

2. **Resolve `<kebab-name>` and collisions**

   If the user supplied a kebab name, use it; otherwise use the derived name.
   If `docs/changes/<name>/` already exists (not under `archive/`), ask whether to continue that change or use a new name.

3. **REQ ID inventory (avoid duplicates)**

   Orient the work using:

   - `docs/PRD/_index.md`, `docs/SPEC/_index.md`
   - Search for `REQ-` under `docs/PRD/` and `docs/SPEC/`
   - Patterns in `docs/traceability.md`

   Propose new IDs consistent with existing prefixes and numbering (canonical prefixes such as FUNC, NFR, ACE, RBAC, JOR, etc.).

4. **Create `docs/changes/<name>/` and the three files**

   - **proposal.md** (minimum sections):
     - Summary
     - Proposed REQs (table: ID, title, type, provisional wording)
     - REQs to change or remove
     - Risks and ambiguities
   - **design.md**:
     - Target files: concrete paths under `docs/PRD/*.md` and `docs/SPEC/*.md`
     - Planned cross-links
     - Reference `docs/audit/decisions-log.md` if there is a product/architecture decision (DEC)
   - **tasks.md**:
     - Suggested order: (1) PRD, (2) SPEC including `Rastreio PRD:`, (3) acceptance criteria in `docs/PRD/05-criterios-aceite.md` if applicable, (4) row(s) in the **global matrix** in `docs/traceability.md`, (5) run `python .cursor/skills/docs-audit-consistency/scripts/check_consistency.py`
     - **Only** documentation tasks (`- [ ]` / `- [x]`). No application code tasks.

5. **Closing**

   Summarize: change name, path `docs/changes/<name>/`, artifacts created.
   State that the next step is **applying documentation** (not shipping product code).
   Prompt: run **`/opsx:apply`** (optionally with `<name>`).

**Output**

- Change folder path and short summary of REQs
- Reminder: `/opsx:apply` updates PRD, SPEC, `docs/traceability.md`, and runs consistency checks
