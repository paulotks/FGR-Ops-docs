---
description: Apply documentation tasks from docs/changes/ (requirements-first); update PRD, SPEC, traceability; run docs-audit-consistency and check_consistency
---

Apply tasks from an active change under `docs/changes/<name>/`. **Do not use OpenSpec CLI.** This workflow only updates **documentation** under `docs/` and audit artifacts that **docs-audit-consistency** references (for example `docs/audit/decisions-log.md`).

**Input**: Optionally pass the change name (e.g. `/opsx:apply onboarding-notificacoes`). If omitted, infer from conversation; if ambiguous, list active changes and use **AskUserQuestion**.

**Guardrails**

- Follow **context-only-docs** (no application source code).
- While editing, follow **docs-audit-consistency** (`.cursor/skills/docs-audit-consistency/SKILL.md`): PRD ↔ SPEC cross-links, `Rastreio PRD:` in SPEC, acceptance criteria in `docs/PRD/05-criterios-aceite.md` when applicable, `docs/traceability.md`, and `docs/audit/decisions-log.md` when there is a DEC.
- If `tasks.md` lists application code or schema-driven implementation, treat as **out of scope** for this repo or confirm with the user.

**Note**: There is **no** generator that auto-creates rows in the traceability matrix. Keeping the matrix correct is **mandatory** via this workflow, explicit checklist items in `tasks.md`, and your edits—not a separate tool (future validation scripts are optional extras).

---

**Steps**

1. **Select the change**

   List subdirectories of `docs/changes/` **excluding** `archive/`.
   If a name is given, verify that folder exists.
   If exactly one active change exists, you may auto-select; if several, use **AskUserQuestion**.

   Always announce: `Using change: <name>` and how to override (e.g. `/opsx:apply <other>`).

2. **Read context**

   Read `docs/changes/<name>/proposal.md`, `design.md`, and `tasks.md`.

3. **Show progress**

   From `tasks.md`, count incomplete `- [ ]` vs complete `- [x]`.
   Display **N/M** tasks complete and a short overview of what remains.

4. **Execute tasks (loop until done or paused)**

   For each **pending** `- [ ]` item in `tasks.md`:

   - State which task you are doing.
   - Edit **only** under `docs/` (typically `docs/PRD/`, `docs/SPEC/`, `docs/traceability.md`, `docs/audit/` when applicable).
   - Reflect the skill’s sync rules while you work: primary change plus dependent artifacts (cross-links, criteria, decisions) as needed—do not leave orphan `REQ-*` references.

   **Traceability (explicit deliverable)**  
   After PRD/SPEC content for this change is **stable**, update **`docs/traceability.md`**:

   - Edit the **Matriz global** table (section *Matriz global*): columns **REQ / grupo**, **PRD**, **SPEC**, **Notas**.
   - Add a new row or adjust existing cells so they match the **same** markdown-table style and linking pattern as neighboring rows (relative links like `PRD/...`, `SPEC/...`).
   - Use `REQ-XXX-*` style in the first column when the row represents a **group** of requirements, consistent with the existing matrix.

   When a task is done, flip its checkbox: `- [ ]` → `- [x]`.

   **Pause if**:

   - The task is unclear → ask.
   - Edits conflict with `proposal.md` or `design.md` → suggest updating those files before continuing.
   - Tooling or validation errors → report and wait.

5. **Consistency check (end of session or when all tasks are done)**

   Read and follow `.cursor/skills/docs-audit-consistency/SKILL.md` end-to-end for this change set.

   Run:

   ```bash
   python .cursor/skills/docs-audit-consistency/scripts/check_consistency.py
   ```

   Report the outcome. If the script reports issues, fix documentation and re-run until clean or document agreed exceptions with the user.

6. **Status**

   **On completion**: Summarize tasks finished this session, overall **N/M**, and suggest `/opsx:archive` when every item in `tasks.md` is `[x]`.

   **On pause**: Explain why and wait for guidance.

---

**Output during work (example)**

```
## Applying documentation: <change-name>

Working on task 3/7: <task description>
✓ Task complete
```

**Output on completion (example)**

```
## Documentation apply complete

**Change:** <change-name>
**Progress:** 7/7 tasks complete ✓

All tasks complete. You can archive with `/opsx:archive`.
```

**Output on pause (example)**

```
## Apply paused

**Change:** <change-name>
**Progress:** 4/7 tasks complete

### Issue
<description>

What should we do next?
```
