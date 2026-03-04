# Session [N+1] Specification
<!-- ANNOTATION: This is specification engineering, not a conversation. -->
<!-- The next Claude session has ZERO memory of this session — write for a stranger. -->
<!-- A great prompt lets the next session start executing in its first message. -->
<!-- Self-contained rule: include ALL context needed here. -->
<!-- Do not reference external docs without quoting the key parts inline. -->

## Current State
<!-- ANNOTATION: Exact state with numbers, not prose. Leave nothing to inference. -->
- **[Metric]:** [Value]
- **Complete:** [Specific items finished — be exact, not approximate]
- **Remaining:** [Specific items not yet done — be exact]
- **Blockers:** [Anything that will stop progress if not addressed first]

## Work Streams
<!-- ANNOTATION: Each stream must be independently executable by a subagent. -->
<!-- Mark dependencies explicitly. Ambiguous dependencies cost a full round-trip. -->

### Stream 1: [Name]
- **Goal:** [Measurable outcome — not "improve X" but "X passes N tests"]
- **Steps:**
  1. [Specific step]
  2. [Specific step]
  3. [Specific step]
- **Depends on:** [nothing / Stream N completing first]
- **Acceptance criteria:** [Verifiable by a command or observable output, not gut feel]

### Stream 2: [Name]
- **Goal:** [Measurable outcome]
- **Steps:**
  1. [Specific step]
  2. [Specific step]
- **Depends on:** [nothing / Stream N completing first]
- **Acceptance criteria:** [Verifiable by a command or observable output]

### Stream 3: [Name]
- **Goal:** [Measurable outcome]
- **Steps:**
  1. [Specific step]
  2. [Specific step]
- **Depends on:** [nothing / Stream N completing first]
- **Acceptance criteria:** [Verifiable by a command or observable output]

## Orchestration
<!-- ANNOTATION: Explicit parallelism plan. This is where context is saved or wasted. -->
<!-- Streams that share no outputs can run simultaneously via subagents. -->
<!-- Rate limits and shared resources create forced sequencing — call that out here. -->
- **Parallel group A:** [Streams that can run together — e.g., Stream 1 + Stream 2]
- **Sequential after A:** [Streams that depend on A's outputs — e.g., Stream 3]
- **Rate limit notes:** [e.g., API X allows N calls/min — batch accordingly]

## Context Management Rules
<!-- ANNOTATION: Carry forward standing rules from CLAUDE.md plus session-specific rules. -->
<!-- Session-specific rules = lessons from what burned context in the previous session. -->
1. All reads over 100 lines use a subagent
2. One-line confirmations for saves
3. Progress updates max 3 lines
4. [Session-specific rule — e.g., "Do not re-read file Y; it is unchanged from last session"]
5. [Session-specific rule — e.g., "API Z returns paginated results; always fetch all pages before processing"]

## Success Criteria
<!-- ANNOTATION: The next session checks these off as work completes. -->
<!-- Each criterion must be verifiable by running a command or observing a concrete output. -->
<!-- "It works" is not a criterion. "curl X returns HTTP 200 with field Y" is. -->
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

## Stretch Goals
<!-- ANNOTATION: Only attempt these if all success criteria above are checked off. -->
<!-- Do not let stretch goals crowd out core criteria. -->
- [ ] [Nice-to-have 1]
- [ ] [Nice-to-have 2]
