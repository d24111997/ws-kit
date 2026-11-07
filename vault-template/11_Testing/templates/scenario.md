---
feature: {feature-code}
priority: critical | high | medium | low
type: happy-path | negative | edge-case | error-recovery
actor: guest | user | admin | system
status: draft
matrix-ref: VM-ROW-{n}
tags:
  - {feature-code}
  - {group}
  - {type}
---

> [Template: `templates/scenario.md`. Xoá hướng dẫn trong [] sau khi điền.]
> [1 scenario = 1 file. Không gộp.]

## Context
- **Môi trường:** Browser (Customer Portal / Ops Portal) / API / Worker / System
- **Precondition:** {điều kiện trước khi scenario bắt đầu}

## Scenario
> {1 câu mô tả ngắn tình huống này}

**Given** {trạng thái ban đầu}
**When** {hành động — 1 trigger duy nhất}
**Then** {kết quả observable ngay lập tức}
**And** {kết quả tiếp theo — nếu có}

**Nhiều nhánh trong một scenario** — mỗi nhánh là một heading `#### Nhánh A — <tên nhánh>` đặt **trước** khối `Given/When/Then` của nhánh đó; không đặt nhãn sau khối. Mỗi nhánh vẫn có đủ `Given/When/Then`.

## Notes
- {lưu ý về implementation detail, business rule, edge case}
- {lý do scenario quan trọng}

## Linked
- Matrix: [[11_Testing/{feature}/testplan/validation-matrix]]
- Test Cases: *(điền sau khi viết test case)*

---

### Frontmatter guide

| Field | Giá trị | Ghi chú |
|-------|---------|---------|
| `feature` | Tên feature code | e.g., `scan`, `billing` |
| `priority` | `critical` → `high` → `medium` → `low` | Happy path = critical/high. Edge case = medium/low |
| `type` | `happy-path` / `negative` / `edge-case` / `error-recovery` | |
| `actor` | `guest` / `user` / `admin` / `system` | Customer feature = user. Webhook = system |
| `status` | `draft` → `reviewed` → `approved` | Mới tạo = draft. User đổi sau approve |
| `matrix-ref` | `VM-ROW-1, VM-ROW-3` | Link tới row(s) trong validation matrix |
| `tags` | 2-3 tags: feature + group + type | |

### Convention đặt tên file

```
SCN-{FEAT}-{NNN}-{GROUP}.md
  ↑       ↑       ↑
  prefix  số 3    group suffix
          digits  UPPER_SNAKE_CASE
```

| Element | Convention | Ví dụ |
|---------|-----------|-------|
| Feature code | 5 ký tự, uppercase | `SCAN`, `BILL`, `SHCON` |
| Số | 3 digits, liên tục | `001` → `027` |
| Group suffix | UPPER_SNAKE_CASE | `PICK-URL`, `PAYMENT` |

### Folder structure

```
scenario/
├── {group-1}/              # ≥ 3 scenarios → subfolder riêng
│   ├── SCN-{FEAT}-001-{GROUP}.md
│   └── SCN-{FEAT}-002-{GROUP}.md
├── {group-2}/
│   └── ...
└── SCN-{FEAT}-017-{GROUP}.md   # Main action — flat ở root
```

### Scenario writing tips

- **Given** = trạng thái. **When** = trigger. **Then** = observable result.
- Không viết quá chi tiết: "{item} được xử lý thành công", không phải "POST trả về 200 với id = uuid4".
- `matrix-ref` trong frontmatter để traceability từ scenario → validation matrix row.
- Mỗi SCN thường chỉ thể hiện 1 nhánh; khi cần nhiều nhánh trong cùng một file (cùng hành vi, khác điều kiện), theo quy ước nhãn nhánh ở mục `## Scenario`.
- SCN phải thể hiện câu chuyện từ góc nhìn của actor. ví dụ USER thì k thể biến là FE gửi request như thế nào, chỉ có thể thấy đang gửi, kết quả. 
