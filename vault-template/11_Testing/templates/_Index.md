# Templates — Test Documentation

> Folder chứa template chuẩn cho 6 loại tài liệu test.
> Copy file template vào feature folder, điền nội dung, xoá hướng dẫn.

---

## Cách dùng

```text
1. Copy template file(s) cần dùng vào 11_Testing/{feature}/
2. Đổi tên file theo convention
3. Điền nội dung, xoá hướng dẫn trong []
4. Tham khảo các feature folder đã hoàn thiện trong 11_Testing/
```

---

## Danh sách template

| # | Template | Tạo file | Mô tả |
|---|----------|----------|-------|
| 1 | [`test-plan.md`](test-plan.md) | `{feature}/testplan/test-plan.md` | Scope, strategy, risk assessment |
| 2 | [`validation-matrix.md`](validation-matrix.md) | `{feature}/testplan/validation-matrix.md` | Field catalog, business rules, DB/FE constraints |
| 3 | [`scenario.md`](scenario.md) | `{feature}/scenario/{group}/SCN-{FEAT}-{NNN}-{GROUP}.md` | Gherkin scenario — 1 tình huống test |
| 4 | [`e2e-test-case.md`](e2e-test-case.md) | `{feature}/e2e/TC-{FEAT}-{NN}.md` | E2E user journey — gom nhiều SCN |
| 5 | [`traceability-matrix.md`](traceability-matrix.md) | `{feature}/TRACEABILITY-MATRIX.md` | Mapping SCN → test layers |
| 6 | [`e2e-index.md`](e2e-index.md) | `{feature}/e2e/_Index.md` | Index + mapping SCN→TC cho E2E |

---

## Feature code reference

Mỗi feature dùng 1 code ngắn gọn (5 ký tự uppercase) — dùng trong tên file SCN/TC.

| Feature | Code | Thư mục |
|---------|------|---------|
| _(ví dụ: Order)_ | `ORDER` | `11_Testing/order/` |

---

## Thứ tự tạo tài liệu

> Scenario là input cho các tài liệu khác, nên viết trước.

```
1. Nghiên cứu code + spec
2. Xác định scenario groups (hành vi user, không theo module)
3. scenario/*.md          — Viết SCN trước (dễ nhất, là input cho docs khác)
4. validation-matrix.md   — Catalog fields + rules, dựa trên scenario + spec
5. test-plan.md           — Test plan (template từ test-plan-general.md)
6. TRACEABILITY-MATRIX.md — Mapping SCN → layers
7. e2e/TC-*.md            — Gom SCN thành E2E test case (không map 1:1)
8. e2e/_Index.md          — Index + mapping SCN→TC
```

---

## Folder structure mẫu sau khi tạo

```
11_Testing/{feature}/
├── TRACEABILITY-MATRIX.md          ← traceability-matrix.md
├── testplan/
│   ├── test-plan.md                ← test-plan.md
│   └── validation-matrix.md        ← validation-matrix.md
├── scenario/
│   ├── {group-1}/
│   │   ├── SCN-{FEAT}-001-{GROUP}.md   ← scenario.md
│   │   └── SCN-{FEAT}-002-{GROUP}.md
│   └── {group-2}/
│       └── SCN-{FEAT}-003-{GROUP}.md
└── e2e/
    ├── _Index.md                   ← e2e-index.md
    ├── TC-{FEAT}-01.md             ← e2e-test-case.md
    └── TC-{FEAT}-02.md
```

---

## Quick Start Checklist

- [ ] Đọc requirement/spec đủ hiểu flow?
- [ ] Tham khảo feature tương tự đã hoàn thiện trong `11_Testing/`
- [ ] **Bước 1:** Nghiên cứu code (BE endpoints + FE components + flow)
- [ ] **Bước 2:** Xác định scenario groups (theo hành vi user)
- [ ] **Bước 3:** Viết **scenarios** (`scenario/{group}/*.md`) — làm trước
- [ ] **Bước 4:** Viết **validation matrix** (`testplan/validation-matrix.md`)
- [ ] **Bước 5:** Viết **test plan** (`testplan/test-plan.md`)
- [ ] **Bước 6:** Viết **traceability matrix** (`TRACEABILITY-MATRIX.md`)
- [ ] **Bước 7:** Gom SCN → viết **E2E test cases** (`e2e/TC-*.md`) + **E2E index** (`e2e/_Index.md`)
- [ ] Thêm `draft` tag vào mọi scenario files
- [ ] PR cho user review → remove `draft` sau approve

> **⛔ Không viết test docs khi chưa có requirement/spec kỹ.** Scenario thiếu, validation matrix sai → phải viết lại.

---

## Quy tắc chung

- **Code là truth.** Nếu spec khác code → code đúng, ghi nhận mismatch.
- **1 scenario = 1 file.** Không gộp.
- **Scenario ≠ Test Case.** Scenario = Gherkin kể chuyện. Test case = script chi tiết.
- **Draft tag:** Mọi scenario mới đều có `status: draft`. Bỏ draft sau khi approve.
- **matrix-ref:** Scenario frontmatter link tới row trong validation matrix để traceability.
