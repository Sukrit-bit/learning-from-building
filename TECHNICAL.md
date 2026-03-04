# Technical Architecture

This document covers the engineering decisions behind learning-from-building: why things are structured the way they are, what alternatives were considered, and where the tradeoffs lie. Written for Claude Code power users, engineers evaluating the framework, and anyone who wants to understand or extend the system.

For what the framework does and how to get started, see [README.md](README.md). For the methodology and intellectual framework behind it, see [METHODOLOGY.md](METHODOLOGY.md).

---

## Architecture Overview

```
learning-from-building/
├── frameworks/        Conceptual models (session lifecycle, four disciplines)
├── templates/         Starter files for new projects (CLAUDE.md, MEMORY.md, etc.)
├── guides/            Reference material (agent orchestration, capability map)
├── patterns/          Cross-project patterns extracted from real failures
├── skills/            Claude Code slash commands (session-start, session-end, etc.)
├── private/           Gitignored docs (voice guidelines, strategic context)
├── install.sh         Symlinks skills to ~/.claude/skills/ for global access
└── learnings_for_Sukrit_global.md   Cross-project learning log
```

Each directory has a distinct role in how Claude Code consumes the content:

- **frameworks/** and **guides/** are referenced by skills via file paths. They are never auto-loaded. An agent reads them only when a skill explicitly points to them, keeping them out of the context window until needed.
- **templates/** are copied, not referenced. The `/new-project` skill copies a template into a target project and fills in project-specific details. The template in this repo stays pristine.
- **patterns/** are checked against during work. The session-start skill reads the relevant pattern files based on what the session involves (data pipelines trigger status-mismatch checks, API work triggers rate-limit checks).
- **skills/** are symlinked to `~/.claude/skills/` and become available as slash commands in any project on the machine.

---

## Design Decisions

### Skills over `.claude/rules/`

Claude Code has two mechanisms for injecting instructions: **rules** (passive, auto-loaded every turn) and **skills** (invocable, triggered by the user or by name).

Rules are a tax on every interaction. Every rule file in `.claude/rules/` is loaded into the context window on every turn, whether it is relevant or not. For standing constraints like "never echo pasted content back," this is the right mechanism -- the instruction must be present unconditionally. But for procedural workflows like "run the 7-step session-end checklist," loading those instructions on every turn wastes context budget on turns where the workflow is not active.

Skills solve this. A skill is loaded only when invoked. The user types `/session-end` and the skill's SKILL.md is injected into context for that interaction. On every other turn, it costs zero tokens.

Skills are also composable in a way rules are not. The session-end skill references the NEXT_SESSION_PROMPT template, which references the session lifecycle framework. Each layer is loaded only when needed, forming a chain of progressive disclosure rather than a monolithic instruction set.

The tradeoff: skills require the user to remember to invoke them. A rule enforces behavior automatically; a skill enforces it only when called. This is why the framework uses both -- rules for standing constraints that must always apply, skills for procedural workflows that are triggered at specific moments.

### Symlinks over copies

Skills are installed by symlinking from this repo into `~/.claude/skills/`:

```bash
ln -s /path/to/learning-from-building/skills/session-end/ ~/.claude/skills/session-end
```

The alternative was copying skill files into `~/.claude/skills/`. Copies have one advantage: they survive if the source repo moves or is deleted. But copies create a synchronization problem. When a skill is improved in the source repo, every copy must be updated manually. With 4 skills across potentially many machines, copy drift is inevitable.

Symlinks maintain a single source of truth. Edit the skill in the repo, and every project on that machine picks up the change immediately. The cost is fragility: if the repo moves, all symlinks break. This is why `install.sh` exists -- re-running it after a repo relocation repairs all symlinks in one command.

The `install.sh` script is intentionally minimal. It iterates over directories in `skills/`, checks for a `SKILL.md` file (the marker that a directory is a valid skill), removes any existing symlink or directory at the target, and creates a fresh symlink. It does not modify any skills that were installed from other sources -- only skills with matching names are overwritten.

### Progressive disclosure

Skills reference files which reference more files. An agent discovers context as it needs it rather than loading everything upfront.

Consider the session-start skill. Its SKILL.md contains the 5-step startup protocol. Step 4 says: "Reference `/path/to/patterns/RECURRING_BUGS.md` if the session involves data pipelines." The agent reads RECURRING_BUGS.md only if the session actually involves data pipelines. If the session is about documentation, that file is never loaded, saving its entire token cost.

This mirrors how a developer navigates a codebase: you read the entry point, follow references as needed, and stop when you have enough context. The alternative -- inlining all reference material into the skill itself -- would produce multi-hundred-line SKILL.md files that consume significant context on every invocation, whether or not most of the content is relevant.

The pattern also means skills stay short. The longest skill in this framework (session-end) is around 210 lines. Without progressive disclosure, it would need to inline the NEXT_SESSION_PROMPT template, the MEMORY_MD template, the learnings template, and the session lifecycle framework -- easily 500+ lines.

### Template constraints: the 150-line rule

Every template in this framework must stay under 150 lines. This is not aesthetic minimalism; it is a context budget constraint.

CLAUDE.md is auto-loaded by Claude Code on every turn. A 300-line CLAUDE.md consumes roughly 3-5% of the context window per turn, compounding across a full session. A 150-line CLAUDE.md halves that cost. Over a 40-turn session, the savings add up to the equivalent of several large file reads.

The enforcement mechanism: if a template exceeds 150 lines during authoring, it must be split. The template keeps the essentials (identity, architecture, constraints, session protocol), and overflow content moves to `.claude/rules/` files that are loaded conditionally. The CLAUDE.md template is currently 150 lines -- right at the limit.

---

## Template Design

### CLAUDE.md: Constraint Architecture

The CLAUDE.md template is structured around four constraint types rather than free-form instructions:

1. **MUSTS** -- invariant behaviors that apply every turn
2. **MUST NOTS** -- structural bans on known failure modes
3. **PREFERENCES** -- judgment calls when multiple valid approaches exist
4. **ESCALATION TRIGGERS** -- bright lines where the agent must stop and ask

This structure exists because flat instruction lists produce inconsistent behavior. When an LLM receives 30 undifferentiated instructions, it treats them as roughly equal in priority. It might follow a critical invariant 95% of the time and a nice-to-have preference 95% of the time -- same compliance rate for vastly different stakes.

The four-tier structure signals priority. MUSTS and MUST NOTS are non-negotiable. PREFERENCES are default behaviors that can be overridden by context. ESCALATION TRIGGERS define the boundary between agent autonomy and human decision-making. An LLM can calibrate its behavior differently across these tiers in a way it cannot when all instructions are presented at the same level.

The template ships with universal rules (parallelize independent tasks, never echo pasted content, delegate large file reads) and blank slots for project-specific additions. The universal rules are drawn from recurring failures across three projects -- they earned their place by breaking things when absent.

### MEMORY.md: Annotations and Staleness

The MEMORY.md template includes HTML comments (annotations) above every section explaining why that section exists and what failure mode it prevents:

```markdown
<!-- ANNOTATION: This section is the delivery mechanism for cross-session tasks. -->
<!-- Handover docs don't get acted on because they have no delivery mechanism. -->
```

These annotations are invisible to humans reading the rendered Markdown but visible to Claude, which reads raw file content. They serve as inline instruction reinforcement: even if the agent has lost the original SKILL.md context, the annotations in MEMORY.md itself explain what each section is for and how to maintain it.

The "Action Required" section at the top of MEMORY.md exists because of a specific failure pattern. Across multiple projects, tasks written in handover documents were never completed. The handover doc was read at session start, but its tasks had no forcing function -- they competed with whatever the new session's goals were and lost. Placing action items at the top of an auto-loaded file (MEMORY.md is read every session by the session-start skill) gives them a delivery mechanism: they are visible immediately, before any new work begins.

The template is kept under 37 lines. MEMORY.md is read every session start. Every line costs tokens across every session for the lifetime of the project.

### NEXT_SESSION_PROMPT: Specification Engineering

The NEXT_SESSION_PROMPT template treats the handover as a specification, not a summary. The distinction matters: a summary describes what happened; a specification prescribes what should happen next.

Each work stream includes:
- A measurable goal (not "improve X" but "X passes N tests")
- Concrete steps
- Explicit dependencies between streams
- Binary acceptance criteria

The template also includes an orchestration section that maps which streams can run in parallel and which must be sequential. This exists because Claude Code supports parallel agent dispatch, but only if the user (or the specification) identifies which tasks are independent. Without this section, the next session defaults to sequential execution even when parallelism is possible.

The self-containment rule -- "write for a stranger" -- is the template's most important constraint. The next Claude session has zero memory of the current one. Any reference to "the approach we discussed" or "continue from where we left off" is a bug. Every piece of context the next session needs must be in the document itself.

---

## Skill System

### Structure

Each skill lives in its own directory under `skills/`:

```
skills/
├── session-start/
│   └── SKILL.md
├── session-end/
│   └── SKILL.md
├── new-project/
│   └── SKILL.md
└── feedback-loop/
    └── SKILL.md
```

The SKILL.md file is the only required file. It contains YAML frontmatter (name, description, optional triggers) and the skill's instructions in Markdown. Claude Code discovers skills by scanning `~/.claude/skills/` for directories containing a SKILL.md file.

The trigger field in the frontmatter defines natural language phrases that activate the skill automatically (e.g., "end session," "wrap up," "close out" all trigger the session-end skill). This reduces reliance on the user remembering the exact slash command.

### Composition

Skills compose through file references, not inheritance or imports. The session-end skill references the NEXT_SESSION_PROMPT template by file path:

```
Reference the template at /path/to/templates/NEXT_SESSION_PROMPT_TEMPLATE.md
```

When the agent reaches that step, it reads the referenced file, applies its contents, and continues. The template itself may reference other files. This creates a directed graph of context loading that is traversed on demand.

The composition model is deliberately simple. There is no skill dependency resolution, no version pinning, no conflict detection. A skill is a Markdown file that tells the agent what to do and where to find more information. The complexity budget is spent on the content of the skills, not on the machinery of loading them.

### The Session Lifecycle

The four core skills form a lifecycle:

```
/session-start → [active work] → /session-end
                                       ↓
                          NEXT_SESSION_PROMPT.md
                                       ↓
                          /session-start (next session)
```

**/session-start** loads context in cache-optimal order (CLAUDE.md first, since it is already auto-loaded; MEMORY.md second for action items; NEXT_SESSION_PROMPT.md third as the session specification). It then proposes a parallelized execution plan and surfaces any relevant bug patterns before work begins.

