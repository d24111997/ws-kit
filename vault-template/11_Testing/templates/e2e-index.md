---
type: index
feature: {feature-code}
date: {YYYY-MM-DD}
---

> [Template: `templates/e2e-index.md`. Xoá hướng dẫn trong [] sau khi điền.]
> [Index tổng quan E2E test cases + mapping SCN→TC + thống kê coverage.]

# {Feature} — E2E Test Cases

> {Mô tả scope E2E của feature}

---

## Test Cases

| File | Priority | Type | Actor | SCN Covered |
|------|----------|------|-------|-------------|
| `TC-{FEAT}-{NN}` | critical | happy-path | user | SCN-{FEAT}-{N01}, SCN-{FEAT}-{N02} |
| `TC-{FEAT}-{NN+1}` | high | negative | user | SCN-{FEAT}-{N03} |

> [Map từng E2E test case với các SCN nó cover.]

---

## Thống kê

| Metric | Value |
|--------|-------|
| Tổng số TC | {N} |
| Critical | {n} |
| High | {n} |
| Medium | {n} |
| Happy path | {n} |
| Negative | {n} |
| SCN coverage | {N/M} ({percent}%) |

---

## Mapping SCN → TC

| SCN | Name | TC(s) |
|-----|------|-------|
| SCN-{FEAT}-{N01} | {name} | `TC-{FEAT}-{NN}` |
| SCN-{FEAT}-{N02} | {name} | `TC-{FEAT}-{NN}`, `TC-{FEAT}-{NN+1}` |

> [Bảng 2 chiều: từ SCN tìm được TC nào đang cover nó.]

---

## SCNs không có E2E coverage

| SCN | Name | Lý do không E2E |
|-----|------|----------------|
| SCN-{FEAT}-{Nxx} | {name} | {reason — worker-level, FE-only, flaky...} |

> [Ghi rõ lý do để không ai thắc mắc "sao thiếu E2E cho SCN này".]

---

### Hướng dẫn

- **Không map 1:1 SCN → TC.** Mỗi TC gom nhiều SCN chung precondition và flow liên tiếp.
- **SCN coverage** tính theo: số SCN có ít nhất 1 E2E / tổng số SCN.
- SCN không E2E = worker-level, FE-only (component test đã cover), hoặc flaky.
- File test code tương ứng: `tests_e2e/{feature}/{group}.spec.ts`.
