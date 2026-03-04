# Documentation Rewrite Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite all public documentation at the strategic/framework level. Delete implementation-level artifacts. Fix all hardcoded paths. Clean gitignore.

**Architecture:** Two public docs (README.md strategic narrative, TECHNICAL.md engineering depth) + sanitized CLAUDE.md + clean .gitignore. Delete METHODOLOGY.md. Fix all SKILL.md hardcoded paths.

**Tech Stack:** Markdown, git, gh CLI (`~/bin/gh`)

**Design doc:** `docs/plans/2026-03-05-documentation-rewrite-design.md`

---

### Task 1: Fix hardcoded paths in all SKILL.md files

**Files:**
- Modify: `skills/session-start/SKILL.md`
- Modify: `skills/session-end/SKILL.md`
- Modify: `skills/new-project/SKILL.md`
- Modify: `skills/feedback-loop/SKILL.md`

**Step 1: Replace all absolute paths**

In every SKILL.md, replace `/Users/sukritandvandana/Documents/Projects/learning-from-building/` with the skill's base directory variable. Each SKILL.md has a `Base directory for this skill:` header injected by Claude Code at runtime — use that to resolve relative paths.

Pattern: Change paths like `/Users/sukritandvandana/Documents/Projects/learning-from-building/templates/CLAUDE_MD_TEMPLATE.md` to relative references like `templates/CLAUDE_MD_TEMPLATE.md` prefixed with the repo root.

Since skills are symlinked, they need to reference the repo root. Use this pattern in each SKILL.md: add a note at the top saying the skill resolves paths relative to the repo root at `~/.claude/skills/<skill-name>/../../..` or simply use the repo name as a landmark: search for `learning-from-building` in the filesystem.

Simpler approach: Since `install.sh` creates symlinks, and the SKILL.md files reference the framework repo's own files, use the symlink resolution to find the repo root. Replace all absolute paths with a pattern like:

`{REPO_ROOT}/templates/CLAUDE_MD_TEMPLATE.md`

where `{REPO_ROOT}` is defined at the top of each SKILL.md as: "This skill's repo root is the directory containing `install.sh`. Resolve from this skill's location: `$(dirname $(readlink ~/.claude/skills/<skill-name>/SKILL.md))/../`"

Actually, the simplest approach: Skills reference files by path. Claude Code resolves these at runtime. The paths just need to work on the user's machine. Since these are symlinks back to the repo, use relative paths from the skill directory: `../../templates/CLAUDE_MD_TEMPLATE.md` (skills are at `skills/<name>/SKILL.md`, so `../../` gets to repo root).

**Replacements across all files:**
- `/Users/sukritandvandana/Documents/Projects/learning-from-building/` → relative paths using `../../` from the skill directory

Specific replacements per file:

**feedback-loop/SKILL.md (2 paths):**
- `Read /Users/.../learnings_for_Sukrit_global.md` → `Read the global learnings file at the project root (named learnings_for_*.md or LEARNINGS.md)`
- `Compare against .../patterns/RECURRING_BUGS.md` → `Compare against patterns/RECURRING_BUGS.md in the framework repo`

**new-project/SKILL.md (3 paths):**
- All template references → `templates/CLAUDE_MD_TEMPLATE.md`, `templates/MEMORY_MD_TEMPLATE.md` etc. in the framework repo
- Pattern reference → `patterns/RECURRING_BUGS.md` in the framework repo

**session-start/SKILL.md (5 paths):**
- All references → relative to framework repo root: `patterns/RECURRING_BUGS.md`, `templates/`, `frameworks/SESSION_LIFECYCLE.md`, `guides/CAPABILITY_MAP.md`, `guides/AGENT_ORCHESTRATION.md`

**session-end/SKILL.md (7 paths):**
- Template references → `templates/MEMORY_MD_TEMPLATE.md`, `templates/NEXT_SESSION_PROMPT_TEMPLATE.md`, `templates/LEARNINGS_TEMPLATE.md` in the framework repo
- Learnings global file → `the global learnings file at the framework repo root`
- Framework references → `frameworks/SESSION_LIFECYCLE.md` in the framework repo

**Step 2: Verify no absolute paths remain**

Run: `grep -r "/Users/" skills/`
Expected: No matches

**Step 3: Commit**

```bash
git add skills/
git commit -m "fix: replace hardcoded absolute paths in skills with relative references"
```

---

### Task 2: Update .gitignore

**Files:**
- Modify: `.gitignore`

**Step 1: Replace .gitignore contents**

Replace entire file with the spec from the design doc:

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

Key changes: CLAUDE.md removed from ignore (will be committed). Named personal files replaced with pattern. Python/database noise removed.

**Step 2: Commit**

```bash
git add .gitignore
git commit -m "fix: clean gitignore — remove noise, use patterns, allow CLAUDE.md"
```

---

### Task 3: Write sanitized CLAUDE.md

**Files:**
- Create/overwrite: `CLAUDE.md` (note: exists locally but is gitignored under old rules; new .gitignore allows it)

