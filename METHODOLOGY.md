# Methodology

How this framework was built, and the thinking behind it. Read [README.md](README.md) for what this project is, or [TECHNICAL.md](TECHNICAL.md) for engineering decisions about skill design and template structure.

---

## The Problem

Most people use Claude Code the way they used GitHub Copilot: type a prompt, get a response, fix the response, type another prompt. It works. It also leaves about 90% of the tool's capability on the table.

The gap isn't technical skill. It's that human-AI collaboration has specific, recurring friction points that nobody has mapped systematically. I kept hitting the same problems across three different projects:

- **Context evaporates between sessions.** Claude has no memory. Every new session starts from zero. I'd spend the first 20 minutes of each session re-explaining decisions that were already made, constraints that were already discovered, and bugs that were already fixed. That's not collaboration, that's repetitive onboarding.

- **Intent drifts during execution.** I'd ask for a bulk data pipeline and get back a working pipeline that processed items sequentially instead of in parallel, used a single API provider with no fallback, and logged verbose success messages that consumed the context window. Technically correct. Not what I wanted. But I'd never specified what I wanted beyond "build the pipeline."

- **The same bugs kept appearing.** Status mismatches between pipeline stages. Rate limit collisions when parallel streams share API quotas. Context window exhaustion from reading large files in the main thread. Each bug felt novel in the moment. Looking across projects, they were the same three or four failure classes repeating in different costumes.

- **Knowledge stayed locked in individual projects.** Session 4 of the Daily Briefing Tool discovered that batch failure statuses are unreliable and should always be retried individually. Session 3 of the AI Summit project rediscovered the same thing independently, because there was no mechanism to carry that learning across projects.

These aren't edge cases. They're structural problems with how humans and AI agents collaborate. This framework is an attempt to solve them.

---

## The Four Disciplines

The intellectual backbone of this framework comes from Nate B. Jones' observation that working effectively with AI agents requires four distinct skills, not one. Most people only practice the first.

### 1. Prompt Craft (the floor, not the ceiling)

Clear instructions, relevant examples, explicit output format, guardrails against known failure modes. This is where almost everyone stops. It's necessary but not sufficient.

In practice, a well-crafted prompt controls maybe 0.02% of what the model actually sees. The other 99.98% is everything else in the context window: system prompts, file contents, conversation history, tool definitions. Prompt craft is the visible part of the iceberg.

**What this looks like in practice:** When building the AI Summit Intel system, a prompt like "extract entities from this transcript" produced output. But specifying "extract entities, deduplicate against existing entities in the database, flag confidence below 0.7 for human review, and format as JSON matching the schema in `entity_schema.json`" produced *useful* output. The difference is specificity, not cleverness.

### 2. Context Engineering (the 99.98%)

Curating the entire information environment the agent operates within. This is where CLAUDE.md lives: project conventions, constraints, gotchas, the current state of the codebase, what tools are available, what's already been tried and failed.

The key insight is that context isn't just "background information." It's the operating system for the session. A CLAUDE.md that says "Gemini is the primary LLM provider" when the project switched to GPT-4o three sessions ago doesn't just fail to help; it actively misdirects. Stale context is worse than no context.

**What this looks like in practice:** The Daily Briefing Tool's CLAUDE.md grew to include a "Key Gotchas" section after Session 4 discovered that PyMuPDF (`fitz`) was available on the machine but `poppler`/`pdftotext` was not. Without that note, every future session would have wasted 10 minutes rediscovering the same environment constraint. With it, zero sessions did.

### 3. Intent Engineering (telling the agent what to *want*)

Context engineering tells the agent what to know. Intent engineering tells the agent what to want. It's the difference between providing a map and providing a destination.

This is where constraint architecture lives: MUSTS (non-negotiable behaviors), MUST NOTS (anticipated failure modes), PREFERENCES (decision guidance when multiple approaches are valid), and ESCALATION TRIGGERS (when to ask the human instead of deciding autonomously).

**What this looks like in practice:** In the Delhi Co-Pilot project, the CLAUDE.md included "MUST: prefer cached data over live scraping when target sites are government domains." This single constraint prevented a recurring failure where Indian government sites blocked cloud provider IP ranges. Without it, the agent would attempt live scraping, fail silently, and produce empty results. The constraint encoded a decision that had already been made, so the agent didn't have to rediscover it.

