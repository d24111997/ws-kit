---
status: draft
feature: {feature-code}
date: {YYYY-MM-DD}
---

# Validation Matrix: {Feature Name}

> [Mô tả scope: UI version, endpoints, thay đổi so với cũ]
> Template: `templates/validation-matrix.md` — xoá hướng dẫn trong [] sau khi điền.
> **Code là truth.** Nếu spec khác code → ghi mismatch, không sửa matrix theo spec.

---

## {METHOD} {/api/path}

[1 bảng cho mỗi endpoint, catalog từng field trong request]

| # | Field | In | Required | Type | Constraints | TC Needed |
|---|-------|----|----------|------|-------------|-----------|
| {n} | `{field_name}` | Body | Yes | `{type}` | {constraints} | {test ideas} |

### Column guide

| Column | Cách điền |
|--------|-----------|
| **#** | Đánh số liên tục toàn bộ feature, không reset theo bảng |
| **Field** | Tên field từ request schema |
| **In** | `Body` / `Path` / `Query` / `Header` |
| **Required** | `Yes` nếu BE required. Nếu khác giữa BE (optional) và FE (required) → ghi rõ |
| **Type** | `str`, `int`, `list[str]`, `UUID`, `str \| None` |
| **Constraints** | `min_length`, `max_length`, `regex`, `ge`/`le`, valid values. **Trích từ code** |
| **TC Needed** | Gợi ý: `missing`, `invalid`, `boundary`, `empty`, `malformed` |

---

## Business Rules / Implicit Validation

[Rules nằm trong service/use case layer — không phải field constraint]

| # | Rule | Source | TC Needed |
|---|------|--------|-----------|
| 1 | {rule description} | {file/class} | {expected error / behavior} |

### Cách tìm business rules

1. Đọc service files — tìm `if/else` kiểm tra trạng thái, quyền, quota
2. Đọc use case files — tìm exception raise, error code mapping
3. Đọc endpoint — tìm thứ tự validation chain (cái nào check trước)
4. Đọc infrastructure services — tìm rate limit config, lock TTL, fail-safe behavior
5. Ghi lại **thứ tự ưu tiên** nếu có

---

## DB Model — {TableName}

[Chỉ catalog model/field liên quan đến feature, không dump whole DB]

| # | Field | Type | Constraints | Notes |
|---|-------|------|-------------|-------|
| 1 | `{field}` | {type} | {PK, FK, NOT NULL, UNIQUE, DEFAULT} | {state machine / allowed transitions} |

---

## FE Input Validation

[Nếu feature có FE — đọc form validation schema + component logic]

| # | Field | Required | FE Validation | Source | Notes |
|---|-------|----------|--------------|--------|-------|
| 1 | `{field}` | Yes/No | {zod rule / component logic} | {file/line} | {notes} |

### Nguồn thông tin

- Form schema (zod/yup) — validation rules
- Component code — logic kiểm tra trước submit
- Hook code — state machine (loading → ok/error), localStorage behavior
- Local state: `disabled`, `hidden`, `max items`, `duplicate check`

---

## Event Types (SSE / WebSocket)

[Nếu feature dùng real-time events]

| # | Event Type | Source | Fields | Notes |
|---|-----------|--------|--------|-------|
| 1 | `{event}` | {worker/service} | {fields} | {notes} |

---

> **Không bắt buộc có đủ sections.** Feature không FE → bỏ FE section. Feature không event → bỏ event section.
