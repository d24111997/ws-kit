# Discuss File Template — Standard for every discussion session

This template is the **source of truth** for the structure of `discuss-[n].md`.
Based on best real-world sessions (decision table per cluster + clear response acknowledgements).

## Standard structure

```markdown
# Discussion [N]: [Short topic]

**Date:** YYYY-MM-DD
**Project:** [project name]
**Goal:** [one-line goal of this discussion session]
**Previous file:** discuss-[N-1].md — [one line: what was decided] (if continuing)

---

## 1. Loaded context

[Agent reads code/docs/research + verifies → summarises what is ALREADY KNOWN.
Do NOT re-ask anything that can be answered from code/docs. Be as concrete as possible:
- which file, which field, current behavior (with paths)
- what was already decided in previous discussions (if continuing)]

## 2. User feedback / Requirements to clarify (if any)

[Quote the user's feedback verbatim + a short "interpretation of locked requirements"
— so anyone reading the file understands the requirements without opening the chat]

## 3. Technical analysis (from code + research)

[What can be answered, feasibility, risks — do this BEFORE asking.
This section saves the user from asking things the agent can find itself.]

## 4. Q&A — Cluster 1: [decision branch 1]

**Q1.1 — [question]:** (a/b/c)
- [short explanation of each option]
- **Recommendation:** (a) — [short reason]

=> (user answers INLINE right here)

### Acknowledged response Q1.1 (YYYY-MM-DD)
- [decision + explanation if needed]
- [If the user asks back → add an "Explain X" section right below]

**Q1.2 — [question]:** ...
=> ...

### Decision table Cluster 1 (locked)

| # | Decision | Value |
|---|----------|-------|
| D1 | [short] | [concrete value] |

## 5. Q&A — Cluster 2: [next branch — often from a NEW user question]

(same structure as Cluster 1)

---

## 6. Consolidated decision table (whole session)

| # | Decision | Value |
|---|----------|-------|
| D1..Dn | [merged from all clusters] | |

## 7. Technical notes for PLAN (no need to ask user)

[Technical details the agent can decide itself — reserved for PLAN,
do NOT dilute the user-facing Q&A]

## 8. Open questions (if any)

## 9. Conclusion / Next steps
```

## Golden rules

1. **The discussion HAPPENS IN THE FILE.** The agent writes questions + recommendations + analysis into the file. The user reads the file and answers with `=>` inline. Chat is only for short notifications.
2. **Load context first, ask later.** Investigate code/docs first; only ask what genuinely needs a user decision.
3. **Every question has a "Recommendation"** — never ask empty.
4. **Decision table PER CLUSTER** — after each cluster is locked, write the table right away (D1, D2...). At the end, merge into a consolidated table.
5. **Acknowledge responses immediately** after the user answers — don't wait until the end.
6. **New questions from the user → new cluster branch** — don't splice them into the current cluster.
7. **Technical notes for PLAN kept separate** — don't dilute the Q&A.

## Worked example (abbreviated — synthetic)

```markdown
# Discussion 1: Saved Filters — Storage & Sync

**Date:** <YYYY-MM-DD>
**Project:** <project name> (BE + FE)
**Goal:** Lock the design for saved filters stored per user.

---

## 1. Loaded context

- Research: `docs/design/saved-filters-research.md` — filters currently live in URL params only; no persistence.
- `filters_api.py` — filter params serialised as query string, no versioning.
- `UserFilterPrefs` — `filters: dict | None`, last write wins.

## 2. User feedback (end of research doc — <YYYY-MM-DD>)

> Can filters survive a reload and follow me across devices? ...

**Interpretation of locked requirements:**
- Persist filters server-side per user; URL params remain supported; sync across devices; UI is out of scope.

## 3. Technical analysis

### Storage: JSON column on user prefs — simple, no migration for new filter keys.
### Sync: last-write-wins per user; conflicts are acceptable for this feature.
### Versioning: bump `schema_version` when the filter shape changes; tolerate unknown keys.

## 4. Q&A — Cluster 1: Storage & scope

**Q1.1 — Where to store the saved filters?**
- (a) JSON column on user prefs — **recommended**: easy to update, no migration.
- (b) Dedicated table — queryable but adds migration + seed.
- (c) Local storage only — does not sync across devices.

=> A then. [user answers]

### Acknowledged response Q1.1 (<YYYY-MM-DD>)
- Locked (a) JSON column on user prefs.

**Q1.2 — Do we need versioning from day 1?** (schema evolution)
- **Recommendation:** Yes — cheap now, avoids data backfills later.

=> makes sense

### Decision table Cluster 1 (locked)

| # | Decision | Value |
|---|----------|-------|
| D1 | Storage | JSON column on user prefs |
| D2 | Versioning | `schema_version` field from day 1 |
```
