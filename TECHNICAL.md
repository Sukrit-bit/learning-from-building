# Technical Architecture

How the framework is structured, why each decision was made, and how to extend it. For what it does and how to get started, see [README.md](README.md).

---

## Architecture Overview

Claude Code consumes each layer differently. The directory tree below annotates how.

```
learning-from-building/
├── CLAUDE.md                        # Auto-loaded every turn (context tax)
├── frameworks/                      # Referenced on demand by skills
│   ├── FOUR_DISCIPLINES.md
│   └── SESSION_LIFECYCLE.md
├── guides/                          # Referenced on demand by skills
│   ├── CAPABILITY_MAP.md
│   └── AGENT_ORCHESTRATION.md
├── patterns/                        # Loaded conditionally by session-start
│   ├── RECURRING_BUGS.md
│   ├── ARCHITECTURE_PATTERNS.md
│   └── ANTI_PATTERNS.md
├── templates/                       # Copied into new projects (never referenced in place)
│   ├── CLAUDE_MD_TEMPLATE.md
│   ├── MEMORY_MD_TEMPLATE.md
│   ├── NEXT_SESSION_PROMPT_TEMPLATE.md
│   └── LEARNINGS_TEMPLATE.md
├── skills/                          # Symlinked to ~/.claude/skills/ for global access
│   ├── session-start/SKILL.md
│   ├── session-end/SKILL.md
│   ├── new-project/SKILL.md
│   └── feedback-loop/SKILL.md
├── install.sh                       # Creates/repairs skill symlinks
└── README.md
```

---

## Design Decisions

### Skills vs. rules

Claude Code has two instruction injection mechanisms: **rules** (`.claude/rules/` files, passive, auto-loaded every turn) and **skills** (`~/.claude/skills/` directories, invocable, zero cost when inactive). Rules are appropriate for standing constraints that must apply unconditionally. Skills are appropriate for procedural workflows triggered at specific moments.

The tradeoff: rules enforce automatically but tax every turn. Skills cost nothing when inactive but require the user to invoke them. The framework uses both -- rules for invariants like "never echo pasted content," skills for workflows like the 7-step session-end checklist.

### Symlinks vs. copies

Skills are installed by symlinking from this repo into `~/.claude/skills/`. The alternative is copying files. Copies survive repo relocation but create a synchronization problem: when a skill is improved in the source repo, every copy must be updated manually. Symlinks maintain a single source of truth -- edit the skill in the repo, every project picks up the change immediately. The cost is fragility: moving the repo breaks all symlinks. `install.sh` repairs them in one command.

### Progressive disclosure

Skills reference files which reference more files. The agent discovers context as needed rather than loading everything upfront. Example: [session-start](skills/session-start/SKILL.md) mentions [patterns/RECURRING_BUGS.md](patterns/RECURRING_BUGS.md) but only loads it if the session involves data pipelines. If the session is about documentation, that file is never loaded, saving its full token cost.

This mirrors how a developer navigates a codebase: read the entry point, follow references as needed, stop when you have enough context.

### 150-line template constraint

[CLAUDE.md](CLAUDE.md) is auto-loaded every turn. A 300-line CLAUDE.md costs roughly 3-5% of context per turn, compounding across a session. The 150-line limit halves that. Enforcement: exceeding 150 lines triggers a mandatory split into template + `.claude/rules/` reference files. This is encoded as an escalation trigger in the [CLAUDE.md template](templates/CLAUDE_MD_TEMPLATE.md) itself.

### Constraint architecture as intent encoding

Four constraint tiers (MUSTS, MUST NOTS, PREFERENCES, ESCALATION TRIGGERS) signal priority to the model. Flat instruction lists get uniform compliance -- the model treats critical invariants and nice-to-haves with roughly the same adherence rate. Tiered structure lets the model calibrate: MUSTS are non-negotiable, PREFERENCES yield to context, ESCALATION TRIGGERS define the boundary between agent autonomy and human decision-making. This structure is documented in [frameworks/FOUR_DISCIPLINES.md](frameworks/FOUR_DISCIPLINES.md).

---

## Template Design

### CLAUDE.md -- constraint architecture

The [CLAUDE.md template](templates/CLAUDE_MD_TEMPLATE.md) is structured around the four constraint types rather than free-form instructions. Universal rules are drawn from recurring failures across projects -- they earned their place by breaking things when absent. Blank slots accept project-specific additions. The constraint tiers ensure the model distinguishes between invariants and preferences without explicit priority numbers.

### MEMORY.md -- annotations and staleness

The [MEMORY.md template](templates/MEMORY_MD_TEMPLATE.md) includes HTML comment annotations above each section:

```markdown
<!-- ANNOTATION: This section is the delivery mechanism for cross-session tasks. -->
```

These are invisible in rendered Markdown but visible to Claude, which reads raw file content. They serve as inline instruction reinforcement that persists even after the skill context is unloaded.

The "Action Required" section sits at the top. This exists because handover tasks written elsewhere had no forcing function -- they competed with new session goals and lost. Placing them at the top of an auto-loaded file gives them a delivery mechanism: visible immediately, before new work begins. Template kept under 37 lines to minimize per-session token cost.

