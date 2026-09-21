---
name: collect-context
description: Use this skill when the user asks to load or collect the mandatory project context before starting a task. It reads the core documentation files in sequence.
---

# Collect Context

## Goal
To read and memorize the core project documentation before starting any code or planning.

## Instructions (MUST follow in order)

### Phase 1 — Read the fixed list
Read the following files sequentially:
1. `AGENTS.md`
2. `docs/general/ARCHITECTURE.md`
3. các file về coding rules trong `docs` (*_CODING_RULES.md*), ví dụ:
   - `docs/backend/CODING_RULES.md`
   - `docs/backend/DATABASE_CODING_RULES.md`
   - `docs/frontend/CODING_RULES.md`
4. `docs/general/SYSTEM_CONTEXT.md`
5. `docs/general/DOMAIN_REFERENCE.md`
6. `DOCS_INDEX.md`

- Các file nền tảng này cung cấp thông tin quan trọng về kiến trúc, coding rules, và bối cảnh hệ thống. Các file có thể được đặt tại path khác, nhưng vẫn sẽ nằm trong folder docs, giữ đúng tên. 

### Phase 2 — Đọc thêm các file liên quan task
- Nếu đã có yêu cầu task, từ `DOCS_INDEX.md`, xác định các file liên quan tới task đó và đọc chúng theo thứ tự xuất hiện trong index.

### Phase 3 — Finish
- Synthesize all information to grasp the project overview.
- DO NOT plan or code until this step is complete.
- Output: `"Context loaded. Ready for next command."`

## Constraints
- Do not skip any files if they exist.
- Do not generate any code or plans during this step.
