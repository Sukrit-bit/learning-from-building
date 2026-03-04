---
name: feedback-loop
description: "Cross-project learning review. Analyzes global learnings file for recurring patterns, suggests template improvements, and identifies new bug classes. Run every 3 sessions or when requested."
---

> **Path resolution:** This skill is part of the learning-from-building framework. The framework repo root is two directories up from this skill's base directory. All file references below are relative to the framework repo root.

## Step 1: Read Global Learnings

- Read the global learnings file at the framework repo root (named `learnings_for_*.md` or `LEARNINGS.md`)
- Also read any project-level learnings files that exist in active projects

## Step 2: Pattern Analysis

- Group learnings by tags
- Identify recurring themes:
  - Tags that appear 3+ times → potential new pattern or bug class
  - Tags that appear across multiple projects → cross-project patterns
  - Learnings with similar root causes → structural issues
- Compare against existing patterns in `patterns/RECURRING_BUGS.md` in the framework repo
  - Are there new bug classes not yet documented?
  - Have existing bug classes recurred since being documented?

## Step 3: Template Assessment

- For each recurring pattern found:
  - Should a prevention rule be added to `CLAUDE_MD_TEMPLATE.md`?
  - Should a new entry be added to `RECURRING_BUGS.md` or `ARCHITECTURE_PATTERNS.md`?
  - Should an existing template section be modified?
- Check: Is the CLAUDE_MD_TEMPLATE still under 150 lines? If not, what can be moved to `.claude/rules/`?

## Step 4: Report & Recommendations

Present findings to the user:

```
## Feedback Loop Report — [Date]

### Recurring Patterns Found
- [Pattern]: appeared [N] times across [projects]
  - Recommendation: [add to template / add to bug patterns / no action]

### Template Health
- CLAUDE_MD_TEMPLATE: [line count] lines ([OK / needs pruning])
- New items recommended for addition: [list]
- Items recommended for removal/move: [list]

### Bug Pattern Updates
- [New bug class]: [description, which sessions it appeared in]
- [Existing bug class recurrence]: [details]

### Framework Gaps
- [Any areas where the framework doesn't have guidance but should]
```

## Step 5: Apply Changes (with user approval)

- For each recommended change, ask the user for approval using AskUserQuestion
- Apply approved changes to templates, patterns, and guides
- Git commit: `docs: feedback-loop — [1-line summary of changes]`

---

**Key principle:** This skill IS the feedback loop. Without it, learnings are captured but never reviewed systematically. Schedule it every 3 sessions or at the start of a new project.