**/session-end** enforces a 7-step checklist: update CLAUDE.md, update MEMORY.md, create HANDOVER.md, create NEXT_SESSION_PROMPT.md, capture learnings (dual-write to project and global files), git commit, and report context budget usage. It includes an emergency mode for when context is critically low -- minimum viable close is NEXT_SESSION_PROMPT.md + MEMORY.md update + git commit.

**/new-project** bootstraps a new project with templates from this repo. It asks four questions (identity, tech stack, scope, constraints), copies and fills templates, creates the directory structure, and makes an initial git commit.

**/feedback-loop** closes the learning cycle. It reads the global learnings file, groups entries by tags, identifies recurring themes (3+ appearances = potential new pattern), compares against existing patterns, and recommends template or pattern updates. It is designed to run every 3 sessions or at the start of a new project.

The lifecycle ensures that knowledge flows forward: session N's learnings become session N+1's starting context via NEXT_SESSION_PROMPT.md and MEMORY.md, and the feedback loop periodically promotes recurring learnings into permanent patterns and template improvements.

---

## Pattern System

### Classification

Patterns are organized into three files, each serving a different purpose:

**RECURRING_BUGS.md** -- Bug classes that appeared across multiple projects. Each entry includes the pattern, specific appearances (which project, which session), root cause analysis, and a prevention checklist. The threshold for inclusion: a bug must have appeared at least twice across at least one project. Single-occurrence bugs stay in project-level learnings files until they recur.

