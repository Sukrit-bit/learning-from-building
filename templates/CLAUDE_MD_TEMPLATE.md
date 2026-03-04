# CLAUDE.md — [Project Name]

<!-- IDENTITY: 1-2 sentences max. Answer: what is this project and who is it for?
     Be specific. Bad: "A tool that helps users." Good: "A daily email digest
     that pulls from 5 APIs and sends to a Substack list of ~200 subscribers." -->

**What this is:** [One sentence describing the project's core function and primary user/audience.]

---

## Architecture

<!-- ARCHITECTURE: Show the shape of the system. A simple diagram or component list works.
     Goal: agent should be able to orient in <30 seconds without reading code. -->

```
[Entry Point] → [Component A] → [Output/Destination]
                     ↓
               [Component B]
```

<!-- KEY FILES: List only the files an agent needs to touch regularly.
     One-line annotation per file. Skip boilerplate and config unless critical. -->

| File | Purpose |
|------|---------|
| `src/main.py` | Entry point — orchestrates the pipeline |
| `src/fetcher.py` | Pulls data from [Source A, B, C] |
| `src/formatter.py` | Transforms raw data into output format |
| `MEMORY.md` | Persistent state across sessions |
| `NEXT_SESSION_PROMPT.md` | Handover instructions from last session |

---

## Constraint Architecture

<!-- CONSTRAINT ARCHITECTURE: This is the core of CLAUDE.md. Four subsections.
     Earned from real mistakes — not aspirational guidelines. Keep it tight. -->

### MUSTS

<!-- Things the agent must always do. Add project-specific items below the universals. -->

- **Always parallelize independent tasks.** If two fetches, reads, or writes don't depend on each other, run them concurrently.
- **Always save state before long operations.** Write progress to MEMORY.md before any batch job or multi-step pipeline.
- **Always verify after aggregate/batch operations.** Check counts, spot-check samples — never assume a batch completed cleanly.
- <!-- [Project-specific MUST] e.g. "Always validate API response schema before processing" -->

### MUST NOTS

<!-- Failure modes. Structural bans beat style suggestions.
     "NEVER start with X" works better than "try to vary your approach."
     Add project-specific items below the universals. -->

- **NEVER ask questions answerable from project context.** Read MEMORY.md and this file before surfacing uncertainty.
- **NEVER process items sequentially when they are batchable.** If you are looping over a list to do the same thing to each item, parallelize.
- **NEVER read files >100 lines in the main thread.** Dispatch to a subagent. (See Context Management Rules.)
- <!-- [Project-specific MUST NOT] e.g. "NEVER send emails without a dry-run flag check" -->

### PREFERENCES

<!-- When multiple valid approaches exist, prefer these. Not hard rules — judgment calls
     that reflect this project's priorities. -->

- Prefer **programmatic verification** over manual checking (write an assertion, not an eyeball pass).
- Prefer **subagents for independent tasks** — keep the main thread for orchestration and decisions.
- <!-- [Project-specific PREFERENCE] e.g. "Prefer Markdown output over HTML for portability" -->

### ESCALATION TRIGGERS

<!-- When to STOP and ask the user instead of deciding. These are bright lines.
     Add project-specific triggers below the universals. -->

- When **>20% of a batch fails** — don't retry blindly, surface the failure pattern.
- When **an operation would permanently delete data** — always confirm, even if user seems to have authorized it.
- When **cost exceeds expected budget** (API calls, tokens, etc.) — pause and report before continuing.
- <!-- [Project-specific trigger] e.g. "When source data is >3 days stale" -->

---

## Context Management Rules

<!-- CONTEXT MANAGEMENT: Universal rules to prevent context window bloat and compaction.
     These apply to every project. Do not abbreviate or skip. -->

- **All file reads >100 lines → dispatch to subagent.** Return only the relevant excerpt or summary to the main thread.
- **Progress updates → 3 lines max.** Never verbose explanations mid-task. Save prose for session-end summaries.
- **Never echo pasted content back.** One-line confirmation only: "Got it — [topic], [N] lines."
- **When context reaches ~60% → proactively warn the user** and begin session-end process. Don't wait to be asked.
- **Strategic context from user → capture in CLAUDE.md immediately.** Don't batch it for session end — it'll be lost.

---

## Session Protocol

<!-- SESSION PROTOCOL: The ritual that makes sessions consistent and recoverable. -->

**Start of session:**
1. Read `MEMORY.md` to restore state.
2. Check `NEXT_SESSION_PROMPT.md` if it exists — follow its instructions, then archive it.
3. Propose a parallelized plan before starting work.

**During session:**
- Update todos as tasks complete (don't batch at the end).
- Capture gotchas immediately in the Key Gotchas section below — real-time, not retrospective.

**End of session (mandatory):**

Run the session-end skill. It covers:
- Update `CLAUDE.md` (this file) with new learnings and gotchas
- Update `MEMORY.md` with current state
- Write `HANDOVER.md` with what happened this session
- Write `NEXT_SESSION_PROMPT.md` with the next session's starting instructions
- Record learnings and decisions made
- Git commit with a descriptive message
- Report context budget used

<!-- Do not skip the session-end skill. A session without a handover is a session that
     cannot be recovered from. -->

---

## Key Gotchas

<!-- GOTCHAS: This section is grown, not born. Each entry is earned from a real mistake.
     Format: **Gotcha:** what happened → **Fix:** what to do instead
     Start empty. Add entries during and after sessions. -->

<!-- Example (delete when adding real entries):
**Gotcha:** Assumed API pagination was 0-indexed, got duplicate results on page 1
→ **Fix:** Always check API docs for index base before paginating; add assertion on first run.
-->

*(No gotchas yet — add as they are discovered.)*

---

## Current State

<!-- CURRENT STATE: Updated every session-end. Snapshot of where the project is.
     Three subsections only. Keep each to a few bullet points. -->

**Done:**
- [ ] *[List completed milestones — updated by session-end skill]*

**Next:**
- [ ] *[Immediate next actions — should match NEXT_SESSION_PROMPT.md]*

**Blockers:**
- *[Anything blocking progress — external dependencies, missing info, decisions needed]*
