# The Four Prompting Disciplines
## A practical framework for working with AI agents. Based on Nate B. Jones' framework, adapted through production AI builds.

---

## Overview

The four disciplines are cumulative — each layer needs the ones below it. You can't do good spec engineering without good context engineering. You can't do good context engineering without good prompt craft. But most people only practice #1.

**The key insight:** In 2025, prompting was synchronous — you were the intent layer, context layer, AND quality layer simultaneously. In 2026, agents run for hours autonomously. Everything you relied on in real-time must be encoded BEFORE the agent starts.

---

## Discipline 1: Prompt Craft

**Status: Table Stakes**

### What it is
Clear instructions, relevant examples, appropriate guardrails, explicit output format, ambiguity resolution.

### Where we stand
Strong foundation. Maintain with periodic re-reads of prompting docs.

### Session Checklist
- [ ] Clear, specific instruction (not "make it good")
- [ ] Examples if the format matters
- [ ] Counter-examples if failure modes are known
- [ ] Output format specified
- [ ] Ambiguity resolution rules stated

---

## Discipline 2: Context Engineering

**Status: Getting Better**

### What it is
Curating the entire information environment the agent operates within. Your 200-token prompt is 0.02% of what the model sees. The other 99.98% is context engineering.

### Key Tools
- **CLAUDE.md** — the core context document (project conventions, constraints, gotchas)
- **MEMORY.md** — auto-loaded session state
- **`.claude/rules/`** — reference material that doesn't need to be in every prompt
- **Skills** — progressive disclosure: agents discover context through file references
- **MCP servers** — external data integration

### Where we stand
CLAUDE.md practice is established but needs standardization and pruning. MEMORY.md management is weak.

### Session Checklist
- [ ] CLAUDE.md under 300 lines and current
- [ ] MEMORY.md matches reality
- [ ] Reference material in `.claude/rules/`, not inlined
- [ ] Skills provide discoverable context paths
- [ ] No stale information in any auto-loaded document

---

## Discipline 3: Intent Engineering

**Status: Gap Area**

### What it is
Encoding goals, trade-off hierarchies, and decision boundaries so agents can work autonomously without drifting. Context engineering tells agents what to know. Intent engineering tells agents what to want.

### Warning Sign of Missing Intent Engineering
Every time you intervene — "parallelize this," "batch those," "clean up the output" — that's a specification failure. You're acting as the real-time quality layer.

### Key Components in CLAUDE.md
- **MUSTS** — non-negotiable behaviors (always parallelize, always save state, always verify)
- **MUST NOTS** — anticipated failure modes (never sequential when batchable, never read large files in main thread)
- **PREFERENCES** — decision guidance (prefer programmatic verification, prefer shorter items first when rate-limited)
- **ESCALATION TRIGGERS** — decision boundaries (when to ask vs. decide)
- **Trade-off hierarchies** — when speed and quality conflict, which wins?
- **Quality standards** — measurable, not subjective ("< 5% error rate", not "make it good")

### Session Checklist
- [ ] Trade-offs between competing goals are explicit
- [ ] Escalation triggers are defined (not everything needs human approval)
- [ ] Agent can work for 30 minutes without checking in
- [ ] Quality is defined by measurable criteria, not gut feel

---

## Discipline 4: Specification Engineering

**Status: Biggest Gap**

### What it is
Writing documents so complete that autonomous agents can execute against them for extended time horizons without human intervention. Not about individual prompts — about your entire organizational document corpus being agent-readable.

### The Shift
From "fixing it in real time" to "getting the spec right up front." Real-time prompting rewards verbal fluency. Specification engineering rewards completeness of thinking and anticipation of edge cases.

### Our Existing Spec Engineering
- **NEXT_SESSION_PROMPT.md** — IS spec engineering in practice (our best example)
- **REPORT_SPEC.md** — measurable acceptance criteria + evaluation checklist
- **CLAUDE.md** — the standing specification for every session

### Five Primitives

**1. Self-contained problem statements**

Include ALL context. The agent receiving this has never seen your project.

> "Update the dashboard" → "Update the dashboard at `src/components/Dashboard.tsx` to show Q3 revenue from the `analytics_db.quarterly_revenue` table, filtered to region='APAC', displayed as a bar chart with the same styling as the Q2 chart at line 142"

**2. Acceptance criteria**

3+ sentences an independent observer could use to verify the output without asking questions.

> "CEO-shareable" is unmeasurable. "350-500 lines, zero duplicates (verified by `python -m src.cli verify`), source attribution on every entity" is measurable.

**3. Constraint architecture**

MUSTS / MUST NOTS / PREFERENCES / ESCALATION TRIGGERS. Write down what a smart, well-intentioned person might do that technically satisfies the request but produces the wrong outcome. Those failure modes become your constraints.

**4. Decomposition**

Break into subtasks that each take <2 hours, have clear input/output boundaries, and can be verified independently. This is the granularity at which agents work best.

**5. Evaluation design**

How do you PROVE the output is good? Not "does it look reasonable" but "can you prove measurably, consistently that this is correct." Build 3-5 test cases with known good outputs.

### Session Checklist
- [ ] Could someone else (or next session Claude) execute this spec without asking you anything?
- [ ] Acceptance criteria are measurable with commands or observable outcomes
- [ ] Decomposition is granular enough (<2 hour subtasks)
- [ ] Evaluation method is defined (how to prove it's good)
- [ ] Edge cases are anticipated (what could go subtly wrong?)

---

## The Stack Visualization

```
┌─────────────────────────────────────────┐
│  Specification Engineering              │ ← Documents agents execute against
│  "What does done look like?"            │    for hours/days autonomously
├─────────────────────────────────────────┤
│  Intent Engineering                     │ ← Goals, trade-offs, decision
│  "What should the agent want?"          │    boundaries encoded as constraints
├─────────────────────────────────────────┤
│  Context Engineering                    │ ← CLAUDE.md, MEMORY.md, skills,
│  "What does the agent need to know?"    │    .claude/rules/, MCP servers
├─────────────────────────────────────────┤
│  Prompt Craft                           │ ← Clear instructions, examples,
│  "How do I ask clearly?"               │    guardrails, output format
└─────────────────────────────────────────┘
    ↑ Each layer needs the ones below it
```
