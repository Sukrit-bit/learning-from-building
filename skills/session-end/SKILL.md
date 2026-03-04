---
name: session-end
description: "Mandatory end-of-session checklist. Use when ending a session, wrapping up, or when context is approaching limits. Enforces documentation updates, handover creation, and learnings capture."
triggers:
  - "end session"
  - "wrap up"
  - "session end"
  - "close out"
  - "context approaching limits"
  - "emergency wrap up"
---

# Session End Skill

> **Path resolution:** This skill is part of the learning-from-building framework. The framework repo root is two directories up from this skill's base directory. All file references below are relative to the framework repo root.

This skill enforces the mandatory 7-step end-of-session checklist. Every session MUST complete these steps before closing. Skipping any step (outside Emergency Mode) is a protocol violation.

Reference material:
- Templates: `templates/` in the framework repo
- Session lifecycle framework: `frameworks/SESSION_LIFECYCLE.md` in the framework repo

---

## Emergency Mode

If context is critically low (user says "emergency wrap up" or similar), execute MINIMUM VIABLE CLOSE and skip to the end:

1. Create/update `NEXT_SESSION_PROMPT.md` (most important artifact)
2. Update `MEMORY.md` "Action Required" section
3. Git commit with message: `docs: session [N] emergency close — [1-line summary]`

Then stop. Do not attempt the full 7 steps under emergency conditions.

---

## Step 1: Update CLAUDE.md

Use a subagent (Task tool) to handle this step if possible to preserve main thread context.

Read the current `CLAUDE.md` at the project root. Then make these specific checks:

- **Gotchas:** Did this session reveal any new failure modes, surprising behaviors, or hard-won lessons? If yes, add them to the "Key Gotchas" section with a brief explanation of why the gotcha matters.
- **Current State:** Does the "Current State" section reflect what actually exists in the codebase and environment right now? Update it to match reality as of the end of this session.
- **Constants and configs:** Did any API endpoints, model names, environment variable names, version numbers, or configuration values change? Update every reference to the old value.
- **Stale information:** Is anything in CLAUDE.md contradicted by what happened this session? Fix it or remove it.
- **Length check:** If CLAUDE.md exceeds 300 lines, flag this explicitly. Do not silently let it grow. Recommend moving reference material (long tables, historical context, detailed specs) to `.claude/rules/` and linking from CLAUDE.md.

Do not add fluff. Every line in CLAUDE.md must earn its place.

---

## Step 2: Update MEMORY.md

Use a subagent (Task tool) to handle this step if possible.

Read the current `MEMORY.md` at the project root. If it does not exist, create it using `templates/MEMORY_MD_TEMPLATE.md` in the framework repo.

Update the following sections:

- **Action Required:** Add any tasks that must carry over to the next session. Remove tasks that were completed this session.
- **Project State:** Update the current version or phase, set today's date as the "last updated" date, and update any key metrics that changed.
- **Active Decisions:** If any architectural, product, or process decisions were made or reversed this session, record them with the rationale. Remove decisions that are no longer active (implemented or abandoned).
- **Known Issues:** Add any bugs or blockers discovered this session. Remove any that were resolved.

CRITICAL: A stale MEMORY.md is a P0 bug. Every field must match reality at the moment the session closes. Do not leave placeholders or approximate values.

---

## Step 3: Create/Update HANDOVER.md

Use a subagent (Task tool) to handle this step if possible.

Create or overwrite `HANDOVER.md` at the project root with the following structure. Determine the session number [N] from prior handover files or MEMORY.md.

```
# Session [N] Handover — [YYYY-MM-DD]

## Accomplished
- [Specific deliverable with enough detail to be unambiguous]
- [Each item is a concrete artifact or outcome, not a category]

## Decisions Made
- [Decision]: [Rationale — why this over the alternatives]

## Bugs Found
- [Bug description]: [Classification from RECURRING_BUGS.md if the file exists and this bug matches a known pattern]

## Current Blockers
- [Blocker]: [Impact on next session — what cannot proceed until this is resolved]
```

Rules for this document:
- "Accomplished" items must be specific. "Worked on auth" is not acceptable. "Implemented JWT refresh token rotation with 15-minute expiry" is acceptable.
- If no bugs were found, write "None found this session." Do not omit the section.
- If no blockers exist, write "None." Do not omit the section.

---

## Step 4: Create NEXT_SESSION_PROMPT.md

