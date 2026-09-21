---
name: to-validation-matrix
description: "Generate a comprehensive validation matrix from source code. Covers: API endpoints (request fields, headers, params), business rules (quota, lock, permission, rate limit), DB model constraints, FE form validation, and event types (SSE/WebSocket). Use when you need a complete input/output catalog to drive test coverage decisions for any feature."
---

# to-validation-matrix

Generate a comprehensive validation matrix from source code analysis. Output is a single `validation-matrix.md` file covering every test-relevant field, rule, constraint, and event across all layers (BE API, BE DB, FE, events).

> **Scope:** This skill produces the *validation matrix document only*. It does not generate test plans, scenarios, or test code.
> **Template chuẩn:** `11_Testing/templates/validation-matrix.md`.

---

## Workflow

```
[INPUT] Source code (BE + FE) + spec / plan (nếu có)
│
▼
┌──────────────────────────────────────────────────────────────┐
│ STEP 1: DISCOVER — Map all endpoints + schemas              │
├──────────────────────────────────────────────────────────────┤
│ STEP 2: CATALOG — Per-endpoint field tables                 │
├──────────────────────────────────────────────────────────────┤
│ STEP 3: EXTRACT — Business rules from code                  │
├──────────────────────────────────────────────────────────────┤
│ STEP 4: DOCUMENT — DB model constraints                     │
├──────────────────────────────────────────────────────────────┤
│ STEP 5: CAPTURE — FE form validation rules                   │
├──────────────────────────────────────────────────────────────┤
│ STEP 6: INVENTORY — Event types (SSE, WebSocket)            │
└──────────────────────────────────────────────────────────────┘
│
▼
[OUTPUT] validation-matrix.md
```

---

## Step 1: Discover — Map All Endpoints + Schemas

Explore the BE source code to find every API endpoint related to the feature. For each endpoint, collect:

| What to find | How | Example |
|-------------|-----|---------|
| URL path + method | Router files (`api/*/endpoints/*.py`) | `POST /api/v1/{resource}/start` |
| Request body schema | Pydantic model used in endpoint | `{Resource}Request(field_a, field_b, field_c)` |
| Path/query params | Endpoint function signature | `{id}: str` (path), `limit: int` (query) |
| Headers | Dependencies (`Authorization`, `X-API-Key`) | `Authorization: Bearer <token>` |
| Response status + body | Return type / response model | `200 → {Resource}Response`, `422 → ValidationError` |
| Auth requirement | Dependency injection | `Depends(auth_required)` |

**Nếu có spec/plan, đối chiếu với code. Code là truth.** Nếu spec khai báo endpoint không có trong code → ghi nhận là "out of scope / deferred". Nếu code có endpoint không trong spec → vẫn catalog (undocumented feature).

---

## Step 2: Catalog — Per-Endpoint Field Tables

Cho mỗi endpoint, tạo 1 bảng với các columns sau:

| # | Field | In | Required | Type | Constraints | TC Needed |
|---|-------|----|----------|------|-------------|-----------|
| 1 | `{field_a}` | Body | Yes | `list[str]` | `min_length=1` | missing, empty list, single item, multiple items |
| 2 | `{field_b}` | Body | No (BE) | `str \| None` | Format check if provided | missing, valid, invalid, wrong format |

**Rules for each column:**

| Column | Cách điền |
|--------|-----------|
| **#** | Đánh số liên tục trong 1 bảng |
| **Field** | Tên field từ request schema / param / header |
| **In** | `Body` / `Path` / `Query` / `Header` |
| **Required** | Dựa trên schema: `Yes` nếu field required, `No` nếu optional. Nếu khác nhau giữa BE và FE (BE optional, FE required) → ghi rõ cả 2 |
| **Type** | Kiểu dữ liệu từ schema (`str`, `int`, `list[str]`, `UUID`, `str \| None`) |
| **Constraints** | Validation rules: `min_length`, `max_length`, `regex`, `ge`/`le`, format requirements. **Trích từ code, không từ spec** |
| **TC Needed** | Các test case ideas gợi ý: `missing`, `invalid`, `boundary`, `empty`, `malformed` |

**Endpoint nào cần catalog:**
- Endpoint chính của feature (CRUD, action)
- Endpoint phụ trợ (verify, stream, upload)
- Endpoint public/auth — phân biệt rõ

---

## Step 3: Extract — Business Rules from Code

Tìm trong code các **implicit validation rules** không phải field constraint. Đây là các rule nằm trong service/use case layer. Ghi vào section riêng:

| # | Rule | Source (file/class) | TC Needed |
|---|------|--------------------|-----------|
| 1 | {Entity} status must be `"{allowed_state}"` | `{service}.py` | disallowed state → 403 |
| 2 | Quota check — hết quota → `{QUOTA_EXCEEDED}` | `{QuotaService}` | quota exhausted → 429 |
| 3 | Concurrent job lock per {owner} | `{LockManager}` (Redis) | active job → 409 |