**Step 1: Write CLAUDE.md**

Framework-level CLAUDE.md for the learning-from-building repo itself. Must follow the constraint architecture from the CLAUDE_MD_TEMPLATE. Contents:

- **Identity**: Meta-framework for human-AI collaboration with Claude Code. Contains templates, skills, patterns, guides, and frameworks.
- **Architecture**: Directory structure with purpose (same as design doc Section 4)
- **Constraints**:
  - MUSTS: templates under 150 lines, patterns cite real project experience, skills must be testable on this repo
  - MUST NOTS: no theoretical patterns without validation, no product-specific references in public docs, no hardcoded absolute paths
  - PREFERENCES: checklists over prose, anti-pattern alongside pattern, progressive disclosure in skills
  - ESCALATION TRIGGERS: template exceeds 150 lines → split, skill instructions ambiguous → clarify
- **Session Protocol**: Start with `/session-start`, end with `/session-end`
- **Key References**: Links to frameworks/, guides/, patterns/, templates/

Zero references to: specific products, private/ directory contents, machine paths, session state, dates.

**Step 2: Stage and commit**

```bash
git add CLAUDE.md
git commit -m "feat: add sanitized framework-level CLAUDE.md"
```

---

### Task 4: Write README.md

**Files:**
- Overwrite: `README.md`

**Step 1: Write README.md following the design spec**

Follow the README.md spec exactly from the design doc (Sections 1-7). Voice rules:
- Strategic altitude
- Big numbers tied to generic project types only
- No product names, no session counts
- Credit Nate B. Jones with link
- Framework voice ("we"), not personal blog

Must include: friction points table, inventory table, how to use it list, quick start, credits.

**Step 2: Verify no product names or session counts**

Run: `grep -i "daily briefing\|AI Summit\|Delhi Co-Pilot\|22+ sessions\|19 files\|1917 lines" README.md`
Expected: No matches

**Step 3: Verify all internal links resolve**

Check that every `[text](path)` link points to a file that exists in the repo.

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README at strategic level — friction points, framework, installation"
```

---

### Task 5: Write TECHNICAL.md

**Files:**
- Overwrite: `TECHNICAL.md`

**Step 1: Write TECHNICAL.md following the design spec**

Follow the TECHNICAL.md spec exactly from the design doc (Sections 1-8). Voice rules:
- Engineering precision with rationale and tradeoffs
- No narrative, no case study framing
- No LLM slop
- Link back to README.md

Must include: architecture overview, 5 design decisions, template design rationale, skill system, pattern system, installation + extension, known limitations.

**Step 2: Verify no product names or session counts**

Run: `grep -i "daily briefing\|AI Summit\|Delhi Co-Pilot\|22+ sessions" TECHNICAL.md`
Expected: No matches

**Step 3: Verify no absolute paths**

Run: `grep "/Users/" TECHNICAL.md`
Expected: No matches

**Step 4: Commit**

```bash
git add TECHNICAL.md
git commit -m "docs: rewrite TECHNICAL.md — architecture decisions, template design, known limitations"
```

---

### Task 6: Delete METHODOLOGY.md and cleanup

**Files:**
- Delete: `METHODOLOGY.md`
- Verify: no remaining references to METHODOLOGY.md in committed files

**Step 1: Remove METHODOLOGY.md from git**

```bash
git rm METHODOLOGY.md
```

**Step 2: Verify no dangling references**

Run: `grep -r "METHODOLOGY" README.md TECHNICAL.md CLAUDE.md`
Expected: No matches

**Step 3: Commit**

```bash
git commit -m "docs: remove METHODOLOGY.md — content absorbed into README and TECHNICAL"
```

---

### Task 7: Final verification and push

**Step 1: Run full acceptance criteria check**

```bash
# No product names in public docs
grep -ri "daily briefing\|AI Summit\|Delhi Co-Pilot" README.md TECHNICAL.md CLAUDE.md

# No session/file counts
grep -i "22+ sessions\|19 files\|1917 lines" README.md TECHNICAL.md CLAUDE.md

# No absolute paths in any committed file
grep -r "/Users/" README.md TECHNICAL.md CLAUDE.md skills/

# No METHODOLOGY references
grep -ri "METHODOLOGY" README.md TECHNICAL.md CLAUDE.md

# Nate B. Jones credited
grep -i "Nate" README.md
```

All greps except the last should return no matches. The last should return a credit line.

**Step 2: Verify repo contents**

```bash
git status
git log --oneline -10
```

**Step 3: Push**

```bash
git push origin main
```

**Step 4: Verify public repo**

```bash
~/bin/gh api repos/Sukrit-bit/learning-from-building/contents/ --jq '.[].name'
```

Expected: .gitignore, CLAUDE.md, README.md, TECHNICAL.md, docs, frameworks, guides, install.sh, patterns, skills, templates

No METHODOLOGY.md. No learnings files. No MEMORY.md/HANDOVER.md/NEXT_SESSION_PROMPT.md.
