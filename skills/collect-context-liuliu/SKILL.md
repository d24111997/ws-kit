---
name: collect-context-liuliu
description: LiuLiu's context loader — reads AGENTS.md + general/ + testing/ docs from BE repo, then vault templates and source code for test documentation.
---

# Collect Context — LiuLiu

## Goal
Đọc bối cảnh dự án + testing conventions + vault templates trước khi tạo test documentation (GĐ4).

## Instructions (MUST follow in order)

### Phase 1 — General
Read the following files from BE repo:
1. `AGENTS.md` — doc index, operational commands
2. `docs/general/SYSTEM_CONTEXT.md` — project context, system boundaries
3. `docs/general/DOMAIN_REFERENCE.md` — domain glossary (nếu có)

### Phase 2 — Testing
Read the following file:
1. `docs/testing/TESTING_GUIDE.md` — test conventions, Classicist/Mockist strategy

### Phase 3 — Finish
- Synthesize all information.
- Output: `"LiuLiu context loaded. Ready for next command."`

## Constraints
- Do not generate any code or plans during this step.
- Các tài liệu chi tiết (vault templates, source code) sẽ đọc riêng trong workflow của LiuLiu.
