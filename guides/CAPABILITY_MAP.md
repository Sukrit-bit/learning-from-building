# Claude Code Capability Map

Everything Claude Code can do, organized by what you're trying to accomplish. Not a tool reference — a workflow guide.

---

## Starting a Session

| Capability | How to Use | When | Key Insight |
|---|---|---|---|
| Session start skill | `/session-start` or invoke skill | Every session | Loads docs in cache-optimal order, proposes parallel plan |
| Plan mode | `EnterPlanMode` tool (Claude can also self-enter) | Non-trivial implementation | Forces exploration before implementation. Designed around prompt cache — no tool changes needed |
| Brainstorming | `superpowers:brainstorming` skill | Any creative/design work | Mandatory before building. Explores intent and requirements first |
| AskUserQuestion | Tool with structured options | When clarification needed | Multiple-choice preferred over open-ended. Lowers friction. User can always select "Other" |

---

## Planning & Designing

| Capability | How to Use | When | Key Insight |
|---|---|---|---|
| Writing plans | `superpowers:writing-plans` skill | After spec/requirements exist | Creates detailed implementation plans with review checkpoints |
| Executing plans | `superpowers:executing-plans` skill | When you have a written plan | Step-by-step execution with review after each step |

---

## Building & Executing

| Capability | How to Use | When | Key Insight |
|---|---|---|---|
| Agent Teams | `Task` tool with multiple calls in one message | 2+ independent tasks | Each agent gets fresh context — prevents main thread compaction! |
| Parallel Agents | `superpowers:dispatching-parallel-agents` skill | Independent tasks, no shared state | Formalizes the multi-agent dispatch pattern |
| Subagent-Driven Dev | `superpowers:subagent-driven-development` skill | Executing plans with independent tasks | Breaks implementation into agent-assignable chunks |
| Git Worktrees | `isolation: "worktree"` on Task tool | Safe experimentation | Creates isolated copy of repo. Auto-cleaned if no changes |
| Enter Worktree | `EnterWorktree` tool | Session-level isolation | Entire session works in isolated branch |
| TDD | `superpowers:test-driven-development` skill | Any feature or bugfix | Write test first, then implementation |
| Systematic Debugging | `superpowers:systematic-debugging` skill | Any bug or unexpected behavior | Structured root-cause analysis before proposing fixes |
| Preview Tools | `preview_start`, `preview_screenshot`, `preview_snapshot`, `preview_inspect` | UI development | `preview_inspect` with CSS selectors is more accurate than screenshots for verifying styles |
| Background Tasks | `run_in_background: true` on Task or Bash | Long-running operations | Don't block main thread. Check output later with TaskOutput |

---

## Reviewing & Verifying

| Capability | How to Use | When | Key Insight |
|---|---|---|---|
| Code Review | `superpowers:requesting-code-review` skill | After completing major features | Fresh context catches drift the main thread misses |
| Receiving Review | `superpowers:receiving-code-review` skill | When getting review feedback | Requires technical rigor — don't just agree with everything |
| Verification | `superpowers:verification-before-completion` skill | Before claiming work is done | Run verification commands FIRST, then assert success. Evidence before assertions. |

---

## Shipping

| Capability | How to Use | When | Key Insight |
|---|---|---|---|
| Commit | `commit-commands:commit` skill | When user requests | Follows git safety protocol — never amend without explicit request |
| Commit + Push + PR | `commit-commands:commit-push-pr` skill | Ready to merge | Creates PR with summary and test plan |
| Finishing branches | `superpowers:finishing-a-development-branch` skill | Implementation complete, tests pass | Guides merge/PR/cleanup decision |
| Deploy to Vercel | `vercel:deploy` skill | Production deployment | First run `vercel:setup` to configure |

---

## Knowledge Management

| Capability | How to Use | When | Key Insight |
|---|---|---|---|
| CLAUDE.md update | `claude-md-management:revise-claude-md` skill | Session end | Adds discovered gotchas, updates state |
| CLAUDE.md audit | `claude-md-management:claude-md-improver` skill | Every 3 sessions | Full quality audit against templates |
| Learnings capture | `learnings` skill | Session end | Dual-write: project + global file |
| Session end | `session-end` skill | Every session end | 7-step mandatory checklist |
| Session start | `session-start` skill | Every session start | Loads context, proposes plan |
| Skills creation | `superpowers:writing-skills` skill | Creating new skills | Ensures skills are properly structured |

---

## Browser & Web

| Capability | How to Use | When | Key Insight |
|---|---|---|---|
| WebSearch | Built-in tool | Research, finding docs | Summaries often more useful than fetching pages |
| WebFetch | Built-in tool | Reading specific page content | Falls back to WebSearch if page returns garbage |
| Browser automation | Claude in Chrome MCP tools | Web tasks, form filling, testing | Full browser control with screenshots |

---

## Prompt Caching Rules

From Thariq, Claude Code creator:

1. CLAUDE.md is cached at the project level — keep it stable within a session
2. Static content first, dynamic last in system prompt (already handled by Claude Code)
3. Use system reminders in messages for dynamic info, not system prompt changes
4. Never change tools or models mid-session — use subagents for different models
5. Plan mode uses tools (EnterPlanMode/ExitPlanMode), not tool set swaps
6. Subagents dispatched to Haiku are cheapest for exploration tasks
