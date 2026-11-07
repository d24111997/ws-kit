---
name: to-test-scenario
description: "Generate test scenarios (Gherkin .md files) from spec, source code, plan, and validation matrix. Covers happy path, invalid input, edge case, and error recovery for every user action in a feature. Output is individual scenario files organized by action group."
---

# to-test-scenario

Generate test scenarios from spec, source code, plan, and (if available) validation matrix. Each scenario = 1 business story (Gherkin format), 1 file `.md`.

> **Relationship with other docs:** Input: spec + source code + plan + validation matrix. Output: individual scenario `.md` files. Template chuẩn tại `11_Testing/templates/scenario.md`.

---

## Workflow

```
[INPUT] spec + source code (BE + FE) + plan + validation matrix (optional)
│
▼
┌──────────────────────────────────────────────────────────────┐
│ STEP 1: IDENTIFY ACTIONS — List all user actions            │
├──────────────────────────────────────────────────────────────┤
│ STEP 2: HAPPY PATH — Main path for each action              │
├──────────────────────────────────────────────────────────────┤
│ STEP 3: VARIATIONS — Invalid, edge, recovery from happy path│
├──────────────────────────────────────────────────────────────┤
│ STEP 4: ORGANIZE — Group + name + folder structure           │
├──────────────────────────────────────────────────────────────┤
│ STEP 5: REVIEW FLAG — Note gaps for user review             │
└──────────────────────────────────────────────────────────────┘
│
▼
[OUTPUT] scenario/{group}/*.md files
```

---

## Step 1: Identify Actions

Mục tiêu: List tất cả **actions** người dùng có thể thực hiện trong feature.

Action = 1 hành động cụ thể, có trigger rõ ràng (click nút, nhập form, chọn dropdown, F5...).

### Cách tìm actions

| Nguồn | Tìm gì | Ví dụ |
|-------|--------|-------|
| **FE code** | Page component + hooks: buttons, forms, event handlers | `{Page}` → {main button}, input Enter, item remove, {selector} |
| **BE endpoints** | Mỗi endpoint là 1 action tiềm năng | `POST /{resource}/start`, `GET /{resource}/history` |
| **Spec / plan** | Use case liệt kê | "User picks {X}", "User views history" |
| **Validation matrix** | Các row "FE validation" / "Business Rules" cho thấy điều kiện trước action | Items required before submit, URL field required |

**Phân loại action:**

| Loại | Mô tả | Ví dụ |
|------|-------|-------|
| **Main action** | Action chính của feature, có BE endpoint | `submit` (POST /{resource}/start) |
| **Prerequisite action** | FE interaction, required để thực hiện main action | `pick-url` (nhập URL → item OK), `set-target` (nhập target), `pick-item` (chọn item) |
| **Post-action** | Xem kết quả sau main action | `view-history`, `view-status` |
| **Recovery** | Xử lý gián đoạn | `session-recovery` (F5), `retry` |

> **Không phải action:** Auth (feature riêng), worker pipeline (backend detail), config lỗi (missing env).

### Ví dụ — feature "{Resource}" actions

| Action | Loại | Trigger | BE endpoint |
|--------|------|---------|-------------|
| pick-url | Prerequisite | Enter trên input URL | `POST /{resources}/verify` (phụ trợ) |
| set-target | Prerequisite | Gõ/paste vào input target | — (FE-only) |
| pick-item | Prerequisite | Chọn từ dropdown | `GET /{items}/recent` (phụ trợ) |
| submit | Main | Click "{Main button}" | `POST /{resource}/start` |
| view-history | Post-action | Mount {page} | `GET /{resource}/history` |
| session-recovery | Recovery | F5/reload | `GET /{resource}/jobs/{id}` |

---

## Step 2: Happy Path — Main Path for Each Action

Với mỗi action, tạo ít nhất 1 happy path scenario mô tả luồng thành công cơ bản nhất.

### Happy path template

Dùng file chuẩn tại **`11_Testing/templates/scenario.md`**. Copy vào mỗi file scenario mới, điền các field.

### Quy tắc happy path

1. **1 action = 1 happy path** — không gộp nhiều action vào 1 scenario
2. **Chỉ input hợp lệ** — mọi precondition đều OK, không error
3. **Button/UI state transitions** — ghi nhận thay đổi UI (spinner, disabled, toast) nếu là FE action
4. **Gherkin đúng** — `Given` = state, `When` = trigger, `Then` = observable result
5. **Không quá chi tiết** — scenario kể chuyện, không phải test case. "{item} được xử lý thành công", không phải "POST /{resource}/start trả về 200 với id = uuid4"

