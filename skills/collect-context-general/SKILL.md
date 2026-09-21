---
name: collect-context-general
description: Load general project context before starting any task. Reads AGENTS.md + docs/general/ (SYSTEM_CONTEXT, DOMAIN_REFERENCE) for system overview and business context. This is the universal baseline — every subagent loads this first, then loads role-specific docs from their own persona file.
---

# Collect Context — General

## Goal
Đọc tài liệu tổng quan dự án (general) để nắm bối cảnh chung. Đây là baseline cho mọi subagent. Sau skill này, từng agent sẽ tự load thêm tài liệu chuyên sâu theo role (backend, testing, frontend...).

## Instructions (MUST follow in order)

### Phase 1 — Read AGENTS.md
Read `AGENTS.md` — operational commands, doc index, repo paths, verify checklist.

### Phase 2 — Read general/ docs
Read the following files in order:
1. `docs/general/SYSTEM_CONTEXT.md` — tech stack, system boundaries, business goals
2. `docs/general/DOMAIN_REFERENCE.md` — domain glossary (nếu file tồn tại)

### Phase 3 — Finish
- Synthesize all information to grasp the project overview.
- DO NOT plan, code, or review until this step is complete.
- Output: `"Context loaded. Ready for next command."`

## Constraints
- Chỉ đọc `docs/general/` — không đọc `docs/backend/`, `docs/testing/`, `docs/frontend/`...
- Các tài liệu role-specific do từng agent tự load riêng trong persona file.
- Do not skip any files if they exist.
- Do not generate any code or plans during this step.
