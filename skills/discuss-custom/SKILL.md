---
name: discuss-custom
description: Structured technical discussion session. Interviews user through the full decision tree, logs all Q&A to discuss-[n].md. Use when needing to clarify requirements, stress-test a plan, or resolve ambiguous design decisions. The discussion HAPPENS IN THE FILE — the agent writes questions and recommendations into discuss-[n].md, the user answers inline; chat is only for short notifications.
---

# Discuss Custom

## Goal
Open a dedicated technical discussion that walks through every branch of the decision tree until zero ambiguity remains. All Q&A is logged to `discuss-[n].md`; chat responses are kept minimal to save tokens.

> **🔴 CORE PRINCIPLE: THE DISCUSSION HAPPENS IN THE FILE, NOT IN CHAT.**
> - The agent writes questions, recommendations, and analysis **into the file** `discuss-[n].md` → the user reads the file and **answers inline** (typically as `=> ...`) → the agent reads the response and closes it out in the file.
> - Chat is only for **short notifications**: "Wrote discuss-N.md, cluster 1 asks about X — read the file and answer inline."
> - **DO NOT ask questions one by one in chat, wait for the user's answer, then copy it into the file** — users don't want that (wastes time, loses the trace, doubles the agent's work).

## Instructions

### Logging (Token Optimization)
- Determine next available index `n` from existing `discuss.md`, `discuss-1.md`, `discuss-2.md`...
- Create `discuss-[n].md` — **use the standard template at `references/template.md`** (read that file; do not improvise).
  - If `new_task.md` is available, take the topic and project from it.
- **Write the full discussion content to this file only.**
- File location: prefer the folder inside the relevant repo. Follow the user's request about where to save if any.
- Chat response: keep to **1-2 lines** summarising what was asked/decided + confirm file written.
  - Good: `"Wrote discuss-3.md. Asked about X, you chose Y."`
  - Bad: long chat messages that are then copied verbatim into the file → wastes tokens x2.
- Append each Q&A to the file immediately after it occurs.
- Format the file using standard Markdown (headings, bullet lists, code blocks).
- Use professional and standard language.

### Discuss file structure (summary — full details and example in `references/template.md`)

```markdown
# Discussion [N]: [Short topic]

**Date:** ... | **Project:** ... | **Goal:** ... | **Previous file:** ... (if continuing)

## 1. Loaded context
[Agent reads code/docs + verifies → summarises what is ALREADY KNOWN. Do not re-ask.]

## 2. User feedback / Requirements to clarify (if any)
[Quote feedback + interpretation]

## 3. Technical analysis (from code + research)
[Feasible? Risks? — do this BEFORE asking]

## 4. Q&A — Cluster 1: [decision branch]
**Q1.1 — [question]:** (a/b/c)
- **Recommendation:** (a) — [reason]
=> (user answers inline)
### Acknowledged response Q1.1 (YYYY-MM-DD)
- [decision]
### Decision table Cluster 1 (locked)
| # | Decision | Value |

## 5. Q&A — Cluster 2: ...
## 6. Consolidated decision table (whole session)
## 7. Technical notes for PLAN (no need to ask user)
## 8. Open questions (if any)
## 9. Conclusion / Next steps
```

### Questioning Technique
- **Ask in clusters (branch batching)**: you may ask several questions at once, but only within the same decision tree / branch. Questions in a cluster must NOT depend on each other's answers.
  - Good: "Which database? MySQL vs Postgres. And which migration tool? Alembic or raw SQL?" — same tree, independent.
  - Bad: "Should we use a queue? And what worker timeout?" — question 2 depends on question 1.
- **Group by decision point**: if several questions depend on one decision, group them — "I see 3 questions all depend on A. Do you choose A1 or A2?" → wait for the answer → move on.
- **Walk the tree**: finish a cluster → lock it → move to the next cluster/child branch. Walk until zero ambiguity remains.
- **Always recommend**: every question must come with your recommendation; never ask empty.
- **Decision table per cluster**: after each cluster is locked, write the table `D1, D2...` immediately (don't wait until the end). At the end of the session, merge into a consolidated table.
- **Acknowledge responses immediately**: after the user answers, write `### Acknowledged response Qx (date)` + the decision + explanation if needed. If the user asks back, add a "Explain X" section right below (e.g. "Explain multi-label", "Explain what cosine is") before asking further.
- **New questions from the user → new cluster branch**: don't splice into the current one; open the next cluster.
- **Edge case probes**: for every locked decision, probe further:
  - **Input Sanitization**: if the spec has user-input text (URL, name, query string...), ask: "Can different string variants of the same business entity occur? (trailing slash, case, encode/decode, extra whitespace). Do we need to normalize before comparing? What is the normalization rule?"
  - **Async State**: if the flow has "read state → await API → write state", ask: "Can state change while awaiting? Do we need a snapshot before await? Do we need a lock against concurrent operations?"
- If a question can be answered by exploring the codebase/docs, do so instead of asking.

### Termination
- When no more questions, state exactly: `"I have no more questions, waiting for your confirmation to end the discussion"`
- Go completely SILENT until the user confirms.
- Do NOT create any plan files or modify code.

## Constraints
- CRITICAL: DO NOT create `implementation_plan.md` or any temporary plan files.
- CRITICAL: DO NOT modify any code in the `src/` directory.
- CRITICAL: DO NOT activate internal AI planning features. ONLY log the discussion.
