# Proven Architecture Patterns

Patterns validated across multiple projects. Each includes when to use, how to implement, and which project validated it.

---

## Pattern 1: Fallback Chains

**What:** Primary → Secondary → Tertiary for any unreliable external service.

**When to Use:** Any LLM call, any third-party API call, any external service where a single provider failure would block the pipeline.

**How to Implement:**
1. Try primary provider, catch specific failure errors (rate limit, timeout, service unavailable)
2. Log which provider was attempted and why it failed
3. Fall through to secondary provider with identical payload
4. Log which provider ultimately succeeded
5. Surface aggregate fallback statistics at the end of each run

**Validated By:** AI Summit — all 200+ content extractions succeeded because Gemini → OpenAI → local fallback meant no single provider failure killed the batch.

**Anti-Pattern:** No fallback. Single provider failures kill the entire pipeline and require manual intervention to restart. One OpenAI outage or rate limit spike blocks all work.

---

## Pattern 2: Dual-Write Pattern

**What:** Write to both project-level and global-level storage simultaneously, rather than syncing later.

**When to Use:** Any time a learning, metric, or state change needs both local detail (for the project) and global aggregation (across projects). Classic cases: learnings files, session summaries, key decisions.

**How to Implement:**
1. Identify the "detail" destination (project-specific file) and the "aggregate" destination (global file)
2. After every write to the detail destination, immediately write a condensed version to the aggregate destination — same call, not a separate step
3. The aggregate write should be shorter: strip project-specific context, keep the universally applicable insight
4. Never defer the aggregate write to "later" — it won't happen

**Example:** Every session generates learnings that go to both `learnings.md` (full detail, project-specific) and `learnings_for_Sukrit_global.md` (condensed, cross-project). The global file is always current because it's updated at the same moment as the project file.

---

## Pattern 3: Resume-Safe Scripts

**What:** Atomic per-item commits to persistent storage so interrupted runs can resume from where they stopped, not from the beginning.

**When to Use:** Any bulk operation that takes more than 5 minutes to complete. Assumes the operation will be interrupted at least once.

**How to Implement:**
1. Before processing each item, check if it already has a completion status in the database
2. If complete, skip it and move to the next — no re-processing
3. After successfully processing each item, commit status to database immediately (not in batches)
4. Re-running the script queries only items without a completion status
5. The script is idempotent: running it 10 times produces the same result as running it once

**Validated By:** Daily Briefing V8 concurrent processing — 868 items processed over multiple interrupted runs. Any interruption lost at most 1 item (the one currently in flight), never the entire batch.

**Why This Matters:** Without this pattern, a network timeout at item 700 of 868 means starting over from item 1. With this pattern, it means resuming from item 701.

---

## Pattern 4: Dry-Run Pattern

**What:** Validate everything except the expensive or irreversible operation. Make the plan visible before executing it.

