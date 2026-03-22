---
name: openspec-apply-change
description: Apply documentation tasks from docs/changes/; update PRD, SPEC, traceability; run check_consistency. Alias for /opsx:apply (no OpenSpec CLI).
license: MIT
compatibility: FGR-Ops-Requisitos docs/changes workflow; no openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

Apply tasks from an active change under `docs/changes/<name>/`. **Do not use OpenSpec CLI.** Edit only under `docs/` (and audit artifacts referenced by **docs-audit-consistency**).

**Input**: Optionally pass the change name (e.g. `/opsx:apply onboarding-notificacoes`). If omitted, infer from conversation; if ambiguous, list active changes and use **AskUserQuestion**.

**Guardrails**: Follow **context-only-docs** and **docs-audit-consistency**. **Do not** implement application source code. If `tasks.md` mentions code implementation, treat it as out of scope for this repo or clarify with the user.

**Steps**

1. **Select the change**

   List subdirectories of `docs/changes/` **excluding** `archive/`.
   If a name is given, ensure that folder exists.
   If exactly one active change exists, you may auto-select; if several, use **AskUserQuestion**.

   Always announce: `Using change: <name>` and how to override (e.g. `/opsx:apply <other>`).

2. **Read context**

   Read `docs/changes/<name>/proposal.md`, `design.md`, and `tasks.md`.

3. **Show progress**

   From `tasks.md`, count incomplete `- [ ]` vs complete `- [x]`.
   Display **N/M** tasks complete and a short overview of what remains.

4. **Execute tasks (loop until done or paused)**

   For each pending task:

   - State which task you are doing
   - Edit only files under `docs/` (PRD, SPEC, `docs/traceability.md`, `docs/audit/` when applicable)
   - **Traceability**: once PRD/SPEC edits for this change are stable, update **`docs/traceability.md`** — add or adjust rows/cells in the **same format** as the existing global table (use `REQ-XXX-*` style when representing a group)
   - Mark the task complete: `- [ ]` → `- [x]`

   **Pause if**:

   - The task is unclear → ask
   - Edits reveal inconsistency with `proposal.md` / `design.md` → suggest updating those files
   - Tooling or validation errors → report and wait

5. **Consistency check (end of session or when all tasks are done)**

   Read and follow `.cursor/skills/docs-audit-consistency/SKILL.md`.
   Run:

   ```bash
   python .cursor/skills/docs-audit-consistency/scripts/check_consistency.py
   ```

   Report the outcome; fix documentation issues if the script reports problems.

6. **Status**

   On completion: tasks finished this session, overall **N/M**, suggest `/opsx:archive` when everything is `[x]`.
   On pause: explain why and wait for guidance.

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