### NEXT_SESSION_PROMPT -- specification, not summary

The [NEXT_SESSION_PROMPT template](templates/NEXT_SESSION_PROMPT_TEMPLATE.md) treats handover as a specification (prescriptive), not a summary (descriptive). Each work stream includes: measurable goals, concrete steps, explicit dependencies, and binary acceptance criteria. An orchestration section maps which streams can run in parallel vs. sequentially -- without this, sessions default to sequential execution even when parallelism is available.

The self-containment rule is the most important constraint: write for a stranger with zero memory. Any reference to "the approach we discussed" is a bug. Every piece of context the next session needs must be in the document itself.

---

## Skill System

Each skill is a directory containing a SKILL.md file with YAML frontmatter (name, description, optional triggers) and Markdown instructions. Composition happens through file references -- no imports, no inheritance, no version pinning. A skill tells the agent what to do and where to find more information.

The four skills form a session lifecycle loop:

```
/session-start --> [work] --> /session-end --> NEXT_SESSION_PROMPT.md --> /session-start
```

**[/session-start](skills/session-start/SKILL.md)** loads context in cache-optimal order (CLAUDE.md first since it is already auto-loaded, then MEMORY.md for action items, then NEXT_SESSION_PROMPT.md as session spec). Proposes a parallelized execution plan and surfaces relevant bug patterns before work begins.

**[/session-end](skills/session-end/SKILL.md)** enforces a 7-step checklist: update CLAUDE.md, update MEMORY.md, create NEXT_SESSION_PROMPT.md, capture learnings (dual-write to project + global files), git commit, and report context usage. Includes an emergency mode for critically low context.

**[/new-project](skills/new-project/SKILL.md)** scaffolds a new project from templates. Asks four questions (identity, tech stack, scope, constraints), copies and fills templates, creates the directory structure, makes an initial commit.

**[/feedback-loop](skills/feedback-loop/SKILL.md)** scans the global learnings file for tags appearing 3+ times, compares against existing patterns, and recommends promotions to pattern files or template updates.

---

## Pattern System

Three files, each with a distinct purpose:

**[RECURRING_BUGS.md](patterns/RECURRING_BUGS.md)** -- Bug classes appearing 2+ times across projects. Each entry: pattern name, specific appearances, root cause analysis, prevention checklist. Threshold: a bug must have appeared at least twice to be included.

**[ARCHITECTURE_PATTERNS.md](patterns/ARCHITECTURE_PATTERNS.md)** -- Solutions validated in production. Each entry: what the pattern is, when to use it, how to implement it, which project validated it. Threshold: must have been used successfully in at least one real project.

**[ANTI_PATTERNS.md](patterns/ANTI_PATTERNS.md)** -- Approaches that look reasonable but fail. Each entry: what it looks like, why it fails, what to do instead. Every entry corresponds to a specific incident where the approach caused measurable damage.

**Extraction pipeline:** Session learnings are dual-written to project + global files. The [feedback-loop](skills/feedback-loop/SKILL.md) skill scans the global file for tags appearing 3+ times. Recurring themes are promoted from learnings entries to pattern files with full documentation. Patterns grow slowly and deliberately -- inclusion requires repeated real-world validation.

---

## Installation and Extension

### Install

```bash
git clone https://github.com/Sukrit-bit/learning-from-building.git
cd learning-from-building
chmod +x install.sh && ./install.sh
```

This symlinks every valid skill (directories under `skills/` containing a SKILL.md) into `~/.claude/skills/`. Re-run after repo relocation to repair broken symlinks.

### Add a new skill

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter and Markdown instructions.
2. Run `./install.sh` to symlink it globally.

### Add a new template

Add a Markdown file to `templates/`. Follow the 150-line constraint. Include HTML comment annotations for sections Claude will maintain -- annotations persist as inline instructions after skill context is unloaded.

### Add a new pattern

Add an entry to the appropriate file in `patterns/`. Follow the existing structure (pattern/appearances/root cause/prevention for bugs; what/when/how/validation for architecture; looks like/why it fails/alternative for anti-patterns). Must cite real project validation -- no theoretical patterns.

---

## Known Limitations

- **Symlink fragility.** Moving the repo breaks all global skill installations. The failure is silent -- skills stop appearing as slash commands with no error. Fix: re-run `install.sh`.
- **Skill shadowing.** A project-level `.claude/skills/<name>/` overrides a global `~/.claude/skills/<name>/`. Intended by Claude Code, but confusing when versions diverge.
- **No versioning.** All projects share the latest skill version via symlinks. A breaking change to a skill affects every project immediately.
- **No automated validation.** Template line counts are manually enforced. The escalation trigger in CLAUDE.md catches violations during authoring, but nothing prevents exceeding the limit outside the framework's own skills.
- **Single-user design.** No multi-user collaboration features. The framework assumes one developer working with Claude Code across multiple projects.
- **Path resolution.** Skills reference framework repo files by path. If the symlink chain is broken (repo moved, intermediate directories renamed), file references in skills resolve to nothing.