**When to Use:** Before bulk API calls (costs money), before sending emails (can't unsend), before deployments (can cause downtime), before any operation where mistakes are expensive.

**How to Implement:**
1. Add a `--dry-run` flag to every bulk script from day one
2. Dry-run mode: load items, apply all filters and partitioning logic, print the execution plan — but skip the actual API calls, sends, or writes
3. The printed plan should show exactly what would happen: "Would process 42 items, skip 18, estimated cost $0.84"
4. Default behavior: prompt user to confirm before switching from dry-run to live

**Examples:**
- Daily Briefing `--no-transcripts` flag validated filter logic before committing to Whisper API costs
- `terraform plan` before `terraform apply` is the canonical example of this pattern in infrastructure

**Anti-Pattern:** Running bulk operations without a dry-run option. The first run is both the test and the production execution. Mistakes are discovered after the cost is already incurred.

---

## Pattern 5: Progressive Disclosure

**What:** Skills reference files which reference more files — agents discover context as needed rather than loading everything upfront.

**When to Use:** When adding new functionality that would bloat the system prompt or exhaust context if loaded upfront. When the agent needs different information for different tasks within the same session.

**How to Implement:**
1. Skill file contains the trigger condition and a pointer: "For API details, read `api_reference.md`"
2. `api_reference.md` contains the summary and pointers to specific endpoint docs
3. Specific endpoint docs contain the full detail
4. Agent reads only what it needs for the current task, loads deeper levels only when required

**Source:** Thariq (Claude Code creator) — this pattern enabled Claude to go from needing RAG infrastructure to building its own context through nested search. The agent navigates a file tree the same way a developer navigates documentation.

---

## Pattern 6: Cache-Safe Forking

**What:** Suboperations reuse the parent conversation's cached prefix to avoid redundant token processing.

**When to Use:** Compaction operations, summarization tasks, any side computation that branches off the main conversation and needs to share its context efficiently.

**How to Implement:**
1. Use the identical system prompt, tool definitions, and message history as the parent conversation
2. Append only the new instruction at the end — do not modify anything that came before
3. The cache hit covers all shared prefix tokens; only the new instruction requires fresh processing
4. Return the result to the parent without echoing back the shared context

**Source:** Thariq — Claude Code's compaction feature uses this exact pattern. The compaction conversation uses the same prefix as the parent, so the cache hit is nearly 100%.

**Why This Matters:** Without cache-safe forking, every subagent re-processes the entire conversation history from scratch. With it, each subagent only pays for the delta.

---

## Pattern 7: Git-Committed Cache as Scraper Fallback

**What:** Commit scraped content to git when live scraping succeeds, so future runs can load from cache when live scraping fails.

**When to Use:** When scraping target sites that block cloud provider IP ranges (common with Indian government sites, rate-limited APIs, or geo-restricted content). When the scraping environment differs from the development environment.

**How to Implement:**
1. Scrape content locally where the target site is reachable
2. Save scraped content as `data/cache/<url-hash>.md` (or equivalent)
3. Commit to git so the cache travels with the codebase
4. In the scraping function: try live fetch first, fall back to git-committed cache if the fetch fails
5. Log clearly which path was taken: "Loaded from live" vs "Loaded from cache (live fetch failed)"

**Validated By:** Delhi Co-Pilot — `delhijalboard.delhi.gov.in` was unreachable from Railway (cloud provider IPs blocked). Local scrape committed to git meant the deployed app still had the content.

**Anti-Pattern:** Assuming the scraping environment matches the development environment. Sites that work fine on a laptop may be entirely unreachable from a cloud provider's IP range.

---

## Pattern 8: State Machine Documentation

**What:** Every status field used for pipeline coordination gets an explicit state diagram documenting all valid values and transitions.

**When to Use:** Any pipeline with multiple processing stages that communicate via status fields in a database. If two different parts of the codebase read or write the same status column, this pattern is mandatory.

**How to Implement:**
1. Create a `STATUS_STATES.md` (or equivalent section in `CLAUDE.md`) before writing any pipeline code
2. Document every valid status value: `discovered`, `has_content`, `extracted`, `failed_transcript`, etc.
3. Document every valid transition as arrows: `discovered → failed_transcript` (if fetch failed), `discovered → has_content` (if fetch succeeded)
4. Document which pipeline stage is responsible for each transition
5. Every new ingestion path must reference this document and confirm its status writes are valid

**Why This Pattern Exists:** Status mismatch bugs appeared 3 times across 2 projects because the state machine was implicit — each developer wrote what felt intuitive for their stage, without knowing what downstream consumers actually queried. Making the state machine explicit eliminates an entire category of pipeline coordination bugs.

**Example Valid State Diagram:**
```
discovered
  → failed_transcript    (transcript fetch returned empty or error)
  → has_content          (transcript successfully fetched)
      → extracted        (entity extraction completed)
      → failed_extract   (entity extraction failed)
```
