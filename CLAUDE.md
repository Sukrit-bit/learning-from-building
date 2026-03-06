# Claude Operating System

## Identity

Meta-framework for human-AI collaboration with Claude Code. Contains templates, skills, patterns, guides, and frameworks that raise the floor for every new project. Not a product — infrastructure for products.

## Architecture

```
claude-operating-system/
├── frameworks/     Conceptual models (Four Disciplines, Session Lifecycle)
├── templates/      Starter files for new projects (CLAUDE.md, MEMORY.md, etc.)
├── guides/         Reference material (Capability Map, Agent Orchestration)
├── patterns/       Cross-project patterns (recurring bugs, architectures, anti-patterns)
├── skills/         Claude Code slash commands — globally installed via install.sh
├── hooks/          PostToolUse + PreCompact hooks — sensor layer for context monitoring
├── private/        Non-public docs (gitignored)
└── install.sh      Installs skills, hooks, and hook config globally
```

**How Claude Code consumes each layer:**
- **Auto-loaded every turn:** CLAUDE.md (kept under 150 lines)
- **Referenced on demand by skills:** frameworks/, guides/, patterns/
- **Copied into new projects:** templates/
- **Symlinked for global access:** skills/ → ~/.claude/skills/

## Constraint Architecture

### MUSTS
- Templates under 150 lines — context budget, not aesthetics
- Patterns cite real project experience — no theoretical entries
- Skills must be testable on this repo before use elsewhere
- No hardcoded absolute paths in any committed file

### MUST NOTS
- No theoretical patterns without production validation
- No product-specific references in public documentation
- No skills too rigid to adapt across project types

### PREFERENCES
- Checklists over prose (checklists scale, vigilance doesn't)
- Anti-pattern alongside pattern (contrast teaches)
- Progressive disclosure in skills (reference files, don't inline)

### ESCALATION TRIGGERS
- Template exceeds 150 lines → stop and split into template + .claude/rules/
- Skill instructions ambiguous enough to produce different behaviors → clarify before shipping

## Context Management Rules

- Documentation-heavy project — use subagents for parallel file creation
- Keep main thread for orchestration, dispatch agents for content creation
- **Auto-session-close:** PostToolUse + PreCompact hooks (`~/.claude/hooks/`) provide accurate tool call counting. `.claude/rules/context-monitor.md` defines the policy — heads-up at 30, auto-close at 50, Emergency Mode on compaction.

## Session Protocol

- **Start:** Run `/session-start` — loads context, proposes parallel execution plan
- **During:** Track progress via TodoWrite
- **End:** Run `/session-end` — mandatory 7-step checklist

## Available Skills

- `/session-start` — Session startup protocol
- `/session-end` — End-of-session documentation checklist
- `/new-project` — Bootstrap new project from templates
- `/feedback-loop` — Cross-project learning review
- `/learnings` — Dual-write learnings (project + global markdown) + generate HTML dashboard
- `/visualize-learnings` — Generate Learning Studio: concept-first dashboard with Mermaid diagrams, deep dives, retrieval practice, bug museum, principles wall

## Key References

- `frameworks/` — Four Prompting Disciplines, Session Lifecycle
- `guides/` — Capability Map, Agent Orchestration
- `patterns/` — Recurring Bugs, Architecture Patterns, Anti-Patterns
- `templates/` — CLAUDE.md, MEMORY.md, NEXT_SESSION_PROMPT, Learnings
