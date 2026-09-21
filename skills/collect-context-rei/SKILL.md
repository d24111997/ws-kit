---
name: collect-context-rei
description: Rei's context loader — reads AGENTS.md + general/ + frontend/ docs from FE repo, plus design system files, before starting UI mock work.
---

# Collect Context — Rei

## Goal
Đọc tài liệu tổng quan FE project + design system trước khi làm UI mock.

## Instructions (MUST follow in order)

### Phase 1 — General
Read the following files in order:
1. `AGENTS.md` — doc index, operational commands, conventions
2. `docs/general/SYSTEM_CONTEXT.md` — project context, boundaries
3. `docs/general/DOMAIN_REFERENCE.md` — domain glossary (nếu có)

### Phase 2 — Frontend
Read the following files in order:
1. `docs/frontend/ARCHITECTURE.md` — FSD structure, routing, state management, i18n
2. `docs/frontend/CODING_RULES.md` — TypeScript, React, naming, Form, i18n conventions
3. `docs/frontend/CHROME_DEBUGGING.md` — chrome-devtools MCP usage guide

### Phase 3 — Design System
Read the following files:
1. `DESIGN.md` — design tokens, component recipes, colors, typography
2. `PRODUCT.md` — product strategy, brand, design principles
3. `components.json` — shadcn/ui alias, style config

### Phase 4 — Testing (lướt)
Read the following file:
1. `docs/testing/TESTING_GUIDE.md` — FE test conventions, Vitest, MSW, RTL

### Phase 5 — Finish
- Synthesize all information to grasp the project and design system.
- Output: `"Rei context loaded. Ready for next command."`

## Constraints
- Do not skip any files if they exist.
- Do not generate any code or plans during this step.
- Làm việc trong FE repo.
