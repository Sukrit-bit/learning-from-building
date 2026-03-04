# Agent Orchestration Guide

How to use Claude Code's agent teams effectively. When, why, and how.

---

## 1. The Orchestrator Pattern

```
Main Agent (Orchestrator)
├── dispatches → Subagent A [independent task]
├── dispatches → Subagent B [independent task]
├── dispatches → Subagent C [independent task]
└── Main thread: coordinates results, handles blocking decisions
```

This mirrors the planner-worker architecture described in production agent deployments: a capable model plans and decomposes, cheaper/faster models execute. The orchestrator retains decision authority — it resolves conflicts, integrates results, and handles anything requiring cross-task context. Workers are kept narrow and cheap.

---

## 2. When to Use Agent Teams

- **2+ independent tasks with no shared state** — the fundamental trigger. If tasks can proceed simultaneously without reading each other's output, dispatch them.
- **Large file reads (>100 lines)** — dispatch a reader agent, get a summary back instead of consuming main thread context. The main thread never sees the raw content.
- **Code review** — fresh context per task catches bugs that accumulated context misses. A reviewer agent that hasn't seen the implementation approach often finds issues the author's context explains away.
- **Documentation updates** — 3 agents writing 3 docs simultaneously is as fast as writing 1 doc sequentially.
- **Any task consuming >20% of remaining context budget** — when a task would significantly compress the main thread, delegate it.
- **The V16 Daily Briefing experience:** a spec reviewer agent caught a border width bug; a code quality reviewer agent caught an XSS vulnerability — both trivial to fix at review time, but each would have been expensive to discover and fix later in the cycle.

---

## 3. Agent Types and When to Use Each

| Type | Use For | Model |
|---|---|---|
| `Explore` | Finding files, searching code, understanding patterns | Haiku (fast, cheap) |
| `Plan` | Designing implementation approaches | Sonnet |
| `general-purpose` | Research, multi-step tasks, content creation | Sonnet |
| `Bash` | Running commands, git operations | Default |
| `code-reviewer` | Reviewing completed work against plan | Default |
| `code-simplifier` | Refining code for clarity | Default |

---

## 4. Anti-Patterns in Agent Teams

- **Dispatching agents to use CLI flags that don't exist** — verify with `--help` first. Agents will hallucinate flag names if not grounded.
- **Sharing rate-limited resources without coordination** — map which APIs each agent stream uses before dispatch. Concurrent agents hitting the same rate-limited endpoint will collide.
- **Not specifying clear acceptance criteria per agent** — without a clear definition of done, agents stop at "good enough." Define what success looks like in the prompt.
- **Using agents for sequential-state tasks** — if task B requires output from task A, keep it on the main thread or chain agents explicitly. Parallel dispatch is for truly independent work.
- **Sending contradictory instructions to concurrent agents** — agents can't negotiate with each other. Contradictions produce inconsistent outputs that require expensive reconciliation.

---

## 5. Practical Tips

- **Launch multiple agents in a SINGLE message** (multiple Task tool calls) for true parallelism. Agents launched in separate messages run sequentially.
- **Use `run_in_background: true`** when you don't need results immediately — don't block the main thread waiting.
- **Use `isolation: "worktree"`** when agents need to modify code independently. Without worktree isolation, concurrent file writes will conflict.
- **Set `model: "haiku"`** for fast exploration tasks to minimize cost and latency. Reserve Sonnet for tasks that require reasoning.
- **Provide clear, self-contained prompts** — agents don't see the main conversation context unless you explicitly include it in the Task prompt. Assume zero shared context.
- **Agent results are NOT visible to the user** — the orchestrator must summarize results back to the user. Raw agent output stays on the main thread.

---

## 6. Example Workflows

**Session start**
1 Explore agent reads project state (HANDOVER.md, recent git log, open issues) in parallel while the main thread loads CLAUDE.md and proposes a session plan. By the time the main thread is ready, the exploration summary is available.

**Implementation**
3 general-purpose agents write 3 independent modules concurrently. Main thread integrates outputs, resolves any interface conflicts, and runs the test suite. Sequential implementation of the same 3 modules would take 3x longer.

**Code review**
1 code-reviewer agent checks the implementation against the original plan while the main thread prepares documentation or the PR description. The reviewer's fresh context catches assumptions the main thread baked in during implementation.

**Session end**
3 agents update 3 docs in parallel: HANDOVER.md, NEXT_SESSION_PROMPT.md, and the project learnings file. All three complete in the time it would take to write one sequentially. Main thread runs the session-end checklist while agents write.
