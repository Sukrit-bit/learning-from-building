# Session Lifecycle Protocol
## The complete protocol for starting, running, and ending Claude Code sessions.

---

## Phase 1: Session Start
**(5-10 minutes)**

1. Read CLAUDE.md (auto-loaded, already cached)
2. Read MEMORY.md — check "Action Required" section first
3. Check for NEXT_SESSION_PROMPT.md — if exists, this IS the session specification
4. Check for HANDOVER.md — understand last session's state
5. Verify CLAUDE.md matches reality:
   - Are the listed tools/APIs still working?
   - Is the "Current State" section accurate?
   - Are constraint architecture rules still appropriate?
6. Propose a parallelized execution plan:
   - Which tasks are independent → dispatch as parallel agents
   - Which tasks are sequential → main thread
   - Context budget allocation: which tasks go to subagents to preserve main thread context

---

## Phase 2: Active Work
**(Bulk of session)**

### Rules
- Update todos as you work (mark in_progress → completed)
- One-line confirmations for completed operations
- Progress updates max 3 lines
- All file reads >100 lines → subagent
- Never echo pasted content back
- Capture gotchas immediately in CLAUDE.md Key Gotchas section
- When user shares strategic context → add to CLAUDE.md immediately, don't wait
- Use agent teams for independent tasks
- At ~60% context → warn user, consider starting Phase 3 early
- When encountering a new bug: check RECURRING_BUGS.md — is this a known class?

---

## Phase 3: Session End
**(10-15 minutes, mandatory)**

The 7-step checklist (enforced by session-end skill):

### Step 1: Update CLAUDE.md
- New gotchas? Add to Key Gotchas section
- "Current State" section reflects reality?
- Constants/configs changed? Update them
- Stale information? Fix or remove

### Step 2: Update MEMORY.md
- "Action Required" section current?
- Cross-session tasks captured with delivery mechanism?
- State description matches what actually happened?

### Step 3: Create/Update HANDOVER.md
- What was accomplished (specific deliverables, not vague)
- Decisions made (with rationale)
- Bugs found (classified against RECURRING_BUGS.md if applicable)
- Current blockers

### Step 4: Create NEXT_SESSION_PROMPT.md
This is a SPECIFICATION, not a summary.
- Exact current state (numbers, not prose)
- Work streams with dependencies and acceptance criteria
- Parallelization opportunities
- Context management rules for next session
- Success criteria with checkboxes

### Step 5: Capture Learnings
- What went wrong? What went right? What was surprising?
- Tag for cross-project pattern matching
- Dual-write: project-level + global file

### Step 6: Git Commit
- Stage documentation changes
- Message: `docs: session N end — [1-line summary]`

### Step 7: Context Budget Report
- How much context was used?
- What consumed the most?
- Recommendations for next session

---

## Emergency Session End
**(Context compaction imminent)**

If context is critically low, minimum viable session end:

1. **NEXT_SESSION_PROMPT.md** (most important — the next session needs this to function)
2. **MEMORY.md "Action Required" update** (delivery mechanism for cross-session tasks)
3. **Git commit**
