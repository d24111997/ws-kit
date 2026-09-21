---
testcase: TC-{FEAT}-{NN}
feature: {feature-code}
priority: critical | high | medium
type: happy-path | negative
actor: user | admin | system
status: draft
scn-covered: SCN-{FEAT}-{NNN}, SCN-{FEAT}-{NNM}
tags:
  - {feature-code}
  - e2e
  - happy-path | negative
---

> [Template: `templates/e2e-test-case.md`. Xoá hướng dẫn trong [] sau khi điền.]
> [Không map 1:1 scenario → test case. Gom nhiều SCN chung precondition và flow liên tiếp.]

# TC-{FEAT}-{NN}: {Title}

> {Mô tả 1 dòng user journey xuyên suốt}

## Mock Strategy

| Layer | Approach | Details |
|-------|----------|---------|
| {API/service 1} | Real / `page.route` / DI override | {mô tả} |
| {API/service 2} | Real / Mock | {mô tả} |

## Precondition

- {điều kiện môi trường: BE, worker, FE đang chạy}
- {dữ liệu cần seed: customer, plan, JD...}
- {trạng thái UI ban đầu}

## Test Steps

### Step {N}: {Action Group} (SCN-{NNN}, SCN-{NNM})

| # | Action | Expected | SCN |
|---|--------|----------|-----|
| {n}.{m} | {hành động cụ thể} | {kết quả mong đợi} | {NNN} |

## Notes
- {implementation notes: data seed, mock config, cleanup}
- {các SCN được gom trong TC này}

## Covered SCNs
- SCN-{FEAT}-{NNN} ({mô tả ngắn})
- SCN-{FEAT}-{NNM} ({mô tả ngắn})

---

### Hướng dẫn

| Mục | Cách làm |
|-----|----------|
| Gom SCN | Gom các SCN tạo thành 1 user journey liên tục. Error/recovery có precondition giống happy → gom chung |
| Mock Strategy | Ghi rõ từng layer: Real (BE thật), `page.route` (mock browser-level), DI override (mock server-side) |
| Test Steps | Mỗi `Step` = 1 action group. Mỗi dòng = 1 hành động cụ thể |
| `#` format | `{step}.{index}` — VD: 1.1, 1.2, 2.1 |

### Cách gom SCN vào E2E

Sắp xếp các SCN vào E2E sao cho có thể giảm thiểu số lượng E2E test case, từ đó giảm thời gian chạy.

### File test code tương ứng

```
tests_e2e/{feature}/
├── {group-1}.spec.ts
├── {group-2}.spec.ts
└── helpers/
    ├── {feature}-fixtures.ts
    └── {feature}-asserts.ts
```