Every time you intervene mid-session to correct the agent's approach, that's a signal that intent wasn't encoded upfront. "Parallelize this" means the spec didn't say to parallelize. "Don't read that whole file" means the spec didn't set context budget rules. The interventions are the diagnostic — they tell you exactly which intent is missing.

### 4. Specification Engineering (writing for autonomous execution)

Documents so complete that agents can execute against them for hours without human intervention. Not individual prompts, but your entire document corpus being agent-readable.

This is the biggest gap for most Claude Code users and was the biggest gap in my own practice. The shift is from "fixing it in real time" to "getting the spec right up front." Real-time prompting rewards verbal fluency. Specification engineering rewards completeness of thinking.

**What this looks like in practice:** The AI Summit project's `REPORT_SPEC.md` included measurable acceptance criteria: "350-500 lines, zero duplicates verified by `python -m src.cli verify`, source attribution on every entity." A session could execute against that spec, produce a report, and I could verify it met the bar without reading the entire output. Compare that to "make a good report" — which requires me to read everything, apply subjective judgment, and iterate.

The five primitives of specification engineering: self-contained problem statements (include ALL context; the receiving agent has never seen your project), acceptance criteria (3+ sentences an independent observer could verify without asking questions), constraint architecture (MUSTS / MUST NOTS / PREFERENCES / ESCALATION TRIGGERS), decomposition (subtasks under 2 hours with clear input/output boundaries), and evaluation design (how do you PROVE the output is correct, not just reasonable-looking).

---

## Session Lifecycle

A single session has three phases. This structure isn't arbitrary — each phase addresses a specific failure mode.

### Phase 1: Start (5-10 minutes)

Read CLAUDE.md and MEMORY.md. Check for a NEXT_SESSION_PROMPT.md (if the previous session wrote one, that IS the session specification). Verify that documentation matches reality. Propose a parallelized execution plan — which tasks are independent and can be dispatched to subagents, which tasks are sequential and stay on the main thread.

**Why this matters:** Without a structured start, the first 20-30 minutes of every session are spent rediscovering project state. The start protocol compresses that to 5-10 minutes by front-loading context verification.

### Phase 2: Active Work (bulk of session)

Execute against the plan with specific rules: one-line confirmations for completed operations, all file reads over 100 lines delegated to subagents, progress updates capped at 3 lines, gotchas captured immediately in CLAUDE.md rather than deferred to session end. At 60% context consumed, warn the user and restructure remaining work into subagents.

**Why these specific rules:** Every rule here exists because its absence caused a problem. The "no file reads over 100 lines in main thread" rule exists because two consecutive AI Summit sessions hit context exhaustion from large file reads — the second session hit the same wall because no prevention was applied after the first. The "60% context warning" exists because context compaction is irreversible and loses information.

### Phase 3: End (10-15 minutes, mandatory)

A 7-step checklist enforced by a skill, not by willpower:

1. Update CLAUDE.md (new gotchas, current state)
2. Update MEMORY.md (action items, cross-session tasks)
3. Create HANDOVER.md (what was accomplished, decisions made, bugs found)
4. Create NEXT_SESSION_PROMPT.md (a specification for the next session, not a summary of this one)
5. Capture learnings (dual-write to project file AND global cross-project file)
6. Git commit
7. Context budget report

**Why mandatory:** Because session ends are where documentation drift originates. "I'll update MEMORY.md later" means it won't get updated. The session-end skill makes the important thing the automatic thing. Vigilance is depletable; checklists are not.

The most valuable artifact from a session end is NEXT_SESSION_PROMPT.md. If the current session writes a good spec for the next session, the next session starts with a clear execution plan instead of a discovery phase. This compounds: each session's end invests in the next session's start.

---

## Pattern Recognition Across Projects

Three projects. 22+ sessions. Enough repetition to see what keeps happening.

### Bug Classes That Cross Project Boundaries

Some bugs look different on the surface but share a root cause. Cataloging them means the third occurrence can be prevented, not just fixed.

**Status Mismatch** appeared 3 times across 2 projects. The pattern: pipeline stages communicate via status fields in a database, and different stages write different values for the same logical state. In the Daily Briefing Tool, ingestion wrote `pending` while downstream queried for `no_transcript` — items fell through the cracks. In the AI Summit project, the same category of failure appeared twice more with different status values. The root cause was always the same: an implicit state machine with no documented state diagram.