Currently documented bug classes: status mismatch (status fields used as implicit state machines without documented transitions), context compaction (main thread context exhaustion from large file reads and verbose output), documentation drift (CLAUDE.md or MEMORY.md diverging from reality), silent failures (operations that succeed at the call level but produce empty or wrong results), and API rate limit collisions (parallel streams sharing rate-limited resources).

**ARCHITECTURE_PATTERNS.md** -- Proven solutions validated across projects. Each entry includes when to use the pattern, how to implement it, which project validated it, and the anti-pattern it replaces. The threshold for inclusion: the pattern must have been used successfully in at least one real project. Theoretical patterns that sound good but have not been tested are excluded.

Current patterns: fallback chains, dual-write, resume-safe scripts, dry-run, progressive disclosure, cache-safe forking, git-committed cache as scraper fallback, and state machine documentation.

**ANTI_PATTERNS.md** -- Things that look reasonable but cause real problems. Each entry includes what the approach looks like, why it fails, and what to do instead. Anti-patterns are sourced directly from session failures -- every entry corresponds to a specific incident where the approach caused measurable damage (context window exhaustion, data loss, wasted API calls, etc.).

### Sourcing methodology

Every pattern, bug class, and anti-pattern in this framework is extracted from real project work across three codebases: Daily Briefing (a multi-source news aggregation pipeline), Delhi Co-Pilot (a civic information tool with web scraping and LLM processing), and AI Summit Intel (a conference content extraction system processing 200+ sessions).