---

## Step 3: Derive Variations

Từ happy path của mỗi action, derive các variations dựa trên:

### 3a. Invalid Input

Dựa vào **validation matrix** — mỗi row có cột `TC Needed` gợi ý test case. Gom các invalid inputs có cùng error code/behavior vào 1 scenario.

| Happy path field | Invalid variations | Scenario |
|-----------------|-------------------|----------|
| `{field_a}` hợp lệ | Sai format, không thuộc nguồn cho phép, empty list | SCN-024 (INVALID_FORMAT) |
| `{token_field}` hợp lệ | Token hết hạn, score thấp, key empty | SCN-028 (TOKEN_INVALID) |
| `{ref_id}` hợp lệ | Không tồn tại, của user khác | SCN-023 (REF_NOT_FOUND) |

### 3b. Business Rule Violations

Dựa vào **Business Rules / Implicit Validation section** trong validation matrix. Mỗi rule fail → 1 scenario.

| Rule | Khi fail → error | Scenario |
|------|-----------------|----------|
| {Owner} must be active | 403 ACCOUNT_NOT_ACTIVE | SCN-020 |
| Quota must be available | 429 {QUOTA_EXCEEDED} | SCN-019 |
| No concurrent job | 409 JOB_IN_PROGRESS | SCN-021 |
| Resource must have editor permission | 403 MISSING_PERMISSION | SCN-022 |

### 3c. FE Validation Blocks

Dựa vào **FE Input Validation section** trong validation matrix. Các rule FE chặn trước khi gửi request.

| FE validation | Khi fail → behavior | Scenario |
|--------------|---------------------|----------|
| `items.length > 0` | Toast "<thông báo chặn submit>", không gửi request | SCN-025 |
| URL field `z.string().min(1)` | Toast "<thông báo bắt buộc>" | SCN-026 |
| Item status must be "ok" | FE re-verify → vẫn error → chặn | SCN-027 |
| Max {N} items | Input disabled | SCN-007 |

### 3d. Edge Cases

Dựa vào boundary values, state machine, và code paths đặc biệt:

| Loại | Ví dụ | Scenario |
|------|-----------|----------|
| **Boundary** | Item đã tồn tại → không thêm mới | SCN-010 |
| **Boundary** | Đạt {max} items → không thêm được nữa | SCN-007 |
| **State** | History có dữ liệu vs history trống | SCN-030, SCN-031 |
| **State** | Item error → retry → vẫn error | SCN-002 |
| **Empty** | Chưa có {item} → dropdown empty state | SCN-013 |
| **Search found/not found** | Tìm thấy, không tìm thấy | SCN-008, SCN-009 |

### 3e. Recovery / Error Recovery

Khi action bị gián đoạn (F5, mất kết nối, crash) → khả năng phục hồi:

| Tình huống | Scenario |
|-----------|----------|
| F5 giữa lúc chạy → recover session + SSE reconnect | SCN-032 |
| F5 sau khi hoàn tất → clear stale session, không mở SSE | SCN-033 |

### 3f. Happy Path Variations

Ngoài happy path chính, có thể có biến thể:

| Biến thể | Scenario |
|----------|----------|
| Không chọn {optional field} | SCN-017 variant → E2E-03 |
| Mixed results (success + duplicate + failed) | SCN-018 |
| Paste URL thay vì gõ tay | SCN-004 |

---

## Step 4: Organize — File Naming & Folder Structure

### Naming convention

```
SCN-{FEAT}-{NNN}-{GROUP}.md
```

- `SCN`: prefix cố định
- `{FEAT}`: mã feature viết tắt, 5 ký tự uppercase (ví dụ: `ORDER`, `USER`, `PAY`)
- `{NNN}`: số 3 chữ số, liên tục toàn bộ feature (001, 002...)
- `{GROUP}`: tên action group, UPPER_SNAKE_CASE — không phải tên type (e.g., `PICK-URL`, `PAYMENT`, `MODAL-INTERACTION`)

### Folder structure

Chia subfolder theo action group. Các action group có **≥ 3 scenarios** tách subfolder riêng:

