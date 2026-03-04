---
name: session-start
description: "Session start protocol. Loads project context in cache-optimal order, reports action items, checks document accuracy, and proposes a parallelized execution plan. Use at the beginning of any session or when the user says 'start session'."
---

## Session Start Protocol

Execute all five steps in order. Keep the startup phase to 5–10 minutes maximum.

---

## Step 1: Load Context (Cache-Optimal Order)

Load files in this order to maximize cache efficiency:

1. **CLAUDE.md** — already auto-loaded by Claude Code. Skim specifically for the "Current State" section. Do not re-read content that CLAUDE.md already summarizes — trust the standing knowledge.

2. **MEMORY.md** — check the "Action Required" section FIRST before reading anything else. If there are pending action items, report them to the user immediately, before proceeding to any other step.

3. **NEXT_SESSION_PROMPT.md** — check whether this file exists:
   - If it **exists** → this IS the session specification. Load it and treat it as the primary work plan. It takes priority over everything else, including MEMORY.md state.
   - If it **does not exist** → proceed using MEMORY.md state, then ask the user what they want to accomplish this session.

4. **HANDOVER.md** — if it exists, read it to understand what happened last session: what was completed, what was left unfinished, and any important context for continuity.

---

## Step 2: Reality Check

Verify that CLAUDE.md accurately reflects the current project state. Check for:

- Tools or APIs listed as active that may be broken or deprecated (e.g., do not say "Gemini primary" if Gemini has been non-functional)
- A "Current State" section that no longer matches the actual codebase or project phase
- Any obviously stale entries (outdated file paths, removed features, changed integrations)

If discrepancies are found: flag them to the user immediately and fix CLAUDE.md before proceeding. Do not silently work around stale information.

---

## Step 3: Propose Execution Plan

Based on NEXT_SESSION_PROMPT.md (if it exists) or the user's stated goals, construct a plan that defaults to parallelism. Sequential execution is the exception, not the norm.

1. Identify independent tasks that can run as parallel subagents.
2. Identify tasks that must run on the main thread (user interaction, blocking decisions, integration work).
3. Estimate context budget allocation — which tasks involve large file reads or isolated work (subagents), and which require live user feedback (main thread).

Present the plan clearly before beginning work:

```
## Proposed Session Plan

### Parallel (agent teams):
- Agent A: [task] — [estimated scope]
- Agent B: [task] — [estimated scope]

### Main thread (sequential):
1. [task] — [why main thread]
2. [task] — [depends on Agent A results]

### Context budget:
- Subagent reads: [list of large files to read via agents]
- Main thread reserved for: [user interaction, decisions, integration]
```

Wait for user confirmation or adjustment before proceeding to Step 4.

---

## Step 4: Check for Recurring Bug Patterns

Before beginning execution, surface any relevant known issues:

- Reference `/Users/sukritandvandana/Documents/Projects/learning-from-building/patterns/RECURRING_BUGS.md` if it exists.
- If the session involves **data pipelines** → remind the user about the status mismatch pattern.
- If the session is **long or complex** → remind the user about context compaction prevention strategies.
- If the session involves **API integrations** → remind the user about rate limit coordination.

Only surface patterns that are relevant to the current session's planned work. Do not list every known bug indiscriminately.

---

## Step 5: Begin Work

- Create a TodoWrite todo list from the proposed and confirmed plan.
- Mark the first task as `in_progress`.
- If NEXT_SESSION_PROMPT.md existed, check off any success criteria that are already met before starting new work.
- Begin executing the first task immediately.

---

## Key Principles

- **Report action items immediately** — before orientation, before planning, before anything else.
- **NEXT_SESSION_PROMPT.md takes priority** over all other context. It is the session specification.
- **Default to parallelism** — decompose work into agents wherever tasks are independent.
- **Do not over-orient** — startup should take 5–10 minutes, not 30. Trust CLAUDE.md.
- **Do not re-read files** that CLAUDE.md already summarizes accurately.

---

## Reference Files

- Templates: `/Users/sukritandvandana/Documents/Projects/learning-from-building/templates/`
- Session lifecycle: `/Users/sukritandvandana/Documents/Projects/learning-from-building/frameworks/SESSION_LIFECYCLE.md`
- Capability map: `/Users/sukritandvandana/Documents/Projects/learning-from-building/guides/CAPABILITY_MAP.md`
- Agent orchestration: `/Users/sukritandvandana/Documents/Projects/learning-from-building/guides/AGENT_ORCHESTRATION.md`
