# Cross-Project Bug Classes

Bugs that appeared across multiple projects. Each entry includes the pattern, how it manifested, and prevention checklist.

---

## Bug Class 1: Status Mismatch

**Pattern:** New ingestion paths write unexpected status values that downstream pipeline stages don't query for.

**Appearances:** 3 times across 2 projects
- Daily Briefing V8: ingestion wrote `pending`, downstream queried for `no_transcript` — items fell through the cracks
- AI Summit Session 3: ingestion wrote `transcribed`, downstream expected `has_content` — transcription work was never picked up
- AI Summit Session 6: extraction wrote `extracted`, downstream expected `has_content` — same category of failure, different stage

**Root Cause:** The `status` field acts as a state machine without a documented state diagram. Every developer (or Claude session) writes what feels intuitive for their stage, with no single source of truth about which values are valid or what the downstream consumers actually query.

**Prevention Checklist:**
- [ ] Document ALL valid status values and their transitions before writing any code (e.g., `discovered → failed_transcript`, `discovered → has_content → extracted`)
- [ ] When adding a new ingestion path, trace it forward through the ENTIRE pipeline — identify every downstream query and confirm your status value matches
- [ ] Add a comment at every status-write point: `# CRITICAL: Set status to 'X', NOT 'Y'`
- [ ] Keep the state diagram in `CLAUDE.md` or a `STATUS_STATES.md` that every session reads at start

---

## Bug Class 2: Context Compaction

**Pattern:** Main thread consumed too much context window, forcing early session close before work was complete.

**Appearances:** 2 consecutive sessions
- AI Summit Session 5: large file reads + verbose progress explanations exhausted context before all sessions were processed
- AI Summit Session 6: same pattern — no fix had been applied between sessions, so it recurred identically

**Root Cause:** Reading large files (>100 lines) in the main thread, echoing pasted content back to the user verbatim, and writing verbose multi-paragraph progress explanations all consume context budget that cannot be recovered. The main thread context window is a finite, irreplaceable resource.

**Prevention Checklist:**
- [ ] All file reads >100 lines → delegate to subagent, never read in main thread
- [ ] Confirmations are one line only: "Saved 42K chars to source X" — never echo pasted content back
- [ ] Progress updates max 3 lines; no pre-work plans, only post-work results
- [ ] At 60% context consumed → proactively warn user and restructure remaining work into subagents
- [ ] Never echo pasted content back under any circumstances

---

## Bug Class 3: Documentation Drift

**Pattern:** `CLAUDE.md` or `MEMORY.md` doesn't match project reality, causing future sessions to operate on false assumptions.

**Appearances:** Continuously across all projects
- Daily Briefing: `MEMORY.md` was stale — listed completed tasks as pending, listed deprecated approaches as current
- AI Summit: `CLAUDE.md` said "Gemini primary" for 3 full sessions after GPT-4o had become the actual primary provider

**Root Cause:** Same bug class as in-memory mutation bugs — "reality changed but the representation didn't." The documentation was correct at the time of writing, then reality diverged and no one updated the file. Unlike code bugs that produce immediate errors, documentation bugs are silent and accumulate.

**Prevention Checklist:**
- [ ] Session-end skill enforces documentation updates before closing — not optional
- [ ] At session start, verify `CLAUDE.md` matches current reality before doing any work
- [ ] When reality diverges, update documentation immediately — do not defer to session end
- [ ] Treat a stale `CLAUDE.md` as a blocking bug, not a cleanup task

---

## Bug Class 4: Silent Failures

**Pattern:** Operations succeed at the call level but produce wrong or empty results, with no error surfaced.

**Appearances:** 2 projects
- Daily Briefing V7: 73% transcript waste rate — 28 out of 80 items had no transcripts, but the fetch operation returned success with empty content rather than an error. Items were marked complete and never retried.
- AI Summit: batch extraction failures were reported as failed, but individual retries of the same items succeeded. The batch wrapper was swallowing per-item errors and reporting aggregate failure.

**Root Cause:** Code doesn't distinguish "no data exists" from "failed to fetch." Both conditions return success with empty content. Downstream code trusts the success status and doesn't validate the content, so empty results flow silently into the database.

**Prevention Checklist:**
- [ ] Use different status codes for "empty result" vs "fetch error" — never conflate them
- [ ] Log both conditions explicitly with counts: "28 items returned empty, 5 items errored"
- [ ] Never trust batch failure status — always retry failed items individually before giving up
- [ ] Add validation checks after every bulk operation: assert expected counts, sample spot-check a few results
- [ ] Empty content should trigger a warning, not silent success

---

## Bug Class 5: API Rate Limit Collisions

**Pattern:** Parallel processing streams look independent at the task level but share rate-limited APIs at the infrastructure level, causing 429s that appear random.

**Appearances:** 2 projects
- AI Summit: Whisper transcription and GPT-4o extraction both call the OpenAI API. Running both pipelines simultaneously caused rate limit collisions. Each stream individually stayed within limits; together they exceeded them.
- Delhi Co-Pilot: Gemini 429 errors during sequential testing sessions that felt slow — the issue was insufficient spacing between calls, not concurrency.

**Root Cause:** Streams look independent at the task level (transcription vs extraction) but share rate-limited resources at the infrastructure level (OpenAI API quota). Rate limits are per-account, not per-process or per-task-type.

**Prevention Checklist:**
- [ ] Before running any parallel pipeline, map which APIs each stream uses — identify shared resources
- [ ] Coordinate shared resources explicitly: don't run Whisper + GPT-4o batches simultaneously if they share an account
- [ ] Test empirically: start at 2-3 concurrent workers, double until failures appear, back off one step
- [ ] Build exponential backoff into every API call from day one — not as a fix, as a default
- [ ] For sequential workflows, space requests 5-8 seconds apart as a baseline; tune from there
