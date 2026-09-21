---
name: collect-context-jack
description: Jack's context loader — reads AGENTS.md + general/ + backend/ + testing/ docs from BE repo before starting orchestration work.
---

# Collect Context — Jack

## Goal
Đọc toàn bộ tài liệu cần thiết cho vai trò Orchestrator: general context + backend architecture + coding conventions + testing strategy.

## Instructions (MUST follow in order)

### Phase 1 — General
Read the following files in order:
1. `AGENTS.md` — doc index, operational commands, repo paths
2. `docs/general/SYSTEM_CONTEXT.md` — tech stack, system boundaries
3. `docs/general/DOMAIN_REFERENCE.md` — domain glossary (nếu có)

### Phase 2 — Backend
Read the following files in order:
1. `docs/backend/ARCHITECTURE.md` — module structure, Clean Architecture, Dependency Rule
2. `docs/backend/CODING_RULES.md` — conventions, typing, response contract
3. `docs/backend/BOUNDARIES.md` — Always / Ask / Never rules
4. `docs/backend/DATABASE_CODING_RULES.md` — DB naming, indexing, migrations (nếu task động đến DB)
5. `docs/backend/CI_CD.md` — CI pipeline, deploy process (nếu task liên quan deploy)

### Phase 3 — Testing
Read the following file:
1. `docs/testing/TESTING_GUIDE.md` — test conventions, Classicist/Mockist strategy

### Phase 4 — Finish
- Synthesize all information to grasp the project overview.
- Output: `"Jack context loaded. Ready for next command."`

## Constraints
- Do not skip any files if they exist.
- Do not generate any code or plans during this step.
