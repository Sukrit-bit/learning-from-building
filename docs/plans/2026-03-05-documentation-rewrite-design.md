# Documentation Rewrite Design

## Problem

The current public documentation (README.md, METHODOLOGY.md, TECHNICAL.md) communicates at implementation-level granularity: specific session counts, named products, file-level details, personal learnings. This is wrong for a strategic framework repo. The documentation should communicate at the framework/architecture/strategic level — the big problems being solved, how they're solved, and how to use the solutions.

## Design Decisions

### Document structure: 2 docs, not 3

- **README.md** (~100 lines) — Strategic narrative + system overview + installation. The main event.
- **TECHNICAL.md** (~170 lines) — Architecture decisions, template design rationale, pattern classification, known limitations. For engineers who want depth.
- **Delete METHODOLOGY.md** — Its strategic content goes into README. Its technical content goes into TECHNICAL.md.

### Committed artifacts

- **CLAUDE.md** — Sanitized, framework-level. Describes THIS repo's identity, architecture, constraints, session protocol. Zero references to specific projects, private docs, machine paths, or session state.
- **README.md** — Strategic narrative.
- **TECHNICAL.md** — Engineering depth.

### Gitignored artifacts

- MEMORY.md, HANDOVER.md, NEXT_SESSION_PROMPT.md — instance-level working state
- learnings_for_*.md — personal learning logs
- private/ — private docs

### .gitignore changes

Remove named personal files (leak info). Remove Python/database entries (irrelevant noise). Use `learnings_for_*.md` pattern. Remove CLAUDE.md from gitignore (it gets committed). Keep MEMORY.md, HANDOVER.md, NEXT_SESSION_PROMPT.md gitignored.

### Skill files: fix hardcoded paths

All SKILL.md files contain `/Users/sukritandvandana/...` absolute paths. Replace with relative-to-repo paths using a base directory variable pattern.

---

## README.md Spec

### Voice rules

- Strategic altitude — framework/architecture level, not implementation level
- Big numbers ONLY when tied to a generic project type ("while building an automated intelligence pipeline processing 900+ items daily...") — never tied to named products
- No product names (Daily Briefing Tool, AI Summit Intel, Delhi Co-Pilot) — describe the TYPE of thing built
- No session counts, no file counts, no line counts
- No "I" — use "we" or passive (framework voice, not blog)
- No LLM slop
- Credit Nate B. Jones by name with link to his video
- Every section earns its place by answering a question the reader has at that point

### Structure

#### 1. Title + One-liner (~2 lines)
What this is. No preamble. Framework voice.

#### 2. The Problem (~8-10 lines)
Human-AI collaboration at production scale has structural friction points that prompting alone cannot solve. Name the friction directly:
- Context evaporates between sessions
- The human becomes the real-time quality layer
- Work stays sequential when it could parallelize
- Session quality is inconsistent
- Knowledge stays locked in individual projects

Strategic numbers dropped naturally: "When a content extraction system processing 900+ items silently wastes most of its output..." / "When the same pipeline failure class appears for the third time across a different codebase..."

Credit: "Building on [Nate B. Jones' Four Prompting Disciplines](link), we identified that prompting is one of four skills — and the one that matters least as agents grow more autonomous."

#### 3. The Friction Points We Addressed (~12-15 lines)
Table format. The strategic backbone.

| Friction Point | Solution |
|---|---|
| Re-explaining context each session | session-start skill loads docs + proposes parallel plan |
| Being the real-time quality layer | Constraint architecture in CLAUDE.md (MUSTS/MUST NOTS/PREFERENCES/ESCALATION TRIGGERS) |
| Sequential work, not parallel | Agent orchestration guide + session-start proposes parallel execution |
| Don't know what Claude Code can do | Capability map organized by workflow stage |
| Inconsistent session quality | Session lifecycle protocol + session-start/session-end skills enforce it |
| No feedback loop on learnings | feedback-loop skill reviews cross-project patterns |

#### 4. What's Inside (~12-15 lines)
Compact inventory table showing categories with strategic-level purpose descriptions:

| Category | What | Purpose |
|---|---|---|
| Templates (4) | CLAUDE.md, MEMORY.md, NEXT_SESSION_PROMPT.md, Learnings | Standardized starters for every new project |
| Frameworks (2) | Four Disciplines, Session Lifecycle | Conceptual references with practical checklists |
| Guides (2) | Capability Map, Agent Orchestration | Everything Claude Code can do, organized by workflow |
| Patterns (3) | Recurring Bugs, Architecture Patterns, Anti-Patterns | Cross-project wisdom from production AI builds |
| Skills (4) | session-start, session-end, new-project, feedback-loop | Enforcement mechanisms, globally installed |

