---
tags: [context-seed]
status: draft
created: <% tp.date.now("YYYY-MM-DD") %>
updated: <% tp.date.now("YYYY-MM-DD") %>
---

# Context Seed — <tên feature>

> **Mục đích:** 1 file duy nhất AI đọc ĐẦU TIÊN khi bắt đầu session cho feature lớn. Compress toàn bộ context thành ~100 dòng. AI đọc xong file này → biết feature state, decisions, API, SCN, và biết cần đọc sâu file nào tiếp theo.
>
> ⚠️ **KHÔNG phải** handover. Handover tường thuật chi tiết, file này chỉ chứa facts.

---

## Feature Summary

<2-3 câu: feature này làm gì, gồm mấy phase, trạng thái tổng thể>

## Current Status

| Phase | Scope | Status |
|-------|-------|--------|
| Phase 1 | | ✅ / 🟡 / ⏳ |
| Phase 2 | | ✅ / 🟡 / ⏳ |

## Branches

| Repo | Branch | Base |
|------|--------|------|
| BE | | |
| FE | | |

---

## Key Architecture Decisions

> **Cấm AI re-open các decisions này nếu chưa có discuss mới.**

| Decision | Source | Detail |
|----------|--------|--------|
| | | |

## Key Risks / Gotchas

> Những thứ dễ miss hoặc dễ implement sai.

- 

---

## API Endpoints (Live)

| Method | Path | Mô tả |
|--------|------|-------|
| | | |

## SCN Coverage

| Feature | Count | Path |
|---------|-------|------|
| | | |

---

## Files cần đọc đầu session

> Layer 1 — MUST. Layer 2 — nếu task liên quan.

| Layer | File | Lý do |
|-------|------|-------|
| 1 | `AGENTS.md` | Operational commands |
| 1 | `CONTEXT_SEED.md` | File này |
| 1 | `HANDOVER-<latest>.md` | Trạng thái mới nhất |
| 2 | `discuss-<latest>.md` | Decisions chốt gần nhất |
| 2 | `phase<N>/plan-context.md` | Confirmed decisions phase hiện tại |
| 2 | SCN group (`11_Testing/<feature>/scenario/`) | Behavior specs |

## Session Log

> Ghi nhanh mỗi session: ngày + decisions mới.

| Date | Session | Decisions / Notes |
|------|---------|-------------------|
| | | |
