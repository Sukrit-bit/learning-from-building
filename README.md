# Learning From Building

A reusable operating system for working with Claude Code. Templates, skills, patterns, and frameworks distilled from 22+ real sessions across 3 AI products.

## The problem

Most people using Claude Code are operating at maybe 10% of what it can do. They write good prompts --- and stop there. But prompting is one of four disciplines, and it's the one that matters least as agents become more autonomous. The other three --- context engineering, intent engineering, specification engineering --- are where the real output gap lives. This repo is my attempt to close that gap systematically, not by theorizing about it but by extracting what actually worked across months of daily building.

## What's inside

```
learning-from-building/
├── frameworks/          Conceptual models (Four Disciplines, Session Lifecycle)
├── templates/           Starter files for new projects (CLAUDE.md, MEMORY.md, etc.)
├── guides/              Reference docs (Capability Map, Agent Orchestration)
├── patterns/            Cross-project patterns (recurring bugs, architectures, anti-patterns)
├── skills/              Claude Code slash commands (session-start, session-end, new-project, feedback-loop)
├── install.sh           Symlinks skills to ~/.claude/skills/ for global access
└── learnings_for_Sukrit_global.md   Cross-project learning log
```

**Frameworks** --- The [Four Disciplines](frameworks/FOUR_DISCIPLINES.md) model is the intellectual backbone: prompt craft is table stakes, context engineering (CLAUDE.md, MEMORY.md, .claude/rules/) is where most people plateau, intent engineering (encoding goals and trade-off hierarchies so agents work autonomously) is where the gap opens, and specification engineering (documents so complete that agents execute against them for hours without intervention) is where the ceiling is. The [Session Lifecycle](frameworks/SESSION_LIFECYCLE.md) protocol turns this into a repeatable start-work-end cadence.

**Templates** --- Battle-tested starter files: CLAUDE.md (project instructions with constraint architecture), MEMORY.md (auto-loaded session state), NEXT_SESSION_PROMPT.md (specifications for the next session, not summaries), and a learnings template. Every template is under 150 lines and grounded in real mistakes --- nothing theoretical.

**Patterns** --- Bug classes that appeared across multiple projects (status mismatches, context compaction, documentation drift, silent failures, rate limit collisions). Architecture patterns that held up under real use (fallback chains, dual-write, resume-safe scripts, dry-run, progressive disclosure). Anti-patterns documented alongside the patterns they replace, because contrast teaches faster than advice.

**Skills** --- Slash commands that install globally via symlinks. `/session-start` loads context in cache-optimal order and proposes a parallelized execution plan. `/session-end` enforces a 7-step checklist (update CLAUDE.md, update MEMORY.md, create handover doc, write next-session spec, capture learnings, git commit, context budget report). `/new-project` scaffolds from templates. `/feedback-loop` reviews cross-project learnings for patterns.

**Guides** --- A [Capability Map](guides/CAPABILITY_MAP.md) organizing everything Claude Code can do by workflow stage (starting, planning, building, reviewing, shipping, knowledge management). An [Agent Orchestration](guides/AGENT_ORCHESTRATION.md) guide covering when to dispatch subagents, how to avoid shared-resource collisions, and practical tips from building with agent teams daily.

## Quick start

```bash
git clone https://github.com/Sukrit-bit/learning-from-building.git
cd learning-from-building
chmod +x install.sh
./install.sh
```

This symlinks the skills to `~/.claude/skills/` so they're available in every Claude Code project. After installation:

- `/session-start` and `/session-end` work in any project
- `/new-project` scaffolds a new project from the templates
- `/feedback-loop` reviews your global learnings for cross-project patterns

To use the templates directly, copy them into a new project and adapt:

```bash
cp templates/CLAUDE_MD_TEMPLATE.md /path/to/new-project/CLAUDE.md
cp templates/MEMORY_MD_TEMPLATE.md /path/to/new-project/MEMORY.md
```

If the repo moves, re-run `install.sh` --- symlinks are absolute paths.

## How it works

The core idea: encode your judgment into infrastructure so agents can work autonomously instead of relying on you as a real-time quality layer.

In practice, this means:

1. **Constraint architecture in CLAUDE.md** --- MUSTS, MUST NOTS, PREFERENCES, and ESCALATION TRIGGERS. Not vague rules but specific anticipated failure modes. "Never read files >100 lines in the main thread" prevents context compaction. "Prefer shorter items first when rate-limited" prevents wasted API budget.

2. **Session lifecycle as enforcement** --- Skills run whether or not you remember. The session-end skill doesn't suggest updating docs; it walks through a 7-step checklist that produces handover docs, next-session specs, and learnings captures. Checklists scale; vigilance doesn't.

3. **Cross-project pattern matching** --- Every bug, architecture decision, and anti-pattern is tagged and logged globally. When the same bug class appears in a third project, it becomes a documented pattern with a prevention checklist. The feedback loop skill surfaces these patterns for review.

See [METHODOLOGY.md](METHODOLOGY.md) for the full intellectual framework behind these decisions.

## Where this came from

Three real AI products, built daily with Claude Code over 22+ sessions:

- **Daily Briefing Tool** --- An automated intelligence pipeline that processes 900+ content items from 8+ sources into a personalized morning email. Built the full stack: ingestion, LLM processing, email generation, GitHub Actions automation. This project generated most of the reliability patterns (fallback chains, resume-safe scripts, timeout architecture) and all of the email/HTML-specific learnings.

- **AI Impact Summit Intel** --- A conference intelligence system that discovered 1,000+ YouTube videos, swept 29 web sources, extracted 185 entities, and produced an 887-line CEO-ready report. This project drove the specification engineering framework --- the constraint architecture and acceptance criteria patterns came directly from sessions where the agent drifted without them.

- **Delhi Co-Pilot** --- A civic information tool for Delhi residents. This project contributed the scraper fallback patterns (government sites blocking cloud IPs) and the rate-limiting learnings (Gemini 429 errors from insufficient request spacing).

Every template, pattern, and skill in this repo traces back to a specific session where something broke, something worked, or something surprised me. Nothing here is theoretical.

## Further reading

- [METHODOLOGY.md](METHODOLOGY.md) --- The four disciplines framework, how the feedback loop works, and why this approach exists
- [TECHNICAL.md](TECHNICAL.md) --- Engineering decisions: skill architecture, template design constraints, pattern classification methodology

## Built with

Built with [Claude Code](https://claude.ai/code). The framework itself was constructed in a single session using parallel agent teams --- 3 subagents per phase, 4 phases, orchestrated from a main thread. The irony is intentional: the operating system for working with Claude Code was built by working with Claude Code.