#### 5. How to Use It (~12-15 lines)
Numbered, action-oriented:
1. Starting a new project → `/new-project`
2. Starting any session → `/session-start`
3. Ending any session → `/session-end`
4. Every few sessions → `/feedback-loop`
5. Capability discovery → `guides/CAPABILITY_MAP.md`
6. Before building → `frameworks/FOUR_DISCIPLINES.md`

#### 6. Quick Start (~8-10 lines)
Clone, install, done. What you get after installation.

#### 7. Credits + Further Reading (~5 lines)
- Nate B. Jones credit with link
- Link to TECHNICAL.md for engineering decisions
- Built with Claude Code (one line)

---

## TECHNICAL.md Spec

### Voice rules

- Engineering precision — decisions with rationale and tradeoffs
- No narrative, no case study framing
- For engineers who are already bought in and want to understand or extend
- No LLM slop
- Link back to README.md

### Structure

#### 1. Intro (~3 lines)
What this doc covers. Link to README.

#### 2. Architecture Overview (~15 lines)
Directory structure with how Claude Code consumes each layer:
- Auto-loaded every turn (CLAUDE.md)
- Referenced on demand by skills (frameworks/, guides/, patterns/)
- Copied into new projects (templates/)
- Symlinked for global access (skills/)

#### 3. Design Decisions (~45 lines)
Five decisions with rationale:
- Skills vs. rules (invocable vs. passive, context cost)
- Symlinks vs. copies (single source of truth vs. fragility)
- Progressive disclosure (skills reference files which reference files)
- 150-line template constraint (context budget, not aesthetics)
- Constraint architecture as intent encoding (why four tiers, not flat lists)

#### 4. Template Design (~25 lines)
Three templates with rationale:
- CLAUDE.md: constraint architecture signals priority to the LLM
- MEMORY.md: HTML annotations as inline instruction reinforcement
- NEXT_SESSION_PROMPT: specification, not summary

#### 5. Skill System (~20 lines)
- Structure and composition via file references
- The session lifecycle loop (start → work → end → next start)
- Agent orchestration: how session-start proposes parallel plans

#### 6. Pattern System (~15 lines)
- Three pattern files, their classification methodology
- Inclusion thresholds (2+ appearances for bugs, validated use for architecture patterns)
- Extraction pipeline from session learnings to promoted patterns

#### 7. Installation + Extension (~15 lines)
How to add your own skills, templates, patterns.

#### 8. Known Limitations (~12 lines)
Honest assessment:
- Symlink fragility
- Skill shadowing
- No versioning
- No automated validation
- Single-user design
- Hardcoded paths (with workaround documented)

---

## CLAUDE.md Spec (Sanitized)

Framework-level only. Structure:

- **Identity**: Meta-framework for Claude Code collaboration
- **Architecture**: Directory structure with purpose of each layer
- **Constraints**: MUSTS / MUST NOTS / PREFERENCES / ESCALATION TRIGGERS for working on this repo
- **Session Protocol**: Use /session-start and /session-end
- **Key References**: Links to frameworks, guides, patterns

Zero references to: specific products, private/ directory contents, machine-specific paths, personal session state, specific session dates.

---

## .gitignore Spec

```gitignore
# Claude Code local state
.claude/

# OS files
.DS_Store
Thumbs.db

# Editor files
*.swp
*.swo
*~
.vscode/
.idea/

# Private documents
private/

# Personal learning logs
learnings_for_*.md

# Working state (instance-level, not framework-level)
MEMORY.md
HANDOVER.md
NEXT_SESSION_PROMPT.md

# Environment
.env
.env.*
```

---

## Cleanup Tasks

1. Delete METHODOLOGY.md from git
2. Fix hardcoded absolute paths in all SKILL.md files
3. Update .gitignore
4. Commit sanitized CLAUDE.md
5. Write and commit README.md
6. Write and commit TECHNICAL.md
7. Push to GitHub

---

## Acceptance Criteria

- [ ] README passes the strategic altitude test — no product names, no session counts, no file counts
- [ ] Big numbers appear only tied to generic project types
- [ ] Nate B. Jones credited with link
- [ ] Friction points table is the backbone of the README
- [ ] TECHNICAL.md covers all design decisions with engineering rationale
- [ ] CLAUDE.md committed with zero private references
- [ ] METHODOLOGY.md deleted
- [ ] No hardcoded absolute paths in any committed file
- [ ] .gitignore is clean (no named personal files, no irrelevant entries)
- [ ] All internal links resolve to files that exist in the public repo
