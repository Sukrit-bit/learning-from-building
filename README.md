# Learning From Building

A meta-framework for human-AI collaboration with Claude Code -- templates, skills, patterns, and enforcement mechanisms extracted from production AI builds.

## The Problem

Human-AI collaboration at production scale has structural friction that better prompting alone cannot fix:

- **Context evaporates between sessions.** Every new session starts cold. The human re-explains architecture, constraints, and project state -- burning context window and patience.
- **The human becomes the real-time quality layer.** Without encoded constraints, the agent drifts. When a content extraction system processing 900+ items silently wastes most of its output, there was no specification telling it what "good" looked like.
- **Work stays sequential when it could parallelize.** Most sessions execute tasks one at a time, even when half the work is independent.
- **Session quality is inconsistent.** Some sessions produce clean handoffs; others end with undocumented state scattered across files.
- **Knowledge stays locked in individual projects.** When the same pipeline failure class appears for the third time across a different codebase, nobody notices because learnings were never extracted.

Building on [Nate B. Jones' Four Prompting Disciplines](https://www.youtube.com/watch?v=BpibZSMGtdY), we identified that prompting is one of four skills -- and the one that matters least as agents grow more autonomous. The other three (context engineering, intent engineering, specification engineering) are where the real output gap lives.

## The Friction Points We Addressed

| Friction Point | What We Built |
|---|---|
| Re-explaining context each session | `session-start` skill loads project docs in cache-optimal order and proposes a parallel execution plan |
| Being the real-time quality layer | Constraint architecture in CLAUDE.md -- MUSTS, MUST NOTS, PREFERENCES, ESCALATION TRIGGERS |
| Sequential work when tasks are independent | [Agent orchestration guide](guides/AGENT_ORCHESTRATION.md) + session-start proposes parallel execution by default |
| Not knowing what Claude Code can do | [Capability map](guides/CAPABILITY_MAP.md) organized by workflow stage |
| Inconsistent session quality | [Session lifecycle protocol](frameworks/SESSION_LIFECYCLE.md) enforced by session-start and session-end skills |
| Knowledge locked in individual projects | Feedback loop skill reviews cross-project learnings and promotes recurring patterns |

## What's Inside

| Category | Contents | Purpose |
|---|---|---|
| [Templates](templates/) (4) | [CLAUDE.md](templates/CLAUDE_MD_TEMPLATE.md), [MEMORY.md](templates/MEMORY_MD_TEMPLATE.md), [NEXT_SESSION_PROMPT](templates/NEXT_SESSION_PROMPT_TEMPLATE.md), [Learnings](templates/LEARNINGS_TEMPLATE.md) | Standardized project starters |
| [Frameworks](frameworks/) (2) | [Four Disciplines](frameworks/FOUR_DISCIPLINES.md), [Session Lifecycle](frameworks/SESSION_LIFECYCLE.md) | Conceptual models with practical checklists |
| [Guides](guides/) (2) | [Capability Map](guides/CAPABILITY_MAP.md), [Agent Orchestration](guides/AGENT_ORCHESTRATION.md) | What Claude Code can do, organized by workflow |
| [Patterns](patterns/) (3) | [Recurring Bugs](patterns/RECURRING_BUGS.md), [Architecture Patterns](patterns/ARCHITECTURE_PATTERNS.md), [Anti-Patterns](patterns/ANTI_PATTERNS.md) | Cross-project wisdom from production AI builds |
| Skills (4) | session-start, session-end, new-project, feedback-loop | Enforcement mechanisms, globally installed |

## How to Use It

1. **Starting a new project** -- `/new-project` scaffolds from templates, giving every project a constraint architecture and session protocol from day one.
2. **Starting any session** -- `/session-start` loads context in cache-optimal order and proposes a parallel execution plan before work begins.
3. **Ending any session** -- `/session-end` enforces a 7-step documentation checklist (update CLAUDE.md, update MEMORY.md, create handover doc, write next-session spec, capture learnings, git commit, context budget report).
4. **Every few sessions** -- `/feedback-loop` reviews learnings across projects and surfaces recurring patterns worth documenting.
5. **Capability discovery** -- [`guides/CAPABILITY_MAP.md`](guides/CAPABILITY_MAP.md) organizes what Claude Code can do by workflow stage.
6. **Before building anything complex** -- [`frameworks/FOUR_DISCIPLINES.md`](frameworks/FOUR_DISCIPLINES.md) defines where effort should go beyond prompting.

## Quick Start

```bash
git clone https://github.com/Sukrit-bit/learning-from-building.git
cd learning-from-building
chmod +x install.sh
./install.sh
```

This symlinks skills to `~/.claude/skills/` so they work in every Claude Code project. After installation, `/session-start`, `/session-end`, `/new-project`, and `/feedback-loop` are available globally. To use templates directly, copy them into a new project and adapt.

If the repo moves, re-run `install.sh` -- symlinks use absolute paths.

## Credits and Further Reading

The [Four Disciplines](frameworks/FOUR_DISCIPLINES.md) framework builds on [Nate B. Jones' work on prompting disciplines](https://www.youtube.com/watch?v=BpibZSMGtdY), extending the model to cover context, intent, and specification engineering. See [TECHNICAL.md](TECHNICAL.md) for engineering decisions behind the skill architecture, template design constraints, and pattern classification methodology.

Built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).
