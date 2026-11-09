---
name: plan-custom
description: Use this skill when the user asks to create a detailed implementation plan or run the dedicated planning mode.
---

# Plan Custom

## Mục tiêu

Tạo file `plan.md` chi tiết đến mức một AI Agent mới (hoặc chính bạn sau này) có thể đọc và execute logic từ đầu đến cuối mà không cần hỏi lại user những thứ đã được quyết định.

## Quy trình tổng thể

```
[1. Thu thập bối cảnh] → [2. Mapping] → [3. Viết Plan] → [4. Trình duyệt] → [5. Tạo ADR nếu approve]
```

Quy trình này **bắt buộc phải chạy tuần tự**. Không nhảy bước.

---

## Bước 1 — Thu thập bối cảnh (Context Gathering)

Trước khi viết bất kỳ chữ nào trong plan, phải đọc đủ các nguồn sau. Nếu thiếu nguồn nào, dừng lại và hỏi user.

### 1A. Đọc task input
- `new_task.md` (nếu có) — yêu cầu gốc
- `discuss*.md` (nếu có) — các quyết định đã thảo luận
- Tin nhắn hiện tại của user

### 1B. Đọc project context
- **AGENTS.md** ở thư mục gốc project — chứa tech stack, operational commands, workflow constraints, self-healing rules (v2 đọc `AGENTS.md`; repo cũ chỉ có `CLAUDE.md` thì đọc file đó)
- **README.md** (nếu có)

Nếu không tìm thấy AGENTS.md, hỏi user "Project này có AGENTS.md không? Cho tôi đường dẫn."

### 1C. Load các skill hỗ trợ phù hợp
Dựa vào tính chất task, load skill tương ứng:
- `frontend-design` — nếu task có UI mới hoặc sửa UI
- `discuss-task` — nếu yêu cầu chưa rõ ràng, cần thảo luận gắn task để ra quyết định
- Các skill khác nếu thấy phù hợp

### 1D. Xác định project(s) bị ảnh hưởng & đọc docs tương ứng

Hệ thống có thể gồm nhiều project repos riêng biệt. Ví dụ — điền repo thật của bạn vào bảng dưới:

| Project    | Vị trí              | Tech            | Mô tả                                |
| ---------- | ------------------- | --------------- | ------------------------------------ |
| **BE**     | `<be-repo>/`    | Backend         | Backend, database, APIs              |
| **FE (customer)** | `<fe-repo>/` | Frontend | Frontend cho người dùng cuối |
| **FE (ops)** | `<fe-ops-repo>/` | Frontend | Frontend cho vận hành nội bộ |

Một task có thể ảnh hưởng 1, 2 hoặc cả 3 project. Xác định ngay từ đầu.

**Sau khi biết project nào bị ảnh hưởng, đọc các docs sau theo thứ tự ưu tiên:**

#### Bắt buộc (phải đọc — với mọi project bị ảnh hưởng)

| Thứ tự | Doc | Mục đích |
|---|---|---|
| 1 | `AGENTS.md` (gốc project) | Tech stack, operational commands (`pnpm dev`, `pnpm build`, `pnpm test`...), workflow constraints, self-healing rules |
| 2 | `docs/SYSTEM_CONTEXT.md` | Phạm vi, mục tiêu, ranh giới hệ thống, invariants |
| 3 | `docs/ARCHITECTURE.md` | Cấu trúc project, directory layout, design patterns (FSD / Clean Architecture) |
| 4 | `docs/DOMAIN_REFERENCE.md` | Business logic, terminology, quy tắc nghiệp vụ |
| 5 | `docs/CODING_RULES.md` | Coding conventions: type hints (Python) / strict mode (TS), naming, error handling patterns |
| 6 | `docs/TESTING_GUIDE.md` | Cách viết test, test runner, coverage yêu cầu |

#### Đặc thù theo project

| Nếu ảnh hưởng | Đọc thêm | Vì sao |
|---|---|---|
| **BE** | `docs/DATABASE_CODING_RULES.md` | Convention naming cho FK, index, constraint, migration rules Alembic |
| **FE (customer)** | `DESIGN_SYSTEM.md` (gốc project) | Design tokens: colors, border-radius, button styles, form patterns, layout rules |
| **FE (ops)** | `docs/DESIGN/DESIGN.md` | Design tokens, format YAML frontmatter |
| **BE** | `docs/WORKFLOW_GUIDE.md` | Agent workflow, process guide cho AI (nếu có) |