**Kỹ thuật tìm business rules:**
1. Đọc service files — tìm `if/else` kiểm tra trạng thái, quyền, quota
2. Đọc use case files — tìm exception raise, error code mapping
3. Đọc endpoint — tìm thứ tự validation chain (cái nào check trước)
4. Đọc infrastructure services — tìm rate limit config, lock TTL, fail-safe behavior
5. Ghi lại **thứ tự ưu tiên** nếu có (vd: anti-bot verify trước mọi thứ)

---

## Step 4: Document — DB Model Constraints

Đọc ORM models / DB schema để catalog mỗi bảng liên quan đến feature:

| # | Field | Type | Constraints | Notes |
|---|-------|------|-------------|-------|
| 1 | `id` | UUID | PK, default uuid4 | |
| 2 | `{owner}_id` | UUID | FK → {users_table}.id, NOT NULL | |
| 3 | `status` | Text | NOT NULL, default="{initial}" | States: {initial} → {done} / {failed} |

**Chỉ catalog model/field feature đang xét.** Không cần dump whole DB.
**Chú ý:** NOT NULL, UNIQUE, FK, DEFAULT, CHECK constraints, state machine (allowed transitions).

---

## Step 5: Capture — FE Form Validation Rules

Nếu feature có FE, đọc form validation schema + component logic:

| # | Field | Required | FE Validation | Source | Notes |
|---|-------|----------|--------------|--------|-------|
| 1 | {Items list} | Yes | `items.length > 0` + all item status = `"ok"` | `{Component}.tsx` handleSubmit | Must pass verify API first |
| 2 | {URL field} | Yes | `zod: z.string().min(1)` | `schema.ts` | |
| 3 | {Selector field} | No | — | `{SelectorCard}` | Optional, có "Không chọn" option |

**Nguồn thông tin:**
- Form schema (zod / yup) — validation rules
- Component code — logic kiểm tra trước submit
- Hook code — state machine (loading → ok/error), localStorage behavior
- Các local state ghi chú: `disabled`, `hidden`, `max items`, `duplicate check`

---

## Step 6: Inventory — Event Types (SSE, WebSocket)

Nếu feature dùng real-time events (SSE, WebSocket), catalog event types:

| # | Event Type | Source | Fields | Notes |
|---|-----------|--------|--------|-------|
| 1 | `progress` | Worker per item | `{status_field}`, `{name_field}`, `{id_field}` | {N} status values |
| 2 | `completed` | Worker done | `total_items`, `successful_items` | |
| 3 | `error` | Worker crash | `message` | |

**Tìm trong:** code gửi event (worker/service), code nhận event (FE hook/EventSource handler).

---

## Output

Output là file `validation-matrix.md` tại `{feature}/testplan/validation-matrix.md`.

Dùng template chuẩn **`11_Testing/templates/validation-matrix.md`** làm khung. Các sections:

1. **BE Endpoints** — từng endpoint, từng field (`#`, Field, In, Required, Type, Constraints, TC Needed)
2. **Business Rules** — implicit validation, ownership check, unique constraints
3. **DB Models** — từng model, từng column
4. **FE Input Validation** — form validation, UI state
5. **Event Types (SSE / WebSocket)** — nếu có

> **Không bắt buộc có đủ 5 sections.** Feature không FE → bỏ FE section. Feature không event → bỏ event section.

---

## Best Practices

1. **Code is truth** — validation dựa trên code, không dựa trên spec. Nếu spec khác code → ghi nhận mismatch trong section tương ứng.
2. **Phân biệt BE optional vs FE required** — ghi rõ nếu khác nhau giữa layers.
3. **Thứ tự validation chain** — ghi rõ step nào xảy ra trước (vd: anti-bot trước auth check, auth trước quota, quota trước lock). Quan trọng cho error path testing.
4. **State machine** — với field có state (status, {status_field}), ghi rõ tất cả transition hợp lệ.
5. **Fail-safe behavior** — nếu code có fallback khi service unavailable (vd: quota check fail → allow), ghi rõ.
6. **Rate limit scopes** — nếu có rate limit, ghi scope (endpoint, key, limit).
7. **DB model chỉ feature scope** — không dump toàn bộ DB, chỉ bảng/field liên quan.
8. **FE validation ≠ BE validation** — không gộp chung. Một field có thể FE required, BE optional.
9. **TC Needed cột cuối cùng** — gợi ý các test case, không phải danh sách đầy đủ. Dùng để tham chiếu khi viết scenario/test case.
10. **Cập nhật khi code thay đổi** — validation matrix lỗi thời = vô dụng. Khi sửa endpoint/field/rule, cập nhật matrix.
