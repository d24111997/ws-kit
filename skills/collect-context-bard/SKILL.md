---
name: collect-context-bard
description: Bard's context loader — reads AGENTS.md + general/ docs from BE repo, then vault templates for scenario writing methodology.
---

# Collect Context — Bard

## Goal
Đọc bối cảnh dự án + templates trong vault trước khi viết scenario (GĐ2).

## Instructions (MUST follow in order)

### Phase 1 — General
Read the following files from BE repo:
1. `AGENTS.md` — doc index, operational commands
2. `docs/general/SYSTEM_CONTEXT.md` — project context, business goals
3. `docs/general/DOMAIN_REFERENCE.md` — domain glossary (nếu có)

### Phase 2 — Vault Templates
Read the following files from Obsidian vault:
1. `11_Testing/templates/scenario.md` — format chuẩn cho mỗi file SCN
2. `~/Documents/21.AgentSkills/to-test-scenario/SKILL.md` — methodology (Steps 1-5)

### Phase 3 — Finish
- Synthesize all information.
- Output: `"Bard context loaded. Ready for next command."`

## Constraints
- Do not generate any code or plans during this step.
- Không đọc backend/ hoặc testing/ docs — không cần cho vai trò BA.
