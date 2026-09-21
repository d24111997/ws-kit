---
name: collect-context-anna
description: Anna's context loader — reads AGENTS.md + general/ + testing/ (especially e2e/) docs from BE repo before writing E2E test cases and Playwright specs.
---

# Collect Context — Anna

## Goal
Đọc bối cảnh dự án + testing conventions + e2e setup/patterns trước khi làm E2E testing (GĐ5).

## Instructions (MUST follow in order)

### Phase 1 — General
Read the following files from BE repo:
1. `AGENTS.md` — doc index, operational commands, repo paths
2. `docs/general/SYSTEM_CONTEXT.md` — project context, tech stack
3. `docs/general/DOMAIN_REFERENCE.md` — domain glossary (nếu có)

### Phase 2 — Testing
Read the following file:
1. `docs/testing/TESTING_GUIDE.md` — test conventions, strategy

### Phase 3 — E2E Docs
Read the following files in order:
1. `docs/testing/e2e/SETUP.md` — môi trường, credentials, worktree setup
2. `docs/testing/e2e/TROUBLESHOOTING.md` — debug guide, common failures
3. `docs/testing/e2e/patterns/_INDEX.md` — overview of available patterns

### Phase 4 — Finish
- Synthesize all information.
- Output: `"Anna context loaded. Ready for next command."`

## Constraints
- Do not generate any code or plans during this step.
- E2E patterns chi tiết (auth, test-data, navigation...) sẽ load trong Phase 2 workflow của Anna.