#### Đọc khi cần (theo tính chất task)

| Khi task liên quan tới | Đọc |
|---|---|
| API thay đổi | `docs/flows/` (các flow docs), API Contract nếu có trong vault |
| DB thay đổi | DB Schema docs, migration files |
| Kiến trúc | `02_Architecture/ADRs/`, `02_Architecture/*` (trong vault) |
| UI component | Design System của project tương ứng |
| Auth | `docs/flows/AUTH_FLOW.md` (BE), `docs/FE_AUTH_FLOW.md` (FE Ops) |

#### Thực hành

- Nếu chưa rõ task ảnh hưởng project nào → hỏi user.
- Không đọc tràn lan. Chỉ đọc docs của project(s) bị ảnh hưởng.
- Nếu task yêu cầu sửa docs vault, thì đọc thêm các docs vault tương ứng (xem `AGENTS.md` vault).

### 1E. Đọc source code có liên quan
Đọc các file source code liên quan trực tiếp để hiểu code hiện tại:
- Routes / Components / Services / Models hiện tại
- Đặc biệt là các file sẽ bị sửa — phải đọc trước để biết cấu trúc và conventions của codebase

---


## Bước 2 — Kiến trúc & Mapping

Xác định chính xác:

### 2A. Những file sẽ bị ảnh hưởng
Danh sách cụ thể:
- Đường dẫn tuyệt đối từ gốc project
- Tên class / function / component cụ thể
- Số dòng tham khảo (nếu cần)
- Phân loại: 🟢 thêm mới / 🟡 sửa / 🔴 xoá

### 2B. Data flow
- Input → Processing → Output
- Các service/API calls liên quan
- Error paths

### 2C. Ràng buộc conventions

#### Input
Với mỗi project bị ảnh hưởng, đọc các file convention tương ứng:

| Project | Convention files |
|---|---|
| **BE** | `docs/CODING_RULES.md`, `docs/DATABASE_CODING_RULES.md` |
| **FE (customer)** | `docs/CODING_RULES.md`, `DESIGN_SYSTEM.md` (gốc project) |
| **FE (ops)** | `docs/CODING_RULES.md`, `docs/DESIGN/DESIGN.md` |

#### Expected trong plan.md

Không dẫn chiếu suông. Plan phải **dùng đúng convention ngay trong thiết kế**:

| Sai | Đúng |
|---|---|
| `FK tuân thủ DATABASE_CODING_RULES.md` | `FK: fk_{table}_{parent}` |
| `Button theo DESIGN_SYSTEM.md` | `variant="destructive" (Xoá), variant="outline" (Huỷ)` |
| `Form validate theo CODING_RULES.md` | `Dùng zod schema với refine()` |

Nếu convention định nghĩa pattern cụ thể (tên FK, index, button variant, error format...), dùng pattern đó trực tiếp. Người đọc plan không phải tự tra.

### 2D. Tham khảo tài liệu liên quan
- Có ADR nào ảnh hưởng tới quyết định này không?
- Có Flow doc nào cần cập nhật sau khi code không?
- Có API Contract / DB Schema nào cần sửa không?
- Có `_Index.md` nào cần cập nhật không?

### 2E. Boundaries check
- Đọc `BOUNDARIES.md` (nếu có) — xác định mục nào liên quan task này
- **Always**: mục nào tự động làm (gen-docs? update timestamp?)
- **Ask First**: có thay đổi nào cần hỏi user không? (dependency mới? DB schema? breaking change?)
- **Never**: có vi phạm rule nào không? (commit secret? skip test? push main?)

---

## Bước 3 — Viết Plan

Tạo file `plan.md` tại thư mục gốc của project, theo cấu trúc sau:

### 3.1 Cấu trúc file (template)

Xem [plan-template.md](plan-template.md). Tạo `plan.md` theo cấu trúc đó.

### 3.2 Nguyên tắc viết plan

