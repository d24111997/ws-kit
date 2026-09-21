---
title: {Feature} Feature — Test Traceability Matrix
date: {YYYY-MM-DD}
last_updated: {YYYY-MM-DD}
type: analysis
feature: {feature-code}
tags:
  - testing
  - traceability
  - coverage
linked:
  - "[[11_Testing/{feature}/testplan/test-plan]]"
  - "[[11_Testing/{feature}/testplan/validation-matrix]]"
---

# {Feature} Feature — Test Traceability Matrix

**Source scenarios:** `11_Testing/{feature}/scenario/` (SCN-{FEAT}-001→{N})
**Test layers (từ thấp đến cao):**

| # | Layer | Ghi chú |
|---|-------|---------|
| 1 | **Pure** | Pure function tests — zero mock, assert on return value |
| 2 | **Classicist** | In-Memory Fakes cho I/O, assert on state/output |
| 3 | **Mockist** | Mock dependencies, assert interaction (call_count, called_with) |
| 4 | **API Integ** | TestClient + real DB, mock chỉ ở external boundary |
| 5 | **FE Unit** | Unit/component test (Vitest + RTL) |
| 6 | **E2E** | Playwright — full stack thật |

> **Nguyên tắc theo test-plan §3.2.1:** Ưu tiên Pure → Classicist → Mockist.
> Mockist chỉ dùng khi Classicist bất khả thi (cần assert control flow / external HTTP).
> Nếu feature không có layer nào → bỏ column đó.
> Nếu feature có Real Infra (`tests_integration/`) → thêm column riêng, ghi chú rõ.

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Covered — ít nhất 1 test case trực tiếp |
| 🟡 | Partial — cover 1 phần scenario |
| 🔵 | Indirect — scenario thuộc layer khác, layer này không test trực tiếp |
| ❌ | Not covered — chưa có test nào |

---

## {Group Name} (SCN-{FEAT}-{N01}→{Nxx})

| SCN | Name | Pure | Classicist | Mockist | API Integ | FE Unit | E2E | Ghi chú |
|-----|------|------|------------|---------|-----------|---------|-----|---------|
| {N01} | {name} | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ | {Ghi chú những điều đáng chú ý, k giải thích là TC nào ở đâu} |
| {N02} | {name} | ✅ | ❌ | ❌ | 🟡 | ❌ | ❌ | {notes — ghi rõ tại sao partial/not covered} |

> 1 bảng cho mỗi group. Layer columns điều chỉnh theo feature.
> Cột `Ghi chú` ghi rõ: lý do nếu 🔵/🟡/❌, BE hay FE layer nào đang cover.

---

## Gaps đáng chú ý

### BE layers (Pure / Classicist / Mockist / API Integ)

| Scenario | Gap | Lý do |
|----------|-----|-------|
| {SCN-path} | ❌ / 🟡 | {reason — e.g., "Auth concern — không có BE unit test riêng"} |

### E2E

| Scenario | Gap | Lý do |
|----------|-----|-------|
| {SCN-path} | ❌ / 🟡 | {reason — e.g., "Cần seed history data — chưa có helper E2E"} |

### FE Unit

| Scenario | Gap | Lý do |
|----------|-----|-------|
| {SCN-path} | ❌ / 🟡 | {reason — e.g., "FE rendering concern, không cần unit test riêng"} |

---

## Changelog

| Date | Thay đổi |
|------|---------|
| {YYYY-MM-DD} | {mô tả thay đổi cụ thể — SCN nào, layer nào, lý do} |