```
scenario/
├── {action-group-1}/           # VD: pick-url (10 files)
│   ├── SCN-{FEAT}-001-{GROUP-1}.md
│   └── SCN-{FEAT}-002-{GROUP-1}.md
├── {action-group-2}/           # VD: set-target (4 files)
└── {action-group-3}/           # VD: submit (3 files)
```

**Quy tắc:**
- Action group có ≥ 3 scenarios → subfolder riêng
- Action group < 3 scenarios → có thể gộp vào group khác hoặc để flat
- Không tách main action / post-action riêng — gom cùng group theo hành vi user

### Frontmatter rules

Dùng file chuẩn **`11_Testing/templates/scenario.md`**. Các field cụ thể:

| Field | Giá trị | Ghi chú |
|-------|---------|---------|
| `feature` | Tên feature (vd: `order`) | |
| `priority` | `critical` / `high` / `medium` / `low` | Happy path = critical/high. Edge case = medium/low |
| `type` | `happy-path` / `negative` / `edge-case` / `error-recovery` | |
| `actor` | `user` / `guest` / `admin` / `system` | Customer feature = user. Webhook = system |
| `status` | `draft` | Mới tạo luôn draft. User đổi thành `reviewed`/`approved` sau khi review. Sửa nội dung file đang `approved` thì đặt lại `draft` ngay trong lần sửa. |
| `matrix-ref` | `VM-ROW-1, VM-ROW-3` | Link tới row(s) trong validation matrix |
| `tags` | `[{feature}, {group}, {type}]` | 3 tags: feature + action group + type |

**Không dùng `id` trong frontmatter** — filename là identifier duy nhất. Tránh maintain 2 chỗ.

---

## Step 5: Review Flag

Skill **không thể đảm bảo coverage đầy đủ**. Sau khi tạo, ghi rõ:

```
## Coverage Note
Scenarios generated từ validation matrix + code analysis. 
User cần kiểm tra:
- [ ] Có thiếu action nào không?
- [ ] Business rules đã đủ chưa? (thứ tự validation chain)
- [ ] Edge cases từ state machine?
- [ ] FE validation blocks đã cover hết form fields?
```

Người dùng review và bổ sung trước khi approve.

---

## Input / Output

| Input | Required | Mô tả |
|-------|----------|-------|
| Spec | Recommended | Business requirements |
| Source code (BE + FE) | **Yes** | Để xác định action thật, validation thật |
| Plan | If available | Implementation plan |
| Validation matrix | Recommended | Field catalog + business rules |
| Existing discuss/handoff | If available | Previous decisions |

| Output | Content |
|--------|---------|
| `scenario/{group}/SCN-*.md` | Individual scenario files (Gherkin) |

---

## Best Practices

1. **Scenario != Test Case** — Scenario kể chuyện người dùng (Gherkin), không liệt kê input/output chi tiết. Test case là cấp độ chi tiết hơn, dùng để viết code test.
2. **3 cấp độ:** Business Scenario (luồng nghiệp vụ) → Test Scenario (path cụ thể) → Test Case (input + steps + expected). Skill này tạo **Test Scenario**.
3. **Validate chain order matters** — Khi tạo invalid input scenarios, ghi nhớ thứ tự validation trong code. VD: anti-bot check trước URL parse, nếu anti-bot fail thì URL invalid không bao giờ xảy ra.
4. **Happy path có thể có biến thể** — Cùng 1 action nhưng different precondition (VD: submit with option X, without option X) = scenarios riêng.
5. **FE-only action vẫn worth scenario** — Nếu action là prerequisite để thực hiện main action, nó quan trọng. VD: không có item OK thì không submit được.
6. **Không tạo scenario cho bug FE** — Nếu FE có bug (VD: missing error code handler), ghi backlog, không tạo scenario cho behavior sai.
7. **1 scenario = 1 file** — Không gộp. Dễ review, dễ maintain, dễ link từ matrix.
8. **Không phụ thuộc số lượng hiện tại** — Scenario mô tả chức năng bằng ngôn ngữ không phụ thuộc số lượng hiện tại: khi thêm hoặc bớt trường, mục hay nhóm, scenario vẫn đúng và không phải sửa lại. Hệ quả: không liệt kê số đếm hay danh sách cố định; chỉ giữ số khi con số chính là luật (VD: mã 1–32 ký tự).