The extraction process:

1. During each session, failures and successes are captured in project-level learnings files using a structured format (what happened, key learnings, tags).
2. Learnings are dual-written to a global file with condensed versions and consistent tags.
3. The feedback-loop skill periodically scans the global file for tags appearing 3+ times or across multiple projects.
4. Recurring patterns are promoted from learnings entries to pattern files with full documentation (root cause, prevention checklist, validation source).

This means the pattern files grow slowly and deliberately. A pattern is not added because it seems like a good idea; it is added because it was proven necessary by repeated failure or success.

---

## Installation and Extension

### Installing skills globally

```bash
git clone https://github.com/Sukrit-bit/learning-from-building.git
cd learning-from-building
chmod +x install.sh
./install.sh
```

This creates symlinks in `~/.claude/skills/` for every skill directory that contains a SKILL.md file. Existing symlinks with the same name are overwritten. Skills installed from other sources (different name) are untouched.

If the repo moves after installation, re-run `install.sh` to repair the broken symlinks.

### Adding a new skill

1. Create a directory under `skills/` with the skill name (e.g., `skills/my-skill/`).
2. Add a `SKILL.md` file with YAML frontmatter and Markdown instructions:
   ```yaml
   ---
   name: my-skill
   description: "What this skill does and when to use it."
   ---
   ```
3. Reference external files by absolute path for any content the skill needs but should not inline.
4. Run `./install.sh` to symlink the new skill globally.

### Adding a new template

Add a Markdown file to `templates/`. Follow the 150-line constraint. Include HTML comment annotations for sections that Claude will read and maintain -- the annotations serve as inline instructions that survive even when the skill context that originally explained them has been unloaded.

### Adding a new pattern

Add an entry to the appropriate file in `patterns/`. Follow the existing structure:
- **Bug class:** Pattern, appearances (with project/session citations), root cause, prevention checklist.
- **Architecture pattern:** What, when to use, how to implement, which project validated it, anti-pattern it replaces.
- **Anti-pattern:** What it looks like, why it fails, what to do instead.

Do not add patterns that have not been validated by real project work. The "real experience" constraint is the single most important quality gate in the framework.

---

## Known Limitations

- **Symlink fragility.** Moving the repo breaks all global skill installations. The fix is simple (re-run `install.sh`) but the failure is silent -- skills stop appearing as slash commands with no error message.
- **Skill shadowing.** If a project has a `.claude/skills/my-skill/` directory and the global `~/.claude/skills/my-skill/` also exists, the project-level skill takes precedence. This is Claude Code's intended behavior, but it can cause confusion when the two versions diverge.
- **No skill versioning.** There is no mechanism for pinning a project to a specific version of a skill. All projects share the latest version via symlinks. A breaking change to a skill affects every project on the machine immediately.
- **Template line counts are manually enforced.** There is no automated check that templates stay under 150 lines. The escalation trigger in CLAUDE.md catches it during authoring, but nothing prevents a template from exceeding the limit if the author does not invoke the framework's own skills.

---

See [README.md](README.md) for setup instructions and a quick-start guide. See [METHODOLOGY.md](METHODOLOGY.md) for the intellectual framework and the reasoning behind the four disciplines.
