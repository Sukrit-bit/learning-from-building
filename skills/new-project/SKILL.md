---
name: new-project
description: "New project setup. Creates CLAUDE.md from template, initializes MEMORY.md, sets up directory structure with best practices. Use when starting a new project."
---

## Step 1: Understand the Project

Use AskUserQuestion to ask (one question at a time):

1. What is this project? (1-2 sentence identity)
2. What's the tech stack? (languages, frameworks, APIs)
3. What's the timeline/scope? (48-hour demo vs. long-running project)
4. Any specific constraints or requirements?

## Step 2: Create CLAUDE.md

- Copy the template from `/Users/sukritandvandana/Documents/Projects/learning-from-building/templates/CLAUDE_MD_TEMPLATE.md`
- Fill in the Identity section with user's answers
- Fill in the Architecture section based on tech stack
- Seed the Constraint Architecture with universal rules from the template PLUS:
  - Project-specific MUSTS based on tech stack (e.g., for Python projects: "always use virtual environment", for web projects: "always test in both Chrome and Safari")
  - Relevant bug prevention rules from `/Users/sukritandvandana/Documents/Projects/learning-from-building/patterns/RECURRING_BUGS.md`
- Keep it under 80 lines initially — it will grow organically

## Step 3: Create MEMORY.md

- Copy the template from `/Users/sukritandvandana/Documents/Projects/learning-from-building/templates/MEMORY_MD_TEMPLATE.md`
- Fill in Project State with initial version/phase
- Leave Action Required empty
- Add initial Technical Context (API keys location, environment setup)

## Step 4: Set Up Directory Structure

- Create `.claude/rules/` directory for reference material
- Create project-specific directories based on tech stack
- Initialize git if not already done
- Create `.gitignore` appropriate for the tech stack

## Step 5: Create Initial Session Specification

- Based on user's scope/timeline, create an initial NEXT_SESSION_PROMPT.md
- This kickstarts the specification engineering practice from day one
- Include the first set of work streams and success criteria

## Step 6: Verify Setup

- Read back CLAUDE.md and confirm with user it looks right
- Confirm all files created
- Git commit: `docs: project setup — [project name] initialized with framework templates`

---

**Key principle:** "Grown not born" — seed with universal rules but keep project-specific sections minimal. Real gotchas will be added as they're discovered.