This is the most important deliverable of the entire end-of-session process. A new session has ZERO memory of this one. Write for a stranger.

Use a subagent (Task tool) to handle this step if possible. Reference `templates/NEXT_SESSION_PROMPT_TEMPLATE.md` in the framework repo.

Create or overwrite `NEXT_SESSION_PROMPT.md` at the project root with the following structure:

```
# Session [N+1] Specification

## Current State
[Exact numbers, file paths, version strings, and status flags — not prose descriptions.
Example: "Auth service: complete. 3 endpoints live. 0 tests written. JWT secret in .env.local."]

## Work Streams
### Stream 1: [Name]
- Goal: [Single sentence stating the end state]
- Steps:
  1. [Concrete action]
  2. [Concrete action]
- Dependencies: [What must be true before this stream can start]
- Acceptance Criteria:
  - [ ] [Measurable, binary criterion]
  - [ ] [Measurable, binary criterion]

### Stream 2: [Name]
[Same structure]

## Orchestration
- Parallel: [List streams that can run concurrently and why]
- Sequential: [List streams that must run in order and state the dependency]

## Context Management Rules
- Carry forward from standing rules: [list applicable standing rules]
- This session: [any session-specific additions, e.g., "avoid reading X file — it's 2000 lines and not needed"]

## Success Criteria
- [ ] [Measurable criterion — binary pass/fail]
- [ ] [Measurable criterion — binary pass/fail]
```

Key principles:
- Write for a stranger. The next session has zero memory of this one.
- Include ALL context needed to start work immediately. The document must be self-contained.
- Prefer exact numbers, file paths, and status flags over qualitative descriptions.
- If a work stream has an unknown dependency, say so explicitly rather than omitting it.

---

## Step 5: Capture Learnings

Use the AskUserQuestion tool to ask:

"What went wrong, what went right, and what was surprising this session? Share anything you'd want to remember in 6 months."

Wait for the user's response before proceeding.

Format each learning the user shares using this structure:

**[Learning title]:** [Explanation with enough context for someone reading 6 months later — include what the situation was, what was tried, and what the insight is.]

Tag each learning from this vocabulary (apply all that fit):
- `#debugging` — finding or fixing bugs
- `#architecture` — structural or design decisions
- `#performance` — speed, memory, or efficiency findings
- `#tooling` — IDE, CLI, build system, or workflow improvements
- `#process` — team or personal workflow insights
- `#external-api` — third-party service behavior
- `#gotcha` — surprising failure mode or footgun
- `#pattern` — reusable solution worth repeating
- `#anti-pattern` — approach that failed and why

Dual-write pattern — write learnings to BOTH:
1. The project-level learnings file (e.g., `LEARNINGS.md` at the project root). Use `templates/LEARNINGS_TEMPLATE.md` in the framework repo if the file does not exist.
2. The global learnings file (named `learnings_for_*.md` or `LEARNINGS.md`) at the framework repo root. Create it if it does not exist, using the same template.

If the user says they have no learnings to share, write a single entry: "No learnings captured this session." in both files so future sessions know the step was completed.

---

## Step 6: Git Commit

Stage all documentation files modified in Steps 1-5:
- `CLAUDE.md`
- `MEMORY.md`
- `HANDOVER.md`
- `NEXT_SESSION_PROMPT.md`
- `LEARNINGS.md`
- The global learnings file in the framework repo

Commit with the message:

```
docs: session [N] end — [1-line summary of what this session accomplished]
```

The summary should name the primary deliverable, not describe the process. Example:
- Good: `docs: session 3 end — implemented JWT refresh token rotation`
- Bad: `docs: session 3 end — updated documentation and wrapped up`

Do NOT push unless the user explicitly says "push" or "push to remote."

---

## Step 7: Context Budget Report

Report the following to the user in a brief, scannable format:

1. **Approximate context used this session:** Estimate based on conversation length, number of files read, and size of files read. Use rough order-of-magnitude (e.g., "~40% of context window").

2. **Biggest context consumers:** Name the top 2-3 items that consumed the most context tokens this session. Examples: "Reading `schema.sql` (800 lines)", "Verbose error message reproduction", "Large file written and echoed back."

3. **Recommendations for next session:** One or two specific, actionable suggestions to reduce context waste. Examples: "Use `head -n 50` before reading large files to decide if full read is needed", "Avoid re-reading CLAUDE.md after the session-start skill has already loaded it."

This report exists to make future sessions more efficient. Keep it under 10 lines.
