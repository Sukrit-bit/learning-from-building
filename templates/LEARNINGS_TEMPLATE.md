# Learnings Entry Template

## Format

```
## [Date] — [Project Name] — [Session Summary Title]

**What happened:** [1-2 sentence summary of what was done]

**Key learnings:**
- **[Learning title]:** [Explanation with enough context that someone reading 6 months later understands]

**Tags:** [comma-separated tags for cross-project pattern matching]
```

---

## What Makes a GOOD Learning Entry

**Good entries are:**
- **Specific** — name the exact function, API, pattern, or failure mode involved
- **Causal** — explain the "why": what broke, what assumption was wrong, what the fix revealed
- **Failure-grounded** — cite the failure mode that taught it ("discovered when X silently returned 200 but...")
- **Transferable** — a dev on a different project should be able to apply it without knowing your codebase

**Bad entries are:**
- **Vague** — "improved the code", "fixed a bug", "refactored for clarity"
- **Project-specific without insight** — "our pipeline uses step 3 before step 4" (no transferable lesson)
- **Obvious** — "always test your code", "read the docs" (no failure mode, no earned wisdom)

### Example: Bad vs. Good

Bad:
> - **API issues:** Had some problems with the YouTube API and fixed them.

Good:
> - **YouTube quota errors are silent in batch mode:** The Data API v3 returns HTTP 200 with an empty `items` array when quota is exhausted during a batch call — it does not raise an exception. Always check `len(items) == 0` and cross-reference quota dashboard before assuming the video genuinely has no results.

---

## Dual-Write Pattern

Each learning lives in two places:

1. **Project-level file** (`/path/to/project/LEARNINGS.md`) — full detail, full context, verbatim notes
2. **Global file** (`~/path/to/global/LEARNINGS.md`) — condensed 1-2 line version with tags for cross-project search

When writing a session entry, write the full version first, then distill it into the global file. The global file is for pattern-matching across projects; the project file is the source of truth.

---

## Standard Tag Vocabulary

Use these tags consistently to enable cross-project pattern matching.

### Bug Classes
`debugging`, `silent-failures`, `status-mismatch`, `documentation-drift`, `context-compaction`

### Architecture
`pipeline-architecture`, `fallback-patterns`, `defense-in-depth`, `resume-safety`, `dry-run-pattern`

### Process
`session-management`, `knowledge-management`, `process-hygiene`, `meta-engineering`, `checklists`

### LLM
`LLM`, `prompt-engineering`, `specification-engineering`, `context-engineering`, `intent-engineering`

### APIs
`API-rate-limiting`, `API-gotcha`, `SDK-migration`, `YouTube-API`, `OpenAI-API`

### Tools
`claude-code`, `git`, `git-worktrees`, `parallel-agents`, `subagent-driven-development`

### Product
`user-feedback`, `information-architecture`, `product-design`, `visual-hierarchy`