1. **Cụ thể đến từng chữ**: Không dùng "tương tự như", "xem code", "làm như cũ". Nếu cần tham khảo, ghi rõ file:line.
2. **Đường dẫn tuyệt đối**: Luôn dùng từ gốc project (VD: `src/features/{module}/components/{Component}.tsx`, không phải `./components/...`).
3. **Tên chính xác**: Dùng đúng tên hàm/class/component từ codebase (không tự đặt tên khác).
4. **AFK over HITL**: Thiết kế slice sao cho AI tự làm được nhiều nhất. HITL chỉ cho những quyết định thực sự cần human.
5. **Estimate mỗi slice**: Nếu slice quá to (>1h code), bẻ nhỏ ra.

---

## Bước 4 — Trình duyệt & Chờ approve

Sau khi tạo xong file `plan.md`, nói chính xác một câu:

> Plan đã tạo tại `plan.md`. Anh/chị review và approve trước khi bắt đầu code nhé.

**Tuyệt đối không code cho đến khi user nói "ok", "approve", "bắt đầu đi".**

---

## Bước 5 — Tạo ADRs (sau khi plan approve)

Khi user approve, kiểm tra **Section 8 (ADR Candidates)**:

- Với mỗi candidate thoả cả 3 tiêu chí (khó đảo ngược, gây ngạc nhiên, trade-off), tạo file ADR.
- Format:
  ```markdown
  ---
  status: accepted
  tags: [adr, architecture]
  project: [tên project]
  review_date: YYYY-MM-DD
  ---

  # [Tiêu đề ngắn]

  [Context → Decision → Rationale — 1-3 câu]
  ```
- Đánh số ADR: scan thư mục `02_Architecture/ADRs/` lấy số cao nhất + 1.
- Cập nhật `_Index.md` của ADRs nếu cần (bỏ qua nếu dùng Dataview query).

---

## Quality Checklist (tự kiểm tra trước khi giao plan)

Trước khi nói "Plan đã tạo", tự kiểm tra:

- [ ] Đã xác định đúng project(s) bị ảnh hưởng (BE / FE customer / FE ops)? (Bước 1D)
- [ ] Đã đọc AGENTS.md + SYSTEM_CONTEXT.md + CODING_RULES.md của từng project bị ảnh hưởng? (Bước 1D)
- [ ] Nếu ảnh hưởng BE, đã đọc DATABASE_CODING_RULES.md? Nếu ảnh hưởng FE, đã đọc Design System? (Bước 1D)
- [ ] Conventions được trích dẫn đúng project — không lấy BE convention áp cho FE và ngược lại? (Bước 3C)
- [ ] Plan có đường dẫn tuyệt đối, không có chỗ nào viết chung chung? (Bước 4)
- [ ] Mỗi slice là demo được, không có slice nào quá to? (Bước 4)
- [ ] Đã liệt kê đủ verify steps (linter, typecheck, test) cho từng project? (Section 6)
- [ ] Nếu task ảnh hưởng docs, đã có slice "Docs Update"? (Section 5)
- [ ] ADR Candidates đã được cân nhắc kỹ? (Section 8)
- [ ] Đã tính đến rollback / self-healing? (Section 6 + 7)
- [ ] Input normalization strategy cho mọi string comparison/dedup? (Section 4)
- [ ] Async state consistency đã review? Snapshot trước await? Lock cho batch operation? (Section 4)

---

## Xử lý tình huống

### Khi verify fail trong lúc execute
1. Phân tích log lỗi, xác định nguyên nhân gốc.
2. Sửa lỗi. Nếu sửa xong không ảnh hưởng plan → tiếp tục.
3. Nếu sửa lỗi làm thay đổi phạm vi/cấu trúc → cập nhật plan.md, thông báo cho user.

### Khi phát hiện thiếu context trong lúc làm
1. Dừng lại. Đọc thêm tài liệu/source code cần thiết.
2. Nếu vẫn không rõ → hỏi user. Không tự suy diễn.

### Khi user bảo "plan này thiếu / sai"
1. Không tranh luận. Hỏi cụ thể phần nào thiếu/sai.
2. Sửa plan dựa trên phản hồi.
3. Trình lại.

---

## Constraints

- **KHÔNG code** cho đến khi user approve plan.
- **KHÔNG commit / push** cho đến khi user yêu cầu.
- **KHÔNG thay đổi** plan sau khi đã approve mà không báo user, trừ khi phát hiện lỗi hiển nhiên (typo, sai logic hiển nhiên) trong quá trình execute.
- Nếu trong lúc execute phát hiện ra điều cần thay đổi plan → dừng, thông báo, chờ user quyết định.