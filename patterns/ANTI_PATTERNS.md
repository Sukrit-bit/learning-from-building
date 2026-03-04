# Anti-Patterns — What NOT to Do

Lessons learned the hard way. Each entry is a specific thing that looks reasonable but causes real problems.

---

## 1. Reading Large Files in the Main Thread

**What it looks like:** Using the Read tool on a 500-line file directly in the main conversation.

**Why it's a problem:** Every file read in the main thread consumes irreplaceable context budget. A 500-line file can consume 10-15% of the context window. Reading three or four large files effectively ends the session before the actual work begins.

**What to do instead:** Any file read over 100 lines goes to a subagent. The subagent reads it, extracts what's needed, and returns a summary. The main thread receives the summary — a fraction of the original size.

---

## 2. Echoing Pasted Content Back

**What it looks like:** User pastes a 42K character transcript. Claude responds: "Here's what you pasted: [entire 42K character transcript]..."

**Why it's a problem:** The pasted content is already in the context window. Echoing it back doubles its context cost. A single echo of a large paste can consume 30-40% of the context budget instantly.

**What to do instead:** Acknowledge with one line: "Saved 42K chars to source X." If confirmation of specific content is needed, quote one representative line, not the whole thing.

---

## 3. Verbose Explanations Before Doing Work

**What it looks like:** "I'm going to start by reading the database schema, then I'll parse the status values, then I'll trace the pipeline forward, then I'll identify where the mismatch occurs, and finally I'll propose a fix."

**Why it's a problem:** This pre-work narration consumes context without producing any output. It also creates an implicit commitment to a plan that may need to change once actual work begins.

**What to do instead:** Just do it. Report results, not plans. "Found the mismatch: ingestion writes `pending`, downstream queries `no_transcript`. Fix: change line 47 of `ingest.py`." The user doesn't need to watch the process — they need the result.

---

## 4. Trusting Batch Failure Status

**What it looks like:** A batch operation returns "4 items failed." Those 4 items get marked as failed and are never retried.

**Why it's a problem:** Batch wrappers aggregate errors in ways that obscure per-item recoverability. The 4 YouTube videos marked "failed" in batch were all individually fetchable. The batch wrapper was surfacing a transient error as a permanent failure.

**What to do instead:** Never accept batch failure as final. Always retry failed items individually before marking them as permanently failed. Log the distinction: "4 failed in batch, 4 succeeded on individual retry — batch error was transient."

---

## 5. Fixed Taxonomy When Heuristics Spiral

**What it looks like:** Writing increasingly complex keyword-matching rules: "if 'water' in title AND 'ministry' in description AND NOT 'wastewater' in body, tag as water-governance..."

**Why it's a problem:** As edge cases accumulate, the rule set becomes unmaintainable. Rules interact in unexpected ways. New content breaks existing rules. The heuristic complexity grows faster than the value it produces.

**What it signals:** The taxonomy itself is wrong. A taxonomy that requires 50 heuristic rules to apply is a taxonomy that doesn't match how the content is actually organized.

**What to do instead:** Stop writing rules. Let the LLM generate dynamic tags from the content directly. The LLM can read context that keywords can't capture. The resulting tags will be messier but more accurate, and they'll adapt to new content automatically.

---

## 6. Manual Vigilance Instead of Checklists

**What it looks like:** "I'll remember to update `MEMORY.md` at the end of this session."

**Why it's a problem:** You won't. Not because of bad intentions — because sessions are long, context switches are constant, and by the end of a session there are always 3 things that feel more urgent than documentation. Vigilance is a depletable resource; checklists are not.

**What to do instead:** Build the checklist into the session-end skill. The skill runs whether or not you remember to update documentation. Make the important thing the automatic thing.

---

## 7. Documentation as Task Manager

**What it looks like:** Writing "Do X later" or "TODO: refactor Y" in a handover doc, then considering the task tracked.

**Why it's a problem:** A task buried in a handover doc has no visibility, no timing, and no ownership. The next session starts, reads the doc, and either misses the item entirely or deprioritizes it because there's no forcing function.

**What to do instead:** Tasks need three properties to actually get done: visibility (auto-loaded at session start), timing (clear about when to do it — start, end, blocking), and ownership (assigned to a specific session or trigger). Use the `MEMORY.md` Action Required section for this. If it's not in Action Required, it doesn't exist.

---

## 8. Assuming Shared Context Exists

**What it looks like:** A handover doc that says "As discussed, use the V2 approach" or "Continue from where we left off."

**Why it's a problem:** The next Claude session has zero memory of previous sessions. "As discussed" is meaningless. "V2 approach" without a definition is meaningless. The new session will either ask for clarification (costing time) or make an assumption that's wrong.

**What to do instead:** Write for a stranger. Every handover doc should be self-contained — a new Claude session with no prior context should be able to read it and know exactly what to do, what the current state is, and why decisions were made. If that's not true, the doc is incomplete.

---

## 9. Prompt-Level Instructions for Hard Requirements

**What it looks like:** "Never mention competitor products" as a system prompt instruction, with no other enforcement.

**Why it's a problem:** LLMs follow prompt instructions approximately 80% of the time on adversarial or edge-case inputs. For soft preferences this is fine. For hard requirements — content that must never appear, formats that must always be followed — 80% compliance means 20% failure, which is unacceptable.

**What to do instead:** Use both layers. Keep the prompt instruction (it helps the LLM generate better output in the first place), but add post-processing validation that catches the 20%. Regex, keyword checks, or a secondary LLM pass. The prompt reduces the failure rate; the post-processing catches the residual failures.

---

## 10. Testing with Back-to-Back API Calls

**What it looks like:** Writing a test loop that calls the Gemini API 20 times sequentially with no sleep between calls.

**Why it's a problem:** Gemini rate limits (and most LLM API rate limits) are measured in requests-per-minute, not concurrent requests. Back-to-back sequential calls can burn through a minute's quota in seconds. The resulting 429 errors look like an API problem when they're actually a pacing problem.

**What to do instead:** Space sequential requests 5-8 seconds apart as a baseline. For bulk operations, build configurable throttling in from day one — not as a fix after rate limits hit, as a default behavior. Test the throttling with a small batch before running the full dataset.