**Context Compaction** appeared in 2 consecutive AI Summit sessions. Large file reads in the main thread consumed irreplaceable context budget, forcing early session close before the actual work was complete. The second session hit the identical wall because no prevention had been encoded after the first.

**Silent Failures** appeared across 2 projects. Operations succeed at the API level but produce empty results, and the code doesn't distinguish "no data exists" from "failed to fetch." In the Daily Briefing Tool, this produced a 73% transcript waste rate — 28 out of 80 items had no transcripts, but the fetch returned success with empty content.

### Architecture Patterns That Proved Their Value

**Fallback Chains:** Primary provider, secondary provider, tertiary provider for any unreliable external service. In the AI Summit project, all 200+ content extractions succeeded because Gemini, OpenAI, and a local model formed a chain — no single provider failure killed the batch.

**Resume-Safe Scripts:** Atomic per-item commits to persistent storage so interrupted runs pick up where they stopped. In the Daily Briefing Tool, 868 items were processed over multiple interrupted runs. Any interruption lost at most 1 item — the one currently in flight — never the entire batch.

**State Machine Documentation:** Every status field used for pipeline coordination gets an explicit state diagram before any code is written. This pattern exists because status mismatch bugs appeared 3 times. Making the state machine explicit eliminates the entire category.

### Anti-Patterns That Look Reasonable Until They Don't

**Reading large files in the main thread** — looks harmless, but a 500-line file can consume 10-15% of the context window. Three large files effectively end the session before the work begins.

**Verbose explanations before doing work** — "I'm going to start by reading the schema, then parse the values, then trace the pipeline..." This narration consumes context without producing output. Report results, not plans.

**Fixed taxonomy when heuristics spiral** — writing increasingly complex keyword-matching rules until the rule set becomes unmaintainable. When the rules get that complex, the taxonomy is wrong. Let the LLM generate dynamic tags from the content directly.

---

## The Feedback Loop

The framework improves itself. Here's how.

### Dual-Write Architecture

Every session generates learnings. Those learnings go to two places simultaneously: the project-specific learnings file (full detail) and a global cross-project file (condensed, universally applicable). The global write happens at the same moment as the project write — never deferred to "later," because deferred writes don't happen.

This means the global file is always current. When starting a new project, the accumulated experience from all previous projects is available in one file.

### Pattern Promotion

A bug that appears once is a bug. A bug that appears across two projects is a pattern. A pattern gets promoted to the cross-project bug classes file with a prevention checklist. The session-start protocol includes checking that file, so future sessions can prevent known failure classes before they occur.

The same promotion logic applies to architecture patterns and anti-patterns. The threshold is simple: if it worked (or failed) across two or more projects, it's a pattern worth documenting.

### Skills as Encoded Process

The session-end checklist isn't a document someone reads — it's a skill that executes. The skill runs the same 7 steps every time, regardless of how tired the human is or how much context pressure the session is under. This is the mechanism that prevents the most common failure mode: skipping documentation updates at session end because something else felt more urgent.

Skills are installed globally via symlinks, so they're available across all projects. They reference files rather than inlining content (progressive disclosure), so they stay small and adaptable.

### The Compounding Effect

Session 1 of a new project benefits from everything learned across all previous projects. The CLAUDE.md template includes constraint architecture because that structure proved essential across three projects. The session-start skill checks for stale documentation because documentation drift was the most consistent silent failure. The patterns files flag known bug classes before they recur.

Each session is slightly better than the last — not because of any single improvement, but because the feedback loop captures, condenses, and makes available the small lessons that would otherwise evaporate between sessions.

---

## What This Is and What It Isn't

This is a builder's methodology, developed across three real projects over 22+ sessions. Every component exists because its absence caused a specific, identifiable problem. Nothing here is theoretical.

It's not a rigid process. The templates, skills, and patterns are starting points — they get adapted for each project. The four disciplines are a thinking framework, not a compliance checklist.

It's also not finished. The framework is designed to grow as new projects reveal new patterns, new bug classes, and new anti-patterns. The feedback loop is the whole point.

For the full list of what's in this repo, see [README.md](README.md). For engineering decisions about how the components are structured, see [TECHNICAL.md](TECHNICAL.md).
